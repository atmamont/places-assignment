//
//  RemotePlacesLoader.swift
//  PlacesTests
//
//  Created by Andrei on 12/09/2023.
//

import AdyenNetworking

public class RemotePlacesLoader: PlacesLoader {
    private let apiClient: APIClientProtocol
    
    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        apiClient.perform(SearchPlacesRequest()) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(response):
                completion(.success(self.map(response.results)))
            case let .failure(error):
                let loaderError = self.handle(error)
                completion(.failure(loaderError))
            }
        }
    }
    
    private func handle(_ error: Swift.Error) -> Error {
        // please read the potential improvements section in README.md
        return error
    }
    
    private func map(_ remotePlaces: [RemotePlaceItem]) -> [PlaceItem] {
        remotePlaces.toModels()
    }
}

internal extension Array where Element == RemotePlaceItem {
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
