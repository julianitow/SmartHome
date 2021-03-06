//
//  CustomSlider.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import SwiftUI

struct CustomSlider: View {
    
    @Binding var percentage: Float
    @Binding var tintColor: Color
    
    let backgroundColor = Color(UIColor.gray.withAlphaComponent(0.5))
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(self.backgroundColor)
                Rectangle()
                    .foregroundColor(tintColor)
                    .frame(width: geometry.size.width * CGFloat(self.percentage / 100))
                Image(systemName: "lightbulb")
                    .resizable()
                    .frame(width: 30, height: 40)
                    .rotationEffect(.degrees(90.0))
                    .padding(.leading, geometry.size.width / 2)
                    .foregroundColor(.white)
            }
            .cornerRadius(30)
            .gesture(DragGesture(minimumDistance: 0)
            .onChanged({ value in
                self.percentage = min(max(0, Float(value.location.x / geometry.size.width * 100)), 100)
            }))
            .rotationEffect(.degrees(-90.0))
            .frame(width: geometry.size.width, height: 100)
            .offset(x: 0,y: 150)
        }
    }
}
