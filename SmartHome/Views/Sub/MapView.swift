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
    @State var location: IdentifiableLocation!
    
    var body: some View {
        GeometryReader{ geometry in
            VStack {
                if displayMap {
                    Map(coordinateRegion: $locationManager.region, annotationItems: [location]) { loc in
                        MapAnnotation(coordinate: location.location) {
                            if location.isHome {
                                Image(systemName: "house.fill")
                                    .frame(width: 50, height: 50)
                            }
                             //().stroke(Color.blue)
                            
                        }
                    }
                    .frame(width:  geometry.size.width, height: geometry.size.height)
                }
            }.onChange(of: locationManager.location) { _ in
                LocationManager.getLocation(from: address) { loc in
                    self.location = IdentifiableLocation(lat: loc.coordinate.latitude, long: loc.coordinate.longitude, isHome: true)
                }
            }.onChange(of: location) { _ in
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
