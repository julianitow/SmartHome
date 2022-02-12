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
    @State var showAlert = false
    @State var refresh: Bool = false
    
    var body: some View {
        if self.showAuto {
            AutoView(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings, temperatureMin: "", temperatureMax: "")
        } else if self.showSettings {
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                Form {
                    Section(header: Text("Clear data")) {
                        Button(role: .destructive) {
                            KeychainManager.clearKeychain()
                            self.showAlert.toggle()
                        } label: {
                            Label("Supprimer adresse enregistrée", systemImage: "trash")
                        }.alert(Text("Adresse supprimée, veuillez-relancer l'application pour prendre en compte les modifications."), isPresented: $showAlert, actions: {})
                    }
                    Section(header: Text("Ajout d'accessoire(s)")) {
                        if accessoriesManager.primaryHome == nil {
                            Button {
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
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                    Text("Ajouter un domicile")
                                }
                            }
                        }
                        
                        if accessoriesManager.primaryHome != nil {
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
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                    Text("Ajouter un accesssoire/bridge")
                                }
                            }
                            
                            Button(role: .destructive) {
                                DispatchQueue.main.async {
                                    if accessoriesManager.primaryHome == nil {
                                        return
                                    }
                                    let home = self.accessoriesManager.homeManager.primaryHome
                                    self.accessoriesManager.homeManager.removeHome(home!) { _ in}
                                    self.refresh.toggle()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                    Text("Supprimer domicile \" \(self.accessoriesManager.primaryHome.name)\"")
                                }
                            }
                        }
                        Section(header: Text("Accessoires disponibles:")) {
                            
                        }
                    }
                }
                Spacer()
                NavigationBar(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings)
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
