//
//  RemotePlacesLoader.swift
//  PlacesTests
//
//  Created by Andrei on 12/09/2023.
//

import Foundation
import AdyenNetworking

public class RemotePlacesLoader: PlacesLoader {
    private let limitPlaces = 50
    
    private let apiClient: APIClientProtocol
    
    public init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    public func load(location: Location? = nil, radius: Int? = nil, completion: @escaping (LoadResult) -> Void) {
        let p = makeParameters(location: location, radius: radius)
        let request = SearchPlacesRequest(queryParameters: p)
        
        apiClient.perform(request) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(response):
                completion(.success(self.map(response.results)))
            case let .failure(error):
                completion(.failure(self.handle(error)))
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
    
    private func makeParameters(location: Location?, radius: Int?) -> [URLQueryItem] {
        var p: [SearchPlaceParameters] = []
        if let location {
            p.append(.location(location))
        }
        if let radius {
            p.append(.radius(radius))
        }
        p.append(.limit(limitPlaces))
        return p.map { URLQueryItem(name: $0.name, value: $0.value) }
    }
}

internal extension Array where Element == RemotePlaceItem {
    func toModels() -> [PlaceItem] {
        map {
            PlaceItem(
                latitude: $0.latitude,
                longitude: $0.longitude,
                name: $0.name,
                address: $0.location.formatted_address)
        }
    }
}

enum SearchPlaceParameters {
    case location(Location)
    case radius(Int)
    case limit(Int)
    
    var name: String {
        switch self {
        case .location: return "ll"
        case .radius: return "radius"
        case .limit: return "limit"
        }
    }
    
    var value: String {
        switch self {
        case let .location(location): return location.toString()
        case let .radius(radius): return String(radius)
        case let .limit(limit): return String(limit)
        }
    }
}
