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
    @StateObject var mapViewModel: MapViewModel
    let delegate = PolyLineDelegate()
    let LOG = Logger()
    var customEdgePadding: UIEdgeInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = delegate
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(mapViewModel.region, animated: true)
        if mapViewModel.myRoute != nil {
            view.removeOverlays(view.overlays)
            view.addOverlay(mapViewModel.myRoute!, level: .aboveLabels)
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
    }
    
}
class PolyLineDelegate: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer: MKOverlayRenderer
        if let routePolyLine = overlay as? MKPolyline {
            let polyLineRenderer = MKPolylineRenderer(polyline: routePolyLine)
            polyLineRenderer.strokeColor = UIColor.systemBlue
            polyLineRenderer.lineWidth = 4
            renderer = polyLineRenderer
        } else {
            renderer = MKOverlayRenderer()
        }
        return renderer
    }
}
