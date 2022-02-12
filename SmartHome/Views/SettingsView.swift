//
//  SettingsView.swift
//  SmartHome
//
//  Created by Julien Guillan on 10/02/2022.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var accessoriesManager: AccessoriesManager
    @Binding var showHome: Bool
    @Binding var showAuto: Bool
    @Binding var showSettings: Bool
    @Binding var temperature: String
    
    @State var refresh: Bool = false
    
    var body: some View {
        if self.showAuto {
            AutoView(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings, temperatureMin: "", temperatureMax: "")
        } else if self.showSettings {
            VStack {
                
                Text("Settings")
                    .font(.system(size: 30))
                    .fontWeight(.semibold)
                
                Form {
                    
                    Section(header: Text("Gestion des données")) {
                        HStack {
                            Image(systemName: "trash").foregroundColor(Color.red)
                            Text("Supprimer les adresses enregistrées")
                                .foregroundColor(Color.red)
                        }.onTapGesture {
                            KeychainManager.clearKeychain()
                        }
                    }
                    
                    Section(header: Text("Gestion des accessoires")) {
                        if accessoriesManager.primaryHome == nil {
                            HStack {
                                Image(systemName: "plus")
                                    .foregroundColor(Color.blue)
                                Text("Ajouter un accessoire")
                                    .foregroundColor(Color.blue)
                            }.onTapGesture {
                                DispatchQueue.main.async {
                                    if self.accessoriesManager.primaryHome == nil {
                                        self.accessoriesManager.homeManager.addHome(withName: "SmartHome") { home, error in
                                            if error != nil {
                                                print("ERROR: \(error?.localizedDescription ?? "unknown error")")
                                            }
                                            self.refresh.toggle()
                                        }
                                    }
                                }
                            }
                        }
                        
                        if accessoriesManager.primaryHome != nil {
                            HStack {
                                Image(systemName: "plus")
                                    .foregroundColor(Color.blue)
                                Text("Ajouter un accessoire")
                                    .foregroundColor(Color.blue)
                            }.onTapGesture {
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
                            }
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(Color.red)
                                Text("Supprimer la maison \(self.accessoriesManager.primaryHome.name)")
                                    .foregroundColor(Color.red)
                            }.onTapGesture {
                                DispatchQueue.main.async {
                                    if accessoriesManager.primaryHome == nil {
                                        return
                                    }
                                    let home = self.accessoriesManager.homeManager.primaryHome
                                    self.accessoriesManager.homeManager.removeHome(home!) { _ in}
                                    self.refresh.toggle()
                                }
                            }
                            Section(header: Text("Accessoires disponibles:")) {
                                
                            }
                        }
                    }
                }
                Spacer()
            }.toolbar {
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
        } else if showHome {
            HomeView()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showHome: .constant(false), showAuto: .constant(false), showSettings: .constant(false), temperature: .constant("20.0"))
    }
}
