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
    @State var homeName: String = "Home Name"
    @State var heaterOn: Bool = false
    @State var deskOn: Bool = false
    @State var percentage: Float = 100.0
    //@State var isOnLight: Bool = false
    @State var isOnHeater: Bool = false
    @State var showLightView: Bool = false
    @State var accessories: [HMAccessory]!
    @State var tempSetMin: String = "N/A"
    @State var tempSetMax: String = "N/A"
    @State var temperature: Float = 20.0
    @State var humidity: Float = 44
    @State var currentLight: Light?
    @State var showHome = true
    @State var showAuto = false
    @State var showSettings = false
    @State var firstLaunch: Bool
    @State var address: Address! = KeychainManager.getHomeAddress()
    @State var thermometre: Thermometre!
    @State var addrAvailable: Bool
    @State var refresh: Bool = false
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
                                                CustomLightButton(showLightView: $showLightView, percentage: $percentage, light: light)
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
                    LightView(isOpen: $showLightView, percentage: $percentage, light: currentLight!)
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
