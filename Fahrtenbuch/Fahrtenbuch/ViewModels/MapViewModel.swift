//
//  MapViewModel.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//
import MapKit
import OSLog
import Combine

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var navigationModel = NavigationModel()
    
    var region: MKCoordinateRegion {
        return navigationModel.region
    }
    var myRoute: MKPolyline? {
        return navigationModel.myRoute
    }
    var locationManager: CLLocationManager
    let navigationQueue = DispatchQueue(label: "navigation")
    let viewController =  HomeViewController()
    var recentLocations = [CLLocation]()
    let subject = PassthroughSubject<CLLocation, Never>()
    var cancellable: AnyCancellable?
    var regionUpdated = false
    
    let LOG = Logger()
    
    override init() {
        locationManager = CLLocationManager()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = CLActivityType.automotiveNavigation
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        super.init()
        cancellable = subject //TODO: cancel it when done?
            .debounce(for: .seconds(0.25), scheduler: RunLoop.main)
            .sink { location in
                self.locationChange(location)
            }
        locationManager.delegate = self
    }
    func checkIfLocationServicesIsEnabled() {
        navigationQueue.async {
            if !CLLocationManager.locationServicesEnabled() {
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
        subject.send(latestLocation)
        
    }
    private func locationChange(_ latestLocation: CLLocation) {
        recentLocations.append(latestLocation)
        
        let coordinates = recentLocations.map { recentLocations -> CLLocationCoordinate2D in
            return recentLocations.coordinate
        }
        let myRoute = MKPolyline(coordinates: coordinates, count: coordinates.count)
        self.navigationModel.updateRoute(route: myRoute)
        self.LOG.debug("#of coordinates: \(coordinates.count)")
//        self.LOG.debug("\r⚡️: \(Thread.current)\r 🏭: \(OperationQueue.current?.underlyingQueue?.label ?? "None")\r")
        regionUpdated = true
        let region = MKCoordinateRegion(center: latestLocation.coordinate, span: MapDetails.defaultSpan)
        self.navigationModel.updateRegion(region: region)
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
                if let coordinate = locationManager.location?.coordinate {
                    let region = MKCoordinateRegion(center: coordinate, span: MapDetails.defaultSpan)
                    navigationModel.updateRegion(region: region)
                }
            @unknown default:
                break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
