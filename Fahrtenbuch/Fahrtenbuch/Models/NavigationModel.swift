
import MapKit

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 48.268590, longitude: 14.251270)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
}
struct NavigationModel {
    private (set) var region = MKCoordinateRegion(center: MapDetails.startingLocation, span: MapDetails.defaultSpan)
    private (set) var myRoute: MKPolyline?
    
    mutating func updateRegion(region: MKCoordinateRegion) {
        self.region = region
    }
    mutating func updateRoute(route: MKPolyline?) {
        myRoute = route
    }
}
