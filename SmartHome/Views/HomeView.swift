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
    @State var isOnLight: Bool = false
    @State var isOnHeater: Bool = false
    @State var showLightView: Bool = false
    
    @State var accessoriesManager: AccessoriesManager = AccessoriesManager()
    
    @State var accessories: [HMAccessory]!
    
    @State var temperature: Float = 20.0
    @State var humidity: Float = 44
    
    @State var currentLight: Light!
    
    var lights: [HMAccessory]!
    
    func fetchData() {
        /**TODO: find another solution to wait for accessories to be reachable **/
        sleep(1)
        self.accessoriesManager.fetchValues(valueType: ValueType.temperature) { temp in
            self.temperature = temp
        }
        self.accessoriesManager.fetchValues(valueType: ValueType.humidity) { hum in
            self.humidity = hum
        }
        
        print(self.accessoriesManager.lights)
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
                    
                    /*HStack {
                        Toggle("Chauffage:", isOn: $heaterOn)
                        
                        if self.heaterOn {
                            Text("Chauffage allumé")
                        } else {
                            Text("Chauffage éteint")
                        }
                    }
                    
                    HStack {
                        Toggle("Bureau:", isOn: $deskOn)
                        
                        if self.deskOn {
                            Text("Bureau allumé")
                        } else {
                            Text("Bureau éteint")
                        }
                    }*/
                    HStack {
                        ForEach(self.accessoriesManager.lights, id: \.id) { light in
                            CustomButton(isOn: $isOnLight, showLightView: $showLightView, type: AccessoryType.light, name: light.accessory!.name)
                                .gesture(LongPressGesture()
                                .onEnded { action in
                                    self.showLightView = true
                                    self.currentLight = light
                                })
                        }
                        //CustomButton(isOn: $isOnHeater, showLightView: $showLightView, type: AccessoryType.heater)
                    }
                    
                    
                    //HStack {
                    //    CustomSlider(percentage: $percentage)
                    //}
                    let value = String(format: "%.1f", self.percentage)
                    Text(value)
                }
                if showLightView {
                    LightView(isOpen: $showLightView, percentage: $percentage, light: currentLight)
                }
            }
        }
        .onAppear {
            self.accessoriesManager.fetchAccessories()
            self.fetchData()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
