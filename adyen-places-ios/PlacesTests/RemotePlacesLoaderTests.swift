//
//  RemotePlacesLoaderTests.swift
//  PlacesTests
//
//  Created by Andrei on 12/09/2023.
//

import XCTest
import AdyenNetworking

class RemotePlacesLoader {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
}

final class RemotePlacesLoaderTests: XCTestCase {
    func test_init_doesNotPerformRequest() {
        let client = APIClientSpy()
        let _ = RemotePlacesLoader(apiClient: client)
        
        XCTAssertEqual(client.performCallCount, 0, "Expected to not perform network request on init")
    }
    

    private class APIClientSpy: APIClientProtocol {
        var performCallCount = 0
        
        func perform<R: Request>(_ request: R, completionHandler: @escaping CompletionHandler<R.ResponseType>) {
            performCallCount += 1
        }
    }

}
