//
//  MyViewController.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 10.04.23.
//

import UIKit

class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up your UI elements here
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Do some setup work before the view appears
    }
    
    func showAllertWith(title: String, message: String, buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: buttonTitle, style: .default))
            present(alert, animated: true)
    }
    
    @IBAction func saveVehicleButtonTapped(_ sender: Any) {
        /*
        // Daten validieren
        guard let make = makeTextField.text, !make.isEmpty else {
            // Fehlermeldung anzeigen, wenn Marke nicht eingegeben wurde
            let alert = UIAlertController(title: "Fehler", message: "Bitte geben Sie eine Marke ein", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        guard let model = modelTextField.text, !model.isEmpty else {
            // Fehlermeldung anzeigen, wenn Modell nicht eingegeben wurde
            let alert = UIAlertController(title: "Fehler", message: "Bitte geben Sie ein Modell ein", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        guard let mileageText = mileageTextField.text, let mileage = Int(mileageText) else {
            // Fehlermeldung anzeigen, wenn Kilometerstand ungültig ist
            let alert = UIAlertController(title: "Fehler", message: "Bitte geben Sie einen gültigen Kilometerstand ein", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Neues Auto-Objekt erstellen und in Datenbank speichern
        let newCar = Vehicle(make: make, model: model, mileage: mileage)
        saveCarToDatabase(newCar)
        
        // Formularfelder leeren
        makeTextField.text = ""
        modelTextField.text = ""
        mileageTextField.text = ""
         */
    }

    // Other methods and properties can go here
         
}
