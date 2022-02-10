//
//  SettingsView.swift
//  SmartHome
//
//  Created by Julien Guillan on 10/02/2022.
//

import SwiftUI

struct SettingsView: View {
    @Binding var showHome: Bool
    @Binding var showAuto: Bool
    @Binding var showSettings: Bool
    @Binding var temperature: String
    
    var body: some View {
        if self.showAuto {
            AutoView(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings, temperatureMin: "", temperatureMax: "")
        } else if self.showSettings {
            VStack {
                Text("Settings")
                NavigationBar(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings)
            }
        } else if showHome {
            HomeView()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showHome: .constant(false), showAuto: .constant(false), showSettings: .constant(false), temperature: .constant("20.0"))
    }
}
