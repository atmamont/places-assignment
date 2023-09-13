//
//  Place.swift
//  
//
//

import Foundation

internal struct RemotePlaceItem: Decodable {
    let name: String
    let geocodes: Geocodes
    let location: Location
    let distance: Int
}

extension RemotePlaceItem {
    var latitude: Double {
        geocodes.main.latitude
    }
    var longitude: Double {
        geocodes.main.longitude
    }
}

extension RemotePlaceItem {
    struct Location: Decodable {
        let formatted_address: String
    }
    
    struct Geocodes: Decodable {
        let main: Geocode
    }
    
    struct Geocode: Decodable {
        let latitude, longitude: Double
    }
}
