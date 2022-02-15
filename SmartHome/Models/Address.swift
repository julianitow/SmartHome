//
//  Address.swift
//  SmartHome
//
//  Created by Julien Guillan on 10/02/2022.
//

import Foundation

struct Address: Encodable, Decodable, Equatable {
    var id = 1
    var country: String!
    var postalCode: Int!
    var street: String!
    var number: Int!
    var city: String!
    var string: String { "\(self.number!) \(self.street!), \(self.city!), \(self.country!) \(self.postalCode!)"}
    var isValid: Bool {
        if self.country == nil || self.postalCode == nil || self.street == nil || self.number == nil || self.city == nil {
            return false
        }
        return true
    }
}
