//
//  ContentView.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 08.03.23.
//

import SwiftUI
import UserNotifications
import CoreBluetooth

class BluetoothViewModel: NSObject, CBCentralManagerDelegate, ObservableObject {
    
    let centralManager = CBCentralManager(delegate: nil, queue: nil)
    private var peripherals: [CBPeripheral] = []
    let targetDeviceUUID = UUID(uuidString: "TARGET_DEVICE_UUID_DAAA")!
    @Published var peripheralNames: [String] = []
    
    override init() {
        super.init()
        centralManager.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
            if central.state == .poweredOn {
                centralManager.scanForPeripherals(withServices: nil, options: nil)
            }
        }

        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            if peripheral.identifier == targetDeviceUUID {
                centralManager.stopScan()
                showNotification()
            }
        }

        func showNotification() {
            let content = UNMutableNotificationContent()
            content.title = "Bluetooth Connection Established"
            content.body = "You are now connected to the target Bluetooth device"
            let request = UNNotificationRequest(identifier: "bluetoothConnection", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    
    let bluetoothManager = BluetoothViewModel()
    
}


/*
extension BluetoothViewModel: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if central.state == .poweredOn {
            self.centralManager?.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if peripheral.identifier == targetDeviceUUID {
            centralManager?.stopScan()
                    showNotification()
                }
        
       /* if !peripherals.contains(peripheral) {
            self.peripherals.append(peripheral)
            self.peripheralNames.append(peripheral.name ?? "unnamed device")
        }*/
        
    }
    
    
    
}
*/
struct ContentView: View {
    @ObservedObject private var bluetoothViewModel = BluetoothViewModel()
    
    var body: some View {
        NavigationView {
            List(bluetoothViewModel.peripheralNames, id: \.self) {
                peripheral in Text(peripheral)
            }
            .navigationTitle("Peripherals")
    }
    
    /*@ObservedObject var viewModel: ViewModel
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .task {
            viewModel.checkForPremission()
        }*/
    }
}

struct ContentView_Previews: PreviewProvider {
    //static let viewModel = ViewModel()
    static var previews: some View {
        ContentView()
        //ContentView(viewModel: viewModel)
    }
}
