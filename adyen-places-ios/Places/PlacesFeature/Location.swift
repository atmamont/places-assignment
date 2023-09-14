//
//  Location.swift
//  Places
//
//  Created by Andrei on 14/09/2023.
//

import Foundation

public struct Location {
    public let latitude, longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension Location {
    func toString() -> String {
        "\(self.latitude),\(self.longitude)"
    }
}
