//
//  ContentView.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 08.03.23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var vehicleViewModel: VehicleViewModel
    @ObservedObject var expenseViewModel: ExpenseViewModel
    @ObservedObject var mapViewModel: MapViewModel
    var body: some View {
        TabView {
            ViewExpenses(expenseViewModel: expenseViewModel, vehicleViewModel: vehicleViewModel)
                .tabItem() {
                    Image(systemName: "eurosign.circle")
                    Text("Ausgaben")
                }
            ViewVehicle(vehicleViewModel: vehicleViewModel)
                .tabItem() {
                    Image(systemName: "car.2")
                    Text("Fahrzeuge")
                }
            ViewRides()
                .tabItem() {
                    Image(systemName: "road.lanes.curved.right")
                    Text("Fahrten")
                }
        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static let vehicleViewModel = VehicleViewModel()
    static let expenseViewModel = ExpenseViewModel()
    static let mapViewModel = MapViewModel()
    static var previews: some View {
        ContentView(vehicleViewModel: vehicleViewModel, expenseViewModel: expenseViewModel, mapViewModel: mapViewModel)
    }
}
