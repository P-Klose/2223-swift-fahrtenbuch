//
//  VehicleViewModel.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 11.04.23.
//

import Foundation

class VehicleViewModel: ObservableObject {
    
    @Published private var model = VehicleModel()
    var vehicles:[Vehicle] {
        model.vehicles
    }
    
    func downloadAllVehicles() {
        let downloadQueue = DispatchQueue(label: "Download Vehicles")
        downloadQueue.async {
            if let data = VehicleViewModel.load(){
                print("downloading")
                DispatchQueue.main.async {
                    print("import JSON")
                    self.model.importFromJson(data: data)
                }
            }
        }
    }
    static func load() -> Data? {
        var data: Data?
        if let url = URL(string: VehicleModel.DATABASE) {
            data = try? Data(contentsOf: url)
        }
        return data
    }
    
    func saveButtonTapped(make: String, model: String, vin: String, milage: String, numberplate: String) {
        
        let newVehilce = Vehicle(id: nil, vin: vin, make: make, numberplate: numberplate, model: model, milage: milage)
        
        saveCarToDatabase(vehicle: newVehilce) { success in
            if success {
//                let alert = UIAlertController(title: "Erfolg", message: "Das Auto wurde erfolgreich gespeichert", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                self.present(alert, animated: true)
                self.downloadAllVehicles()
            } else {
//                let alert = UIAlertController(title: "Fehler", message: "Das Auto konnte nicht gespeichert werden", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                self.present(alert, animated: true)
            }
        }
    }
    func update(vehicle: Vehicle, make: String, model: String, vin: String, milage: String, numberplate: String) {
        
        let updatedVehilce = Vehicle(id: vehicle.id, vin: vin, make: make, numberplate: numberplate, model: model, milage: milage)
        
        saveCarToDatabase(vehicle: updatedVehilce) { success in
            if success {
//                let alert = UIAlertController(title: "Erfolg", message: "Das Auto wurde erfolgreich gespeichert", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                self.present(alert, animated: true)
                self.downloadAllVehicles()
            } else {
//                let alert = UIAlertController(title: "Fehler", message: "Das Auto konnte nicht gespeichert werden", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .default))
//                self.present(alert, animated: true)
            }
        }
    }
    
    func saveCarToDatabase(vehicle: Vehicle, completion: @escaping (Bool) -> Void) {
        var success = true
        let url = URL(string: "http://localhost:3000/vehicles")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(vehicle)
        request.httpBody = jsonData

        // Erstelle die URLSession und den Datentask
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            // Handle die Antwort vom Server
            if let error = error {
                print("Fehler: \(error)")
                success = false
            } else if let data = data {
                print("Antwort: \(String(data: data, encoding: .utf8) ?? "")")
            } else {
                print("Keine Daten erhalten")
                success = false
            }
        }

        // Starte den Datentask
        task.resume()
        
        completion(success)
    }
    
}
