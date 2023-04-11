//
//  FahrtenbuchApp.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 08.03.23.
//

import SwiftUI

@main
struct FahrtenbuchApp: App {
    let viewModel = HomeViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
