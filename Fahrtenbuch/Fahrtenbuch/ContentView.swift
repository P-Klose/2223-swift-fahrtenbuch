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
    @State private var selectedTab = 1
    var body: some View {
        TabView (selection: $selectedTab) {
            ViewExpenses(expenseViewModel: expenseViewModel, vehicleViewModel: vehicleViewModel)
                .tabItem() {
                    Image(systemName: "eurosign.circle")
                    Text("Ausgaben")
                }
                .tag(0)
                .onAppear(perform: { tabColor = .green })
            ViewVehicle(vehicleViewModel: vehicleViewModel, tvm: mapViewModel.tripViewModel)
                .tabItem() {
                    Image(systemName: "car.2")
                    Text("Fahrzeuge")
                }
                .tag(1)
                .onAppear(perform: { tabColor = .pink })
            ViewRides(mapViewModel: mapViewModel, vehicleViewModel: vehicleViewModel)
                .tabItem() {
                    Image(systemName: "map")
                    Text("Aufzeichnen")
                }
                .tag(2)
                .onAppear(perform: { tabColor = .blue })
            ViewTrips(tvm: mapViewModel.tripViewModel, vvm: vehicleViewModel)
                .tabItem {
                    Image(systemName: "road.lanes.curved.right")
                    Text("Fahrten")
                }
                .tag(3)
                .onAppear(perform: { tabColor = .pink })
        }
        .tint(tabColor)
        .onAppear{
            expenseViewModel.downloadAllExpenses {}
            mapViewModel.tripViewModel.downloadAllTrips {}
            vehicleViewModel.downloadAllVehicles(){}
            selectedTab = 1
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
