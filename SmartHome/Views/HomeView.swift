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
    @State var homeName: String = "Alésia"
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
    
    @State var thermometre: Thermometre!
    
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
    
    var body: some View {
        GeometryReader { geometry in
            if self.showAuto {
                AutoView(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings, temperatureMin: tempSetMin, temperatureMax: tempSetMax)
            } else if self.showSettings {
                SettingsView(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings, temperature: $tempSetMin)
            } else {
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Text(self.homeName)
                                .fontWeight(.semibold)
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                                .padding()
                            Spacer()
                        }
                        HStack {
                            Text(String(self.accessoriesManager.temperature) + "°c")
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                .padding()
                            
                            Text(String(self.accessoriesManager.humidity) + "%")
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                                .padding()
                        }
                        
                        HStack {
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
                            //CustomButton(isOn: $isOnHeater, showLightView: $showLightView, type: AccessoryType.heater)
                        }
                        VStack {
                            MapView(address: Address(country: "France", postalCode: 75014, street: "Villa d'Alésia", number: 20, city: "Paris"))
                                .offset(y: -200)
                                .padding()
                        }
                        NavigationBar(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings)
                    }
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
                }
            }
        }.onAppear() {
            self.fetchData()
        }
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}
