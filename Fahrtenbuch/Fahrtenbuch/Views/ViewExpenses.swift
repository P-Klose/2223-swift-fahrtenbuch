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
    
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Übersicht")
                    
                    Text("Insgesammt: \(expenseViewModel.summ(), format: .number.precision(.fractionLength(1)))")
                        .fontWeight(.semibold)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 12)
                    
                    Chart {
                        let gasAverage = expenseViewModel.expenses[0].map(\.expenseValue)
                            .reduce(0.0, +) / Double(expenseViewModel.expenses[0].count)
                        RuleMark(y: .value("Mean", gasAverage))
                            .foregroundStyle(.orange)
                            .lineStyle(StrokeStyle(lineWidth: 1,dash: [5]))
                        
                        ForEach(expenseViewModel.expenses[0]) { expense in
                            BarMark(
                                x: .value("Datum", expense.date),
                                y: .value("Kosten", expense.expenseValue))
                        }
                        .foregroundStyle(Color.orange.gradient)
                        ForEach(expenseViewModel.expenses[1]) { expense in
                            BarMark(
                                x: .value("Datum", expense.date),
                                y: .value("Kosten", expense.expenseValue))
                        }
                        .foregroundStyle(Color.purple.gradient)
                        ForEach(expenseViewModel.expenses[2]) { expense in
                            BarMark(
                                x: .value("Datum", expense.date),
                                y: .value("Kosten", expense.expenseValue))
                        }
                        .foregroundStyle(Color.blue.gradient)
                    }
                    .frame(height: 180)
                    .chartXAxis {
                        AxisMarks()
                    }
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
                
            })
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
}

struct ExpensesFormView: View {
    @ObservedObject var vehicleVM: vvm
    @ObservedObject var expenseVM: evm
    
    private let LOG = Logger()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var vehicleName: String = "alle"
    @State private var value: String = ""
    
    
    @State private var date = Date()
    @State private var selectedExpenseType: ExpenseType = .other
    @State private var selectedVehicleId = -1
    
    
    var body: some View {
        
        NavigationView{
            Form {
                Section {
                    TextField("Preis:", text: $value).keyboardType(.numberPad)
                    Picker("Fahrzeug", selection: $selectedVehicleId) {
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
                                expenseVM.saveExpenses(in: selectedExpenseType.rawValue, vehicleId: 1, expenseValue: Double(value) ?? 0, onDate: date)
                                LOG.info("\(selectedVehicleId)")
                                dismiss()
                            }) {
                                Text("Speichern")
                            }
                            
                        }
            }
        }
        
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

