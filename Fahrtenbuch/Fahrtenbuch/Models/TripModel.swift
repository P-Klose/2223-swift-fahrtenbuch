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
        LOG.info("Data: \(data)")
        if let dowloadedTrips = try? JSONDecoder().decode([TripDto].self, from: data){
            let myTrips = dowloadedTrips.map { Trip(dto: $0) }
            trips = myTrips
        }
    }
}

struct Trip: Codable, Identifiable, Hashable {
    var id: Int?
    var coordinates: [Coordinate]?
    var length: Double
    var date: Date
    var vehicleId: Int
    var isPrivat: Bool?
//    var animate: Bool = false
}
extension Trip {
    init(dto: TripDto) {
        self.id = dto.id
        self.coordinates = dto.coordinates
        self.length = dto.length ?? 0.0
        if let timestamp = dto.date {
            self.date = Date(timeIntervalSinceReferenceDate: timestamp)
        } else {
            self.date = Date()
        }
        self.vehicleId = dto.vehicleId
        self.isPrivat = dto.isPrivat
    }
}

struct TripDto: Codable, Identifiable, Hashable {
    var id: Int?
    var coordinates: [Coordinate]?
    var length: Double?
    var date: TimeInterval?
    var vehicleId: Int
    var isPrivat: Bool?
//    var animate: Bool = false
}

struct Coordinate: Codable, Identifiable, Hashable {
    var id: Int
    var latitude: Double
    var longitude: Double
}

