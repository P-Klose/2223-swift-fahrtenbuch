//
//  Vehicle.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//
import Foundation



struct ExpenseModel {
    //typealias Gas = 0
    private (set) var expenses = [Expense]()
    
    static let DATABASE = "http://localhost:3000/expenses"
    
    mutating func importFromJson(data: Data) {
        if let dowloadedExpenses = try? JSONDecoder().decode([ExpenseDto].self, from: data){
            let myExpenses = dowloadedExpenses.map { Expense(dto: $0) }
            expenses = myExpenses
        }
    }
//    mutating func choose(_ chosenVehicle: Vehicle){
//        // change data
//    }
    
    mutating func initData() {
//        addExpense(expenseType: 0, expenseValue: 80, vehicleId: 1, date: Date.from(year: 2023, month: 2, day: 12))
//        addExpense(expenseType: 0, expenseValue: 90, vehicleId: 1, date: Date.from(year: 2023, month: 2, day: 21))
//        addExpense(expenseType: 0, expenseValue: 79, vehicleId: 1, date: Date.from(year: 2023, month: 2, day: 23))
//        addExpense(expenseType: 0, expenseValue: 92, vehicleId: 1, date: Date.from(year: 2023, month: 2, day: 30))
//        addExpense(expenseType: 0, expenseValue: 29, vehicleId: 1, date: Date.from(year: 2023, month: 3, day: 1))
//        addExpense(expenseType: 0, expenseValue: 65, vehicleId: 1, date: Date.from(year: 2023, month: 3, day: 5))
//        addExpense(expenseType: 0, expenseValue: 34, vehicleId: 1, date: Date.from(year: 2023, month: 3, day: 16))
//        addExpense(expenseType: 0, expenseValue: 54, vehicleId: 1, date: Date.from(year: 2023, month: 3, day: 23))
//        addExpense(expenseType: 0, expenseValue: 45, vehicleId: 1, date: Date.from(year: 2023, month: 4, day: 23))
//        addExpense(expenseType: 0, expenseValue: 12, vehicleId: 1, date: Date.from(year: 2023, month: 4, day: 25))
//
//        addExpense(expenseType: 1, expenseValue: 2, vehicleId: 1, date: Date.from(year: 2023, month: 2, day: 3))
//        addExpense(expenseType: 1, expenseValue: 2.5, vehicleId: 1, date: Date.from(year: 2023, month: 2, day: 17))
//        addExpense(expenseType: 1, expenseValue: 4, vehicleId: 1, date: Date.from(year: 2023, month: 3, day: 12))
//        addExpense(expenseType: 1, expenseValue: 5, vehicleId: 1, date: Date.from(year: 2023, month: 3, day: 23))
//        addExpense(expenseType: 1, expenseValue: 2, vehicleId: 1, date: Date.from(year: 2023, month: 4, day: 30))
//
//        addExpense(expenseType: 2, expenseValue: 10, vehicleId: 1, date: Date.from(year: 2023, month: 2, day: 4))
//        addExpense(expenseType: 2, expenseValue: 12.5, vehicleId: 1, date: Date.from(year: 2023, month: 2, day: 16))
//        addExpense(expenseType: 2, expenseValue: 15, vehicleId: 1, date: Date.from(year: 2023, month: 2, day: 28))
//        addExpense(expenseType: 2, expenseValue: 5, vehicleId: 1, date: Date.from(year: 2023, month: 3, day: 1))
//        addExpense(expenseType: 2, expenseValue: 12.5, vehicleId: 1, date: Date.from(year: 2023, month: 3, day: 10))
//        addExpense(expenseType: 2, expenseValue: 20, vehicleId: 1, date: Date.from(year: 2023, month: 3, day: 27))
//        addExpense(expenseType: 2, expenseValue: 5, vehicleId: 1, date: Date.from(year: 2023, month: 4, day: 5))
//
//        addExpense(expenseType: 3, expenseValue: 10, vehicleId: 1, date: Date.from(year: 2023, month: 2, day: 4))
    }
    
    mutating func addExpense(expenseType: Int, expenseValue: Double, vehicleId: Int, date: Date) {
        expenses.append(Expense(date: date, expenseValue: expenseValue, expenseType: expenseType, vehicleId: vehicleId))
    }
}

struct Expense: Codable, Identifiable, Hashable {
    var id: Int?
    var date: Date
    var expenseValue: Double
    var expenseType: Int
    var vehicleId: Int
}
extension Expense {
    init(dto: ExpenseDto) {
        self.id = dto.id
        self.expenseType = dto.expenseType
        self.expenseValue = dto.expenseValue ?? 0.0
        if let timestamp = dto.date {
            self.date = Date(timeIntervalSinceReferenceDate: timestamp)
        } else {
            self.date = Date()
        }
        self.vehicleId = dto.vehicleId
    }
}
struct ExpenseDto: Codable, Identifiable, Hashable {
    var id: Int
    var date: TimeInterval?
    var expenseValue: Double
    var expenseType: Int
    var vehicleId: Int
}

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date{
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
}

