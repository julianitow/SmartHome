//
//  LocationManager.swift
//  SmartHome
//
//  Created by Julien Guillan on 10/02/2022.
//

import Foundation
import MapKit

final class LocationManager: NSObject, ObservableObject {
    @Published var location: CLLocation?
    @Published var region: MKCoordinateRegion?
    
    var locationManager = CLLocationManager()
    var hasSetRegion = false
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location
            
            if !hasSetRegion {
                self.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
                self.hasSetRegion = true
            }
        }
    }
}
