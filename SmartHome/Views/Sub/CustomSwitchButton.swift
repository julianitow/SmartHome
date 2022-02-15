//
//  CustomButton.swift
//  SmartHome
//
//  Created by Julien Guillan on 08/02/2022.
//

import SwiftUI

struct CustomSwitchButton: View {
    @EnvironmentObject var accessoriesManager: AccessoriesManager
    @State var socket: Accessory
    @State var isOn: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName:"power")
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.top, 20)
                .foregroundColor(.white)
            Text(socket.accessory.name)
                .frame(minWidth: 100, idealWidth: 100, maxWidth: 100, minHeight: 60, idealHeight: 60, maxHeight: 75, alignment: .center)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .offset(y: -10)
        }
        .background(Color(socket.on ? .systemRed : .systemGray4))
        .cornerRadius(15)
        .padding([.top, .bottom], 10)
        .onTapGesture {
            self.socket.on.toggle()
            AccessoriesManager.writeData(accessory: socket.accessory, accessoryType: AccessoryType.socket, dataType: DataType.powerState, value: socket.on)
            AccessoriesManager.fetchCharacteristicValue(accessory: socket.accessory, dataType: DataType.powerState) { state in
                self.socket.on = state as! Bool
                self.isOn = state as! Bool
            }
        }
        .onChange(of: accessoriesManager.onChangeSocketId) { _ in
            if accessoriesManager.onChangeSocketId.first?.key == socket.id {
                socket.on = accessoriesManager.onChangeSocketId.first!.value
            }
        }
        .onAppear {
            AccessoriesManager.fetchCharacteristicValue(accessory: socket.accessory, dataType: DataType.powerState) { state in
                self.socket.on = state as! Bool
                self.isOn = state as! Bool
            }
        }
    }
}
