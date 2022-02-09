//
//  BlurView.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import SwiftUI

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
