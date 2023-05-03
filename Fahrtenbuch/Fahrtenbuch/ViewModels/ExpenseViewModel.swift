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
        var toReturn = 0.0;
        for expense in expenses {
            toReturn = toReturn + expense.reduce(0.0, { $0 + Double($1.expenseValue) })
        }
        return toReturn
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
