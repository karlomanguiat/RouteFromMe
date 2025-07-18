//
//  LocationService.swift
//  RouteFromMe
//
//  Created by Glenn Karlo Manguiat on 7/18/25.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate: AnyObject {
    func didUpdateLocation(_ coordinate: CLLocationCoordinate2D)
}

protocol LocationServiceProtocol {
    var delegate: LocationServiceDelegate? { get set }
    var lastKnownLocation: CLLocationCoordinate2D? { get }
    func setup()
}

class LocationService: NSObject, LocationServiceProtocol {
    private let manager = CLLocationManager()
    weak var delegate: LocationServiceDelegate?
    var lastKnownLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func setup() {
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.startUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("LOCATION RECEIVED:", locations)
        if let coordinate = locations.last?.coordinate {
            lastKnownLocation = coordinate
            delegate?.didUpdateLocation(coordinate)
            manager.stopUpdatingLocation()
        }
    }
}
