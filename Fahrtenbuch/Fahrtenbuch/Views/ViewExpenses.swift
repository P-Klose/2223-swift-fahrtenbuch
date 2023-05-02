//
//  ViewAusgaben.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//

import SwiftUI
import Charts

struct ViewExpenses: View {
    
    @State var showExpenseCreateForm = false
    let expenses: [GeneralExense] = [
        .init(date: Date.from(year: 2023, month: 1, day: 3), expenseValue: 83, vehicleId: 1),
        .init(date: Date.from(year: 2023, month: 1, day: 12), expenseValue: 80, vehicleId: 1),
        .init(date: Date.from(year: 2023, month: 1, day: 21), expenseValue: 90, vehicleId: 1),
        .init(date: Date.from(year: 2023, month: 1, day: 23), expenseValue: 79, vehicleId: 1),
        .init(date: Date.from(year: 2023, month: 1, day: 30), expenseValue: 92, vehicleId: 1),
        .init(date: Date.from(year: 2023, month: 2, day: 1), expenseValue: 29, vehicleId: 1),
        .init(date: Date.from(year: 2023, month: 2, day: 5), expenseValue: 65, vehicleId: 1),
        .init(date: Date.from(year: 2023, month: 2, day: 16), expenseValue: 34, vehicleId: 1),
        .init(date: Date.from(year: 2023, month: 2, day: 23), expenseValue: 54, vehicleId: 1),
        .init(date: Date.from(year: 2023, month: 3, day: 23), expenseValue: 45, vehicleId: 1),
        .init(date: Date.from(year: 2023, month: 3, day: 25), expenseValue: 12, vehicleId: 1)
        
    ]
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spritt Ausgaben")
                    
                    Text("Insgesammt: \(expenses.reduce(0, { $0 + $1.expenseValue }))")
                        .fontWeight(.semibold)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 12)
                    
                    Chart {
                        RuleMark(y: .value("Avg", 60))
                            .foregroundStyle(Color.orange)
                            .lineStyle(StrokeStyle(lineWidth: 1,dash: [5]))
                        ForEach(expenses) { expense in
                            BarMark(
                                x: .value("Datum", expense.date),
                                y: .value("Kosten", expense.expenseValue))
                        }
                        .foregroundStyle(Color.blue.gradient)
                        //                        .cornerRadius(2)
                        
                    }
                    .frame(height: 180)
                    .chartXAxis {
                        AxisMarks()
                    }
                    HStack {
                        Image(systemName: "line.diagonal")
                            .rotationEffect(Angle(degrees: 45))
                            .foregroundColor(.orange)
                        
                        Text("Durschnitts Tankpreis")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption2)
                    .padding(.leading, 4)
                    
                }
                .padding()
            }
            .navigationTitle("Ausgaben")
            .toolbar(){
                ToolbarItemGroup(placement:
                        .navigationBarLeading){
                            Button(action: {
                                showExpenseCreateForm.toggle()
                            },label: {
                                Image(systemName: "plus")
                            })
                        }
            }
        }
        .sheet(isPresented: $showExpenseCreateForm) {
            ExpensesFormView()
                .presentationDetents([.medium])
        }
    }
}

struct ExpensesFormView: View {
    @Environment(\.dismiss) var dismiss
    
    var vehicle: Vehicle?
    init(vehicle: Vehicle? = nil) {
        self.vehicle = vehicle
        if self.vehicle != nil {
            vehicleName = vehicle!.getName()
        }
    }
    @State private var vehicleName: String = "alle"
    @State private var value: Int?
    @State private var expenseType = ["gas","cleaning","maintance","other"]

    
    var body: some View {
        
        NavigationView{
//            Form {
//
//                Section {
//                    TextField("Marke:", text: $makeTextField)
//                    TextField("Modell:", text: $modelTextField)
//                    TextField("Kennzeichen:",text: $numberplateTextField)
//                }
//                Section {
//                    TextField("Kilometerstand:", text: $milageTextField)
//                        .keyboardType(.numberPad)
//                }
//                Section {
//                    TextField("Identifizierungsnummer:", text: $vinTextField)
//                } header: {
//                    Text("Zusätzliche Informationen:")
//                }
//            }
//            .navigationTitle("Fahrzeug hinzufügen")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar(){
//                ToolbarItemGroup(placement:
//                        .navigationBarLeading){
//                            Button(action: {
//                                dismiss()
//                            }) {
//                                Text("Abbrechen")
//                            }
//                        }
//                ToolbarItemGroup(placement:
//                        .navigationBarTrailing){
//                            Button(action: {
//                                print("ImageURL: \(imageUrl ?? "")")
//                                vehicleViewModel.saveButtonTapped(make: makeTextField, model: modelTextField, vin: vinTextField, milage: milageTextField, numberplate: numberplateTextField, imageUrl: imageUrl ?? "")
//                                dismiss()
//                            }) {
//                                Text("Speichern")
//                            }
//
//                        }
//            }
        }
    }
}

struct ViewExpenses_Previews: PreviewProvider {
    static var previews: some View {
        ViewExpenses()
    }
}

struct GeneralExense: Identifiable {
    let id = UUID()
    let date: Date
    let expenseValue: Int
    let vehicleId: Int
}

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date{
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
}
