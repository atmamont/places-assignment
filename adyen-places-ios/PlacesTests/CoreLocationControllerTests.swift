//
//  CoreLocationControllerTests.swift
//  PlacesTests
//
//  Created by Andrei on 13/09/2023.
//

import XCTest
import Places
import CoreLocation

final class CoreLocationController: NSObject, CLLocationManagerDelegate {
    var locationUpdateHandler: ((LocationController.Location) -> Void)?
    
    private let locationManager: CLLocationManager
    
    init(locationManager: CLLocationManager = CLLocationManager()) {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager = locationManager
    }

    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdating() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    func stopUpdating() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        
        let location = LocationController.Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
        locationUpdateHandler?(location)
    }
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
    
    func test_startUpdating_callsLocationManagerStartUpdating() {
        let manager = CLLocationManagerSpy()
        let sut = CoreLocationController(locationManager: manager)
        
        sut.startUpdating()

        XCTAssertEqual(manager.startUpdatingLocationCallCount, 1)
    }

    func test_startUpdating_setsDelegate() {
        let manager = CLLocationManagerSpy()
        let sut = CoreLocationController(locationManager: manager)
        
        sut.startUpdating()

        XCTAssertNotNil(manager.delegate, "Expected to set delegate on startUpdating call")
    }

    func test_stopUpdating_callsLocationManagerStopUpdating() {
        let manager = CLLocationManagerSpy()
        let sut = CoreLocationController(locationManager: manager)
        
        sut.stopUpdating()

        XCTAssertEqual(manager.stopUpdatingLocationCallCount, 1)
    }

    func test_stopUpdating_unsetsDelegate() {
        let manager = CLLocationManagerSpy()
        let sut = CoreLocationController(locationManager: manager)
        
        sut.stopUpdating()

        XCTAssertNil(manager.delegate, "Expected to set delegate to nil on stopUpdating call")
    }

    func test_startUpdating_deliversValues() {
        let manager = CLLocationManagerSpy()
        let sut = CoreLocationController(locationManager: manager)
        let exp = expectation(description: "Waiting for coordinates")
        
        let handler: ((LocationController.Location) -> Void) = { location in
            exp.fulfill()
        }
        sut.locationUpdateHandler = handler
        sut.startUpdating()

        wait(for: [exp], timeout: 1.0)
    }

    private class CLLocationManagerSpy: CLLocationManager {
        var requestWhenInUseAuthorizationCallCount = 0
        var requestAuthorizedAlwaysCallCount = 0
        var requestAuthorizationCallCount = 0
        var startUpdatingLocationCallCount = 0
        var stopUpdatingLocationCallCount = 0
        
        override func requestWhenInUseAuthorization() {
            requestWhenInUseAuthorizationCallCount += 1
        }
        
        override func requestAlwaysAuthorization() {
            requestAuthorizedAlwaysCallCount += 1
        }
        
        override func startUpdatingLocation() {
            startUpdatingLocationCallCount += 1
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                self.delegate?.locationManager?(self, didUpdateLocations: [CLLocation(latitude: 1.0, longitude: 1.0)])
            }
        }
        
        override func stopUpdatingLocation() {
            stopUpdatingLocationCallCount += 1
        }
    }
}
