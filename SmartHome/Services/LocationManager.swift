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
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.828564, longitude: 2.322384), latitudinalMeters: 750, longitudinalMeters: 750)
    
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
    
    class func getLocation(from address: Address, completion: @escaping (CLLocation) -> Void) -> Void {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address.string) { (placemarks, err) in
            if err != nil {
                print("ERROR", err?.localizedDescription ?? "unknown error")
                return
            }
            if placemarks == nil {
                print("ERROR placemarks nil")
            }
            
            let location = placemarks?.first?.location
            completion(location!)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location
            
            if !hasSetRegion {
                self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 750, longitudinalMeters: 750)
                print(region)
                self.hasSetRegion = true
            }
        }
    }
}
