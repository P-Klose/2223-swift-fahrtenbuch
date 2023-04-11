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
                Map(coordinateRegion: $mapViewModel.region, showsUserLocation: true)
                    .accentColor(Color(.systemBlue))
                    .onAppear{
                        mapViewModel.checkIfLocationServicesIsEnabled()
                    }
            }.navigationTitle("Fahrten")
        }
    }
}

struct ViewRides_Previews: PreviewProvider {
    static var previews: some View {
        ViewRides()
    }
}
