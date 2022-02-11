//
//  IdentifiablePlace.swift
//  SmartHome
//
//  Created by Julien Guillan on 10/02/2022.
//

import Foundation
import MapKit

struct IdentifiableLocation: Identifiable, Equatable {
    let id: UUID
    let location: CLLocationCoordinate2D
    var isHome: Bool
    init(id: UUID = UUID(), lat: Double, long: Double, isHome: Bool) {
        self.id = id
        self.isHome = isHome
        self.location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
    }
    
    static func == (lhs: IdentifiableLocation, rhs: IdentifiableLocation) -> Bool {
        let lhsLat = Float(String(format: "%.3f", lhs.location.latitude))
        let rhsLast = Float(String(format: "%.3f", rhs.location.latitude))
        let lhsLong = Float(String(format: "%.3f", lhs.location.longitude))
        let rhsLong = Float(String(format: "%.3f", rhs.location.longitude))
        if lhsLat == rhsLast && lhsLong == rhsLong {
            return true
        } else {
            return false
        }
    }
}
