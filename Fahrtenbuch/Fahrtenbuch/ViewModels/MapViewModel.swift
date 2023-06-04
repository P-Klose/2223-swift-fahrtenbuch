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
    private final let DATABASE = TripModel.DATABASE
    
    var region: MKCoordinateRegion {
        return navigationModel.region
    }
    var myRoute: MKPolyline? {
        return navigationModel.myRoute
    }
    @Published private var tripModel = TripModel()
    var trips:[Trip] {
        tripModel.trips
    }

    
    var locationManager: CLLocationManager
    let navigationQueue = DispatchQueue(label: "navigation")
    let viewController =  HomeViewController()
    var recentLocations = [CLLocation]()
    let subject = PassthroughSubject<CLLocation, Never>()
    var cancellable: AnyCancellable?
    var recording = false
    var isStopped = false
    var selectedVehicleId = -1
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
    
    func startRecording(vehicle: Int){
        recording = true
        selectedVehicleId = vehicle
    }
    func stopRecording(){
        recording = false
        isStopped = true
    }
    
    func saveTrip(vehicleId: Int, date: Date, coordinates: [[Double]], distanceTraveled: Double) {
        let toSaveTrip = Trip(id: nil, coordinates: IntArrayToCoordinatesUsing(numbers: coordinates), length: distanceTraveled, date: date, vehicleId: vehicleId)
        saveTripToDatabase(trip: toSaveTrip){ success in
            if success {
                self.LOG.info("🟢 Trip Saved in Database")
            } else {
                self.LOG.error("🔴 Trip not saved in Database")
            }
        }
        self.tripModel.add(trip: toSaveTrip)
        LOG.info("#of trips \(self.tripModel.trips.count)")
    }
    private func IntArrayToCoordinatesUsing(numbers: [[Double]]) -> [Coordinate] {
        var finalCoordinates = [Coordinate]()
        for (index,coordinates) in numbers.enumerated() {
            finalCoordinates.append(Coordinate(id: index, latitude: coordinates[0], longitude: coordinates[1]))
        }
        return finalCoordinates
    }
    

    func animateTrip(index: Int) {
        tripModel.animateTrip(index: index)
    }
    
    func saveTripToDatabase(trip: Trip, completion: @escaping (Bool) -> Void) {
        var success = true
        let finalUrl = "\(DATABASE)"
        
        if let url = URL(string: finalUrl){
            print(finalUrl)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            let jsonData = try! encoder.encode(trip)
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
                    //self.downloadAllTrips()
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
    }
    
    func downloadAllTrips() {
        let downloadQueue = DispatchQueue(label: "Download Trips")
        downloadQueue.async {
            if let data = MapViewModel.load(){
                DispatchQueue.main.async {
                    self.tripModel.importFromJson(data: data)
                }
            }
        }
    }
    
    func generateYearlyTrips() -> [Trip] {
        var yearlyTrips = [Trip]()
        
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        
        for month in 1...12 {
            let monthDateComponents = DateComponents(year: currentYear, month: month)
            guard let monthDate = calendar.date(from: monthDateComponents) else {
                continue
            }
            
            let trip = Trip(length: calculateExpenseSum(forMonth: month), date: monthDate, vehicleId: -1)
            yearlyTrips.append(trip)
        }
        
        return yearlyTrips
    }
    
    func generateWeeklyTrips() -> [Trip] {
        let currentDate = Date()
        let calendar = Calendar.current

        var expenses = [Trip]()

        // Generiere Ausgaben für jeden Wochentag der aktuellen Woche
        for day in 1...7 {
            guard let weekday = calendar.date(byAdding: .day, value: day - calendar.component(.weekday, from: currentDate), to: currentDate) else {
                continue
            }

            let expense = Trip(length: calculateExpenseSum(forDay: weekday), date: weekday, vehicleId: -1)
            expenses.append(expense)
        }

        return expenses
    }
    
    func generateMonthlyTrips() -> [Trip] {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)

        var expenses = [Trip]()

        // Generiere Ausgaben für jeden Tag des aktuellen Monats
        if let range = calendar.range(of: .day, in: .month, for: currentDate) {
            for day in range {
                let dayDateComponents = DateComponents(year: currentYear, month: currentMonth, day: day)
                guard let dayDate = calendar.date(from: dayDateComponents) else {
                    continue
                }

                let expense = Trip(length: calculateExpenseSum(forDay: dayDate), date: dayDate, vehicleId: -1)
                expenses.append(expense)
            }
        }

        return expenses
    }
    
    
    func calculateExpenseSum(forMonth month: Int) -> Double {
        let calendar = Calendar.current
        let filteredExpenses = trips.filter { calendar.component(.month, from: $0.date) == month }
        let expenseSum = filteredExpenses.reduce(0.0) { $0 + $1.length }
        return expenseSum
    }
    
    func calculateExpenseSum(forDay day: Date) -> Double {
        let calendar = Calendar.current
        let filteredExpenses = trips.filter { calendar.isDate($0.date, inSameDayAs: day) }
        
        // Berechne die Summe der expenseValue-Werte für das angegebene Datum
        let expenseSum = filteredExpenses.reduce(0) { $0 + $1.length }
        
        return expenseSum
    }
    
    
    
    static func load() -> Data? {
        var data: Data?
        if let url = URL(string: TripModel.DATABASE) {
            data = try? Data(contentsOf: url)
        }
        return data
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
            saveTrip(vehicleId: selectedVehicleId, date: Date(), coordinates: coordinatesArray, distanceTraveled: totalDistance)
            
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
        //        regionUpdated = true
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
