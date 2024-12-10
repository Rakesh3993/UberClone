//
//  LocationSearchViewModel.swift
//  UberClone
//
//  Created by Rakesh Kumar on 07/12/24.
//

import Foundation
import MapKit
import SwiftUICore

class LocationSearchViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    
    @Published var results = [MKLocalSearchCompletion]()
    @Published var selectedUberLocation: UberLocation?
    @Published var pickUpTime: String?
    @Published var dropOffTime: String?
    
    private let searchCompleter = MKLocalSearchCompleter()
    var queryFragment: String = "" {
        didSet {
            searchCompleter.queryFragment = queryFragment
        }
    }
    
    var userLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.queryFragment = queryFragment
    }
    
    // MARK: - Helper
    func selectLocation(_ localSearch: MKLocalSearchCompletion) {
        locationSearch(forLocalSearchCompletion: localSearch) { response, error in
            if let error = error {
                print("DEBUG: Location search failed with error \(error.localizedDescription)")
                return
            }
            
            guard let item = response?.mapItems.first else {return}
            let coordinate = item.placemark.coordinate
            self.selectedUberLocation = UberLocation(title: localSearch.title, coordinate: coordinate)
        }
    }
    
    func locationSearch(forLocalSearchCompletion localSearch: MKLocalSearchCompletion, completion: @escaping MKLocalSearch.CompletionHandler) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        
        let search = MKLocalSearch(request: searchRequest)
        search.start(completionHandler: completion)
    }
    
    func calculateRidePrice(forType type: RideType) -> Double {
        guard let destCoordinate = selectedUberLocation?.coordinate else { return 0.0 }
        guard let userCoordinate = userLocation else {return 0.0 }
        
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let destination = CLLocation(latitude: destCoordinate.latitude, longitude: destCoordinate.longitude)
        
        let distanceInMeter = userLocation.distance(from: destination)
        print(distanceInMeter)
        return type.computePrices(for: distanceInMeter)
    }
    
    func getDestinationRoute(from userLocation: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping(MKRoute) -> ()){
        let userPlacemark = MKPlacemark(coordinate: userLocation)
        let destPlaceMark = MKPlacemark(coordinate: destination)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlacemark)
        request.destination = MKMapItem(placemark: destPlaceMark)
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                print("DEBUG: Failed to get directions with error \(error.localizedDescription)")
                return
            }
            
            guard let route = response?.routes.first else { return }
            self.pickUpAndDropOffTime(with: route.expectedTravelTime)
            completion(route)
        }
    }
    
    func pickUpAndDropOffTime(with expectedTime: Double) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        
        pickUpTime = formatter.string(from: Date())
        dropOffTime = formatter.string(from: Date() + expectedTime)
    }
}

extension LocationSearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
}
