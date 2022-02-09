//
//  LightView.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import SwiftUI
import Introspect

struct LightView: View {
    @Binding var isOpen: Bool
    @Binding var percentage: Float
    @State var height: CGFloat = 0
    
    @State var blurOffset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset = 0
    var body: some View {

        ZStack {
            GeometryReader { geometry in
                
            }.ignoresSafeArea()
            
            GeometryReader { geometry -> AnyView in
                //let height = geometry.frame(in: .global).height
                if !isOpen {
                    self.blurOffset = geometry.frame(in: .global).height
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
                            CustomSlider(percentage: $percentage)
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

struct LightView_Previews: PreviewProvider {
    static var previews: some View {
        LightView(isOpen: .constant(true), percentage: .constant(100))
    }
}
