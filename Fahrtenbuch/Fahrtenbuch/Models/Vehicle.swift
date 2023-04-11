//
//  Vehicle.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//
import Foundation

struct Vehicle: Identifiable, Hashable {
    
    var id: Int?
    var vin: String?
    var make: String
    var numberplate: String
    var model: String
    
}

