//
//  SetupView.swift
//  SmartHome
//
//  Created by Julien Guillan on 11/02/2022.
//

import SwiftUI

struct SetupView: View {
    @EnvironmentObject var locationManager: LocationManager
    @Binding var isOpen: Bool
    @State var height: CGFloat = 0
    @State var blurOffset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset = 0
    
    @State @State var address: Address = Address()
    @State var street: String = ""
    @State var city: String  = ""
    @State var country: String = ""
    @State var postalCode: String = ""
    @State var number: String = ""
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                
            }.ignoresSafeArea()
            
            GeometryReader { geometry -> AnyView in
                if !isOpen {
                    DispatchQueue.main.async {
                        self.blurOffset = geometry.frame(in: .global).height
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
                            
                            VStack {
                                Text("Ou se trouve votre domicile ?")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .padding()
                                
                                VStack {
                                    Form {
                                        Section(header: Text("Adresse du domicile")) {
                                            TextField("France", text: $country)
                                            TextField("Paris", text: $city)
                                            TextField("Rue du Général De Gaulle", text: $street)
                                            TextField("75014", text: $postalCode)
                                            TextField("22", text: $number)
                                        }
                                        Section {
                                            Button(action: {
                                                guard self.country != "", self.postalCode != "", self.street != "", self.number != "", self.city != "" else {
                                                    return
                                                }
                                                let addr = Address(country: self.country, postalCode: Int(self.postalCode), street: self.street, number: Int(self.number), city: self.city)
                                                KeychainManager.storeAddress(address: addr)
                                            }) {
                                                HStack {
                                                    Image(systemName: "checkmark")
                                                        .resizable()
                                                        .frame(width: 20, height: 20)
                                                    Text("Valider")
                                                }
                                            }
                                            Button(action: {
                                                guard let location = locationManager.currentLocation else {
                                                    print("Current location nil")
                                                    return
                                                }
                                                self.locationManager.getAddress(from: location) { addr in
                                                    self.address = addr
                                                    KeychainManager.storeAddress(address: addr)
                                                    self.isOpen = false
                                                }
                                            }) {
                                                HStack {
                                                    Image(systemName: "location")
                                                        .resizable()
                                                        .frame(width: 20, height: 20)
                                                    Text("Utiliser la position actuelle")
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
    }
    
    func onChange() {
        DispatchQueue.main.async {
            self.blurOffset = CGFloat(gestureOffset) + lastOffset
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
