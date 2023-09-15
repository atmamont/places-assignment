//
//  CoreLocationController.swift
//  Places
//
//  Created by Andrei on 13/09/2023.
//

import CoreLocation

public final class CoreLocationController: NSObject, CLLocationManagerDelegate, LocationController {
    private var locationUpdateHandler: ((Location) -> Void)?
    
    private let locationManager: CLLocationManager
    
    public init(locationManager: CLLocationManager = CLLocationManager()) {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager = locationManager
    }

    public func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    public func startUpdating(completion: @escaping ((Location) -> Void)) {
        locationManager.delegate = self
        locationUpdateHandler = completion
        locationManager.startUpdatingLocation()
    }

    public func stopUpdating() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        locationUpdateHandler = nil
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        
        let location = Location(latitude: coordinate.latitude,
                                longitude: coordinate.longitude)
        locationUpdateHandler?(location)
    }
}
