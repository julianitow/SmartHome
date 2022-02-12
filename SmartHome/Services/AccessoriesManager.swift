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
    @Published var primaryHome: HMHome!
    var locationManager: CLLocationManager!
    
    @Published var temperature: Float = 20.0
    @Published var humidity: Float = 44
    @Published var lights: [Light] = []
    @Published var sockets: [Socket] = []
    
    @Published var accessories: [HMAccessory] = []
    @Published var updatedHome: Int = 0
    
    @State var minTemp: Float = 20.0
    @State var maxTemp: Float = 23.0
        
    override init() {
        super.init()
        self.homeManager = HMHomeManager()
        self.homeManager.delegate = self
    }

    class func writeData(accessory: HMAccessory, accessoryType: AccessoryType, dataType: DataType?, value: Any) {
        var characteristicType: String = ""
        if accessoryType == AccessoryType.light {
            if dataType == DataType.brightness {
                characteristicType = HMCharacteristicTypeBrightness
            } else if dataType == DataType.hue {
                characteristicType = HMCharacteristicTypeHue
            }
        } else if accessoryType == AccessoryType.socket {
            characteristicType = HMCharacteristicTypePowerState
        }
        
        for service in accessory.services {
            for charateristic in service.characteristics {
                if charateristic.characteristicType == characteristicType {
                    charateristic.writeValue(value) { error in
                        if error != nil {
                            print("ERROR: \(accessory.name) -> \(error?.localizedDescription ?? "Unkown error")")
                        } else {
                            print("Wrote: \(accessory.name) -> \(value)")
                        }
                    }
                }
            }
        }
    }
    
    func fetchAccessories() -> Void {
        for accessory in self.primaryHome.accessories {
            self.accessories.append(accessory)
        }
        self.fetchLights()
        self.fetchSockets()
    }
    
    func fetchLights() -> Void {
        guard let accessories = self.homeManager.primaryHome?.accessories else {
            print("Accessories nil lights")
            return
        }
        var i = 0
        for accessory in accessories {
            accessory.delegate = self
            for service in accessory.services {
                for characteristic in service.characteristics {
                    characteristic.enableNotification(true) { error in
                        if error != nil {
                            //print("ERROR: \(accessory.name) -> unable to enable notifications: \(error?.localizedDescription)")
                        }
                    }
                    if characteristic.characteristicType == HMCharacteristicTypeHue {
                        let light = Light(id: i, accessory: accessory)
                        self.lights.append(light)
                        i += 1
                    }
                }
            }
        }
    }
    
    func fetchSockets() -> Void {
        guard let accessories = self.homeManager.primaryHome?.accessories else {
            print("Accessories nil sockets")
            return
        }
        var i = 0
        // rewrite
        for accessory in accessories {
            print(accessory.name, accessory.model)
            if accessory.model == "switch" || accessory.name.contains("Bureau"){
                let socket = Socket(id: i, accessory: accessory)
                self.sockets.append(socket)
                i += 1
            }
        }
        //print(self.sockets)
    }
    
    func fetchBrightness(light: HMAccessory) -> Void {
        for service in light.services {
            for characteristic in service.characteristics {
                if characteristic.characteristicType == HMCharacteristicTypeBrightness {
                    for i in 0...lights.count {
                        if lights[i].accessory == light {
                            characteristic.readValue { _ in
                                let value = characteristic.value
                                let brightness = value as! Double
                                if brightness > 0 {
                                    self.lights[i].on = true
                                } else {
                                    self.lights[i].on = false
                                }
                            }
                        }
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
            if accessory.name.lowercased().contains("temp") && valueType == ValueType.temperature {
                self.fetchTemp(thermometre: accessory) { temp in
                    completion(temp)
                }
            } else if accessory.name.lowercased().contains("hum") && valueType == ValueType.humidity {
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
        //print(accessory.name, "->", characteristic.value)
        if characteristic.characteristicType == HMCharacteristicTypeCurrentTemperature {
            print("TEMPERATURE: \(characteristic.value as! Float)")
            let temp = characteristic.value as! Float
            self.temperature = temp
            if temp < self.minTemp {
                for socket in self.sockets {
                    if socket.accessory!.name == "Chauffage" {
                        AccessoriesManager.writeData(accessory: socket.accessory!, accessoryType: AccessoryType.socket, dataType: DataType.powerState, value: true)
                    }
                }
            } else if temp > self.maxTemp {
                for socket in self.sockets {
                    if socket.accessory!.name == "Chauffage" {
                        AccessoriesManager.writeData(accessory: socket.accessory!, accessoryType: AccessoryType.socket, dataType: DataType.powerState, value: false)
                    }
                }
            }
        } else if characteristic.characteristicType == HMCharacteristicTypeCurrentRelativeHumidity {
            print("HUMIDITY: \(characteristic.value as! Float)")
            let hum = characteristic.value as! Float
            self.humidity = hum
        } else if characteristic.characteristicType == HMCharacteristicTypePowerState {
            print(accessory.name, "->", characteristic.value!)
        }
    }
}

extension AccessoriesManager: HMHomeManagerDelegate, HMHomeDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        self.updatedHome += 1
        if manager.homes.first != nil {
            //manager.removeHome(manager.homes.first!) { _ in}
            self.primaryHome = self.homeManager.homes.first
            self.primaryHome.delegate = self
            self.fetchAccessories()
        }
    }
}
