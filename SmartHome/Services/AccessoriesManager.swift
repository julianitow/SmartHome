//
//  AccessoriesManager.swift
//  SmartHome
//
//  Created by Julien Guillan on 09/02/2022.
//

import Foundation
import HomeKit
import CoreLocation
import SwiftUI

enum ValueType { case temperature, humidity}

class AccessoriesManager: NSObject, ObservableObject {
    
    var stateTemperature: Binding<Double>!
    var homeManager: HMHomeManager!
    var primaryHome: HMHome!
    var locationManager: CLLocationManager!
    
    var lights: [Light] = []
    
    var temperature = 20.0
    
    override init() {
        super.init()
        self.homeManager = HMHomeManager()
        self.homeManager.delegate = self
    }
    
    class func writeData(accessory: HMAccessory, accessoryType: AccessoryType, dataType: DataType, value: Any) {
        var characteristicType: String = ""
        if accessoryType == AccessoryType.light {
            if dataType == DataType.brightness {
                characteristicType = HMCharacteristicTypeBrightness
            } else if dataType == DataType.hue {
                characteristicType = HMCharacteristicTypeHue
                print("HUE: \(value)")
            }
        } else if accessoryType == AccessoryType.relay {
            characteristicType = HMCharacteristicTypePowerState
        }
        
        for service in accessory.services {
            for charateristic in service.characteristics {
                if charateristic.characteristicType == characteristicType {
                    charateristic.writeValue(value) { error in
                        if error != nil {
                            print("ERROR: \(accessory.name) -> \(error?.localizedDescription ?? "Unkown error")")
                        }
                    }
                }
            }
        }
    }
    
    func fetchAccessories() -> Void {
        guard let accessories = self.homeManager.primaryHome?.accessories else {
            print("Accessories nil")
            return
        }
        var i = 0
        for accessory in accessories {
            accessory.delegate = self
            for service in accessory.services {
                for characteristic in service.characteristics {
                    if characteristic.characteristicType == HMCharacteristicTypeHue {
                        let light = Light(id: i, accessory: accessory)
                        lights.append(light)
                        i += 1
                    }
                }
            }
        }
    }
    
    func fetchValues(valueType: ValueType, completion: @escaping (Float) -> Void) -> Void {
        guard let accessories = self.homeManager.primaryHome?.accessories else {
            print("Accessories nil")
            return
        }
        for accessory in accessories {
            if accessory.name.contains("temp") && valueType == ValueType.temperature {
                self.fetchTemp(thermometre: accessory) { temp in
                    completion(temp)
                }
            } else if accessory.name.contains("hum") && valueType == ValueType.humidity {
                self.fetchHum(hygrometre: accessory) { hum in
                    completion(hum)
                }
            }
        }
    }
    
    func fetchHum(hygrometre: HMAccessory, completion: @escaping (Float) -> Void) -> Void {
        for service in hygrometre.services {
            for characteristic in service.characteristics {
                if characteristic.characteristicType == HMCharacteristicTypeCurrentRelativeHumidity {
                    characteristic.readValue { err in
                        if err != nil {
                            print("ERROR: \(hygrometre.name) -> \(err?.localizedDescription ?? "Unknown error")")
                        }
                        let value = characteristic.value
                        let result = value as! Float
                        completion(result)
                    }
                }
            }
        }
    }
    
    func fetchTemp(thermometre: HMAccessory, completion: @escaping (Float) -> Void) -> Void {
        for service in thermometre.services {
            for characteristic in service.characteristics {
                if characteristic.characteristicType == HMCharacteristicTypeCurrentTemperature {
                    characteristic.readValue { err in
                        if err != nil {
                            print("ERROR: \(thermometre.name) -> \(err?.localizedDescription ?? "Unknown error")")
                        }
                        let value = characteristic.value
                        let result = value as! Float
                        completion(result)
                    }
                }
            }
        }
    }
    
}

extension AccessoriesManager: HMAccessoryDelegate {
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        print(accessory.name)
    }
}

extension AccessoriesManager: HMHomeManagerDelegate, HMHomeDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        self.primaryHome = self.homeManager.homes.first
        self.primaryHome.delegate = self
        self.fetchAccessories()
    }
}
