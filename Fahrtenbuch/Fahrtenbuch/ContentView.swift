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
    @ObservedObject var viewModel: HomeViewModel
    @State private var tabColor: Color = .accentColor
    var body: some View {
        TabView {
            ViewExpenses(expenseViewModel: expenseViewModel, vehicleViewModel: vehicleViewModel)
                .tabItem() {
                    Image(systemName: "eurosign.circle")
                    Text("Ausgaben")
                }.onAppear(perform: { tabColor = .green })
            ViewVehicle(vehicleViewModel: vehicleViewModel)
                .tabItem() {
                    Image(systemName: "car.2")
                    Text("Fahrzeuge")
                }.onAppear(perform: { tabColor = .pink })
            ViewRides(mapViewModel: mapViewModel, vehicleViewModel: vehicleViewModel)
                .tabItem() {
                    Image(systemName: "map")
                    Text("Aufzeichnen")
                }.onAppear(perform: { tabColor = .blue })
            ViewTrips(tvm: mapViewModel.tripViewModel, vvm: vehicleViewModel)
                .tabItem {
                    Image(systemName: "road.lanes.curved.right")
                    Text("Fahrten")
                }.onAppear(perform: { tabColor = .pink })
        }
        .tint(tabColor)
        .onAppear{
            expenseViewModel.downloadAllExpenses {}
            mapViewModel.tripViewModel.downloadAllTrips {}
            vehicleViewModel.downloadAllVehicles(){}
        }
        .task {
            viewModel.checkForPremission()
        }
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static let vehicleViewModel = VehicleViewModel()
    static let expenseViewModel = ExpenseViewModel()
    static let mapViewModel = MapViewModel()
    static let viewModel = HomeViewModel()
    static var previews: some View {
        ContentView(vehicleViewModel: vehicleViewModel, expenseViewModel: expenseViewModel, mapViewModel: mapViewModel, viewModel: viewModel)
    }
}
