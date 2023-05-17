//
//  DriveAttributes.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 16.05.23.
//

import ActivityKit
import SwiftUI

struct DriveAttributes: ActivityAttributes {
    public typealias DriveState = ContentState
    
    public struct ContentState: Codable, Hashable {
        var startTime: Date
        var distance: Double
    }
    
    var vehicleName: String
}
