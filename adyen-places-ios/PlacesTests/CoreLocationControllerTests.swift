//
//  CoreLocationControllerTests.swift
//  PlacesTests
//
//  Created by Andrei on 13/09/2023.
//

import XCTest
import Places
import CoreLocation

final class CoreLocationController {
    var currentLocation: LocationController.Location?
    
    private let locationManager: CLLocationManager
    
    init(locationManager: CLLocationManager = CLLocationManager()) {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager = locationManager
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
//
//    func startUpdating() {
//
//    }
//
//    func stopUpdating() {
//
//    }
}

class CoreLocationManagerTests: XCTestCase {
    func test_init_doesNotRequestAuthorizationWhenInUse() {
        let manager = CLLocationManagerSpy()
        let _ = CoreLocationController(locationManager: manager)
        
        XCTAssertEqual(manager.requestWhenInUseAuthorizationCallCount, 0)
    }
    
    func test_init_doesNotRequestAuthorizedAlways() {
        let manager = CLLocationManagerSpy()
        let _ = CoreLocationController(locationManager: manager)
        
        XCTAssertEqual(manager.requestAuthorizedAlwaysCallCount, 0)
    }
    
    func test_init_setsDesiredAccuracy() {
        let manager = CLLocationManagerSpy()
        let _ = CoreLocationController(locationManager: manager)
        
        XCTAssertEqual(manager.desiredAccuracy, kCLLocationAccuracyHundredMeters)
    }

    func test_requestAuthorization_requestsWenInUseAuthorization() {
        let manager = CLLocationManagerSpy()
        let sut = CoreLocationController(locationManager: manager)
        
        sut.requestAuthorization()
        
        XCTAssertEqual(manager.requestWhenInUseAuthorizationCallCount, 1)
    }
    
    private class CLLocationManagerSpy: CLLocationManager {
        var requestWhenInUseAuthorizationCallCount = 0
        var requestAuthorizedAlwaysCallCount = 0
        var requestAuthorizationCallCount = 0
        
        override func requestWhenInUseAuthorization() {
            requestWhenInUseAuthorizationCallCount += 1
        }
        
        override func requestAlwaysAuthorization() {
            requestAuthorizedAlwaysCallCount += 1
        }
    }
}
