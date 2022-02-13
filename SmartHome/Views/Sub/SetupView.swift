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
                        BlurView(style: .systemMaterial)
                            .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 30))
                        VStack {
                            Text("Bienvenue sur SmartHome")
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding()
                                .multilineTextAlignment(.center)
                            
                            VStack {
                                Text("Où se trouve votre domicile ?")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .padding()
                                
                                VStack {
                                    Form {
                                        if !self.isAddressAvailable {
                                            Section(header: Text("Adresse du domicile")) {
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
                                                        self.address = addr
                                                        KeychainManager.storeAddress(address: addr)
                                                        self.isAddressAvailable = true
                                                    }
                                                } label : {
                                                    HStack {
                                                        Image(systemName: "location")
                                                        Text("Utiliser la position actuelle")
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if !self.isHomeAvailable {
                                            Section(header: Text("Ajouter un lieu")) {
                                                TextField("Nom du lieu", text: $homeName)
                                               
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
                                            Section(header: Text("Ajouter accessoire(s)")) {
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
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    .onAppear {
                        UITableView.appearance().backgroundColor = .clear
                    }
                )
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .shadow(color: .gray, radius: 13.0)
        .onChange(of: accessoriesManager.primaryHome) {  _ in
            self.isHomeAvailable = true
        }
    }
}

// struct SetupView_Previews: PreviewProvider {
//     let addr = Address(country: "France", postalCode: 75014, street: "Rue du général de Gaulle", // number: 20, city: "Paris")
//
//     static var previews: some View {
//         SetupView(isOpen: .constant(true))
//     }
// }
