//
//  TripModel.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 09.05.23.
//

import Foundation
import OSLog

struct TripModel {
    //typealias Gas = 0
    private (set) var trips = [Trip]()
    private var LOG = Logger()
    static let DATABASE = "http://localhost:3000/trips"

    mutating func initData() {
        
    }
    mutating func addTrip(key: Int?, vehicleId: Int, date: Date, coordinates: [[Double]]) {
        trips.append(Trip(id: key, coordinates: IntArrayToCoordinatesUsing(numbers: coordinates), length: 0, date: date))
    }
    private func IntArrayToCoordinatesUsing(numbers: [[Double]]) -> [Coordinate] {
        var finalCoordinates = [Coordinate]()
        for coordinates in numbers {
            finalCoordinates.append(Coordinate(latitude: coordinates[0], longitude: coordinates[1]))
        }
        return finalCoordinates
    }
    
}

struct Trip: Identifiable {
    var id: Int?
    var coordinates: [Coordinate]
    var length: Double
    var date: Date
}

struct Coordinate: Identifiable {
    var id: Int?
    var latitude: Double
    var longitude: Double
}

