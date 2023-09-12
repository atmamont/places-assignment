//
//  RemotePlacesLoaderTests.swift
//  PlacesTests
//
//  Created by Andrei on 12/09/2023.
//

import XCTest
import AdyenNetworking
@testable import Places

class RemotePlacesLoader {
    typealias LoadResult = (Result<[PlaceItem], Error>) -> Void
    
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func load(completion: @escaping LoadResult) {
        apiClient.perform(SearchPlacesRequest()) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(response):
                completion(.success(self.map(response.results)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func map(_ remotePlaces: [RemotePlaceItem]) -> [PlaceItem] {
        remotePlaces.toModels()
    }
    
    private struct Root: Decodable {
        let results: [RemotePlaceItem]
    }

}

private extension Array where Element == RemotePlaceItem {
    func toModels() -> [PlaceItem] {
        map {
            PlaceItem(
                latitude: $0.geocodes.main.latitude,
                longitude: $0.geocodes.main.longitude,
                name: $0.name,
                description: "")
        }
    }
}

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
        let exp = expectation(description: "Wait for load completion")
        let expectedError = NSError(domain: "any", code: 1)

        sut.load { result in
            switch result {
            case .success:
                XCTFail("Expected to receive client error")
            case .failure(let receivedError):
                XCTAssertEqual(expectedError, receivedError as NSError, "Expected error \(expectedError) doesn't match received error \(receivedError)")
            }
            exp.fulfill()
        }
        
        client.completeWithError(expectedError)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private let placesRequestPath = "places/search"
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemotePlacesLoader, client: APIClientSpy) {
        let client = APIClientSpy()
        let sut = RemotePlacesLoader(apiClient: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut: sut, client: client)
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
    }
}
