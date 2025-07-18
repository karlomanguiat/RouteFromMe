//
//  RouteViewController.swift
//  RouteFromMe
//
//  Created by Glenn Karlo Manguiat on 7/18/25.
//

import UIKit
import MapKit

class RouteViewController: UIViewController, MKMapViewDelegate, MapViewModelDelegate {
    private let mapView = MKMapView()
    private var viewModel: MapViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.frame = view.bounds
        mapView.delegate = self
        view.addSubview(mapView)
        
        let userService = UserService()
        let locationService = LocationService()
        self.viewModel = MapViewModel(userService: userService, locationService: locationService)
        self.viewModel.delegate = self
        
        viewModel.fetchRouteToUser()
    }
    
    func didLoadRoute(_ route: MKRoute, from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, toName: String) {
        let userAnnotation = MKPointAnnotation()
        userAnnotation.title = "You"
        userAnnotation.coordinate = from
        
        let targetAnnotation = MKPointAnnotation()
        targetAnnotation.title = toName
        targetAnnotation.coordinate = to
        
        mapView.addAnnotations([targetAnnotation, userAnnotation])
        mapView.addOverlay(route.polyline)
        mapView.showAnnotations([userAnnotation, targetAnnotation], animated: true)
    }
    
    func didFail(_ error: String) {
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKPolyline else { return MKOverlayRenderer() }
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .blue
        return renderer
    }
    


}
