//
//  RemotePlacesLoaderTests.swift
//  PlacesTests
//
//  Created by Andrei on 12/09/2023.
//

import XCTest
import AdyenNetworking
@testable import Places

final class RemotePlacesLoaderTests: XCTestCase {
    func test_init_doesNotPerformRequest() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedPaths, [], "Expected to not perform network request on init")
    }
    
    func test_load_performsRequest() {
        let (sut, client) = makeSUT()

        sut.load { _ in }
        
        XCTAssertEqual(client.requestedPaths, [placesRequestPath], "Expected to perform request on load call")
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedPaths, [placesRequestPath, placesRequestPath])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let expectedError = NSError(domain: "any", code: 1)
        
        expect(sut, toCompleteWith: .failure(expectedError), when: {
            client.completeWithError(expectedError)
        })
    }
    
    func test_load_deliversPlacesOnSuccess() {
        let (sut, client) = makeSUT()
        let expectedPlaces = makePlaces()
        let expectedMappedPlaces = expectedPlaces.toModels()
        
        expect(sut, toCompleteWith: .success(expectedMappedPlaces), when: {
            client.completeWithPlaces(expectedPlaces)
        })
    }
    
    func test_load_doesNotDeliverResultAfterSUTWasDeallocated() {
        let client = APIClientSpy()
        var weakSut: PlacesLoader? = RemotePlacesLoader(apiClient: client)

        var capturedResults = [PlacesLoader.LoadResult]()
        weakSut?.load { capturedResults.append($0) }
        
        weakSut = nil
        client.completeWithPlaces(makePlaces())
        
        XCTAssertEqual(capturedResults.count, 0)
    }
    
    // MARK: - Helpers
    
    private let placesRequestPath = "places/search"
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: PlacesLoader, client: APIClientSpy) {
        let client = APIClientSpy()
        let sut = RemotePlacesLoader(apiClient: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut: sut, client: client)
    }
    
    private func expect(_ sut: PlacesLoader, toCompleteWith expectedResult: PlacesLoader.LoadResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedPlaces), .success(expectedPlaces)):
                XCTAssertEqual(receivedPlaces, expectedPlaces, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }

    private func makePlaces() -> [RemotePlaceItem] {
        let place1 = RemotePlaceItem(
            name: "Place 1",
            geocodes: .init(main: .init(latitude: 1.111, longitude: 2.222),
                           roof: nil,
                           drop_off: nil,
                           front_door: nil),
            location: [.init(formatted_address: "Address")],
            distance: 100)
        let places = [place1]
        return places
    }

    private class APIClientSpy: APIClientProtocol {
        typealias T = SearchPlacesRequest.ResponseType
        
        var requestedPaths = [String]()
        var completions: [CompletionHandler<T>] = []
        
        func perform<R: Request>(_ request: R, completionHandler: @escaping CompletionHandler<R.ResponseType>) {
            requestedPaths.append(request.path)
            completions.append(completionHandler as! CompletionHandler<T>)
        }
        
        func completeWithError(_ error: Error, at index: Int = 0) {
            completions[index](.failure(error))
        }
        
        func completeWithPlaces(_ places: [RemotePlaceItem], at index: Int = 0) {
            let response = PlacesResponse(results: places)
            completions[index](.success(response))
        }
    }
}

