//
//  LocationController.swift
//  Places
//
//  Created by Andrei on 13/09/2023.
//

import CoreLocation

public protocol LocationController {
    func requestAuthorization()
    func startUpdating()
    func stopUpdating()

    var locationUpdateHandler: ((Location) -> Void)? { get set }
}
