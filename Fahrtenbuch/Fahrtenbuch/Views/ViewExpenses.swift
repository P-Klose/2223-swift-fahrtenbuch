//
//  ViewAusgaben.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//

import SwiftUI

struct ViewExpenses: View {
    var body: some View {
        NavigationView {
            ZStack {
                Image(systemName: "eurosign.circle.fill")
                    .foregroundColor(.black)
                    .font(.system(size: 100.0))
            }.navigationTitle("Ausgaben")
        }
    }
}

struct ViewExpenses_Previews: PreviewProvider {
    static var previews: some View {
        ViewExpenses()
    }
}
