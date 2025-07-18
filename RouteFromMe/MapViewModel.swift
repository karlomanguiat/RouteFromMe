//
//  MapViewModel.swift
//  RouteFromMe
//
//  Created by Glenn Karlo Manguiat on 7/18/25.
//

import Foundation
import MapKit

protocol MapViewModelDelegate: AnyObject {
    func didLoadRoute(_ route: MKRoute, from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, toName: String)
    func didFail(_ error: String)
}

class MapViewModel: LocationServiceDelegate {
   
    weak var delegate: MapViewModelDelegate?
    
    private let userService: UserServiceProtocol
    private var locationService: LocationServiceProtocol
    
    init(userService: UserServiceProtocol, locationService: LocationServiceProtocol) {
        self.userService = userService
        self.locationService = locationService
        self.locationService.delegate = self
    }
    
    func fetchRouteToUser() {
        locationService.setup()
    }
    
    func didUpdateLocation(_ coordinate: CLLocationCoordinate2D) {
        
        userService.fetchUser { [weak self] user in
            guard let self = self,
                let user = user,
                let lat = Double(user.address.geo.lat),
                let lng = Double(user.address.geo.lng)
            else {
                self?.delegate?.didFail("Failed to fetch user location")
                return
            }
            
            let destinationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let source = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
            let destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
            
            let request = MKDirections.Request()
            request.source = source
            request.destination = destination
            request.transportType = .automobile
            
            MKDirections(request: request).calculate { response, error in
                if let route = response?.routes.first {
                    DispatchQueue.main.async {
                        self.delegate?.didLoadRoute(route, from: coordinate, to: destinationCoordinate, toName: user.name)
                    }
                } else {
                    self.delegate?.didFail("Failed to fetch route")
                }
            }
        }
    }
    
    func routeToManualCoordinate(latitude: Double, longitude: Double) {
        guard let lastKnown = locationService.lastKnownLocation else {
            delegate?.didFail("Current location not available.")
            return
        }

        let destinationCoord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let source = MKMapItem(placemark: MKPlacemark(coordinate: lastKnown))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoord))

        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = .automobile

        MKDirections(request: request).calculate { [weak self] response, error in
            if let route = response?.routes.first {
                DispatchQueue.main.async {
                    self?.delegate?.didLoadRoute(route, from: lastKnown, to: destinationCoord, toName: "Manual Target")
                }
            } else {
                self?.delegate?.didFail("Failed to calculate route.")
            }
        }
    }
    
}
