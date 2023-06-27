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
    let tripViewModel = TripViewModel()
    
    private final let DATABASE = TripModel.DATABASE
    
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
    
    //MARK: Trip Recoring
    var selectedVehicleId: Int = -1
    var isPrivateTrip: Bool = false
    var recording = false
    var isStopped = false
    
    let LOG = Logger()
    
    override init() {
        locationManager = CLLocationManager()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = CLActivityType.automotiveNavigation
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        super.init()
        cancellable = subject //TODO: cancel it when done?
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
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
        //        if(recording) {
        subject.send(latestLocation)
        //        }
    }
    
    private func locationChange(_ latestLocation: CLLocation) {
        if(isStopped && recentLocations.count != 0){
            self.LOG.debug("Stop Recording")
            
            let coordinatesArray = recentLocations.map { [$0.coordinate.longitude, $0.coordinate.latitude] }
            var totalDistance = 0.0

            for i in 0..<recentLocations.count-1 {
                let currentLocation = recentLocations[i]
                let nextLocation = recentLocations[i+1]
                let distance = currentLocation.distance(from: nextLocation)
                totalDistance += distance
            }
            tripViewModel.saveTrip(vehicleId: selectedVehicleId, date: Date(), coordinates: coordinatesArray, isPrivat: isPrivateTrip, distanceTraveled: totalDistance)
            
            self.LOG.debug("Recent Locations: \(coordinatesArray)")
            recentLocations = [CLLocation]()
            isStopped=false
            return
        }else if(recording){
            recentLocations.append(latestLocation)
            
            let coordinates = recentLocations.map { recentLocations -> CLLocationCoordinate2D in
                return recentLocations.coordinate
            }
            let myRoute = MKPolyline(coordinates: coordinates, count: coordinates.count)
            self.navigationModel.updateRoute(route: myRoute)
            self.LOG.debug("#of coordinates: \(coordinates.count)")
        }
        /// for region updates on map (follow possision)
        ///
        let region = MKCoordinateRegion(center: latestLocation.coordinate, span: MapDetails.defaultSpan)
            navigationModel.updateRegion(region: region)
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
    
    //Trip
    
    func startRecording(vehicle: Int, isPrivat: Bool){
        recording = true
        selectedVehicleId = vehicle
        isPrivateTrip = isPrivat
    }
    func stopRecording(){
        recording = false
        isStopped = true
    }
}
