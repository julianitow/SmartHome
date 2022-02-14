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
 
    var body: some View {
        VStack {
            Text("Automatisation")
                .fontWeight(.semibold)
                .font(.system(size: 30))
            Form{
                Section(header: Text("Chauffage")) {
                    HStack {
                        Image(systemName: "snowflake").foregroundColor(.cyan)
                        Text("Température min :")
                        Stepper("\(Int(accessoriesManager.minTemp)) °C", value: $accessoriesManager.minTemp, in: Float(Int.min)...accessoriesManager.maxTemp)
                            .foregroundColor(.cyan)
                    }
                    HStack {
                        Image(systemName: "flame.fill").foregroundColor(Color.red)
                        Text("Température max :")
                        Stepper("\(Int(accessoriesManager.maxTemp)) °C", value: $accessoriesManager.maxTemp, in: accessoriesManager.minTemp...Float(Int.max))
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Localisation")) {
                    HStack {
                        Image(systemName: "location.fill").foregroundColor(Color.green)
                        Text("Rayon domicile :")
                        Stepper("\(accessoriesManager.distanceFromHome) m", value: $accessoriesManager.distanceFromHome, in: 10...500, step: 10)
                    }
                }
            }
        }
        .onChange(of: accessoriesManager.maxTemp , perform: { _ in
            KeychainManager.storeMaxTemp(maxTemp: accessoriesManager.maxTemp)
        })
        .onChange(of: accessoriesManager.minTemp, perform: { _ in
            KeychainManager.storeMinTemp(minTemp: accessoriesManager.minTemp)
        })
        .onChange(of: accessoriesManager.distanceFromHome, perform: { _ in
            KeychainManager.storeDistanceFromHome(distance: accessoriesManager.distanceFromHome)
        })
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Image(systemName: "house")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        showHome = true
                        showAuto = false
                        showSettings = false
                    }
                Spacer()
                Image(systemName: "clock")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.blue)
                    .onTapGesture {
                        showHome = false
                        showAuto = true
                        showSettings = false
                    }
                Spacer()
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        showHome = false
                        showAuto = false
                        showSettings = true
                    }
                Spacer()
            }
        }
    }
}
