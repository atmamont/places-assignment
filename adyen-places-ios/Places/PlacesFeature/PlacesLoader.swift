//
//  PlacesLoader.swift
//  Places
//
//  Created by Andrei on 12/09/2023.
//

import Foundation

public struct PlaceItem: Equatable {
    let latitude: Double
    let longitude: Double
    let name: String
    let description: String
}

public protocol PlacesLoader {
    typealias LoadResult = Result<[PlaceItem], Error>

    func load(completion: @escaping (LoadResult) -> Void)
}
