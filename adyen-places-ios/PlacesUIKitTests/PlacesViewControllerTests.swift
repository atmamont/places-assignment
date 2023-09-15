//
//  PlacesViewControllerTests.swift
//  PlacesTests
//
//  Created by Andrei on 14/09/2023.
//

import XCTest
@testable import PlacesUIKit
import Places

final class PlacesViewControllerTests: XCTestCase {
    
    func test_load_doesNotTriggerFetch() {
        let loader = RemotePlacesLoaderSpy()
        let locationController = LocationControllerSpy()
        let sut = PlacesViewController(loader: loader,
                                       locationController: locationController)
        
        sut.loadView()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_init_doesNotTriggerLocationRequest() {
        let loader = RemotePlacesLoaderSpy()
        let locationController = LocationControllerSpy()
        let sut = PlacesViewController(loader: loader,
                                       locationController: locationController)
        
        XCTAssertEqual(locationController.requestAuthorizationCallCount, 0)
    }

    func test_load_triggersLocationRequest() {
        let loader = RemotePlacesLoaderSpy()
        let locationController = LocationControllerSpy()
        let sut = PlacesViewController(loader: loader,
                                       locationController: locationController)

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(locationController.requestAuthorizationCallCount, 1)
    }

    private class RemotePlacesLoaderSpy: PlacesLoader {
        var loadCallCount = 0
        func load(location: Places.Location?, radius: Int?, completion: @escaping (LoadResult) -> Void) {
            loadCallCount += 1
        }
    }
    
    private class LocationControllerSpy: LocationController {
        var requestAuthorizationCallCount = 0
        var startUpdatingCallCount = 0
        var stopUpdatingCallCount = 0

        var locationUpdateHandler: ((Places.Location) -> Void)?

        func requestAuthorization() {
            requestAuthorizationCallCount += 1
        }
        
        func startUpdating() {
            startUpdatingCallCount += 1
        }
        
        func stopUpdating() {
            stopUpdatingCallCount += 1
        }
    }
}
