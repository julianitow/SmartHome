//
//  Accessory.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import Foundation
import HomeKit

protocol Accessory {
    var id: UUID { get set }
    var accessory: HMAccessory { get set }
    var on: Bool { get set }
}

struct Light: Accessory {
    var id: UUID
    var accessory: HMAccessory = HMAccessory()
    var on: Bool = false
    var brightness: Double = 0
    var hue: Double?
    var saturation: Double?
    init(accessory: HMAccessory) {
        self.id = UUID()
        self.accessory = accessory
    }
}

struct Socket: Accessory {
    var id: UUID
    var accessory: HMAccessory = HMAccessory()
    var on: Bool = false
    init(accessory: HMAccessory) {
        self.id = UUID()
        self.accessory = accessory
    }
}

struct Thermometre: Accessory {
    var id: UUID
    var accessory: HMAccessory = HMAccessory()
    var on: Bool = false
    var temperature: Float = 0.0
    init(accessory: HMAccessory) {
        self.id = UUID()
        self.accessory = accessory
    }
}

enum DataType { case hue, brightness, powerState}

enum AccessoryType { case socket, light }

