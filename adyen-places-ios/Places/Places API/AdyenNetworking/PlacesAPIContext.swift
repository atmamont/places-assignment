//
//  ApiContext.swift
//  Places
//
//

import Foundation
import AdyenNetworking

internal struct Environment: AnyAPIEnvironment {
    var baseURL: URL = URL(string: "https://api.foursquare.com/v3/")!
    
    static let `default`: Environment = Environment()
}

internal struct PlacesAPIContext: AnyAPIContext {
    let environment: AnyAPIEnvironment = Environment.default
    
    var headers: [String : String] = [
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": FSQConfig.fsq_token
    ]
    
    var queryParameters: [URLQueryItem] = []
}
