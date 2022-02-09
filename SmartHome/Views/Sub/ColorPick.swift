//
//  ColorPick.swift
//  SmartHome
//
//  Created by Julien Guillan on 09/02/2022.
//

import SwiftUI

struct ColorPick: View {
    @State var color: UIColor
    var body: some View {
        VStack {
            Circle()
                .frame(width: 45, height: 45)
                .foregroundColor(Color(self.color))
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: 5)
                )
        }
    }
}

struct ColorPick_Previews: PreviewProvider {
    static var previews: some View {
        ColorPick(color: UIColor(.red))
    }
}
