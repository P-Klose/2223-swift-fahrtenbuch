//
//  ViewFahrten.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//
import SwiftUI
import MapKit

struct ViewRides: View {
    
    @StateObject private var mapViewModel = MapViewModel()
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                MapView(routeOverlay: mapViewModel.routeOverlay, region: mapViewModel.region)
            }.navigationTitle("Fahrten")
        }
    }
}

struct ViewRides_Previews: PreviewProvider {
    static var previews: some View {
        ViewRides()
    }
}


