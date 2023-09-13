//
//  CoreLocationController.swift
//  Places
//
//  Created by Andrei on 13/09/2023.
//

import CoreLocation

public final class CoreLocationController: NSObject, CLLocationManagerDelegate, LocationController {
    public var locationUpdateHandler: ((Location) -> Void)?
    
    private let locationManager: CLLocationManager
    
    public init(locationManager: CLLocationManager = CLLocationManager()) {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager = locationManager
    }

    public func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    public func startUpdating() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    public func stopUpdating() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        
        let location = Location(latitude: coordinate.latitude,
                                longitude: coordinate.longitude)
        locationUpdateHandler?(location)
    }
}
