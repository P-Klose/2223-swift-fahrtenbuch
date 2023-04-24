//
//  MapViewModel.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//
import MapKit
import OSLog

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 48.268590, longitude: 14.251270)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
}

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(center: MapDetails.startingLocation, span: MapDetails.defaultSpan)
    
    var locationManager = CLLocationManager()
    let navigationQueue = DispatchQueue(label: "navigation")
    let viewController =  HomeViewController()
    let LOG = Logger()
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.activityType = CLActivityType.automotiveNavigation
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
    }
    func checkIfLocationServicesIsEnabled() {
        navigationQueue.async {
            if CLLocationManager.locationServicesEnabled() {
                
            } else {
                self.LOG.info("Standortfunktionen sind deaktiviert")
                self.viewController.showAllertWith(title: "Fehler", message: "Standortfunktionen sind deaktiviert", buttonTitle: "OK")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else {
            self.viewController.showAllertWith(title: "Fehler", message: "Es wurde kein letzter Standort gefunden", buttonTitle: "OK")
            LOG.info("No last location found")
            return
        }
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(center: latestLocation.coordinate, span: MapDetails.defaultSpan)
        }
    }
    
    private func checkLocationAuthorization() {
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
            self.viewController.showAllertWith(title: "Fehler", message: "Standortfunktionen sind eingeschränkt bitte prüfen Sie Ihre Einstellungen", buttonTitle: "OK")
        case .denied:
            self.viewController.showAllertWith(title: "Fehler", message: "Standortfunktionen sind deaktiviert bitte aktivieren Sie Sie in den Einstellungen", buttonTitle: "OK")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MapDetails.defaultSpan)
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
