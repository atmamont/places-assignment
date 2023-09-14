//
//  Location.swift
//  Places
//
//  Created by Andrei on 14/09/2023.
//

import Foundation

public struct Location {
    let latitude, longitude: Double
}

extension Location {
    func toString() -> String {
        "\(self.latitude),\(self.longitude)"
    }
}
