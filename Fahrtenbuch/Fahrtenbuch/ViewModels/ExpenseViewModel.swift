//
//  VehicleViewModel.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 03.05.23.
//

import Foundation
import OSLog

class ExpenseViewModel: ObservableObject {
    
    private final let DATABASE = "http://localhost:3000/expenses"
    
    let LOG = Logger()
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
    
    
    func generateYearlyExpenses(expenseIndex: Int) -> [Expense] {
        var yearlyGasExpenses = [Expense]()
        
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        
        for month in 1...12 {
            let monthDateComponents = DateComponents(year: currentYear, month: month)
            guard let monthDate = calendar.date(from: monthDateComponents) else {
                continue
            }
            
            let expense = Expense(date: monthDate, expenseValue: calculateExpenseSum(forMonth: month, expenseIndex: expenseIndex), vehicleId: -1)
            yearlyGasExpenses.append(expense)
        }
        
        return yearlyGasExpenses
    }
    
    func generateWeeklyExpenses(expenseIndex: Int) -> [Expense] {
        let currentDate = Date()
        let calendar = Calendar.current
        
        var expenses = [Expense]()
        
        // Generiere Ausgaben für jeden Wochentag der aktuellen Woche
        for day in 1...7 {
            guard let weekday = calendar.date(byAdding: .day, value: day - calendar.component(.weekday, from: currentDate), to: currentDate) else {
                continue
            }
            
            let expense = Expense(date: weekday, expenseValue: calculateExpenseSum(forDay: weekday, expenseIndex: expenseIndex), vehicleId: -1)
            expenses.append(expense)
        }
        
        return expenses
    }
    
    // Funktion zum Generieren des Arrays von "expenses" für einen Monat
    func generateMonthlyExpenses(expenseIndex: Int) -> [Expense] {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        var expenses = [Expense]()
        
        // Generiere Ausgaben für jeden Tag des aktuellen Monats
        if let range = calendar.range(of: .day, in: .month, for: currentDate) {
            for day in range {
                let dayDateComponents = DateComponents(year: currentYear, month: currentMonth, day: day)
                guard let dayDate = calendar.date(from: dayDateComponents) else {
                    continue
                }
                
                let expense = Expense(date: dayDate, expenseValue: calculateExpenseSum(forDay: dayDate, expenseIndex: expenseIndex), vehicleId: -1)
                expenses.append(expense)
            }
        }
        
        return expenses
    }
    
    
    func calculateExpenseSum(forMonth month: Int, expenseIndex: Int) -> Double {
        let calendar = Calendar.current
        let filteredExpenses = expenses[expenseIndex].filter { calendar.component(.month, from: $0.date) == month }
        let expenseSum = filteredExpenses.reduce(0.0) { $0 + $1.expenseValue }
        return expenseSum
    }
    
    func calculateExpenseSum(forDay day: Date, expenseIndex: Int) -> Double {
        let calendar = Calendar.current
        let filteredExpenses = expenses[expenseIndex].filter {
//            LOG.debug("Tripdatum: \($0.date) Filterdatum: \(day)")
            return calendar.isDate($0.date, inSameDayAs: day)
            
        }
        
        // Berechne die Summe der expenseValue-Werte für das angegebene Datum
        let expenseSum = filteredExpenses.reduce(0) { $0 + $1.expenseValue }
        
        return expenseSum
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
