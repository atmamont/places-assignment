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
    func load(completion: Result<[PlaceItem], Error>)
}
