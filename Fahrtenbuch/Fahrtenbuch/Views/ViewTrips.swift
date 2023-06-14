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
    @ObservedObject  var tvm: TripViewModel
    @ObservedObject var vvm: VehicleViewModel
    
    @State private var showAlertFahrt = false
    @State private var showTripConfigSheet = false
    
    @State var showOverviewChart: Bool = true
    @State var showPrivateTripChart: Bool = false
    @State var showBusinessTripChart: Bool = false
    @State var showPercentageDifference: Bool = false
    
    @State var overviewTrips = [Trip]()
    @State var privateTrips = [Trip]()
    @State var businessTrips = [Trip]()
    
    let LOG = Logger()
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("Statistiken")
                            .fontWeight(.bold)
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Button(action: {
                            showTripConfigSheet = true;
                        }) {
                            Text("Edit")
                                .font(.body)
                        }
                    }
                    if showOverviewChart { ViewTripChart(tvm: tvm ,trips: overviewTrips, totalTrips: tvm.trips, title: "Gesammt") }
                    if showPrivateTripChart { ViewTripChart(tvm: tvm ,trips: privateTrips ,totalTrips: tvm.privateTrips, title: "Privat") }
                    if showBusinessTripChart { ViewTripChart(tvm: tvm ,trips: businessTrips ,totalTrips: tvm.businessTrip, title: "Unternehmen") }
                    ViewTriplist(vvm: vvm, tvm: tvm)
                }
                
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding()
            }
            .navigationTitle("Fahrten")
            .background(Color("Background"))
            .gesture(DragGesture()
                .onChanged { gesture in
                    if gesture.startLocation.y < gesture.location.y {
                        tvm.downloadAllTrips {}
                    }
                }
            )
        }
        .sheet(isPresented: $showTripConfigSheet) {
            WhatToDisplayView(showOverviewChart: $showOverviewChart, showPrivateTripChart: $showPrivateTripChart, showBusinessTripChart: $showBusinessTripChart, showPercentageDifference: $showPercentageDifference)
                .presentationDetents([.large])
                .onDisappear{
                    
                }
        }
        .onChange(of: tvm.trips) { newValue in
            overviewTrips = tvm.generateWeeklyTrips(selectedTrips: tvm.trips)
            privateTrips = tvm.generateWeeklyTrips(selectedTrips: tvm.privateTrips)
            businessTrips = tvm.generateWeeklyTrips(selectedTrips: tvm.businessTrip)
            LOG.info("Trips updated")
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
    func kmText() -> Text {
        let formattedNumber = String(
            format: "%.1f",
            locale: Locale(identifier: "de_DE"),
            self / 1000)
            .replacingOccurrences(of: ".0", with: "")
        let numberText = Text(formattedNumber)
            .font(.largeTitle).bold()
            .fontDesign(.rounded)
        let euroText = Text(" km")
            .font(.body).bold()
            .foregroundColor(.gray)
            .fontDesign(.rounded)
        return numberText + euroText
    }
}

struct ViewTripChart: View {
    @ObservedObject var tvm: TripViewModel
    @State var currentTab: String = "Woche"
    @State var chartDisplayUnit = Calendar.Component.day
    @State var trips: [Trip]
    var totalTrips: [Trip]
    var title: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack {
                    Image(systemName: "road.lanes")
                        .bold()
                    Text(title)
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
            
            let tripTotal = totalTrips.map(\.length)
                .reduce(0.0, +)
            
            tripTotal.kmText()
            AnimatedChart()
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color("Forground"))
        }
        .onChange(of: currentTab) { newValue in
            switch newValue {
            case "Woche":
                chartDisplayUnit = Calendar.Component.day
                trips = tvm.generateWeeklyTrips(selectedTrips: totalTrips)
            case "Monat":
                chartDisplayUnit = Calendar.Component.day
                trips = tvm.generateMonthlyTrips(selectedTrips: totalTrips)
            case "Jahr":
                chartDisplayUnit = Calendar.Component.month
                trips = tvm.generateYearlyTrips(selectedTrips: totalTrips)
            default:
                return
            }
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
            .foregroundStyle((title == "Unternehmen" ? Color("BusinessTrip") : (title == "Privat" ? Color("PrivateTrip") : Color.blue)))
        }
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
            trips = tvm.generateWeeklyTrips(selectedTrips: totalTrips)
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
                    .fontWeight(.semibold)
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
            HStack {
                DatePicker("Von:", selection: $startDate, in: ...endDate, displayedComponents: .date)
                    .datePickerStyle(.automatic)
                    .environment(\.locale, Locale(identifier: "de_DE"))
                
                
                DatePicker("Bis:", selection: $endDate, in: startDate..., displayedComponents: .date)
                    .datePickerStyle(.automatic)
                    .environment(\.locale, Locale(identifier: "de_DE"))
            }
            
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
                .fill(Color("Forground"))
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

struct WhatToDisplayView: View {
    
    private let LOG = Logger()
    
    @Binding var showOverviewChart: Bool
    @Binding var showPrivateTripChart: Bool
    @Binding var showBusinessTripChart: Bool
    @Binding var showPercentageDifference: Bool
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        
        NavigationView{
            VStack {
                Toggle("Übersichts Chart", isOn: $showOverviewChart)
                Toggle("Private Fahrten", isOn: $showPrivateTripChart)
                Toggle("Geschäftliche Fahrten", isOn: $showBusinessTripChart)
                Toggle("Privatanteil in Prozent", isOn: $showPercentageDifference)
            }
            .navigationTitle("Statistiken bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(){
                ToolbarItemGroup(placement:
                        .cancellationAction){
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Abbrechen")
                            }
                        }
                ToolbarItemGroup(placement:
                        .confirmationAction){
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Fertig")
                            }
                        }
            }
        }
    }
}
