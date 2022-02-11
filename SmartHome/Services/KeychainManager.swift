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
    
    static func clearKeychain() {
        KeychainSwift().clear()
    }
}
