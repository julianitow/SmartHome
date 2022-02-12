//
//  HomeView.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import SwiftUI
import HomeKit

struct HomeView: View {
    
    @EnvironmentObject var accessoriesManager: AccessoriesManager
    @State var homeName: String = "Home Name"
    @State var heaterOn: Bool = false
    @State var deskOn: Bool = false
    @State var percentage: Float = 100.0
    //@State var isOnLight: Bool = false
    @State var isOnHeater: Bool = false
    @State var showLightView: Bool = false
    @State var accessories: [HMAccessory]!
    @State var tempSetMin: String = "20.0"
    @State var tempSetMax: String = "23.0"
    @State var temperature: Float = 20.0
    @State var humidity: Float = 44
    @State var currentLight: Light!
    @State var showHome = true
    @State var showAuto = false
    @State var showSettings = false
    @State var minTemp: Float = 20.0
    @State var maxTemp: Float = 23.0
    @State var firstLaunch = true
    @State var address: Address! = KeychainManager.getHomeAddress()
    @State var thermometre: Thermometre!
    @State var addrAvailable: Bool
    
    var lights: [HMAccessory]!
    
    func fetchData() {
        self.accessoriesManager.fetchValues(valueType: ValueType.temperature) { temp in
            self.accessoriesManager.temperature = temp
            self.temperature = temp
        }
        self.accessoriesManager.fetchValues(valueType: ValueType.humidity) { hum in
            self.accessoriesManager.humidity = hum
            self.humidity = hum
        }
    }
    
    func getTempColor(value : Int) -> Color{
        switch value {
        case Int.min..<20 :
            return Color.blue
        case 20...23 :
            return Color.green
        case 23..<Int.max :
            return Color.red
        default:
            return Color.black
        }
    }
    
    init() {
        /***Fetch address from keychain **/
        let addr = KeychainManager.getHomeAddress()
        if addr == nil {
            self.addrAvailable = false
            self.firstLaunch = true
            return
        } else {
            self.firstLaunch = false
            self.addrAvailable = true
            self.address = addr
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if self.showAuto {
                AutoView(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings, temperatureMin: tempSetMin, temperatureMax: tempSetMax)
            } else if self.showSettings {
                SettingsView(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings, temperature: $tempSetMin)
            } else {
                VStack {
                    Text(self.accessoriesManager.homeManager.primaryHome?.name ?? "Domicile name")
                        .fontWeight(.semibold)
                        .font(.system(size: 30))
                    Form {
                        Section {
                            HStack {
                                Spacer()
                                VStack(spacing: 0) {
                                    Text("Temperature")
                                    Text(String(self.accessoriesManager.temperature) + "°C")
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                        .overlay(Circle().stroke(getTempColor(value: Int(self.accessoriesManager.temperature)), lineWidth: 2))
                                        .foregroundColor(getTempColor(value: Int(self.accessoriesManager.temperature)))
                                        .padding()
                                }
                                
                                VStack(spacing: 0) {
                                    Text("Humidity")
                                    Text(String(self.accessoriesManager.humidity) + "%")
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                        .padding()
                                }
                                Spacer()
                            }
                        }
                        Section(header: Text("Actions")) {
                            HStack {
                                if self.accessoriesManager.accessories.count == 0 {
                                    Text("Aucun accessoire disponible, rendez-vous dans les paramètres pour en ajouter")
                                        .fontWeight(.semibold)
                                }
                                ForEach(self.accessoriesManager.lights, id: \.id) { light in
                                    CustomButton(showLightView: $showLightView, percentage: $percentage, type: AccessoryType.light, accessory: light)
                                        .gesture(LongPressGesture()
                                                    .onEnded { action in
                                                        self.showLightView = true
                                                        self.currentLight = light
                                        })
                                }
                                ForEach(self.accessoriesManager.sockets, id: \.id) { socket in
                                    CustomButton(showLightView: $showLightView, percentage: $percentage, type: AccessoryType.socket, accessory: socket)
                                }
                            }
                        }
                        Section(header: Text("Localisation")) {
                            if self.addrAvailable {
                                MapView(address: self.address)
                                    .frame(height: 300, alignment: .center)
                            }
                        }
                    
                    }
                }
                .frame(alignment: .center)
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        if !self.firstLaunch {
                            Spacer()
                            Image(systemName: "house")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color.blue)
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
                                .onTapGesture {
                                    showHome = false
                                    showAuto = false
                                    showSettings = true
                                }
                            Spacer()
                        }
                    }
                }
                .background(NavigationConfigurator { nc in
                    nc.setToolbarHidden(true, animated: true)
                })
                
                if showLightView {
                    LightView(isOpen: $showLightView, percentage: $percentage, light: currentLight)
                        .onChange(of: percentage) { _ in
                            //if self.percentage > 0 {
                            //    self.currentLight.on = true
                            //} else {
                            //    self.currentLight.on = false
                            //}
                        }
                }
                
                if self.firstLaunch {
                    SetupView(isOpen: $firstLaunch)
                        .onDisappear {
                            self.addrAvailable = true
                            self.address = KeychainManager.getHomeAddress()
                        }
                }
            }
        }.onAppear() {
            if self.accessoriesManager.homeManager.primaryHome == nil {
                self.firstLaunch = true
            } else {
                self.fetchData()
            }
        }
        .onChange(of: self.accessoriesManager.updatedHome) { _ in
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}

//ZStack {
//    VStack {
//
//        VStack {
//            if self.addrAvailable {
//                MapView(address: self.address)
//                    .padding()
//            }
//        }
//        NavigationBar(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings)
//    }
//
//    if showLightView {
//        LightView(isOpen: $showLightView, percentage: $percentage, light: currentLight)
//            .onChange(of: percentage) { _ in
//                //if self.percentage > 0 {
//                //    self.currentLight.on = true
//                //} else {
//                //    self.currentLight.on = false
//                //}
//            }
//    }
//
//    if self.firstLaunch {
//        SetupView(isOpen: $firstLaunch)
//            .onDisappear {
//                self.addrAvailable = true
//                self.address = KeychainManager.getHomeAddress()
//            }
//    }
//}
