//
//  PlacesLoaderAssembly.swift
//  Places
//
//  Created by Andrei on 13/09/2023.
//

import Foundation
import AdyenNetworking

public final class PlacesLoaderAssembly {
    public static func foursquareLoader() -> PlacesLoader {
        let context = PlacesAPIContext()
        let client = APIClient(apiContext: context)
        return RemotePlacesLoader(apiClient: client)
    }
}
