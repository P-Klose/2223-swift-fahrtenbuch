//
//  FahrtenbuchApp.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 08.03.23.
//

import SwiftUI

@main
struct FahrtenbuchApp: App {
    let vehicleViewModel = VehicleViewModel()
    let expenseViewModel = ExpenseViewModel()
    let mapViewModel = MapViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView(vehicleViewModel: vehicleViewModel, expenseViewModel: expenseViewModel, mapViewModel: mapViewModel)
        }
    }
}
