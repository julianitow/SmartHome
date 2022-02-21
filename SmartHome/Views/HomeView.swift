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
    @State var currentLight: Light?
    @State var showHome = true
    @State var showAuto = false
    @State var showSettings = false
    @State var firstLaunch: Bool
    @State var address: Address! = KeychainManager.getHomeAddress()
    @State var addrAvailable: Bool
    @State var homeAvailable: Bool = false
    
    func fetchData() {
        self.accessoriesManager.fetchValues(dataType: .temperature) { temp in
            self.accessoriesManager.temperature = temp as! Float
        }
        self.accessoriesManager.fetchValues(dataType: .humidity) { hum in
            self.accessoriesManager.humidity = hum as! Int
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
    
    func hapticNotification() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
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
                        if self.accessoriesManager.accessories.count > 0 {
                            Section {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 0) {
                                        /*Text("Température")
                                            .fontWeight(.semibold)*/
                                        Image(systemName: "thermometer")
                                            .font(Font.system(.largeTitle))
                                        Text(self.accessoriesManager.temperature == -100.0 ? "N/A" : String(self.accessoriesManager.temperature) + "°C")
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                            .shadow(radius: 3)
                                            .overlay(Circle().stroke(getTempColor(value: self.accessoriesManager.temperature), lineWidth: 2))
                                            .foregroundColor(getTempColor(value: self.accessoriesManager.temperature))
                                            .padding()
                                    }
                                    
                                    VStack(spacing: 0) {
                                        Image(systemName: "humidity")
                                            .font(Font.system(.largeTitle))
                                        Text(self.accessoriesManager.humidity == -100 ? "N/A" : String(self.accessoriesManager.humidity) + "%")
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                            .shadow(radius: 3)
                                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                            .padding(.top, 5)
                                            .padding()
                                            .foregroundColor(Color.blue)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    ForEach(self.accessoriesManager.rooms) { room in
                        Section(header: Text("\(room.hmroom.name)")) {
                            if self.accessoriesManager.accessories.count == 0 {
                                Text("Aucun accessoire disponible, rendez-vous dans les paramètres pour en ajouter")
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                            } else {
                                ScrollView(.horizontal) {
                                    VStack(alignment: .leading) {
                                        HStack(alignment: .bottom) {
                                            ForEach(room.accessories, id: \.id) { accessory in
                                                if accessory.type == .light {
                                                    CustomLightButton(showLightView: $showLightView, brightnessLevel: $brightnessLevel, light: accessory as! Light)
                                                        .padding(5)
                                                        /*.gesture(LongPressGesture()
                                                            .onEnded { action in
                                                            self.currentLight = accessory
                                                            AccessoriesManager.fetchCharacteristicValue(accessory: light.accessory, dataType: DataType.brightness) { brightness in
                                                                self.currentLight?.brightness = brightness as! Float
                                                                AccessoriesManager.fetchCharacteristicValue(accessory: light.accessory, dataType: DataType.hue) { hue in
                                                                    self.currentLight?.hue = hue as! Float
                                                                    self.showLightView = true
                                                                    self.hapticNotification()
                                                                }
                                                            }
                                                        })*/
                                                } else if accessory.type == .socket{
                                                    HStack(alignment: .bottom)  {
                                                        CustomSwitchButton(socket: accessory)
                                                            .padding(5)
                                                    }
                                                }
                                             
                                            }
                                        }
                                    }
                                
                                }
                            }
                        }
                    }
                        
                        Section(header: Text("Localisation")) {
                            if self.addrAvailable && self.address.isValid {
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
        .onChange(of: accessoriesManager.updatedHome, perform: { _ in
            if self.accessoriesManager.primaryHome == nil {
                self.firstLaunch = true
            } else {
                self.firstLaunch = false
            }
        })
        .onChange(of: locationManager.homeAddress, perform: { _ in
            if locationManager.homeAddress == nil {
                self.addrAvailable = false
                self.firstLaunch = true
            }
        })
        
    }
}
