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
        self.locationManager = locationManager
    }

//    func requestAuthorization() async -> LocationAuthorizationStatus {
//        return .granted
//    }
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
    
    private class CLLocationManagerSpy: CLLocationManager {
        var requestWhenInUseAuthorizationCallCount = 0
        
        override func requestWhenInUseAuthorization() {
            requestWhenInUseAuthorizationCallCount += 1
        }
    }
}
