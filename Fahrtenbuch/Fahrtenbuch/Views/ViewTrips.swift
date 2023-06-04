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
    @State private var showAlertFahrt = false
    
    
    let LOG = Logger()
    
    var body: some View {
        
        NavigationStack {
            VStack {
                if (mapViewModel.trips.count > 0){
                    TripDiagramView(mapViewModel: mapViewModel)
                    Form{
                        Section{
                            Picker("Fahrzeug", selection: $selectedVehicleId) {
                                Text("bitte auswählen")
                                ForEach(vehicleViewModel.vehicles.indices) { index in
                                    Text(self.vehicleViewModel.vehicles[index].getName()).tag(index)
                                }
                            }
                            DatePicker("Start-Datum", selection: $startDate, in: ...endDate, displayedComponents: .date)
                                .datePickerStyle(.automatic)
                            
                            DatePicker("End-Datum", selection: $endDate, in: startDate..., displayedComponents: .date)
                                .datePickerStyle(.automatic)
                            
                        }
                    }
                    ViewSelectedTrips(trips: filteredTrips)
                }else{
                    Text("Oops")
                        .foregroundStyle(.blue.gradient)
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    Text("Es sind noch keine Fahrten aufgenommen worden. Kommen sie später wieder")
                        .padding(.horizontal)
                        
                }
                
            }
            .navigationTitle("Fahrten")
            .onAppear(perform: {
                LOG.info("\(mapViewModel.trips.count)")
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
    
    
    struct ViewTrips_Previews: PreviewProvider {
        static let vehicleViewModel = VehicleViewModel()
        static let mapViewModel = MapViewModel()
        static var previews: some View {
            ViewRides(mapViewModel: mapViewModel, vehicleViewModel: vehicleViewModel)
        }
    }
}

struct TripDiagramView: View {
    @StateObject  var mapViewModel: MapViewModel
    var body: some View {
        Chart {
            let tripAverage = mapViewModel.trips.map(\.length)
                .reduce(0.0, +) / Double(mapViewModel.trips.count)
            RuleMark(y: .value("Mean", tripAverage))
                .foregroundStyle(.orange)
                .lineStyle(StrokeStyle(lineWidth: 1,dash: [5]))
            
            
            ForEach(mapViewModel.trips) { trip in
                BarMark(
                    x: .value("Datum", trip.date, unit: .weekOfMonth),
                    y: .value("Strecke", trip.length)
                )
            }
            .foregroundStyle(Color.blue.gradient)
        }
        .frame(height: 180)
        .chartXAxis {
            AxisMarks()
        }
    }
}

struct ViewSelectedTrips: View {
    var trips: [Trip]
    var body: some View {
        List(trips) { trip in
            VStack(alignment: .leading) {
                Text("AM: \(formattedDate(for: trip.date))")
                Text("Gefahren Strecke: \(trip.length/1000, format: .number.precision(.fractionLength(2)))km")
            }
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
