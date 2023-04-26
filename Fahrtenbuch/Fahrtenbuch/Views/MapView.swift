//
//  MapView.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 25.04.23.
//

import MapKit
import SwiftUI
import OSLog

struct MapView: UIViewRepresentable {
    var routeOverlay: MKPolyline?
    var region: MKCoordinateRegion
    let LOG = Logger()
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(region, animated: true)
        //LOG.debug("\(routeOverlay != nil)")
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
        let LOG = Logger()
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            self.LOG.debug("Call Map Renderer")
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = .blue
            lineView.lineCap = .round
            lineView.lineWidth = 3.0
            
            return lineView
        }
    }
    
}
