//
//  CustomButton.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import SwiftUI

struct CustomButton: View {
    let width = CGFloat(75)
    let height = CGFloat(75)
    
    @Binding var showLightView: Bool
    @Binding var percentage: Float
    @State var type: AccessoryType
    @State var accessory: Accessory
    @State var isOn: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: self.type == AccessoryType.socket ? "power" : "lightbulb")
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.top, 10)
                .foregroundColor(.white)
            Text(accessory.accessory!.name)
                .frame(minWidth: self.width, idealWidth: self.width, maxWidth: 150, minHeight: self.height, idealHeight: self.height, maxHeight: self.height, alignment: .center)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .background(Color(type == AccessoryType.light ? (accessory.on ? .systemGreen : .systemGray4) : ((accessory.on ? .systemBlue : .systemGray4))))
        .cornerRadius(15)
        .padding([.top, .bottom], 10)
        .gesture(TapGesture()
        .onEnded { action in
            self.accessory.on.toggle()
            AccessoriesManager.writeData(accessory: accessory.accessory!, accessoryType: AccessoryType.socket, dataType: nil, value: accessory.on)
        })
        .onChange(of: percentage) { _ in
            if percentage > 0 {
                self.accessory.on = true
            } else {
                self.accessory.on = false
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
