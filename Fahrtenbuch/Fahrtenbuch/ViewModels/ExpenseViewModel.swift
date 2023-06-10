//
//  VehicleViewModel.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 03.05.23.
//

import Foundation
import OSLog

class ExpenseViewModel: ObservableObject {
    
    private final let DATABASE = ExpenseModel.DATABASE
    
    let LOG = Logger()
    @Published private var model = ExpenseModel()
    var expenses: [Expense] {
        model.expenses
    }
    
    func downloadAllExpenses(completion: @escaping () -> Void){
        let downloadQueue = DispatchQueue(label: "Download Trips")
        LOG.info("ℹ️ Start Downloading Expenses")
        downloadQueue.async {
            if let data = ExpenseViewModel.load(){
                DispatchQueue.main.async {
                    self.model.importFromJson(data: data)
                    completion()
                }
            }
        }
    }
    static func load() -> Data? {
        var data: Data?
        if let url = URL(string: ExpenseModel.DATABASE) {
            data = try? Data(contentsOf: url)
        }
        return data
    }
    
    
    
    func reloadAllExpenses() {
        model.initData()
    }
    
    func summ() -> Double{
        return summGas()+summPark()+summWash()
    }
    func summGas() -> Double{
        expenses.filter { $0.expenseType == 0 }.reduce(0.0, { $0 + Double($1.expenseValue) })
    }
    func summPark() -> Double{
        expenses.filter { $0.expenseType == 1 }.reduce(0.0, { $0 + Double($1.expenseValue) })
    }
    func summWash() -> Double{
        expenses.filter { $0.expenseType == 2 }.reduce(0.0, { $0 + Double($1.expenseValue) })
    }
    
    func saveExpenses(in _Type: String, vehicleId: Int, expenseValue: Double, onDate: Date) {
        var expenseType = -1
        switch _Type {
        case "gas":
            expenseType = 0
        case "parking":
            expenseType = 1
        case "cleaning":
            expenseType = 2
        default:
            expenseType = 3
        }
        let toSaveExpense = Expense(date: onDate, expenseValue: expenseValue, expenseType: expenseType, vehicleId: vehicleId)
        
        saveExpenseToDatabase(expense: toSaveExpense) { success in
            if success {
                self.LOG.info("🟢 Expense Saved in Database")
            } else {
                self.LOG.error("🔴 Expense not saved in Database")
            }
        }
        //        self.tripModel.add(trip: toSaveTrip)
        LOG.info("#of expenses \(self.model.expenses.count)")
    }
    
    func saveExpenseToDatabase(expense: Expense, completion: @escaping (Bool) -> Void) {
        var success = true
        let finalUrl = "\(DATABASE)"
        
        if let url = URL(string: finalUrl){
            print(finalUrl)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            let jsonData = try! encoder.encode(expense)
            request.httpBody = jsonData
            
            // Erstelle die URLSession und den Datentask
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                // Handle die Antwort vom Server
                if let error = error {
                    print("Fehler: \(error)")
                    success = false
                } else if let data = data {
//                    print("Antwort: \(String(data: data, encoding: .utf8) ?? "")")
                    //self.downloadAllTrips()
                } else {
                    print("Keine Daten erhalten")
                    success = false
                }
            }
            // Starte den Datentask
            task.resume()
        } else {
            success = false
        }
        completion(success)
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
            
            let expense = Expense(date: monthDate, expenseValue: calculateExpenseSum(forMonth: month, expenseIndex: expenseIndex), expenseType: expenseIndex, vehicleId: -1)
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
            
            let expense = Expense(date: weekday, expenseValue: calculateExpenseSum(forDay: weekday, expenseIndex: expenseIndex), expenseType: expenseIndex, vehicleId: -1)
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
                
                let expense = Expense(date: dayDate, expenseValue: calculateExpenseSum(forDay: dayDate, expenseIndex: expenseIndex), expenseType: -1, vehicleId: -1)
                expenses.append(expense)
            }
        }
        
        return expenses
    }
    
    
    func calculateExpenseSum(forMonth month: Int, expenseIndex: Int) -> Double {
        let calendar = Calendar.current
        let filteredExpenses = expenses.filter { calendar.component(.month, from: $0.date) == month && $0.expenseType == expenseIndex }
        let expenseSum = filteredExpenses.reduce(0.0) { $0 + $1.expenseValue }
        return expenseSum
    }
    
    func calculateExpenseSum(forDay day: Date, expenseIndex: Int) -> Double {
        let calendar = Calendar.current
        let filteredExpenses = expenses.filter { calendar.isDate($0.date, inSameDayAs: day) }
        
        // Berechne die Summe der expenseValue-Werte für das angegebene Datum
        let expenseSum = filteredExpenses.reduce(0) { $0 + $1.expenseValue }
        
        return expenseSum
    }
    
    
}
