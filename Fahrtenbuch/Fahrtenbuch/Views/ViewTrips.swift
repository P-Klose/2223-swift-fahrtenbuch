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
    @StateObject  var tvm: TripViewModel
    @ObservedObject var vvm: VehicleViewModel
    
    @State var trips = [Trip]()
    
    @State private var showAlertFahrt = false
    @State private var showTripConfigSheet = false
    
    
    let LOG = Logger()
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Statistiken")
                        .fontWeight(.bold)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    ViewOverviewChart(tvm: tvm, trips: trips)
                    ViewTriplist(vvm: vvm, tvm: tvm)
                }
                
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
            }
            .navigationTitle("Fahrten")
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

extension Double {
    var kmString: String {
        return String(format: "%.1fkm", self / 1000).replacingOccurrences(of: ".0", with: "")
    }
}

struct ViewOverviewChart: View {
    @StateObject  var tvm: TripViewModel
    @State var currentTab: String = "Woche"
    @State var chartDisplayUnit = Calendar.Component.day
    @State var trips: [Trip]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack {
                    Image(systemName: "road.lanes")
                        .bold()
                    Text("Strecken")
                        .fontWeight(.bold)
                        .font(.body)
                }
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
            
            let tripTotal = tvm.trips.map(\.length)
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
        .onChange(of: currentTab) { newValue in
            trips = tvm.trips
            switch newValue {
            case "Woche":
                chartDisplayUnit = Calendar.Component.day
                trips = tvm.generateWeeklyTrips()
            case "Monat":
                chartDisplayUnit = Calendar.Component.day
                trips = tvm.generateMonthlyTrips()
            case "Jahr":
                chartDisplayUnit = Calendar.Component.month
                trips = tvm.generateYearlyTrips()
            default:
                return
            }
            //animateGraph()
        }
    }
    
    @ViewBuilder
    func AnimatedChart() -> some View {
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
            if currentTab == "Jahr" {
                AxisMarks(values: trips.map {$0.date }) { date in
                    AxisValueLabel(format: .dateTime.month(.narrow))
                }
            } else {
                AxisMarks()
            }
        }
        .onAppear {
            tvm.downloadAllTrips(){
                trips = tvm.generateWeeklyTrips()
            }
            //            animateGraph()
        }
    }
}

struct ViewTriplist: View {
    @ObservedObject var vvm: VehicleViewModel
    @StateObject  var tvm: TripViewModel
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var selectedVehicleId = -1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Fahrzeug")
                    .fontWeight(.bold)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Picker("Fahrzeug", selection: $selectedVehicleId) {
                    Text("bitte auswählen")
                        .tag(-1)
                    ForEach(vvm.vehicles.indices, id: \.self) { index in
                        Text(vvm.vehicles[index].getName())
                            .tag(vvm.vehicles[index].id)
                    }
                }
                .pickerStyle(.menu)
            }
            DatePicker("Von:", selection: $startDate, in: ...endDate, displayedComponents: .date)
                .datePickerStyle(.automatic)
                .environment(\.locale, Locale(identifier: "de_DE"))
            
            
            DatePicker("Bis:", selection: $endDate, in: startDate..., displayedComponents: .date)
                .datePickerStyle(.automatic)
                .environment(\.locale, Locale(identifier: "de_DE"))
            
            ForEach(filterTrips()) { trip in
                
                VStack(alignment: .leading) {
                    Text("Am: \(formattedDate(for: trip.date))")
                    Text("Gefahren Strecke: \(trip.length)km")
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white.shadow(.drop(radius: 2)))
        }
    }
    func filterTrips() -> [Trip] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: startDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: endDate)!
        
        
        
        let filteredTrips = tvm.trips.filter { trip in
            return trip.date >= startOfDay && trip.date <= endOfDay && trip.vehicleId == selectedVehicleId
        }
        
        return filteredTrips
    }
    func formattedDate(for date: Date?) -> String {
        guard let date = date else {
            return "Unbekanntes Datum"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}
