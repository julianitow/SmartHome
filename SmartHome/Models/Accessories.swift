//
//  Accessory.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import Foundation
import HomeKit

protocol Accessory {
    var id: Int { get set }
    var accessory: HMAccessory? { get set }
    var on: Bool { get set }
}

struct Light: Accessory {
    var id: Int
    var accessory: HMAccessory?
    var on: Bool = false
    var brightness: Double?
    var hue: Double?
    var saturation: Double?
}

struct Socket: Accessory {
    var id: Int
    var accessory: HMAccessory?
    var on: Bool = false
}

enum DataType { case hue, brightness, powerState}

enum AccessoryType { case socket, light }

