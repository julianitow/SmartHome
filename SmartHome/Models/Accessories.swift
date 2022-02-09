//
//  Accessory.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import Foundation
import HomeKit

struct Light {
    var id: Int
    let accessory: HMAccessory?
}

enum DataType { case hue, brightness}

enum AccessoryType{ case relay, light }
