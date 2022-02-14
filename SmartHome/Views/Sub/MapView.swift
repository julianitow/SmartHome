//
//  MapView.swift
//  SmartHome
//
//  Created by Julien Guillan on 10/02/2022.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var locationManager: LocationManager
    @State var displayMap: Bool = false
    @State var displayHome: Bool = false
    @State var address: Address
    @State var homeLocation: IdentifiableLocation!
    @State var currentLocation: IdentifiableLocation!
    
    var body: some View {
        GeometryReader{ geometry in
            VStack {
                if displayMap {
                    Map(coordinateRegion: $locationManager.region, annotationItems: [homeLocation, currentLocation]) { loc in
                        MapAnnotation(coordinate: loc.location) {
                            if loc.isHome {
                                Image(systemName: "house.fill")
                                    .frame(width: 50, height: 50)
                            } else {
                                Image(systemName: "person.fill")
                                    .frame(width: 50, height: 50)
                            }
                        }
                    }
                    .frame(width:  geometry.size.width, height: geometry.size.height)
                }
            }.onChange(of: locationManager.currentLocation) { _ in
                LocationManager.getLocation(from: address) { loc in
                    self.homeLocation = IdentifiableLocation(lat: loc.coordinate.latitude, long: loc.coordinate.longitude, isHome: true)
                }
                let loc = locationManager.currentLocation
                self.currentLocation = IdentifiableLocation(lat: (loc?.coordinate.latitude)!, long: (loc?.coordinate.longitude)!, isHome: false)
            }.onChange(of: homeLocation) { _ in
                self.displayMap = true
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(address: Address(country: "France", postalCode: 75014, street: "Villa d'Alésia", number: 20, city: "Paris"))
    }
}
