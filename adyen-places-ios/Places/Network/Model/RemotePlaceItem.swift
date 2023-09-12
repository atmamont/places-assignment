//
//  Place.swift
//  
//
//

import Foundation

internal struct RemotePlaceItem: Decodable {
    let name: String
    let geocodes: Geocodes
    let location: [Location]
    let distance: Int
}

extension RemotePlaceItem {
    struct Location: Decodable {
        let formatted_address: String
    }
    
    struct Geocodes: Decodable {
        let main: Geocode
        let roof, drop_off, front_door: Geocode?
    }
    
    struct Geocode: Decodable {
        let latitude, longitude: Double
    }
}
