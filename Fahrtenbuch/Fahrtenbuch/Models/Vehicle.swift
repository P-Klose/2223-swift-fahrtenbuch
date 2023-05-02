//
//  Vehicle.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//
import Foundation

struct VehicleModel {
    private (set) var vehicles = [Vehicle]()
    
    static let DATABASE = "http://localhost:3000/vehicles"
    
    mutating func importFromJson(data: Data) {
        if let dowloadedVehicles = try? JSONDecoder().decode([Vehicle].self, from: data){
            vehicles = dowloadedVehicles
        }else{
            
        }
    }
    mutating func choose(_ chosenVehicle: Vehicle){
        // change data
    }
}

struct Vehicle: Codable, Identifiable, Hashable {

    var id: Int?
    var vin: String
    var make: String
    var numberplate: String
    var model: String
    var milage: String
    var imageUrl: String
    
    func getName() -> String {
        return make + " " + model
    }
    
}

