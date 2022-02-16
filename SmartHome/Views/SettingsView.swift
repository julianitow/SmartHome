//
//  SettingsView.swift
//  SmartHome
//
//  Created by Julien Guillan on 10/02/2022.
//

import SwiftUI
import HomeKit

struct SettingsView: View {
    @EnvironmentObject var accessoriesManager: AccessoriesManager
    @EnvironmentObject var locationManager: LocationManager
    @Binding var showHome: Bool
    @Binding var showAuto: Bool
    @Binding var showSettings: Bool
    @State var homeName: String = ""
    @State var roomName: String = ""
    @State var showAlert = false
    @State var refresh = false
    @State var isHomeAvailable = true
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.system(size: 30))
                .fontWeight(.semibold)
            Form {
                Section(header: Text("Gestion des données")) {
                    Button {
                        KeychainManager.clearAddress()
                        self.locationManager.homeAddress = nil
                        self.showAlert.toggle()
                    } label : {
                        HStack {
                            Image(systemName: "trash").foregroundColor(Color.red)
                            Text("Supprimer Adresse")
                                .foregroundColor(Color.red)
                        }
                    }
                    
                    Button {
                        KeychainManager.clearKeychain()
                        self.locationManager.homeAddress = nil
                        self.showAlert.toggle()
                    } label : {
                        HStack {
                            Image(systemName: "trash").foregroundColor(Color.red)
                            Text("Supprimer les données enregistrées")
                                .foregroundColor(Color.red)
                        }
                    }
                    .alert("Données supprimées, veuillez-relancer l'application pour prendre en compte les modifications.", isPresented: $showAlert) {
                        Button("OK", role: .cancel) { }
                    }
                }
                Section(header: Text("Gestion du domicile")) {
                    if accessoriesManager.primaryHome == nil {
                        TextField("Nom du domicile, ex: \"Maison\"", text: $homeName)
                        Button {
                            if self.homeName != "" {
                                self.accessoriesManager.homeManager.addHome(withName: self.homeName) { home, error in
                                    if error != nil {
                                        print("ERROR - 1: \(error?.localizedDescription ?? "unkown error")")
                                        return
                                    }
                                    self.accessoriesManager.primaryHome = home
                                    self.isHomeAvailable = true
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Ajouter un domicile")
                            }
                        }
                    }
                    
                    if accessoriesManager.primaryHome != nil {
                        TextField(self.accessoriesManager.primaryHome.name, text: $homeName)
                        Button {
                            if self.accessoriesManager.primaryHome != nil && self.homeName != "" {
                                self.accessoriesManager.primaryHome.updateName(self.homeName) { error in
                                    if error != nil {
                                        print("ERROR: while renaming primaryHome: \(self.accessoriesManager.primaryHome.name) \(error?.localizedDescription ?? "unkown error")")
                                    }
                                    self.accessoriesManager.updatedHome += 1
                                    self.refresh.toggle()
                                }
                            }
                        } label : {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(Color.blue)
                                Text("Renommer \(self.accessoriesManager.primaryHome.name)")
                                    .foregroundColor(Color.blue)
                            }
                        }
                        
                        Button(role: .destructive) {
                            if accessoriesManager.primaryHome == nil {
                                return
                            }
                            let home = self.accessoriesManager.homeManager.primaryHome
                            self.accessoriesManager.homeManager.removeHome(home!) { error in
                                if error != nil {
                                    print("ERROR: \(error?.localizedDescription ?? "unkown error")")
                                }
                                accessoriesManager.primaryHome = nil
                                accessoriesManager.accessories = []
                                self.accessoriesManager.updatedHome += 1
                                self.refresh.toggle()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "trash").foregroundColor(Color.red)
                                Text("Supprimer le domicile \"\(self.accessoriesManager.primaryHome.name)\"")
                            }
                        }
                    }
                }
                
                if self.isHomeAvailable {
                    Section(header: Text("Gestion des pièces")) {
                        TextField("Cuisine", text: $roomName)
                        Button(action: {
                            if self.roomName != "" {
                                self.accessoriesManager.homeManager.primaryHome!.addRoom(withName: self.roomName) { hmroom, error in
                                    if error != nil {
                                        print("ERROR: while creating room \(self.roomName) -> \(error?.localizedDescription ?? "unknown error")")
                                        return
                                    }
                                    let room = Room(from: hmroom!)
                                    self.accessoriesManager.rooms.append(room)
                                    self.roomName = ""
                                }
                            }
                        }, label: {
                            HStack {
                                Image(systemName: "plus")
                                    .foregroundColor(.blue)
                                Text("Ajouter une pièce")
                            }
                        })
                    }
                    
                    Section {
                        if self.accessoriesManager.rooms.count > 0 {
                            ForEach(self.accessoriesManager.rooms) { room in
                                Text(room.hmroom.name)
                            }.onDelete(perform: self.accessoriesManager.removeRoom)
                        }
                    }
                
                    Section(header: Text("Gestion des accessoires")) {
                        Button {
                            DispatchQueue.main.async {
                                if self.accessoriesManager.primaryHome == nil {
                                    return
                                }
                                self.accessoriesManager.primaryHome.addAndSetupAccessories() { error in
                                    if error != nil {
                                        print("ERROR - 2: \(error?.localizedDescription ?? "unkown error")")
                                        return
                                    }
                                    self.refresh.toggle()
                                }
                            }
                        } label : {
                            HStack {
                                Image(systemName: "plus")
                                    .foregroundColor(Color.blue)
                                Text("Ajouter un accessoire/bridge")
                                    .foregroundColor(Color.blue)
                            }
                        }
                    }
                }
                
                if self.isHomeAvailable && self.accessoriesManager.accessories.count > 0 {
                    Section {
                        ForEach(self.accessoriesManager.accessories, id: \.id) { accessory in
                            HStack {
                                Text(accessory.accessory.name)
                            }
                        }.onDelete(perform: self.accessoriesManager.removeAccessory)
                    }
                }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Image(systemName: "house")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        showHome = true
                        showAuto = false
                        showSettings = false
                    }
                Spacer()
                Image(systemName: "clock")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        showHome = false
                        showAuto = true
                        showSettings = false
                    }
                Spacer()
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.blue)
                    .onTapGesture {
                        showHome = false
                        showAuto = false
                        showSettings = true
                    }
                Spacer()
            }
        }
        .onChange(of: accessoriesManager.updatedHome, perform: { _ in
            if self.accessoriesManager.primaryHome == nil {
                self.isHomeAvailable = false
            } else {
                self.isHomeAvailable = true
            }
            self.refresh.toggle()
        })}
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showHome: .constant(false), showAuto: .constant(false), showSettings: .constant(false), homeName: "ok")
    }
}
