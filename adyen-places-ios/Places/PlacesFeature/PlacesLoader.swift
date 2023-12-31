//
//  PlacesLoader.swift
//  Places
//
//  Created by Andrei on 12/09/2023.
//

import Foundation

public struct PlaceItem: Equatable {
    public let latitude: Double
    public let longitude: Double
    public let name: String
    public let address: String
}

public protocol PlacesLoader {
    typealias LoadResult = Result<[PlaceItem], Error>

    func load(location: Location?, radius: Int?, completion: @escaping (LoadResult) -> Void)
}
