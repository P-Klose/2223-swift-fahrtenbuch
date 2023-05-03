//
//  VehicleViewModel.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 03.05.23.
//

import Foundation

class ExpenseViewModel: ObservableObject {
    
    private final let DATABASE = "http://localhost:3000/expenses"
    @Published private var model = ExpenseModel()
    var expenses: [[Expense]] {
        model.expenses
    }
    
        func reloadAllExpenses() {
            model.initData()
        }
    
    func summ() -> Double{
        return summGas()+summPark()+summWash()
    }
    func summGas() -> Double{
        expenses[0].reduce(0.0, { $0 + Double($1.expenseValue) })
    }
    func summPark() -> Double{
        expenses[1].reduce(0.0, { $0 + Double($1.expenseValue) })
    }
    func summWash() -> Double{
        expenses[2].reduce(0.0, { $0 + Double($1.expenseValue) })
    }
    
    func saveExpenses(in _Type: String, vehicleId: Int, expenseValue: Double, onDate: Date) {
        switch _Type {
        case "gas":
            saveGas(value: expenseValue, vehicleId: vehicleId, date: onDate)
        case "parking":
            saveParking(value: expenseValue, vehicleId: vehicleId, date: onDate)
        case "cleaning":
            saveCleaning(value: expenseValue, vehicleId: vehicleId, date: onDate)
            
        default:
            saveOther(value: expenseValue, vehicleId: vehicleId, date: onDate)
        }
    }
    private func saveGas(value: Double, vehicleId: Int, date: Date){
        model.addExpense(IndexKey: 0, expenseValue: value, vehicleId: vehicleId, date: date, amount: nil)
    }
    
    private func saveParking(value: Double, vehicleId: Int, date: Date){
        model.addExpense(IndexKey: 1, expenseValue: value, vehicleId: vehicleId, date: date, amount: nil)
    }
    
    private func saveCleaning(value: Double, vehicleId: Int, date: Date){
        model.addExpense(IndexKey: 2, expenseValue: value, vehicleId: vehicleId, date: date, amount: nil)
    }
    
    private func saveOther(value: Double, vehicleId: Int, date: Date){
        model.addExpense(IndexKey: 3, expenseValue: value, vehicleId: vehicleId, date: date, amount: nil)
    }

    
    
//    func downloadAllVehicles() {
//        let downloadQueue = DispatchQueue(label: "Download Vehicles")
//        downloadQueue.async {
//            if let data = VehicleViewModel.load(){
//                DispatchQueue.main.async {
//                    self.model.importFromJson(data: data)
//                }
//            }
//        }
//    }
//    static func load() -> Data? {
//        var data: Data?
//        if let url = URL(string: VehicleModel.DATABASE) {
//            data = try? Data(contentsOf: url)
//        }
//        return data
//    }
    
    
}
