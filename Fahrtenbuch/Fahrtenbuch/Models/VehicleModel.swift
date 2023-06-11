//
//  Vehicle.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//
import Foundation
import OSLog

struct VehicleModel {
    private (set) var vehicles = [Vehicle]()
    
    static let DATABASE = "http://localhost:3000/vehicles"
    let LOG = Logger()
    
    mutating func importFromJson(data: Data) {
        if let dowloadedVehicles = try? JSONDecoder().decode([Vehicle].self, from: data){
            vehicles = dowloadedVehicles
        }else{
            
        }
    }
    mutating func choose(_ chosenVehicle: Vehicle){
        // change data
    }
    mutating func updateMillage(vehicleId: Int, toAddMilage: Double) -> Vehicle? {
        LOG.info("vehicleid: \(vehicleId)")
        if let index = vehicles.firstIndex(where: { $0.id == vehicleId }) {
            LOG.info("Index: \(index)")
//            LOG.info("Vehicleid at index: \(self.vehicles[index].getFullName())")
            if let mileage = Double(vehicles[index].milage) {
                let newMileage = mileage + (toAddMilage / 1000)
                var vehicle = vehicles[index]
                vehicle.milage = String(newMileage)
                return vehicle
            } else {
                self.LOG.error("🔴 Something is wrong with Millage")
            }
        } else {
            self.LOG.error("🔴 Vehicle couldn't be found")
        }
        return nil
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
    var vehicleType: String?
    var fuelType: String?
    
    func getName() -> String {
        return make + " " + model
    }
    func getFullName() -> String {
        return "\(id ?? -1) " + make + " " + model
    }
    func getSortName() -> String {
        return numberplate + " " + make + " " + model
    }
    func getId() -> Int {
        return id ?? -1
    }
    
}
extension Date {
    static func from(year: Int, month: Int) -> Date{
        let components = DateComponents(year: year, month: month)
        return Calendar.current.date(from: components)!
    }
}

