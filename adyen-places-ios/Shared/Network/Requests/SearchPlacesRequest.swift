//
//  SearchPlacesRequest.swift
//  Places
//
//

import Foundation
import AdyenNetworking

internal struct SearchPlacesRequest: Request {
    
    typealias ResponseType = PlacesResponse
    
    typealias ErrorResponseType = EmptyErrorResponse
    
    let method: HTTPMethod = .post
    
    let path: String = "places/search"
    
    let queryParameters: [URLQueryItem] = []
    
    var counter: UInt = 0
    
    var headers: [String : String] = [:]
    
    internal func encode(to encoder: Encoder) throws {}
}
