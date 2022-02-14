//
//  CustomButton.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import SwiftUI

struct CustomLightButton: View {
    @Binding var showLightView: Bool
    @Binding var percentage: Float
    @State var light: Light
    @State var isOn: Bool = false
    @State var color: UIColor = .systemGreen
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "lightbulb")
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.top, 10)
                .foregroundColor(.white)
            Text(light.accessory.name)
                .frame(minWidth: 100, idealWidth: 100, maxWidth: 100, minHeight: 75, idealHeight: 75, maxHeight: 75, alignment: .center)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .background(Color(light.on ? .systemGreen : .systemGray4))
        .cornerRadius(15)
        .padding([.top, .bottom], 10)
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
    }
}

//struct CustomButton_Previews: PreviewProvider {
//
//    @State static var value = false
//    static var previews: some View {
//        CustomButton(isOn: .constant(value), showLightView: .constant(true), type: //AccessoryType.relay, name: "Light")
//    }
//}
