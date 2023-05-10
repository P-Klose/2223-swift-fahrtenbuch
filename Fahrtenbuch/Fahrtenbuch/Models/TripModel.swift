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
    mutating func add(trip: Trip) {
        trips.append(trip)
    }
    mutating func importFromJson(data: Data) {
        if let dowloadedTrips = try? JSONDecoder().decode([Trip].self, from: data){
            trips = dowloadedTrips

        }else{
            
        }
    }
}

struct Trip: Codable, Identifiable, Hashable {
    var id: Int?
    var coordinates: [Coordinate]
    var length: Double
    var date: Date
}

struct Coordinate: Codable, Identifiable, Hashable {
    var id: Int
    var latitude: Double
    var longitude: Double
}

