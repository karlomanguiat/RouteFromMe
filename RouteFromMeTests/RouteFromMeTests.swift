//
//  RouteFromMeTests.swift
//  RouteFromMeTests
//
//  Created by Glenn Karlo Manguiat on 7/18/25.
//

import XCTest
import MapKit
@testable import RouteFromMe

final class RouteFromMeTests: XCTestCase {

    // Mocks
    class MockUserService: UserServiceProtocol {
        var shouldReturnUser = true
        var userToReturn: User? = nil

        func fetchUser(completion: @escaping (User?) -> Void) {
            if shouldReturnUser {
                completion(userToReturn)
            } else {
                completion(nil)
            }
        }
    }

    class MockLocationService: LocationServiceProtocol {
        var lastKnownLocation: CLLocationCoordinate2D?
        weak var delegate: LocationServiceDelegate?

        func setup() {
            // Simulate location update
            let mockLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // San Francisco
            delegate?.didUpdateLocation(mockLocation)
        }
    }

    // Delegate recorder
    class DelegateRecorder: MapViewModelDelegate {
        var routeCalled = false
        var route: MKRoute?
        var error: String?

        var fromCoordinate: CLLocationCoordinate2D?
        var toCoordinate: CLLocationCoordinate2D?
        var userName: String?

        func didLoadRoute(_ route: MKRoute, from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, toName: String) {
            routeCalled = true
            self.route = route
            self.fromCoordinate = from
            self.toCoordinate = to
            self.userName = toName
        }

        func didFail(_ error: String) {
            self.error = error
        }
    }
    
    func test_fetchRoute_success() {
        let mockUser = User(name: "Dio", address: Address(geo: Geo(lat: "37.7793", lng: "-122.4192")))
        
        let mockUserService = MockUserService()
        mockUserService.shouldReturnUser = true
        mockUserService.userToReturn = mockUser
        
        let mockLocationService = MockLocationService()
        let mockDelegateRecorder = DelegateRecorder()
        let viewModel = MapViewModel(userService: mockUserService, locationService: mockLocationService)
        
        viewModel.delegate = mockDelegateRecorder
        
        let promise = expectation(description: "Fetch route success")
        
        viewModel.fetchRouteToUser()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if mockDelegateRecorder.routeCalled {
                XCTAssertEqual(mockDelegateRecorder.userName, "Dio")
                XCTAssertNotNil(mockDelegateRecorder.route)
                promise.fulfill()
            } else if let error = mockDelegateRecorder.error {
                XCTFail("Expected success, got error: \(error)")
                promise.fulfill()
            } else {
                XCTFail("Neither success nor failure callback was called.")
                promise.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5.0)
    }
    
    func test_fetchRoute_failure() {
        let mockUserService = MockUserService()
        mockUserService.shouldReturnUser = false
        
        let mockLocationService = MockLocationService()
        let mockDelegateRecorder = DelegateRecorder()
        
        let viewModel = MapViewModel(userService: mockUserService, locationService: mockLocationService)
        viewModel.delegate = mockDelegateRecorder
        
        let promise = expectation(description: "Fetch route failure")
        
        viewModel.fetchRouteToUser()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNil(mockDelegateRecorder.route)
            XCTAssertNil(mockDelegateRecorder.userName)
            promise.fulfill()
        }
        waitForExpectations(timeout: 3.0)
    }
    
    
    func test_fetchRoute_invalidCoordinates() {
        let mockUser = User(name: "Dio", address: Address(geo: Geo(lat: "invalid", lng: "invalid")))
        
        let mockUserService = MockUserService()
        mockUserService.shouldReturnUser = true
        mockUserService.userToReturn = mockUser
        
        let mockLocationService = MockLocationService()
        let mockDelegateRecorder = DelegateRecorder()
        
        let viewModel = MapViewModel(userService: mockUserService, locationService: mockLocationService)
        
        viewModel.delegate = mockDelegateRecorder
        
        let promise = expectation(description: "Fetch route failure - Invalid coordinates")
        viewModel.fetchRouteToUser()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNil(mockDelegateRecorder.route)
            XCTAssertEqual(mockDelegateRecorder.error, "Failed to fetch user location")
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
    }
}
