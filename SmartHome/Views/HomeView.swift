//
//  HomeView.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import SwiftUI

struct HomeView: View {
    @State var homeName: String = "Alésia"
    @State var heaterOn: Bool = false
    @State var deskOn: Bool = false
    @State var percentage: Float = 100.0
    @State var isOnLight: Bool = false
    @State var isOnHeater: Bool = false
    
    @State var showLightView: Bool = false
    
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
                        Text("20.0°c")
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            .padding()
                        
                        Text("44%")
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            .padding()
                    }
                    HStack {
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
                    }
                    HStack {
                        CustomButton(isOn: $isOnLight, showLightView: $showLightView, type: AccessoryType.heater)
                        CustomButton(isOn: $isOnHeater, showLightView: $showLightView, type: AccessoryType.light)
                    }
                    
                    
                    //HStack {
                    //    CustomSlider(percentage: $percentage)
                    //}
                    let value = String(format: "%.1f", self.percentage)
                    Text(value)
                }
                if showLightView {
                    LightView(isOpen: $showLightView, percentage: $percentage)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
