//
//  AccessoryView.swift
//  SmartHome
//
//  Created by Julien Guillan on 20/02/2022.
//

import SwiftUI
import HomeKit

struct AccessoryView: View {
    @State var accessory: Accessory
    @State var isShown: Bool = false
    var body: some View {
        GeometryReader { geometry in
            
        }.ignoresSafeArea()
        
        GeometryReader { geometry -> AnyView in
            if !isShown {
                
            }
            
            return AnyView(
                ZStack {
                    Text(self.accessory.accessory.name)
                }
            )
        }
    }
}
