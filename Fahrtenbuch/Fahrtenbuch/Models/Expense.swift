//
//  Vehicle.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//
import Foundation



struct ExpenseModel {
    //typealias Gas = 0
    private (set) var expenses = [[Expense](),[Expense](),[Expense](),[Expense]()]
    
    static let DATABASE = "http://localhost:3000/expenses"
    
//    mutating func importFromJson(data: Data) {
//        if let dowloadedVehicles = try? JSONDecoder().decode([Vehicle].self, from: data){
//            vehicles = dowloadedVehicles
//        }else{
//
//        }
//    }
//    mutating func choose(_ chosenVehicle: Vehicle){
//        // change data
//    }
    mutating func initData() {
        expenses[0] = [
            .init(date: Date.from(year: 2023, month: 2, day: 3), expenseValue: 83, vehicleId: 1, amount: 50),
            .init(date: Date.from(year: 2023, month: 2, day: 12), expenseValue: 80, vehicleId: 1, amount: 49.5),
            .init(date: Date.from(year: 2023, month: 2, day: 21), expenseValue: 90, vehicleId: 1, amount: 52.4),
            .init(date: Date.from(year: 2023, month: 2, day: 23), expenseValue: 79, vehicleId: 1, amount: 45.3),
            .init(date: Date.from(year: 2023, month: 2, day: 30), expenseValue: 92, vehicleId: 1, amount: 62),
            .init(date: Date.from(year: 2023, month: 3, day: 1), expenseValue: 29, vehicleId: 1, amount: 17.2),
            .init(date: Date.from(year: 2023, month: 3, day: 5), expenseValue: 65, vehicleId: 1, amount: 40.8),
            .init(date: Date.from(year: 2023, month: 3, day: 16), expenseValue: 34, vehicleId: 1, amount: 20.3),
            .init(date: Date.from(year: 2023, month: 3, day: 23), expenseValue: 54, vehicleId: 1, amount: 26.9),
            .init(date: Date.from(year: 2023, month: 4, day: 23), expenseValue: 45, vehicleId: 1, amount: 30.1),
            .init(date: Date.from(year: 2023, month: 4, day: 25), expenseValue: 12, vehicleId: 1, amount: 7.5)
        ]
        expenses[1] = [
            .init(date: Date.from(year: 2023, month: 2, day: 3), expenseValue: 2, vehicleId: 1),
            .init(date: Date.from(year: 2023, month: 2, day: 17), expenseValue: 2.5, vehicleId: 1),
            .init(date: Date.from(year: 2023, month: 3, day: 12), expenseValue: 4, vehicleId: 1),
            .init(date: Date.from(year: 2023, month: 3, day: 23), expenseValue: 5, vehicleId: 1),
            .init(date: Date.from(year: 2023, month: 4, day: 30), expenseValue: 2, vehicleId: 1)
        ]
        expenses[2] = [
            .init(date: Date.from(year: 2023, month: 2, day: 4), expenseValue: 10, vehicleId: 1),
            .init(date: Date.from(year: 2023, month: 2, day: 16), expenseValue: 12.5, vehicleId: 1),
            .init(date: Date.from(year: 2023, month: 2, day: 28), expenseValue: 15, vehicleId: 1),
            .init(date: Date.from(year: 2023, month: 3, day: 1), expenseValue: 5, vehicleId: 1),
            .init(date: Date.from(year: 2023, month: 3, day: 10), expenseValue: 12.5, vehicleId: 1),
            .init(date: Date.from(year: 2023, month: 3, day: 27), expenseValue: 20, vehicleId: 1),
            .init(date: Date.from(year: 2023, month: 4, day: 5), expenseValue: 5, vehicleId: 1)
        ]
        expenses[3] = [
            .init(date: Date.from(year: 2023, month: 2, day: 4), expenseValue: 10, vehicleId: 1),
        ]
    }
    mutating func addExpense(IndexKey: Int, expenseValue: Double, vehicleId: Int, date: Date, amount: Double?) {
        expenses[IndexKey].append(Expense(date: date, expenseValue: expenseValue, vehicleId: vehicleId, amount: amount))
    }
}

struct Expense: Identifiable {
    var id = UUID()
    var date: Date
    var expenseValue: Double
    var vehicleId: Int
    var amount: Double?
}

extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date{
        let components = DateComponents(year: year, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
}

