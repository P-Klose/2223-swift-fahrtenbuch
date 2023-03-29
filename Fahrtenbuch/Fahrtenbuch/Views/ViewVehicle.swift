//
//  ViewFahrzeuge.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//

import SwiftUI

struct ViewVehicle: View {
    var body: some View {
        NavigationView {
            ZStack {
                Image(systemName: "car.2.fill")
                    .foregroundColor(.black)
                    .font(.system(size: 100.0))
            }.navigationTitle("Fahrzeuge")
        }
    }
}

struct ViewVehicle_Previews: PreviewProvider {
    static var previews: some View {
        ViewVehicle()
    }
}
