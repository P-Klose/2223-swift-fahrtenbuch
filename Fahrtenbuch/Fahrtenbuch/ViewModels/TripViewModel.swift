//
//  TripViewModel.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 05.06.23.
//

import Foundation
import OSLog

class TripViewModel: ObservableObject {
    
    private final let DATABASE = TripModel.DATABASE
    
    @Published private var tripModel = TripModel()
    var trips:[Trip] {
        tripModel.trips
    }

    
    let navigationQueue = DispatchQueue(label: "navigation")
    let viewController =  HomeViewController()
    let vehicleViewModel = VehicleViewModel()

    var recording = false
    var isStopped = false
    var selectedVehicleId = -1
    var regionUpdated = false
    
    let LOG = Logger()
    
    func saveTrip(vehicleId: Int, date: Date, coordinates: [[Double]], distanceTraveled: Double) {
        let toSaveTrip = Trip(id: trips.count, coordinates: IntArrayToCoordinatesUsing(numbers: coordinates), length: distanceTraveled, date: date, vehicleId: vehicleId)
        vehicleViewModel.updateMillage(vehicleId: vehicleId, toAddMilage: distanceTraveled)
        // ONLY Working if Trp has nil as ID but problems in displaying otherwise
        //        saveTripToDatabase(trip: toSaveTrip){ success in
        //            if success {
        //                self.LOG.info("🟢 Trip Saved in Database")
        //            } else {
        //                self.LOG.error("🔴 Trip not saved in Database")
        //            }
        //        }
        self.tripModel.add(trip: toSaveTrip)
        LOG.info("#of trips \(self.tripModel.trips.count)")
    }
    private func IntArrayToCoordinatesUsing(numbers: [[Double]]) -> [Coordinate] {
        var finalCoordinates = [Coordinate]()
        for (index,coordinates) in numbers.enumerated() {
            finalCoordinates.append(Coordinate(id: index, latitude: coordinates[0], longitude: coordinates[1]))
        }
        return finalCoordinates
    }

//    func animateTrip(index: Int) {
//        tripModel.animateTrip(index: index)
//    }
    
    func saveTripToDatabase(trip: Trip) -> Bool {
        var success = true
        let finalUrl = "\(DATABASE)"
        
        if let url = URL(string: finalUrl){
            print(finalUrl)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            let jsonData = try! encoder.encode(trip)
            request.httpBody = jsonData
            
            // Erstelle die URLSession und den Datentask
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                // Handle die Antwort vom Server
                if let error = error {
                    print("Fehler: \(error)")
                    success = false
                } else if let data = data {
                    print("Antwort: \(String(data: data, encoding: .utf8) ?? "")")
                    //self.downloadAllTrips()
                } else {
                    print("Keine Daten erhalten")
                    success = false
                }
            }
            // Starte den Datentask
            task.resume()
        } else {
            success = false
        }
        return success
    }
    
    func downloadAllTrips() {
        let downloadQueue = DispatchQueue(label: "Download Trips")
        downloadQueue.async {
            if let data = TripViewModel.load(){
                DispatchQueue.main.async {
                    self.tripModel.importFromJson(data: data)
                }
            }
        }
    }
    static func load() -> Data? {
            var data: Data?
            if let url = URL(string: TripModel.DATABASE) {
                data = try? Data(contentsOf: url)
            }
            return data
        }
    
    
    func generateYearlyTrips() -> [Trip] {
        var yearlyTrips = [Trip]()
        
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        
        for month in 1...12 {
            let monthDateComponents = DateComponents(year: currentYear, month: month)
            guard let monthDate = calendar.date(from: monthDateComponents) else {
                continue
            }
            
            let trip = Trip(length: calculateExpenseSum(forMonth: month), date: monthDate, vehicleId: -1)
            yearlyTrips.append(trip)
        }
        
        return yearlyTrips
    }
    
    func generateWeeklyTrips() -> [Trip] {
        let currentDate = Date()
        let calendar = Calendar.current

        var expenses = [Trip]()

        // Generiere Ausgaben für jeden Wochentag der aktuellen Woche
        for day in 1...7 {
            guard let weekday = calendar.date(byAdding: .day, value: day - calendar.component(.weekday, from: currentDate), to: currentDate) else {
                continue
            }

            let expense = Trip(length: calculateExpenseSum(forDay: weekday), date: weekday, vehicleId: -1)
            expenses.append(expense)
        }

        return expenses
    }
    
    func generateMonthlyTrips() -> [Trip] {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)

        var expenses = [Trip]()

        // Generiere Ausgaben für jeden Tag des aktuellen Monats
        if let range = calendar.range(of: .day, in: .month, for: currentDate) {
            for day in range {
                let dayDateComponents = DateComponents(year: currentYear, month: currentMonth, day: day)
                guard let dayDate = calendar.date(from: dayDateComponents) else {
                    continue
                }

                let expense = Trip(length: calculateExpenseSum(forDay: dayDate), date: dayDate, vehicleId: -1)
                expenses.append(expense)
            }
        }

        return expenses
    }
    
    
    func calculateExpenseSum(forMonth month: Int) -> Double {
        let calendar = Calendar.current
        let filteredExpenses = trips.filter { calendar.component(.month, from: $0.date) == month }
        let expenseSum = filteredExpenses.reduce(0.0) { $0 + $1.length }
        return expenseSum
    }
    
    func calculateExpenseSum(forDay day: Date) -> Double {
        let calendar = Calendar.current
        let filteredExpenses = trips.filter { calendar.isDate($0.date, inSameDayAs: day) }
        
        // Berechne die Summe der expenseValue-Werte für das angegebene Datum
        let expenseSum = filteredExpenses.reduce(0) { $0 + $1.length }
        
        return expenseSum
    }
    
    
    
    
}

    
