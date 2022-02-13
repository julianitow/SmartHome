//
//  CustomButton.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import SwiftUI

struct CustomButton: View {
    @Binding var showLightView: Bool
    @State var type: AccessoryType
    @State var accessory: Accessory
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: self.type == AccessoryType.socket ? "power" : "lightbulb")
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.top, 10)
                .foregroundColor(.white)
            Text(accessory.accessory!.name)
                .frame(minWidth: 75, idealWidth: 75, maxWidth: 150, minHeight: 75, idealHeight: 75, maxHeight: 75, alignment: .center)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .background(Color(type == AccessoryType.light ? (accessory.on ? .systemGreen : .systemGray4) : ((accessory.on ? .systemBlue : .systemGray4))))
        .cornerRadius(15)
        .padding([.top, .bottom], 10)
        .onTapGesture {
            self.accessory.on.toggle()
            AccessoriesManager.writeData(accessory: accessory.accessory!, accessoryType: AccessoryType.socket, dataType: nil, value: accessory.on)
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                if self.accessory.on {
                    Rectangle()
                        .frame(width: self.width, height: self.height)
                        .foregroundColor(.blue)
                } else {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: self.width, height: self.height)
                }
                VStack {
                    if self.type == AccessoryType.socket {
                        Image(systemName: "power")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(.leading, 20)
                            .foregroundColor(.white)
                        Text("Switch")
                            .padding(.leading)
                            .foregroundColor(.white)
                    } else if self.type == AccessoryType.light {
                        Image(systemName: "lightbulb")
                            .resizable()
                            .frame(width: 30, height: 40)
                            .padding(.leading, 20)
                            .foregroundColor(.white)
                        Text("Light")
                            .padding(.leading)
                            .foregroundColor(.white)
                    }
                }
            }
            .cornerRadius(15)
            .gesture(TapGesture()
            .onEnded { action in
                self.accessory.on.toggle()
                self.isOn.toggle()
                AccessoriesManager.writeData(accessory: accessory.accessory, accessoryType: AccessoryType.socket, dataType: nil, value: self.isOn)
                AccessoriesManager.fetchCharacteristicValue(accessory: accessory.accessory, dataType: DataType.powerState) { state in
                    self.accessory.on = state
                    self.isOn = state
                }
            })
            .onChange(of: self.accessory.on) { _ in
                // print(self.accessory.on)
            }
            .onAppear {
                AccessoriesManager.fetchCharacteristicValue(accessory: accessory.accessory, dataType: DataType.powerState) { state in
                    self.accessory.on = state
                    self.isOn = state
                }
            }
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
