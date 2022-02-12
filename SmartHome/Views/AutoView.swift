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
                Text("Automatisation")
                    .fontWeight(.semibold)
                    .font(.system(size: 30))
                Form{
                    Section(header: Text("Chauffage")) {
                        HStack {
                            Image(systemName: "snowflake").foregroundColor(Color.blue)
                            Text("Température min :")
                            Stepper("\(Int(minTemp)) °C", value: $minTemp).foregroundColor(.blue)
                        }
                        HStack {
                            Image(systemName: "sun.max").foregroundColor(Color.red)
                            Text("Température max :")
                            Stepper("\(Int(maxTemp)) °C", value: $maxTemp).foregroundColor(.red)
                        }
                    }
                    
                    Section(header: Text("Localisation")) {
                        HStack {
                            Image(systemName: "location.fill").foregroundColor(Color.green)
                            Text("Rayon domicile :")
                            Stepper("\(Int(minTemp)) m", value: $minTemp, step: 5)
                        }
                    }
                }
            }
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
        } else if self.showSettings {
            //SettingsView(showHome: $showHome, showAuto: $showAuto, showSettings: $showSettings)
        } else if showHome {
            HomeView()
        }
    }
}

// struct AutoView_Previews: PreviewProvider {
   // static var previews: some View {
     //   AutoView(showHome: .constant(false), showAuto: .constant(false), showSettings: .constant(false), temperatureMin: "20.0", temperatureMax: "23.0")
    //}
// }




    //VStack {
    //    VStack {
    //        Text("Chauffage")
    //            .fontWeight(.semibold)
    //            .font(.body)
    //            .foregroundColor(.black)
    //            .frame(alignment: .center)
    //            .padding(.top, 25)
    //        Divider()
    //        HStack {
    //            Text("Temperature min:")
    //                .fontWeight(.thin)
    //                .foregroundColor(.black)
    //                .padding(.leading, 20)
    //            TextField("ex: 20.0", text: $temperatureMin)
    //                .focused($tempMinFocused)
    //                .keyboardType(.numberPad)
    //                .background(Color.red)
    //                .cornerRadius(5)
    //            Button("Valider") {
    //                tempMinFocused.toggle()
    //                self.minTemp = Float(self.temperatureMin)!
    //                self.accessoriesManager.minTemp = self.minTemp
    //            }
    //        }
    //        HStack {
    //            Text("Temperature max:")
    //                .fontWeight(.semibold)
    //                .foregroundColor(.white)
    //                .padding(.leading, 20)
    //            TextField("ex: 23.0", text: $temperatureMax)
    //                .focused($tempMaxFocused)
    //                .keyboardType(.numberPad)
    //            Button("Valider") {
    //                tempMaxFocused.toggle()
    //                self.maxTemp = Float(self.temperatureMax)!
    //                self.accessoriesManager.maxTemp = self.maxTemp
    //            }
    //        }
    //    }
    //    VStack {
    //        Text("Localisation")
    //            .fontWeight(.semibold)
    //            .font(.body)
    //            .foregroundColor(.black)
    //            .frame(alignment: .center)
    //            .padding(.top, 25)
    //        Divider()
    //    }
    //    Spacer()
//
