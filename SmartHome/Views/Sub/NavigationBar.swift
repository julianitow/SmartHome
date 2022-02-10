//
//  NavigationBar.swift
//  SmartHome
//
//  Created by Julien Guillan on 10/02/2022.
//

import SwiftUI

struct NavigationBar: View {
    @Binding var showHome: Bool
    @Binding var showAuto: Bool
    @Binding var showSettings: Bool
    
    var body: some View {
        HStack {
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

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar(showHome: .constant(false), showAuto: .constant(false), showSettings: .constant(false))
    }
}
