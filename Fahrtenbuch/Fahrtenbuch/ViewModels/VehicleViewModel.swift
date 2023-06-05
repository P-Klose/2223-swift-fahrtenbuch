//
//  VehicleViewModel.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 11.04.23.
//

import Foundation

class VehicleViewModel: ObservableObject {
    
    private final let DATABASE = "http://localhost:3000/vehicles"
    @Published private var model = VehicleModel()
    var vehicles:[Vehicle] {
        model.vehicles
    }
    
    func downloadAllVehicles() {
        let downloadQueue = DispatchQueue(label: "Download Vehicles")
        downloadQueue.async {
            if let data = VehicleViewModel.load(){
                DispatchQueue.main.async {
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
    
    func saveButtonTapped(make: String, model: String, vin: String, milage: String, numberplate: String, imageUrl: String, vehicleType: String, fuelType: String) {
        
        let newVehilce = Vehicle(id: nil, vin: vin, make: make, numberplate: numberplate, model: model, milage: milage, imageUrl: imageUrl, vehicleType: vehicleType, fuelType: fuelType)
        print("ImageURL: \(imageUrl)")
        
        saveCarToDatabase(vehicle: newVehilce, httpMethod: "POST") { success in
            if success {
                
            } else {
                
            }
        }
    }
    func update(vehicle: Vehicle, make: String, model: String, vin: String, milage: String, numberplate: String, imageUrl: String, vehicleType: String, fuelType: String) {
        
        let updatedVehilce = Vehicle(id: vehicle.id, vin: vin, make: make, numberplate: numberplate, model: model, milage: milage, imageUrl: imageUrl, vehicleType: vehicleType, fuelType: fuelType)
        print(imageUrl)
        
        saveCarToDatabase(vehicle: updatedVehilce, httpMethod: "PUT") { success in
            if success {
                //                let alert = UIAlertController(title: "Erfolg", message: "Das Auto wurde erfolgreich gespeichert", preferredStyle: .alert)
                //                alert.addAction(UIAlertAction(title: "OK", style: .default))
                //                self.present(alert, animated: true)
            } else {
                //                let alert = UIAlertController(title: "Fehler", message: "Das Auto konnte nicht gespeichert werden", preferredStyle: .alert)
                //                alert.addAction(UIAlertAction(title: "OK", style: .default))
                //                self.present(alert, animated: true)
            }
        }
    }
    
    func deleteVehicle(_ vehicle: Vehicle) {
        let finalUrl =  "\(DATABASE)/\(vehicle.id ?? -1)"
        
        if let url = URL(string: finalUrl){
            print(finalUrl)
            
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            
            // Erstelle die URLSession und den Datentask
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                // Handle die Antwort vom Server
                if let error = error {
                    print("Fehler: \(error)")
                } else if let data = data {
                    print("Antwort: \(String(data: data, encoding: .utf8) ?? "")")
                    self.downloadAllVehicles()
                } else {
                    print("Keine Daten erhalten")
                }
            }
            // Starte den Datentask
            task.resume()
        }
    }
    
    func saveCarToDatabase(vehicle: Vehicle, httpMethod: String, completion: @escaping (Bool) -> Void) {
        var success = true
        let finalUrl =  "\(DATABASE)"
        
        if let url = URL(string: finalUrl){
            print(finalUrl)
            
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod
            
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
                    self.downloadAllVehicles()
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
    
}
