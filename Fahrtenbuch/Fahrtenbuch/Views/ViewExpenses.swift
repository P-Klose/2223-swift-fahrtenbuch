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

//typealias Gas = 0
struct ViewExpenses: View {
    
    @State var showExpenseCreateForm = false
    @ObservedObject var expenseViewModel: ExpenseViewModel
   

    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("VW T7")
                    
                    Text("Insgesammt: \(expenseViewModel.summ(), format: .number.precision(.fractionLength(1)))")
                        .fontWeight(.semibold)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 12)
                    
                    Chart {
                        RuleMark(y: .value("Avg", 60))
                            .foregroundStyle(Color.orange)
                            .lineStyle(StrokeStyle(lineWidth: 1,dash: [5]))
                        
                        let gasAverage = expenseViewModel.expenses[0].map(\.expenseValue)
                            .reduce(0.0, +) / Float(expenseViewModel.expenses[0].count)
                          RuleMark(y: .value("Mean", gasAverage))
                            .foregroundStyle(.orange)
                            .lineStyle(StrokeStyle(lineWidth: 1))
//                            .annotation(position: .top, alignment: .trailing) {
//                              Text("Mean: \(average, format: .number.precision(.fractionLength(1)))")
//                                    .fontWeight(.semibold)
//                                    .font(.footnote)
//                                .foregroundStyle(.orange)
//                            }
                        
                        ForEach(expenseViewModel.expenses[0]) { expense in
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
                        Image(systemName: "line.diagonal")
                            .rotationEffect(Angle(degrees: 45))
                            .foregroundColor(.orange)
                        
                        Text("Durchschnittlicher Tankpreis")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption2)
                    .padding(.leading, 4)
                    
                }
                .padding()
            }
            .navigationTitle("Ausgaben")
            .onAppear(perform: {
                expenseViewModel.reloadAllExpenses()
            })
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
    static let expenseViewModel = ExpenseViewModel()
    static var previews: some View {
        ViewExpenses(expenseViewModel: expenseViewModel)
    }
}


