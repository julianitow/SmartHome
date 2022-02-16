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

class AccessoriesManager: NSObject, ObservableObject {
    
    @Published var primaryHome: HMHome!
    
    @Published var temperature: Float = -100.0
    @Published var humidity: Int = -100
    
    @Published var lights: [Light] = []
    @Published var sockets: [Socket] = []
    @Published var rooms: [Room] = []
    @Published var accessories: [Accessory] = []
    @Published var updatedHome: Int = 0
    
    @Published var minTemp: Float
    @Published var maxTemp: Float
    
    @Published var distanceFromHome: Int
    
    @Published var onChangeSocketId: [UUID: Bool]!
    
    var homeManager: HMHomeManager!
            
    override init() {
        minTemp = KeychainManager.getMinTemp() ?? 19.0
        maxTemp = KeychainManager.getMaxTemp() ?? 22.0
        self.distanceFromHome = KeychainManager.getDistanceFromHome() ?? 20
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
            }
        }
        
        if dataType == DataType.powerState {
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
    
    class func fetchCharacteristicValue(accessory: HMAccessory, dataType: DataType, completion: @escaping (Any) -> Void) {
        var characteristicType = ""
        
        switch dataType {
        case .hue:
            characteristicType = HMCharacteristicTypeHue
            break
        case .brightness:
            characteristicType = HMCharacteristicTypeBrightness
            break
        case .powerState:
            characteristicType = HMCharacteristicTypePowerState
            break
        case .temperature:
            characteristicType = HMCharacteristicTypeCurrentTemperature
            break
        case .humidity:
            characteristicType = HMCharacteristicTypeCurrentRelativeHumidity
        }
        
        for service in accessory.services {
            for characteristic in service.characteristics {
                if characteristic.characteristicType == characteristicType {
                    characteristic.readValue { error in
                        if error != nil {
                            print("ERROR: \(accessory.name) -> \(error?.localizedDescription ?? "unkown error")")
                            return
                        }
                        
                        let res = characteristic.value
                        completion(res!)
                    }
                }
            }
        }
    }
    
    func fetchValues(dataType: DataType, completion: @escaping (Any) -> Void) {
        guard let accessories = self.homeManager.primaryHome?.accessories else {
                    print("Accessories nil")
                    return
                }
        for accessory in accessories {
            if accessory.name.lowercased().contains("temp") && dataType == .temperature {
                AccessoriesManager.fetchCharacteristicValue(accessory: accessory, dataType: .temperature) { temp in
                    completion(temp)
                }
            } else if accessory.name.lowercased().contains("hum") && dataType == .humidity {
                AccessoriesManager.fetchCharacteristicValue(accessory: accessory, dataType: .humidity) { hum in
                    completion(hum)
                }
            }
        }
    }
    
    func clear() {
        self.primaryHome = nil
        self.accessories = []
        self.lights = []
        self.sockets = []
        self.rooms = []
    }
    
    func fetchHome() {
        self.fetchAccessories()
        self.fetchRooms()
    }
    
    func fetchRooms() {
        self.rooms = []
        for hmroom in self.primaryHome.rooms {
            let room = Room(from: hmroom)
            self.rooms.append(room)
        }
    }
    
    func fetchAccessories() -> Void {
        self.lights = []
        self.sockets = []
        self.accessories = []
        for accessory in self.primaryHome.accessories {
            accessory.delegate = self
            for service in accessory.services {
                for characteristic in service.characteristics {
                    characteristic.enableNotification(true) { _ in }
                    
                    //search for thermometer or hygrometer
                    if characteristic.characteristicType == HMCharacteristicTypeCurrentTemperature {
                        self.accessories.append(Thermometre(accessory: accessory))
                    } else if characteristic.characteristicType == HMCharacteristicTypeCurrentRelativeHumidity {
                        self.accessories.append(Hygrometre(accessory: accessory))
                    }
                }
            }
        }
        self.fetchLights()
        self.fetchSockets()
    }
    
    func fetchLights() -> Void {
        guard let accessories = self.homeManager.primaryHome?.accessories else {
            print("Accessories nil lights")
            return
        }
        for accessory in accessories {
            for service in accessory.services {
                for characteristic in service.characteristics {
                    if characteristic.characteristicType == HMCharacteristicTypeHue {
                        var light = Light(accessory: accessory)
                        characteristic.readValue { error in
                            if error != nil {
                                print(error?.localizedDescription ?? "Unknown Error")
                            } else {
                                light.hue = characteristic.value as! Float
                            }
                        }
                        for characteristic in service.characteristics {
                            if characteristic.characteristicType == HMCharacteristicTypeBrightness {
                                characteristic.readValue { error in
                                    if error != nil {
                                        print(error?.localizedDescription ?? "Unknown Error")
                                    } else {
                                        light.brightness = characteristic.value as! Float
                                    }
                                }
                            }
                        }
                        self.accessories.append(light)
                        self.lights.append(light)
                    }
                }
            }
        }
    }
    
    func removeRoom(at offsets: IndexSet) {
        offsets.forEach({ i in
            let room = self.rooms[i]
            self.primaryHome.removeRoom(room.hmroom) { error in
                if error != nil {
                    print("ERROR: while deleting \(room.hmroom.name) \(error?.localizedDescription ?? "unkown error") ")
                }
                self.rooms.remove(at: i)
            }
        })
    }
    
    func removeAccessory(at offsets: IndexSet) {
        offsets.forEach({ i in
            let accessory = self.accessories[i]
            self.primaryHome.removeAccessory(accessory.accessory) { error in
                if error != nil {
                    print("ERROR: while deleting \(accessory.accessory.name) \(error?.localizedDescription ?? "unkown error") ")
                }
                self.fetchAccessories()
            }
        })
    }
    
    func fetchSockets() -> Void {
        guard let accessories = self.homeManager.primaryHome?.accessories else {
            print("Accessories nil sockets")
            return
        }
        for accessory in accessories {
            
            if accessory.model?.lowercased() == "switch" || accessory.name.lowercased().contains("prise"){
                let socket = Socket(accessory: accessory)
                self.accessories.append(socket)
                self.sockets.append(socket)
            }
        }
    }
    
    func checkDistanceFromHome(distance: CLLocationDistance) {
        let currentDistance = Int(distance)
        if currentDistance >= self.distanceFromHome {
            for var light in self.lights {
                light.on = false
                AccessoriesManager.writeData(accessory: light.accessory, accessoryType: AccessoryType.light, dataType: DataType.powerState, value: light.on)
            }
        }
    }    
}

extension AccessoriesManager: HMAccessoryDelegate {
    
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        if characteristic.characteristicType == HMCharacteristicTypeCurrentTemperature {
            let temp = (characteristic.value as? NSNumber)!.floatValue
            self.temperature = temp
            if temp < self.minTemp {
                for var socket in self.sockets {
                    if socket.accessory.name == "Relais" || socket.accessory.name == "Chauffage" {
                        socket.on = true
                        AccessoriesManager.writeData(accessory: socket.accessory, accessoryType: AccessoryType.socket, dataType: DataType.powerState, value: socket.on)
                    }
                }
            } else if temp > self.maxTemp {
                for var socket in self.sockets {
                    if socket.accessory.name == "Relais" || socket.accessory.name == "Chauffage" {
                        socket.on = false
                        AccessoriesManager.writeData(accessory: socket.accessory, accessoryType: AccessoryType.socket, dataType: DataType.powerState, value: socket.on)
                    }
                }
            }
        } else if characteristic.characteristicType == HMCharacteristicTypeCurrentRelativeHumidity {
            let hum = characteristic.value as! Int
            self.humidity = hum
        } else if characteristic.characteristicType == HMCharacteristicTypePowerState {
            for var socket in self.sockets {
                if socket.accessory == accessory {
                    let state = characteristic.value as! Bool
                    socket.on = state
                    self.onChangeSocketId = [socket.id: socket.on]
                }
            }
            for var light in self.lights {
                if light.accessory == accessory {
                    let state = characteristic.value as! Bool
                    light.on = state
                    self.onChangeSocketId = [light.id: light.on]
                }
            }
        }
    }
}

extension AccessoriesManager: HMHomeManagerDelegate, HMHomeDelegate {
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        print("DELEGATE UPDATE HOMES")
        if manager.homes.first != nil {
            self.primaryHome = self.homeManager.homes.first
            self.primaryHome.delegate = self
            self.fetchHome()
        }
    }
    
    func homeManager(_ manager: HMHomeManager, didAdd home: HMHome) {
        print("DELEGATE ADD PRIMARY HOME")
        self.updatedHome += 1
    }
    
    func homeManager(_ manager: HMHomeManager, didRemove home: HMHome) {
        print("DELEGATE DIDRAMOVE HOME")
        self.primaryHome = nil
        self.updatedHome += 1
    }
    
    func homeManagerDidUpdatePrimaryHome(_ manager: HMHomeManager) {
        if manager.homes.first != nil {
            self.primaryHome = manager.homes.first
            self.primaryHome.delegate = self
            print("DELEGATE UPDATE PM: \(self.primaryHome.name)")
        }
    }
    
    func home(_ home: HMHome, didRemove accessory: HMAccessory) {
        print("DELEGATE DIDREMOVE", accessory.name)
    }
    
    func home(_ home: HMHome, didAdd accessory: HMAccessory) {
        self.fetchAccessories()
        self.updatedHome += 1
    }
    
    func home(_ home: HMHome, didAdd room: HMRoom, to: HMZone) {
        self.fetchRooms()
    }
}
