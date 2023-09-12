//
//  PlacesLoader.swift
//  Places
//
//  Created by Andrei on 12/09/2023.
//

import Foundation

struct PlaceItem {
    let latitude: Double
    let longitude: Double
    let name: String
    let description: String
}

protocol PlacesLoader {
    func load(completion: Result<[PlaceItem], Error>)
}
