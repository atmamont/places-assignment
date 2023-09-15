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
        let (sut, _, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        usleep(1)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_init_doesNotTriggerLocationRequest() {
        let (_, locationController, _) = makeSUT()
        
        XCTAssertEqual(locationController.requestAuthorizationCallCount, 0)
    }

    func test_load_triggersLocationRequest() {
        let (sut, locationController, _) = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(locationController.requestAuthorizationCallCount, 1)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (PlacesViewController, LocationControllerSpy, RemotePlacesLoaderSpy) {
        let loader = RemotePlacesLoaderSpy()
        let locationController = LocationControllerSpy()
        let sut = PlacesViewController(loader: loader,
                                       locationController: locationController)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(locationController, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        return (sut, locationController, loader)
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
        
        func startUpdating(completion: @escaping (Location) -> Void) {
            startUpdatingCallCount += 1
        }
        
        func stopUpdating() {
            stopUpdatingCallCount += 1
        }
    }
}
