//
//  Address.swift
//  SmartHome
//
//  Created by Julien Guillan on 10/02/2022.
//

import Foundation

struct Address {
    var country: String!
    var postalCode: Int!
    var street: String!
    var number: Int!
    var city: String!
    var string: String { "\(self.number!) \(self.street!), \(self.city!), \(self.country!) \(self.postalCode!)"}
}
