//
//  CoreLocationControllerTests.swift
//  PlacesTests
//
//  Created by Andrei on 13/09/2023.
//

import XCTest
import Places
import CoreLocation

class CoreLocationManagerTests: XCTestCase {
    func test_init_doesNotRequestAuthorizationWhenInUse() {
        let (_, manager) = makeSUT()
        
        XCTAssertEqual(manager.requestWhenInUseAuthorizationCallCount, 0)
    }
    
    func test_init_doesNotRequestAuthorizedAlways() {
        let (_, manager) = makeSUT()
        
        XCTAssertEqual(manager.requestAuthorizedAlwaysCallCount, 0)
    }
    
    func test_init_setsDesiredAccuracy() {
        let (_, manager) = makeSUT()
        
        XCTAssertEqual(manager.desiredAccuracy, kCLLocationAccuracyHundredMeters)
    }

    func test_requestAuthorization_requestsWenInUseAuthorization() {
        let (sut, manager) = makeSUT()
        
        sut.requestAuthorization()
        
        XCTAssertEqual(manager.requestWhenInUseAuthorizationCallCount, 1)
    }
    
    func test_startUpdating_callsLocationManagerStartUpdating() {
        let (sut, manager) = makeSUT()
        
        sut.startUpdating()

        XCTAssertEqual(manager.startUpdatingLocationCallCount, 1)
    }

    func test_startUpdating_setsDelegate() {
        let (sut, manager) = makeSUT()
        
        sut.startUpdating()

        XCTAssertNotNil(manager.delegate, "Expected to set delegate on startUpdating call")
    }

    func test_stopUpdating_callsLocationManagerStopUpdating() {
        let (sut, manager) = makeSUT()
        
        sut.stopUpdating()

        XCTAssertEqual(manager.stopUpdatingLocationCallCount, 1)
    }

    func test_stopUpdating_unsetsDelegate() {
        let (sut, manager) = makeSUT()
        
        sut.stopUpdating()

        XCTAssertNil(manager.delegate, "Expected to set delegate to nil on stopUpdating call")
    }

    func test_startUpdating_deliversValues() {
        var (sut, _) = makeSUT()

        let exp = expectation(description: "Waiting for coordinates")
        
        let handler: ((Location) -> Void) = { location in
            exp.fulfill()
        }
        sut.locationUpdateHandler = handler
        sut.startUpdating()

        wait(for: [exp], timeout: 1.0)
    }
    
    func test_coreLocationManagerDoesNotDeliverValuesOnDeallocate() {
        var weakSut: LocationController? = CoreLocationController(locationManager: CLLocationManagerSpy())
        
        var capturedLocation: Location?
        weakSut?.locationUpdateHandler = { location in
            capturedLocation = location
        }

        weakSut?.startUpdating()
        weakSut = nil
        
        XCTAssertNil(capturedLocation, "Should not deliver values after deallocation")
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LocationController, CLLocationManagerSpy) {
        let manager = CLLocationManagerSpy()
        let sut = CoreLocationController(locationManager: manager)

        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(manager, file: file, line: line)
        
        return (sut, manager)
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
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self else { return }
                self.delegate?.locationManager?(self, didUpdateLocations: [CLLocation(latitude: 1.0, longitude: 1.0)])
            }
        }
        
        override func stopUpdatingLocation() {
            stopUpdatingLocationCallCount += 1
        }
    }
}
