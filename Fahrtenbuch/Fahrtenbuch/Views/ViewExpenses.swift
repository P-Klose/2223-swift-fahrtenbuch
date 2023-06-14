//
//  ViewAusgaben.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//


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
    
    func setExpenses() {
        gasExpense = expenseViewModel.generateWeeklyExpenses(expenseIndex: 0)
        parkExpense = expenseViewModel.generateWeeklyExpenses(expenseIndex: 1)
        washExpense = expenseViewModel.generateWeeklyExpenses(expenseIndex: 2)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Übersicht")
                                .fontWeight(.bold)
                                .font(.body)
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
                        
                        expenseViewModel.summ().euroText()
                        AnimatedChart()
                        DesciptionView()
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color("ForgroundColor"))
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
            .background(Color("BackgroundColor"))
            .navigationTitle("Ausgaben")
            .onAppear(perform: {
                expenseViewModel.downloadAllExpenses(){
                    setExpenses()
                }
                vehicleViewModel.downloadAllVehicles(){}
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
                .onDisappear{
                    expenseViewModel.downloadAllExpenses(){
                        setExpenses()
                    }
                }
        }
    }
    
    @ViewBuilder
    func AnimatedChart() -> some View {
        Chart {
            ForEach(gasExpense) { expense in
                BarMark(
                    x: .value("Datum", expense.date, unit: chartDisplayUnit),
                    y: .value("Kosten", expense.expenseValue))
            }
            .foregroundStyle(Color("GasExpenseColor"))
            ForEach(parkExpense) { expense in
                BarMark(
                    x: .value("Datum", expense.date, unit: chartDisplayUnit),
                    y: .value("Kosten", expense.expenseValue))
            }
            .foregroundStyle(Color("ParkExpenseColor"))
            ForEach(washExpense) { expense in
                BarMark(
                    x: .value("Datum", expense.date, unit: chartDisplayUnit),
                    y: .value("Kosten", expense.expenseValue))
            }
            .foregroundStyle(Color("WashExpenseColor"))
        }
        .frame(height: 250)
//        .foregroundColor(Color("ForgroundColor"))
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
}

struct DesciptionView: View {
    var body: some View {
        HStack {
            Image(systemName: "square.fill")
                .foregroundColor(Color("GasExpenseColor"))
            Text("Tanken")
                .foregroundColor(.secondary)
        }
        .font(.caption2)
        .padding(.leading, 4)
        HStack {
            Image(systemName: "square.fill")
                .foregroundColor(Color("ParkExpenseColor"))
            Text("Parken")
                .foregroundColor(.secondary)
        }
        .font(.caption2)
        .padding(.leading, 4)
        HStack {
            Image(systemName: "square.fill")
                .foregroundColor(Color("WashExpenseColor"))
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
                        ForEach(vehicleVM.vehicles.indices, id: \.self) { index in
                            Text(vehicleVM.vehicles[index].getName())
                                .tag(vehicleVM.vehicles[index].id)
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
                    .environment(\.locale, Locale(identifier: "de_DE"))

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
                                    expenseVM.saveExpenses(in: selectedExpenseType.rawValue, vehicleId: 1, expenseValue: Double(value) ?? 0, onDate: date){
                                        
                                    }
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

extension Double {
    func euroText() -> Text {
        let formattedNumber = String(
            format: "%.2f",
            locale: Locale(identifier: "de_DE"), self)
            .replacingOccurrences(of: ".00", with: "")
        let numberText = Text(formattedNumber)
            .font(.largeTitle).bold()
            .fontDesign(.rounded)
        let euroText = Text(" €")
            .font(.body).bold()
            .foregroundColor(.gray)
            .fontDesign(.rounded)
        return numberText + euroText
    }
}
