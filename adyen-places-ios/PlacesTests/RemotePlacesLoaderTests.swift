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
        apiClient.perform(SearchPlacesRequest()) { result in
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
        
        XCTAssertEqual(client.performCallCount, 0, "Expected to not perform network request on init")
    }
    
    func test_load_performsRequest() {
        let (sut, client) = makeSUT()

        sut.load { _ in
        }
        
        XCTAssertEqual(client.performCallCount, 1, "Expected to perform request on load call")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemotePlacesLoader, client: APIClientSpy) {
        let client = APIClientSpy()
        let sut = RemotePlacesLoader(apiClient: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut: sut, client: client)

    }

    private class APIClientSpy: APIClientProtocol {
        var performCallCount = 0
        var requestedPaths = [String]()
        
        func perform<R: Request>(_ request: R, completionHandler: @escaping CompletionHandler<R.ResponseType>) {
            requestedPaths.append(request.path)
            performCallCount += 1
        }
    }

}
