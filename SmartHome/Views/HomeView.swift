//
//  HomeView.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import SwiftUI
import HomeKit

struct HomeView: View {
    @State var homeName: String = "Alésia"
    @State var heaterOn: Bool = false
    @State var deskOn: Bool = false
    @State var percentage: Float = 100.0
    //@State var isOnLight: Bool = false
    @State var isOnHeater: Bool = false
    @State var showLightView: Bool = false
    
    @State var accessoriesManager: AccessoriesManager = AccessoriesManager()
    
    @State var accessories: [HMAccessory]!
    
    @State var temperature: Float = 20.0
    @State var humidity: Float = 44
    
    @State var currentLight: Light!
    
    var lights: [HMAccessory]!
    
    func fetchData() {
        self.accessoriesManager.fetchValues(valueType: ValueType.temperature) { temp in
            self.temperature = temp
        }
        self.accessoriesManager.fetchValues(valueType: ValueType.humidity) { hum in
            self.humidity = hum
        }
        
        for light in self.accessoriesManager.lights {
            self.accessoriesManager.fetchBrightness(light: light.accessory!)
        }
        
        print(self.accessoriesManager.sockets)
    }
    
    var body: some View {
        GeometryReader { geometry in
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
                        Text(String(temperature) + "°c")
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            .padding()
                        
                        Text(String(humidity) + "%")
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
                    let value = String(format: "%.1f", self.percentage)
                    Text(value)
                }
                if showLightView {
                    LightView(isOpen: $showLightView, percentage: $percentage, light: currentLight)
                        .onChange(of: percentage) { _ in
                            if self.percentage > 0 {
                                self.currentLight.on = true
                            } else {
                                self.currentLight.on = false
                            }
                        }
                }
            }
        }
        .onAppear {
            self.accessoriesManager.fetchAccessories()
            /**TODO: find another solution to wait for accessories to be reachable **/
            sleep(1)
            self.fetchData()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
