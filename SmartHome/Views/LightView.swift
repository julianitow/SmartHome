//
//  LightView.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import SwiftUI

struct Color_ {
    var id: Int
    let color: UIColor
}

struct LightView: View {
    @Binding var isOpen: Bool
    @Binding var brightnessLevel: Float
    @State var light: Light
    @State var height: CGFloat = 0
    
    @State var blurOffset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset = 0
    
    @State var selectedColor: Color = Color(UIColor.yellow.withAlphaComponent(0.5))
    
    let red = Color_(id: 0, color: UIColor.red.withAlphaComponent(0.5))
//    let white = Color_(id: 1, color: .white)
    let blue = Color_(id: 2, color: UIColor.blue.withAlphaComponent(0.5))
    let orange = Color_(id: 3, color: UIColor.orange.withAlphaComponent(0.5))
    let yellow = Color_(id: 4, color: UIColor.yellow.withAlphaComponent(0.5))
    let brown = Color_(id: 5, color: UIColor.green.withAlphaComponent(0.5))
    let pink = Color_(id: 6, color: UIColor.systemPink.withAlphaComponent(0.5))
    
    var body: some View {
        let colors: [Color_] = [red, blue, orange, yellow, brown, pink]
        ZStack {
            GeometryReader { geometry in
                
            }.ignoresSafeArea()
            
            GeometryReader { geometry -> AnyView in
                let accessory = self.light.accessory
                if !isOpen {
                    DispatchQueue.main.async {
                        self.blurOffset = geometry.frame(in: .global).height
                    }
                } else {
                }
                return AnyView(
                    ZStack {
                        BlurView(style: .systemThinMaterialDark)
                            .clipShape(CustomCorner(corners: [.topLeft, .topRight], radius: 30))
                        
                        VStack {
                            Capsule()
                                .fill(.white)
                                .frame(width: 60, height: 4)
                                .padding(.top)
                            Text(accessory.name)
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                            CustomSlider(percentage: $brightnessLevel, tintColor: $selectedColor)
                                .onChange(of: brightnessLevel) { value in
                                    AccessoriesManager.writeData(accessory: accessory, accessoryType: AccessoryType.light, dataType: DataType.brightness, value: value)
                                    self.light.brightness = brightnessLevel
                                }
                            
                            HStack {
                                ForEach(colors, id: \.id) { color in
                                    ColorPick(color: color.color)
                                        .onTapGesture {
                                            let hue = color.color.getHue()
                                            self.selectedColor = Color(color.color.withAlphaComponent(0.5))
                                            AccessoriesManager.writeData(accessory: accessory, accessoryType: AccessoryType.light, dataType: DataType.hue, value: hue)
                                            self.light.hue = Float(hue)
                                        }
                                }
                            }.offset(y: -200)
                        }
                    }
                    .offset(y: self.blurOffset)
                        .gesture(DragGesture().updating($gestureOffset, body: { value, out, _ in
                            out = Int(value.translation.height)
                            onChange()
                        }).onEnded({ value in
                            let maxHeight = height
                            withAnimation {
                                if -blurOffset > 100 && -blurOffset < maxHeight / 2 {
                                    blurOffset = -(maxHeight / 3)
                                } else if -blurOffset > maxHeight / 2 {
                                    blurOffset = -maxHeight
                                } else {
                                    self.blurOffset = geometry.frame(in: .global).height
                                    self.isOpen = false
                                }
                            }
                            lastOffset = blurOffset
                        }))
                )
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear {
            self.brightnessLevel = self.light.brightness
            print("COLOR", self.light.hue)
            self.selectedColor = Color(uiColor: UIColor(hue: CGFloat(self.light.hue / 360), saturation: 100.0, brightness: CGFloat(self.light.brightness), alpha: 0.5))
        }
    }
    
    func onChange() {
        DispatchQueue.main.async {
            self.blurOffset = CGFloat(gestureOffset) + lastOffset
        }
    }
}

/*struct LightView_Previews: PreviewProvider {
    var light = Light(id: 1, accessory: nil)
    static var previews: some View {
        LightView(isOpen: .constant(true), percentage: .constant(100), light: light)
    }
}*/
