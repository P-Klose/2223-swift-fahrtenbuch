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
    
    @State var trips = [Trip]()
    
    @State private var selectedVehicleId = -1
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var showAlertFahrt = false
    
    @State var currentTab: String = "Woche"
    @State var chartDisplayUnit = Calendar.Component.weekOfMonth
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
            .onChange(of: currentTab) { newValue in
                trips = mapViewModel.trips
                switch newValue {
                case "Woche":
                    chartDisplayUnit = Calendar.Component.day
                case "Monat":
                    chartDisplayUnit = Calendar.Component.day
                case "Jahr":
                    chartDisplayUnit = Calendar.Component.month
                default:
                    return
                }
                if newValue != "Woche" {
                    for (index,_) in trips.enumerated() {
                        trips[index].length = .random(in: 500...5000)
                    }
                }
                
                //animateGraph()
            }
            .onAppear(perform: {
                trips = mapViewModel.trips
            })
        }
    }
    
    @ViewBuilder
    func AnimatedChart() -> some View {
        let max = mapViewModel.trips.max { item1, item2 in
            return item2.length > item1.length
        }?.length ?? 0
        Chart {
            ForEach(trips) { trip in
                BarMark(
                    x: .value("Datum", trip.date, unit: chartDisplayUnit),
                    y: .value("Strecke", trip.length )
                )
            }
            .foregroundStyle(Color.blue.gradient)
        }
        //        .chartYScale(domain: 0...(max + 50))
        .frame(height: 250)
        .chartXAxis {
            //            AxisValueLabel(format: .dateTime.day())
            if currentTab == "Woche" {
                AxisMarks(values: trips.map {$0.date }) { date in
                    AxisValueLabel(format: .dateTime.weekday())
                }
            }
            if currentTab == "Monat" {
                AxisMarks(values: trips.map {$0.date }) { date in
                    AxisValueLabel(format: .dateTime.day(.defaultDigits))
                }
            }
            if currentTab == "Jahr" {
                AxisMarks(values: trips.map {$0.date }) { date in
                    AxisValueLabel(format: .dateTime.month(.narrow))
                }
            }
            
            
        }
        .onAppear {
            //            animateGraph()
        }
    }
    
    //    func animateGraph() {
    //        for (index,_) in mapViewModel.trips.enumerated(){
    //            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
    //                withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)){
    //                    mapViewModel.animateTrip(index: index)
    //                }
    //            }
    //        }
    //    }
    
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
