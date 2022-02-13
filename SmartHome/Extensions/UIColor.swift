//
//  UIColor.swift
//  SmartHome
//
//  Created by Julien Guillan on 09/02/2022.
//

import Foundation
import UIKit

extension UIColor {
    var hsbComponents:(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var hue:CGFloat = 0
        var saturation:CGFloat = 0
        var brightness:CGFloat = 0
        var alpha:CGFloat = 0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha){
            return (hue,saturation,brightness,alpha)
        }
        return (0,0,0,0)
    }
    
    func getHue() -> (CGFloat) {
        let ciColor = CIColor(color: self)
        let r = ciColor.red
        let g = ciColor.green
        let b = ciColor.blue
        let minV:CGFloat = CGFloat(min(r, g, b))
        let maxV:CGFloat = CGFloat(max(r, g, b))
        let delta:CGFloat = maxV - minV
        var hue:CGFloat = 0
        if delta != 0 {
        if r == maxV {
           hue = (g - b) / delta
        }
        else if g == maxV {
           hue = 2 + (b - r) / delta
        }
        else {
           hue = 4 + (r - g) / delta
        }
        hue *= 60
            if hue < 0 {
               hue += 360
            }
        }
        return hue
    }
}
