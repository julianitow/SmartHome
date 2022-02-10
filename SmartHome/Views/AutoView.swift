//
//  AutoView.swift
//  SmartHome
//
//  Created by Julien Guillan on 10/02/2022.
//

import SwiftUI

struct AutoView: View {
    @EnvironmentObject var accessoriesManager: AccessoriesManager
    @Binding var showHome: Bool
    @Binding var showAuto: Bool
    @Binding var showSettings: Bool
    @State var temperatureMin: String
    @State var temperatureMax: String
    @FocusState var tempMinFocused: Bool
    @FocusState var tempMaxFocused: Bool
    @State var minTemp: Float = 20.0
    @State var maxTemp: Float = 23.0
    
    var body: some View {
        if self.showAuto {
            VStack {
                HStack {
                    Spacer()
                    Text("Automatisation")
                        .fontWeight(.semibold)
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                        .padding()
                    Spacer()
                }
                VStack {
                    Text("Chauffage")
                        .fontWeight(.semibold)
                        .font(.body)
                        .foregroundColor(.blue)
                        .padding(.leading, 10)
                    HStack {
                        Text("Temperature min:")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                        TextField("ex: 20.0", text: $temperatureMin)
                            .focused($tempMinFocused)
                            .keyboardType(.numberPad)
                        Button("Valider") {
                            tempMinFocused.toggle()
                            self.minTemp = Float(self.temperatureMin)!
                            self.accessoriesManager.minTemp = self.minTemp
                        }
                    }
                    HStack {
                        Text("Temperature max:")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                        TextField("ex: 23.0", text: $temperatureMax)
                            .focused($tempMaxFocused)
                            .keyboardType(.numberPad)
                        Button("Valider") {
                            tempMaxFocused.toggle()
                            self.maxTemp = Float(self.temperatureMax)!
                            self.accessoriesManager.maxTemp = self.maxTemp
                        }
                    }
                    Spacer()
                }
                NavigationBar(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings)
            }
        } else if self.showSettings {
            //SettingsView(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings)
        } else if showHome {
            HomeView(minTemp: self.minTemp)
        }
    }
}

struct AutoView_Previews: PreviewProvider {
    static var previews: some View {
        AutoView(showHome: .constant(false), showAuto: .constant(false), showSettings: .constant(false), temperatureMin: "20.0", temperatureMax: "23.0")
    }
}
