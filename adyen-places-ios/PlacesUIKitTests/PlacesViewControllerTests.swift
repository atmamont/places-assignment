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
        let sut = PlacesViewController(loader: loader)
        
        sut.loadView()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    private class RemotePlacesLoaderSpy: PlacesLoader {
        var loadCallCount = 0
        func load(location: Places.Location?, radius: Int?, completion: @escaping (LoadResult) -> Void) {
            loadCallCount += 1
        }
        
        
    }
}
