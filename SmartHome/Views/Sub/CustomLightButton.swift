//
//  CustomButton.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import SwiftUI

struct CustomLightButton: View {
    @EnvironmentObject var accessoriesManager: AccessoriesManager
    @Binding var showLightView: Bool
    @Binding var brightnessLevel: Float
    @State var light: Light
    @State var isOn: Bool = false
    @State var color: UIColor = .systemGreen
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "lightbulb")
                .resizable()
                .frame(width: 30, height: 40)
                .padding(.top, 20)
                .foregroundColor(light.on ? .black : .white)
            Text(light.accessory.name)
                .frame(minWidth: 100, idealWidth: 100, maxWidth: 100, minHeight: 60, idealHeight: 60, maxHeight: 75, alignment: .center)
                .multilineTextAlignment(.center)
                .foregroundColor(light.on ? .black : .white)
                .offset(y: -10)
        }
        .background(Color(light.on ? .systemYellow : .systemGray4))
        .cornerRadius(15)
        .padding([.top], 10)
        .onChange(of: light, perform: { _ in
            self.color = UIColor(hue: CGFloat(light.hue / 360), saturation: 100, brightness: CGFloat(light.brightness), alpha: 0.5)
        })
        .onTapGesture {
            self.light.on.toggle()
            AccessoriesManager.writeData(accessory: light.accessory, accessoryType: AccessoryType.light, dataType: DataType.powerState, value: light.on)
        }
        .onAppear {
            AccessoriesManager.fetchCharacteristicValue(accessory: light.accessory, dataType: DataType.powerState) { state in
                self.light.on = state as! Bool
                self.isOn = state as! Bool
            }
            var light = Light(accessory: light.accessory)
            AccessoriesManager.fetchCharacteristicValue(accessory: light.accessory, dataType: DataType.brightness) { brightness in
                light.brightness = brightness as! Float
                if light.brightness > 0 {
                    light.on = true
                } else {
                    light.on = false
                }
            }
            
            /* IMPLEMENTATION COULEUR BOUTON NON TERMINEE
            AccessoriesManager.fetchCharacteristicValue(accessory: light.accessory, dataType: DataType.hue) { hue in
                light.hue = hue as! Float
                self.color = UIColor(hue: CGFloat(light.hue / 360), saturation: 100, brightness: CGFloat(light.brightness), alpha: 0.5)
            }*/
        }
        .onChange(of: accessoriesManager.onChangeSocketId) { _ in
            if accessoriesManager.onChangeSocketId.first?.key == light.id {
                light.on = accessoriesManager.onChangeSocketId.first!.value
            }
        }
    }
}
