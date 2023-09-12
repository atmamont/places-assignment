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
        "Accept": "", // TODO: Fill it with necessary value.
        "Content-Type": "", // TODO: Fill it with necessary value.
        "Authorization": "" // TODO: Fill it with your api key.
    ]
    
    var queryParameters: [URLQueryItem] = []
}
