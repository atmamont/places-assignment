//
//  PlacesLoader.swift
//  Places
//
//  Created by Andrei on 12/09/2023.
//

import Foundation

public typealias Location = (latitude: Double, longitude: Double)

public struct PlaceItem: Equatable {
    public let latitude: Double
    public let longitude: Double
    public let name: String
    public let address: String
}

public protocol PlacesLoader {
    typealias LoadResult = Result<[PlaceItem], Error>

    func load(completion: @escaping (LoadResult) -> Void)
}
