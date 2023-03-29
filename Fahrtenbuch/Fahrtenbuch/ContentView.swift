//
//  ContentView.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 08.03.23.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            ViewAusgaben()
                .tabItem() {
                    Image(systemName: "eurosign.circle")
                    Text("Ausgaben")
                }
            ViewFahrzeuge()
                .tabItem() {
                    Image(systemName: "car.2")
                    Text("Fahrzeuge")
                }
            ViewFahrten()
                .tabItem() {
                    Image(systemName: "road.lanes.curved.right")
                    Text("Fahrten")
                }
        }
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static let viewModel = ViewModel()
    static var previews: some View {
        ContentView()
    }
}
