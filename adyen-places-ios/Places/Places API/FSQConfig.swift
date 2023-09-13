//
//  FSQConfig.swift
//  PlacesUIKit
//
//  Created by Andrei on 13/09/2023.
//

import Foundation

struct FSQConfig {
    static var fsq_token: String = {
        guard let infoDictionary: [String: Any] = Bundle.main.infoDictionary else { return "" }
        guard let token: String = infoDictionary["FSQ_TOKEN"] as? String else { return "" }
        return token
    }()
}

