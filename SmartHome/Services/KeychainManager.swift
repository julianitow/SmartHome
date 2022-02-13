//
//  KeyChainManager.swift
//  SmartHome
//
//  Created by Julien Guillan on 11/02/2022.
//

import Foundation

struct KeychainManager {
    static func storeAddress(address: Address){
        if let addr = try? JSONEncoder().encode(address) {
            KeychainSwift().set(addr, forKey: "homeAddress")
        }
    }
    
    static func getHomeAddress() -> Address? {
        if let addrData = KeychainSwift().getData("homeAddress"), let homeAddr = try? JSONDecoder().decode(Address.self, from: addrData) {
            return homeAddr
        }
        return nil
    }
    
    static func storeMinTemp(minTemp: Float) {
        if let min = try? JSONEncoder().encode(minTemp) {
            KeychainSwift().set(min, forKey: "minTemp")
        }
    }
    
    static func getMinTemp() -> Float? {
        if let minTempData = KeychainSwift().getData("minTemp"), let minTemp = try? JSONDecoder().decode(Float.self, from: minTempData) {
            return minTemp
        }
        return nil
    }
    
    static func storeMaxTemp(maxTemp: Float) {
        if let max = try? JSONEncoder().encode(maxTemp) {
            KeychainSwift().set(max, forKey: "maxTemp")
        }
    }
    
    static func getMaxTemp() -> Float? {
        if let maxTempData = KeychainSwift().getData("maxTemp"), let maxTemp = try? JSONDecoder().decode(Float.self, from: maxTempData) {
            return maxTemp
        }
        return nil
    }
    
    static func clearKeychain() {
        KeychainSwift().clear()
    }
}
