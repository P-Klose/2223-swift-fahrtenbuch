//
//  MapView.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 25.04.23.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    var routeOverlay: MKOverlay?
    var region: MKCoordinateRegion
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(region, animated: true)
        if routeOverlay != nil {
            view.removeOverlays(view.overlays)
            view.addOverlay(routeOverlay!, level: .aboveRoads)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKGradientPolylineRenderer(overlay: overlay)
            renderer.setColors([
                .black
            ], locations: [])
            
            renderer.lineCap = .round
            renderer.lineWidth = 3.0
            
            return renderer
        }
    }
    
}
