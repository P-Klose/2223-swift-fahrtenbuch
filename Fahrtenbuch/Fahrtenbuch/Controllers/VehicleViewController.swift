//
//  VehicleViewController.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 10.04.23.
//

import UIKit

class VehicleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func saveButtonTapped(make: String, model: String, vin: String, milage: String, numberplate: String) {
        
        // Erstelle ein neues Car-Objekt
        let newVehilce = Vehicle(id: nil, vin: vin, make: make, numberplate: numberplate, model: model,milage: milage, imageUrl: "")
        
        // Speichere das neue Auto in der Datenbank
        saveCarToDatabase(vehicle: newVehilce) { success in
            if success {
                // Zeige Erfolgsmeldung an
                let alert = UIAlertController(title: "Erfolg", message: "Das Auto wurde erfolgreich gespeichert", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            } else {
                // Zeige Fehlermeldung an
                let alert = UIAlertController(title: "Fehler", message: "Das Auto konnte nicht gespeichert werden", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    func saveCarToDatabase(vehicle: Vehicle, completion: @escaping (Bool) -> Void) {
        // Implementiere hier die Logik zum Speichern des Autos in der Datenbank
        // ...
        
        // Hier rufen wir die completion-Handler-Funktion auf, um anzuzeigen, ob das Speichern erfolgreich war oder nicht
        let success = true // Setze auf "true", wenn das Speichern erfolgreich war, andernfalls auf "false"
        completion(success)
    }
}
