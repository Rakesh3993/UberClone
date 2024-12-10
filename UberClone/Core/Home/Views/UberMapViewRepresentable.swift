//
//  UberMapViewRepresentable.swift
//  UberClone
//
//  Created by Rakesh Kumar on 06/12/24.
//

import Foundation
import SwiftUI
import MapKit

struct UberMapViewRepresentable: UIViewRepresentable {
    let mapView = MKMapView()
    let locationManger = LocationManager()
    @Binding var mapState: MapViewState
    @EnvironmentObject private var locationSearchViewModel: LocationSearchViewModel
    
    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        switch mapState {
        case .noInput:
            context.coordinator.clearMapViewAndRecenterUserLocation()
            
        case .searchingForLocation:
            break
        case .locationSelected:
            guard let coordinate = locationSearchViewModel.selectedUberLocation?.coordinate else { return }
            if context.coordinator.currentPolyline == nil {
                context.coordinator.addAndSelectAnnotation(withCoordinate: coordinate)
                context.coordinator.configurePolyline(withDestinationCoordinate: coordinate)
            }
            break
        case .polylineAdded:
            break
        }
    
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }
}

extension UberMapViewRepresentable {
    
    class MapCoordinator: NSObject, MKMapViewDelegate {
        let parent: UberMapViewRepresentable
        var userLocationCoordinate: CLLocationCoordinate2D?
        var currentRegion: MKCoordinateRegion?
        var currentPolyline: MKPolyline?
        
        init(parent: UberMapViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            self.userLocationCoordinate = userLocation.coordinate
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            currentRegion = region
            parent.mapView.setRegion(region, animated: true)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
            let polyline = MKPolylineRenderer(overlay: overlay)
            polyline.strokeColor = .systemBlue
            polyline.lineWidth = 6
            return polyline
        }
        
        func addAndSelectAnnotation(withCoordinate coordinate: CLLocationCoordinate2D) {
            // remove annotation
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            
            let pin = MKPointAnnotation()
            pin.coordinate = coordinate
            parent.mapView.addAnnotation(pin)
            parent.mapView.selectAnnotation(pin, animated: true)
            parent.mapView.showAnnotations(parent.mapView.annotations, animated: true)
        }
        
        func configurePolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D) {
            guard let userLocation = self.userLocationCoordinate else { return }
            parent.locationSearchViewModel.getDestinationRoute(from: userLocation, to: coordinate) { result in
                print("DEBUG: Adding polyline...")
                self.parent.mapState = .polylineAdded
                self.parent.mapView.addOverlay(result.polyline)
                let rect = self.parent.mapView.mapRectThatFits(result.polyline.boundingMapRect, edgePadding: .init(top: 64, left: 32, bottom: 550, right: 32))
                self.parent.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
        }
        
        func clearMapViewAndRecenterUserLocation() {
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            parent.mapView.removeOverlays(parent.mapView.overlays)
        
            if let currentRegion = currentRegion {
                parent.mapView.setRegion(currentRegion, animated: true)
            }
        }
    }
}
