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
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let dowloadedTrips = try? decoder.decode([Trip].self, from: data){
            trips = dowloadedTrips

        }
    }
    mutating func animateTrip (index: Int){
        trips[index].animate = true
    }
}

struct Trip: Codable, Identifiable, Hashable {
    var id: Int?
    var coordinates: [Coordinate]?
    var length: Double
    var date: Date
    var vehicleId: Int
    var isPrivat: Bool?
    var animate: Bool = false
}

struct Coordinate: Codable, Identifiable, Hashable {
    var id: Int
    var latitude: Double
    var longitude: Double
}

