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
    @EnvironmentObject var locationManager: LocationManager
    @State var brightnessLevel: Float = 100.0
    @State var showLightView: Bool = false
    @State var temperature: Float = 20.0
    @State var humidity: Int = 44
    @State var currentLight: Light?
    @State var showHome = true
    @State var showAuto = false
    @State var showSettings = false
    @State var firstLaunch: Bool
    @State var address: Address! = KeychainManager.getHomeAddress()
    @State var addrAvailable: Bool
    
    func fetchData() {
        self.accessoriesManager.fetchValues(dataType: .temperature) { temp in
            self.accessoriesManager.temperature = temp as! Float
            self.temperature = temp as! Float
        }
        self.accessoriesManager.fetchValues(dataType: .humidity) { hum in
            self.accessoriesManager.humidity = hum as! Int
            self.humidity = hum as! Int
        }
    }
    
    func getTempColor(value : Float) -> Color{
        switch value {
        case Float(Int.min)..<accessoriesManager.minTemp :
            return Color.cyan
        case accessoriesManager.minTemp...accessoriesManager.maxTemp :
            return Color.green
        case accessoriesManager.maxTemp..<Float(Int.max) :
            return Color.red
        default:
            return Color.white
        }
    }
    
    init() {
        let addr = KeychainManager.getHomeAddress()
        if addr == nil {
            _firstLaunch = State(initialValue: true)
            _addrAvailable = State(initialValue: false)
        } else {
            _address = State(initialValue: addr)
            _addrAvailable = State(initialValue: true)
            _firstLaunch = State(initialValue: false)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            if self.showAuto {
                AutoView(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings)
            } else if self.showSettings {
                SettingsView(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings)
            } else {
                VStack {
                    Text(self.accessoriesManager.homeManager.primaryHome?.name ?? "Mon Domicile")
                        .fontWeight(.semibold)
                        .font(.system(size: 30))
                    Form {
                        Section {
                            HStack {
                                Spacer()
                                VStack(spacing: 0) {
                                    Text("Température")
                                    Text(String(self.accessoriesManager.temperature) + "°C")
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                        .overlay(Circle().stroke(getTempColor(value: self.accessoriesManager.temperature), lineWidth: 2))
                                        .foregroundColor(getTempColor(value: self.accessoriesManager.temperature))
                                        .padding()
                                }
                                
                                VStack(spacing: 0) {
                                    Text("Humidité")
                                    Text(String(self.accessoriesManager.humidity) + "%")
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                        .padding()
                                        .foregroundColor(Color.blue)
                                }
                                Spacer()
                            }
                        }
                        
                        Section(header: Text("Actions")) {
                            if self.accessoriesManager.accessories.count == 0 {
                                Text("Aucun accessoire disponible, rendez-vous dans les paramètres pour en ajouter")
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                            } else {
                                ScrollView(.horizontal) {
                                    VStack(alignment: .leading) {
                                        HStack(alignment: .bottom) {
                                            ForEach(self.accessoriesManager.lights, id: \.id) { light in
                                                CustomLightButton(showLightView: $showLightView, brightnessLevel: $brightnessLevel, light: light)
                                                    .padding(5)
                                                    .gesture(LongPressGesture()
                                                        .onEnded { action in
                                                        self.currentLight = light
                                                        AccessoriesManager.fetchCharacteristicValue(accessory: light.accessory, dataType: DataType.brightness) { brightness in
                                                            self.currentLight?.brightness = brightness as! Float
                                                            AccessoriesManager.fetchCharacteristicValue(accessory: light.accessory, dataType: DataType.hue) { hue in
                                                                self.currentLight?.hue = hue as! Float
                                                                self.showLightView = true
                                                            }
                                                        }
                                                    })
                                            }
                                        }
                                        HStack(alignment: .bottom)  {
                                            ForEach(self.accessoriesManager.sockets, id: \.id) { socket in
                                                CustomSwitchButton(socket: socket)
                                                    .padding(5)
                                            }
                                        }
                                    }
                                
                                }
                            }
                        }
                        
                        Section(header: Text("Localisation")) {
                            if self.addrAvailable {
                                MapView(address: self.address)
                                    .frame(height: 250)
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
                
                if showLightView {
                    LightView(isOpen: $showLightView, brightnessLevel: $brightnessLevel, light: currentLight!)
                }
                
                if self.firstLaunch {
                    SetupView(isOpen: $firstLaunch)
                        .onDisappear {
                            self.addrAvailable = true
                            self.address = KeychainManager.getHomeAddress()
                        }
                }
            }
        }
        .onAppear() {
            if self.accessoriesManager.homeManager.primaryHome == nil {
                self.firstLaunch = true
            } else {
                self.fetchData()
            }
        }
        .onChange(of: locationManager.distanceFromHome, perform: { _ in
            self.accessoriesManager.checkDistanceFromHome(distance: locationManager.distanceFromHome)
        })
    }
}
