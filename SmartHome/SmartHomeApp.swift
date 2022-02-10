//
//  SmartHomeApp.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import SwiftUI

@main
struct SmartHomeApp: App {
    var accessoriesManager = AccessoriesManager()
    var locationManager = LocationManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(accessoriesManager)
                .environmentObject(locationManager)
        }
    }
}
