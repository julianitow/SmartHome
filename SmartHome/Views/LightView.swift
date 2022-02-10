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
    @Binding var percentage: Float
    @State var light: Light
    @State var height: CGFloat = 0
    
    @State var blurOffset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset = 0
    
    @State var selectedColor: Color = Color(UIColor.yellow.withAlphaComponent(0.5))
    
    let red = Color_(id: 0, color: .red)
    let white = Color_(id: 1, color: .white)
    let blue = Color_(id: 2, color: .blue)
    let orange = Color_(id: 3, color: .orange)
    let yellow = Color_(id: 4, color: UIColor.yellow.withAlphaComponent(0.5))
    let brown = Color_(id: 5, color: .brown)
    let pink = Color_(id: 6, color: .systemPink)
    
    var body: some View {
        let colors: [Color_] = [red, white, blue, orange, yellow, brown, pink]
        ZStack {
            GeometryReader { geometry in
                
            }.ignoresSafeArea()
            
            GeometryReader { geometry -> AnyView in
                guard let accessory = self.light.accessory else {
                    return AnyView(
                        Text("Accessory Nil")
                    )
                }
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
                            CustomSlider(percentage: $percentage, tintColor: $selectedColor)
                                .onChange(of: percentage) { value in
                                    AccessoriesManager.writeData(accessory: accessory, accessoryType: AccessoryType.light, dataType: DataType.brightness, value: value)
                                }
                            
                            HStack {
                                ForEach(colors, id: \.id) { color in
                                    ColorPick(color: color.color)
                                        .onTapGesture {
                                            let hue = color.color.hsbComponents.hue
                                            self.selectedColor = Color(color.color)
                                            AccessoriesManager.writeData(accessory: accessory, accessoryType: AccessoryType.light, dataType: DataType.hue, value: hue)
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
        }.ignoresSafeArea(.all, edges: .bottom)
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
