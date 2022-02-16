//
//  Room.swift
//  SmartHome
//
//  Created by Julien Guillan on 16/02/2022.
//

import Foundation
import HomeKit

struct Room: Identifiable {
    var id: UUID
    var hmroom: HMRoom
    
    init(from hmroom: HMRoom) {
        self.id = UUID()
        self.hmroom = hmroom
    }
}
