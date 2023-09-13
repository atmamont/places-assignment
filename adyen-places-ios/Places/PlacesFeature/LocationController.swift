//
//  LocationController.swift
//  Places
//
//  Created by Andrei on 13/09/2023.
//

import CoreLocation
import Combine

public enum LocationAuthorizationStatus {
    case granted
    case denied
}

public protocol LocationController {
    
    typealias Location = (latitude: Double, longitude: Double)
    
    func requestAuthorization() async -> LocationAuthorizationStatus
    func startUpdating()
    func stopUpdating()

    var currentLocation: Location? { get }
}
