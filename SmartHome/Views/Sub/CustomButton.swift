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
}

//struct CustomButton_Previews: PreviewProvider {
//
//    @State static var value = false
//    static var previews: some View {
//        CustomButton(isOn: .constant(value), showLightView: .constant(true), type: //AccessoryType.relay, name: "Light")
//    }
//}
