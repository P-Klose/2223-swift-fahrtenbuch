//
//  ViewAusgaben.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//

//Orange -> Tanken
//Purple -> Parken
//Blue -> Waschen

import SwiftUI
import Charts
import OSLog

typealias vvm = VehicleViewModel
typealias evm = ExpenseViewModel
struct ViewExpenses: View {
    
    @State var showExpenseCreateForm = false
    @ObservedObject var expenseViewModel: evm
    @ObservedObject var vehicleViewModel: vvm
    
    @State var currentTab: String = "Woche"
    
    @State var gasExpense = [Expense]()
    @State var parkExpense = [Expense]()
    @State var washExpense = [Expense]()
    
    @State var chartDisplayUnit = Calendar.Component.day
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Übersicht")
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
                        
                        Text("\(expenseViewModel.summ(), format: .number.precision(.fractionLength(2))) €")
                            .font(.largeTitle.bold())
                        AnimatedChart()
                        DesciptionView()
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.white.shadow(.drop(radius: 2)))
                    }
                    
                    
                    Spacer()
                    
                    Section() {
                        Text("Tanken")
                        
                        Text("Gesammt: \(expenseViewModel.summGas(), format: .number.precision(.fractionLength(1)))")
                            .fontWeight(.semibold)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 12)
                    }
                    
                    Section() {
                        Text("Parken")
                        
                        Text("Gesammt: \(expenseViewModel.summPark(), format: .number.precision(.fractionLength(1)))")
                            .fontWeight(.semibold)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 12)
                    }
                    Section() {
                        Text("Waschen")
                        
                        Text("Gesammt: \(expenseViewModel.summWash(), format: .number.precision(.fractionLength(1)))")
                            .fontWeight(.semibold)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 12)
                    }
                }
                .padding()
                
                
            }
            .navigationTitle("Ausgaben")
            .onAppear(perform: {
                expenseViewModel.reloadAllExpenses()
                vehicleViewModel.downloadAllVehicles()
                setExpenses()
                
            })
            .onChange(of: currentTab) { newValue in
                switch newValue {
                case "Woche":
                    chartDisplayUnit = Calendar.Component.day
                    gasExpense = expenseViewModel.generateWeeklyExpenses(expenseIndex: 0)
                    parkExpense = expenseViewModel.generateWeeklyExpenses(expenseIndex: 1)
                    washExpense = expenseViewModel.generateWeeklyExpenses(expenseIndex: 2)
                case "Monat":
                    chartDisplayUnit = Calendar.Component.day
                    gasExpense = expenseViewModel.generateMonthlyExpenses(expenseIndex: 0)
                    parkExpense = expenseViewModel.generateMonthlyExpenses(expenseIndex: 1)
                    washExpense = expenseViewModel.generateMonthlyExpenses(expenseIndex: 2)
                case "Jahr":
                    chartDisplayUnit = Calendar.Component.month
                    gasExpense = expenseViewModel.generateYearlyExpenses(expenseIndex: 0)
                    parkExpense = expenseViewModel.generateYearlyExpenses(expenseIndex: 1)
                    washExpense = expenseViewModel.generateYearlyExpenses(expenseIndex: 2)
                default:
                    return
                }
            }
            .toolbar(){
                ToolbarItemGroup(placement:
                        .navigationBarTrailing){
                            Button(action: {
                                showExpenseCreateForm.toggle()
                            },label: {
                                Image(systemName: "plus")
                            })
                        }
            }
        }
        .sheet(isPresented: $showExpenseCreateForm) {
            ExpensesFormView(vehicleVM: vehicleViewModel, expenseVM: expenseViewModel)
                .presentationDetents([.medium])
        }
    }
    
    @ViewBuilder
    func AnimatedChart() -> some View {
        let max = expenseViewModel.summ()
        Chart {
//            let gasAverage = expenseViewModel.expenses[0].map(\.expenseValue)
//                .reduce(0.0, +) / Double(expenseViewModel.expenses[0].count)
//            RuleMark(y: .value("Mean", gasAverage))
//                .foregroundStyle(.orange)
//                .lineStyle(StrokeStyle(lineWidth: 1,dash: [5]))
            
            ForEach(gasExpense) { expense in
                BarMark(
                    x: .value("Datum", expense.date, unit: chartDisplayUnit),
                    y: .value("Kosten", expense.expenseValue))
            }
            .foregroundStyle(Color.orange.gradient)
            ForEach(parkExpense) { expense in
                BarMark(
                    x: .value("Datum", expense.date, unit: chartDisplayUnit),
                    y: .value("Kosten", expense.expenseValue))
            }
            .foregroundStyle(Color.purple.gradient)
            ForEach(washExpense) { expense in
                BarMark(
                    x: .value("Datum", expense.date, unit: chartDisplayUnit),
                    y: .value("Kosten", expense.expenseValue))
            }
            .foregroundStyle(Color.blue.gradient)
        }
        //        .chartOverlay(content: { proxy in
        //            GeometryReader { innerProxy in
        //                Rectangle()
        //                    .fill(.clear).containerShape(Rectangle())
        //                    .gesture(
        //                        DragGesture()
        //                            .onChanged({ value in
        //                                let location = value.location
        //                                if let data: Date = proxy.value(atX: location.x){
        //                                    print("Y: \(data)")
        //                                }
        //
        //                            })
        //                            .onEnded({ value in
        //                                //none
        //                            })
        //                    )
        //            }
        //        })
        .frame(height: 250)
        .chartXAxis {
            if currentTab == "Jahr" {
                AxisMarks(values: gasExpense.map {$0.date }) { date in
                    AxisValueLabel(format: .dateTime.month(.narrow))
                }
            } else {
                AxisMarks()
            }
            // NOTE: Custom Axis Marks but a little bit buggy
//            if currentTab == "Woche" {
//                AxisMarks(values: trips.map {$0.date }) { date in
//                    AxisValueLabel(format: .dateTime.weekday(.short))
//                }
//            }
//            if currentTab == "Monat" {
//                AxisMarks(values: trips.map {$0.date }) { date in
//                    AxisValueLabel(format: .dateTime.day(.defaultDigits))
//                }
//            }
        }
    }
    
    //    func animateGraph() {
    //        for (index,_) in expenseViewModel.trips.enumerated(){
    //            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
    //                withAnimation(.interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)){
    //                    mapViewModel.animateTrip(index: index)
    //                }
    //            }
    //        }
    //    }
    func setExpenses() {
        gasExpense = expenseViewModel.generateWeeklyExpenses(expenseIndex: 0)
        parkExpense = expenseViewModel.generateWeeklyExpenses(expenseIndex: 1)
        washExpense = expenseViewModel.generateWeeklyExpenses(expenseIndex: 2)
    }
}

struct DesciptionView: View {
    var body: some View {
        HStack {
            Image(systemName: "square.fill")
                .foregroundColor(.orange)
            Text("Tanken")
                .foregroundColor(.secondary)
        }
        .font(.caption2)
        .padding(.leading, 4)
        HStack {
            Image(systemName: "square.fill")
                .foregroundColor(.purple)
            Text("Parken")
                .foregroundColor(.secondary)
        }
        .font(.caption2)
        .padding(.leading, 4)
        HStack {
            Image(systemName: "square.fill")
                .foregroundColor(.blue)
            Text("Waschen")
                .foregroundColor(.secondary)
        }
        .font(.caption2)
        .padding(.leading, 4)
    }
}

struct ExpensesFormView: View {
    @ObservedObject var vehicleVM: vvm
    @ObservedObject var expenseVM: evm
    
    private let LOG = Logger()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var vehicleName: String = "alle"
    @State private var value: String = ""
    
    @State private var showAlertNoVehicleExpenses = false
    @State private var showAlertNoPriceExpenses = false
    
    
    
    @State private var date = Date()
    @State private var selectedExpenseType: ExpenseType = .other
    @State private var selectedVehicleId = -1
    
    
    var body: some View {
        
        NavigationView{
            Form {
                Section {
                    TextField("Preis:", text: $value).keyboardType(.numberPad)
                    Picker("Fahrzeug", selection: $selectedVehicleId) {
                        Text("bitte auswählen")
                        ForEach(vehicleVM.vehicles.indices) { index in
                            Text(self.vehicleVM.vehicles[index].getName()).tag(index)
                        }
                    }
                    
                    Picker("Ausgabentyp", selection: $selectedExpenseType) {
                        ForEach(ExpenseType.allCases) { expense in
                            Text(expense.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section {
                    DatePicker(
                        "Datum",
                        selection: $date,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.automatic)
                }
            }
            .navigationTitle("Ausgabe hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(){
                ToolbarItemGroup(placement:
                        .navigationBarLeading){
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Abbrechen")
                            }
                        }
                ToolbarItemGroup(placement:
                        .navigationBarTrailing){
                            Button(action: {
                                if selectedVehicleId != -1 {
                                    expenseVM.saveExpenses(in: selectedExpenseType.rawValue, vehicleId: 1, expenseValue: Double(value) ?? 0, onDate: date)
                                    LOG.info("\(selectedVehicleId)")
                                    dismiss()
                                } else {
                                    showAlertNoVehicleExpenses = true
                                    //LOG.error("🔴 Eintrag konnte nicht erstellt werden - Kein Fahrzeug wurde ausgewählt")
                                }
                                
                                if value == "" {
                                    showAlertNoPriceExpenses = true
                                }
                                
                            }) {
                                Text("Speichern")
                            }
                            
                        }
            }
        }.alert(isPresented: $showAlertNoVehicleExpenses) {
            Alert(title: Text("Fehler"),
                  message: Text("Bitte wählen Sie ein Fahrzeug aus!"),
                  dismissButton: .default(Text("OK")))}
        .alert(isPresented: $showAlertNoPriceExpenses) {
            Alert(title: Text("Fehler"),
                  message: Text("Bitte geben sie einen Wert ein!"),
                  dismissButton: .default(Text("OK")))}
    }
}

struct ViewExpenses_Previews: PreviewProvider {
    static let expenseViewModel = ExpenseViewModel()
    static let vehicleViewModel = VehicleViewModel()
    static var previews: some View {
        ViewExpenses(expenseViewModel: expenseViewModel,vehicleViewModel: vehicleViewModel)
    }
}


enum ExpenseType: String, CaseIterable, Identifiable {
    case gas, cleaning, parking, other
    var id: Self { self }
}

