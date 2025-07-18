//
//  ViewController.swift
//  RouteFromMe
//
//  Created by Glenn Karlo Manguiat on 7/18/25.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, MapViewModelDelegate {
    private let mapView = MKMapView()
    private var viewModel: MapViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.frame = view.bounds
        mapView.delegate = self
        view.addSubview(mapView)
        
        [latField, lonField, goButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            latField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            latField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            latField.widthAnchor.constraint(equalToConstant: 120),
            
            lonField.leadingAnchor.constraint(equalTo: latField.trailingAnchor, constant: 8),
            lonField.topAnchor.constraint(equalTo: latField.topAnchor),
            lonField.widthAnchor.constraint(equalToConstant: 120),
            
            goButton.leadingAnchor.constraint(equalTo: lonField.trailingAnchor, constant: 8),
            goButton.centerYAnchor.constraint(equalTo: latField.centerYAnchor),
        ])
        
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
    

    private let latField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Latitude"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        return tf
    }()

    private let lonField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Longitude"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        return tf
    }()

    private let goButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Go", for: .normal)
        btn.addTarget(ViewController.self, action: #selector(didTapGo), for: .touchUpInside)
        return btn
    }()
    
    @objc func didTapGo() {
        guard let lat = Double(latField.text ?? ""),
              let lon = Double(lonField.text ?? "") else {
            didFail("Invalid coordinates")
            return
        }
        viewModel.routeToManualCoordinate(latitude: lat, longitude: lon)
    }
}
