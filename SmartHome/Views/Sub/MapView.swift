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
    
    var body: some View {
        VStack {
            if self.locationManager.hasSetRegion {
                //Map(coordinateRegion: $locationManager.region)
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
