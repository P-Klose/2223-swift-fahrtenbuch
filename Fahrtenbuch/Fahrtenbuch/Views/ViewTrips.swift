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
    
    @State var currentTab: String = "Woche"
    
    let LOG = Logger()
    
    var body: some View {
        
        NavigationStack {
            
            ScrollView {
                VStack {
                    if (mapViewModel.trips.count > 0){
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Gefahrene km")
                                    .fontWeight(.semibold)
                                Picker("", selection: $currentTab) {
                                    Text("Woche")
                                        .tag("Woche")
                                    Text("Monat")
                                        .tag("Monat")
                                    Text("Jahr")
                                        .tag("Jahr")
                                }
                                .pickerStyle(.segmented)
                                .padding(.leading,40)
                            }
                            
                            let tripTotal = mapViewModel.trips.map(\.length)
                                .reduce(0.0, +)
                            
                            Text(tripTotal.kmString)
                                .font(.largeTitle.bold())
                            AnimatedChart()
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.white.shadow(.drop(radius: 2)))
                        }
                        //                    TripDiagramView(mapViewModel: mapViewModel)
                        VStack {
                            Picker("Fahrzeug", selection: $selectedVehicleId) {
                                Text("bitte auswählen")
                                    .tag(-1)
                                ForEach(vehicleViewModel.vehicles.indices) { index in
                                    Text(self.vehicleViewModel.vehicles[index].getName()).tag(index)
                                }
                            }
                            DatePicker("Start-Datum", selection: $startDate, in: ...endDate, displayedComponents: .date)
                                .datePickerStyle(.automatic)
                            
                            DatePicker("End-Datum", selection: $endDate, in: startDate..., displayedComponents: .date)
                                .datePickerStyle(.automatic)
                            
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.white.shadow(.drop(radius: 2)))
                        }
                        VStack {
                            ForEach(filteredTrips) { trip in
                                VStack(alignment: .leading) {
                                    Text("Am: \(formattedDate(for: trip.date))")
                                    Text("Gefahren Strecke: \(trip.length/1000, format: .number.precision(.fractionLength(1)))km")
                                }
//                                .overlay(
//                                    Rectangle()
//                                        .frame(height: 4)
//                                        .foregroundColor(.blue),
//                                    alignment: .bottom
//                                )
                            }
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.white.shadow(.drop(radius: 2)))
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
            }
            .navigationTitle("Fahrten")
            .onAppear(perform: {
                //                LOG.info("\(mapViewModel.trips.count)")
            })
        }
    }
    
    @ViewBuilder
    func AnimatedChart() -> some View {
        let max = mapViewModel.trips.max { item1, item2 in
            return item2.length > item1.length
        }?.length ?? 0
        Chart {
            ForEach(mapViewModel.trips) { trip in
                BarMark(
                    x: .value("Datum", trip.date, unit: .weekOfMonth),
                    y: .value("Strecke", trip.animate ? trip.length : 0)
                )
            }
            .foregroundStyle(Color.blue.gradient)
        }
        .chartYScale(domain: 0...(max + 50))
        .frame(height: 250)
        .onAppear {
            for (index,_) in mapViewModel.trips.enumerated(){
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                    withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)){
                        mapViewModel.animateTrip(index: index)
                    }
                }
            }
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
            return "Unbekanntes Datum"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    struct ViewTrips_Previews: PreviewProvider {
        static let vehicleViewModel = VehicleViewModel()
        static let mapViewModel = MapViewModel()
        static var previews: some View {
            ViewRides(mapViewModel: mapViewModel, vehicleViewModel: vehicleViewModel)
        }
    }
}

extension Double {
    var kmString: String {
        return String(format: "%.1fkm", self / 1000).replacingOccurrences(of: ".0", with: "")
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
