//
//  SetupView.swift
//  SmartHome
//
//  Created by Julien Guillan on 11/02/2022.
//

import SwiftUI

struct SetupView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var accessoriesManager: AccessoriesManager
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var isOpen: Bool
    @State var height: CGFloat = 0
    @State var blurOffset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset = 0
    
    @State var address: Address = Address()
    @State var street: String = ""
    @State var city: String  = ""
    @State var country: String = ""
    @State var postalCode: String = ""
    @State var number: String = ""
    @State var homeName: String = ""
    @State var isHomeAvailable = false
    @State var isAddressAvailable = false
    @State var locationError = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                
            }.ignoresSafeArea()
            
            GeometryReader { geometry -> AnyView in
                if !isOpen {
                    DispatchQueue.main.async {
                        withAnimation {
                            self.blurOffset = geometry.frame(in: .global).height
                        }
                    }
                } else {
                    
                }
                return AnyView(
                    ZStack {
                        VStack {
                            VStack {
                                VStack {
                                    Form {
                                        Text("Configuration de SmartHome")
                                            .font(.largeTitle)
                                            .fontWeight(.semibold)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                            .multilineTextAlignment(.center)
                                            .frame(maxWidth: .infinity)
                                            .multilineTextAlignment(.center)
                                            
                                        
                                        if !self.isAddressAvailable {
                                            Section(header: Text("Où se trouve votre domicile ?")
                                                        .fontWeight(.semibold)
                                            ) {
                                                TextField("22", text: $number)
                                                TextField("Rue du Général De Gaulle", text: $street)
                                                TextField("75014", text: $postalCode)
                                                TextField("Paris", text: $city)
                                                TextField("France", text: $country)
                                            }
                                            
                                            Section {
                                                Button(action: {
                                                    guard self.country != "", self.postalCode != "", self.street != "", self.number != "", self.city != "" else {
                                                        return
                                                    }
                                                    let addr = Address(country: self.country, postalCode: Int(self.postalCode), street: self.street, number: Int(self.number), city: self.city)
                                                    KeychainManager.storeAddress(address: addr)
                                                    self.isAddressAvailable = true
                                                }) {
                                                    HStack {
                                                        Image(systemName: "checkmark")
                                                            .foregroundColor(Color(.systemGreen))
                                                        Text("Valider")
                                                            .foregroundColor(Color(.systemGreen))
                                                    }
                                                }
                                                
                                                Button {
                                                    guard let location = locationManager.currentLocation else {
                                                        print("Current location nil")
                                                        return
                                                    }
                                                    self.locationManager.getAddress(from: location) { addr in
                                                        if addr.isValid {
                                                            self.address = addr
                                                            KeychainManager.storeAddress(address: addr)
                                                            self.isAddressAvailable = true
                                                        } else {
                                                            self.locationError = true
                                                        }
                                                    }
                                                } label : {
                                                    HStack {
                                                        Image(systemName: "location")
                                                        if self.locationError {
                                                            Text("Veuillez réessayer, une erreur s'est produite")
                                                                .foregroundColor(.red)
                                                        } else {
                                                            Text("Utiliser la position actuelle")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if !self.isHomeAvailable {
                                            Section(header: Text("Ajouter un domicile")) {
                                                TextField("Nom du domicile, ex: \"Maison\"", text: $homeName)
                                               
                                                Button {
                                                    if self.homeName != "" {
                                                        self.accessoriesManager.homeManager.addHome(withName: self.homeName) { home, error in
                                                            if error != nil {
                                                                print("ERROR - 1: \(error?.localizedDescription ?? "unkown error")")
                                                                return
                                                            }
                                                            self.accessoriesManager.primaryHome = home
                                                        }
                                                    }
                                                } label: {
                                                    HStack {
                                                        Image(systemName: "plus")
                                                        Text("Ajouter un domicile")
                                                    }
                                                }
                                            }
                                            Text("Ajoutez une adresse et lieu pour continuer")
                                                .foregroundColor(.red)
                                        } else {
                                            Section(header: Text("\(accessoriesManager.primaryHome.name):")) {
                                                Button {
                                                    DispatchQueue.main.async {
                                                        self.accessoriesManager.primaryHome.addAndSetupAccessories() { error in
                                                            if error != nil {
                                                                print("ERROR - 2: \(error?.localizedDescription ?? "unkown error")")
                                                                return
                                                            }
                                                        }
                                                    }
                                                } label: {
                                                    HStack {
                                                        Image(systemName: "plus")
                                                        Text("Ajouter un accesssoire/bridge")
                                                    }
                                                }
                                            }
                                            
                                            if self.isAddressAvailable {
                                                Section {
                                                    Button(action: {
                                                        self.isOpen = false
                                                    }, label: {
                                                        Text("Terminer configuration")
                                                            .foregroundColor(.green)
                                                    })
                                                }
                                            } else {
                                                Section {
                                                    Text("Veuillez saisir une adresse pour continuer")
                                                        .foregroundColor(.red)
                                                }
                                            }
                                            
                                            if self.isHomeAvailable && self.accessoriesManager.accessories.count > 0 {
                                                Section (header: Text("Accessoires disponibles:")) {
                                                    ForEach(self.accessoriesManager.accessories, id: \.id) { accessory in
                                                        HStack {
                                                            Text(accessory.accessory.name)
                                                        }
                                                    }.onDelete(perform: self.accessoriesManager.removeAccessory)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                )
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .shadow(color: .gray, radius: 13.0)
        .onChange(of: accessoriesManager.primaryHome) {  _ in
            self.isHomeAvailable = true
        }
        .onAppear {
            if KeychainManager.getHomeAddress() != nil {
                self.isAddressAvailable = true
            } else {
                self.isAddressAvailable = false
            }
            if self.accessoriesManager.primaryHome == nil {
                self.isHomeAvailable = false
            } else {
                self.isHomeAvailable = true
            }
        }
    }
}
