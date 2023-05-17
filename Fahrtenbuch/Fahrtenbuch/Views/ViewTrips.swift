//
//  ViewTrips.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 10.05.23.
//

import SwiftUI
import OSLog
import Charts

struct ViewTrips: View {
    @StateObject  var mapViewModel: MapViewModel
    @ObservedObject var vehicleViewModel: VehicleViewModel
    
    @State private var selectedVehicleId = -1
    @State private var startDate = Date()
    @State private var endDate = Date()
//    @State private var showAllert = true
    
    
    let LOG = Logger()
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Chart {
                    let tripAverage = mapViewModel.trips.map(\.length)
                        .reduce(0.0, +) / Double(mapViewModel.trips.count)
                    RuleMark(y: .value("Mean", tripAverage))
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(lineWidth: 1,dash: [5]))
                    
                    
                    ForEach(mapViewModel.trips) { trip in
                        BarMark(
                            x: .value("Datum", formattedDate(for: trip.date)),
                            y: .value("Strecke", trip.length))
                    }
                    .foregroundStyle(Color.blue.gradient)
                }
                .frame(height: 180)
                .chartXAxis {
                    AxisMarks()
                }
                Form{
                    Section{
                        Picker("Fahrzeug", selection: $selectedVehicleId) {
                            Text("bitte auswählen")
                            ForEach(vehicleViewModel.vehicles.indices) { index in
                                Text(self.vehicleViewModel.vehicles[index].getName()).tag(index)
                            }
                        }
                        DatePicker(
                            "Start-Datum",
                            selection: $startDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.automatic)
                        DatePicker(
                            "End-Datum",
                            selection: $endDate,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.automatic)
                        
                    }
                }
                
                
                List(filteredTrips) { trip in
                    VStack(alignment: .leading) {
                        Text("AM: \(formattedDate(for: trip.date))")
                        Text("Gefahren Strecke: \(trip.length/1000, format: .number.precision(.fractionLength(2)))km")
                    }
                }
            }
//            .alert(isPresented: $showAllert) {
//                Alert(title: Text("Fehler"),
//                                  message: Text("Ein Fehler ist aufgetreten!"),
//                                  dismissButton: .default(Text("OK")))
//            }
            .navigationTitle("Fahrten")
            .onAppear(perform: {
                LOG.info("\(mapViewModel.trips.count)")
                if let lastTrip = mapViewModel.trips.last {
                    LOG.info("\(lastTrip.date)")
                }
                
            })
        }
    }
    var filteredTrips: [Trip] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: endDate)!
        
        return mapViewModel.trips.filter { trip in
            
            return trip.date >= startOfDay && trip.date <= endOfDay && trip.vehicleId == selectedVehicleId
        }
    }
    func formattedDate(for date: Date?) -> String {
        guard let date = date else {
            return "Unknown Date"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

struct ViewTrips_Previews: PreviewProvider {
    static let vehicleViewModel = VehicleViewModel()
    static let mapViewModel = MapViewModel()
    static var previews: some View {
        ViewRides(mapViewModel: mapViewModel, vehicleViewModel: vehicleViewModel)
    }
}