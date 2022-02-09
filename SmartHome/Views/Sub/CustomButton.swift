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
    
    @Binding var isOn: Bool
    @Binding var showLightView: Bool
    @State var type: AccessoryType
    @State var name: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                if self.isOn {
                    Rectangle()
                        .frame(width: self.width, height: self.height)
                        .foregroundColor(.blue)
                } else {
                    Rectangle()
                        .foregroundColor(.gray)
                        .frame(width: self.width, height: self.height)
                }
                VStack {
                    if self.type == AccessoryType.relay {
                        Image(systemName: "flame")
                            .resizable()
                            .frame(width: 30, height: 40)
                            .padding(.leading, 20)
                            .foregroundColor(.white)
                        Text("Heater")
                            .padding(.leading)
                            .foregroundColor(.white)
                    } else if self.type == AccessoryType.light {
                        Image(systemName: "lightbulb")
                            .resizable()
                            .frame(width: 30, height: 40)
                            .padding(.leading, 20)
                            .foregroundColor(.white)
                        Text("light")
                            .padding(.leading)
                            .foregroundColor(.white)
                    }
                }
            }
            .cornerRadius(15)
            .gesture(TapGesture()
            .onEnded { action in
                self.isOn.toggle()
                print(self.isOn)
            })
            /*.gesture(LongPressGesture()
            .onEnded { action in
                if self.type == AccessoryType.light {
                    self.showLightView.toggle()
                }
            })*/
        }
    }
}

struct CustomButton_Previews: PreviewProvider {
    
    @State static var value = false
    static var previews: some View {
        CustomButton(isOn: .constant(value), showLightView: .constant(true), type: AccessoryType.relay, name: "Light")
    }
}
