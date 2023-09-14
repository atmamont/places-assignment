//
//  ViewController.swift
//  PlacesUIKit
//
//  Created by Yurii Zadoianchuk on 03/05/2023.
//

import UIKit
import MapKit

import Places

class PlacesViewController: UIViewController {
    private struct Constants {
        static let minSearchRadius = 100
        static let maxSearchRadius = 3000
    }
    
    @IBOutlet private weak var radiusSlider: UISlider!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var currentRadiusLabel: UILabel!
    @IBOutlet private weak var minSearchRadiusLabel: UILabel!
    @IBOutlet private weak var maxSearchRadiusLabel: UILabel!

    private var lastKnownUserLocation: Location?
    private var radius: Int = 1000 {
        didSet {
            let template = NSLocalizedString(
                "places_screen_current_radius_label",
                comment: "Places screen - `Current radius (in meters)` label")
            currentRadiusLabel.text = String(format: template, radius)
            
            focusAndScaleMap(on: lastKnownUserLocation)
        }
    }
    
    var loader: PlacesLoader?
    var locationController: LocationController?
    
    convenience init(loader: PlacesLoader = PlacesLoaderAssembly.foursquareLoader(),
                     locationController: LocationController = CoreLocationController()) {
        self.init()
        
        var locationController = locationController
        locationController.locationUpdateHandler = self.handleFirstLocationUpdate
        self.locationController = locationController
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        
        minSearchRadiusLabel.text = "\(Constants.minSearchRadius)"
        maxSearchRadiusLabel.text = "\(Constants.maxSearchRadius)"
        
        radiusSlider.minimumValue = Float(Constants.minSearchRadius)
        radiusSlider.maximumValue = Float(Constants.maxSearchRadius)

        locationController?.requestAuthorization()
        locationController?.startUpdating()
    }
    
    // MARK - Private
    
    private func fetchPlaces() {
        loader?.load(location: lastKnownUserLocation, radius: radius) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(items):
                self.renderAnnotations(items.toAnnotations())
            case let .failure(error):
                self.showAlert(for: error)
            }
        }
    }
    
    private func handleFirstLocationUpdate(location: Location) {
        locationController?.stopUpdating()
        lastKnownUserLocation = location

        fetchPlaces()
    }

    // MARK: - Map
    
    private func renderAnnotations(_ annotations: [MKAnnotation]) {
        mapView.addAnnotations(annotations)
        let focusPoint = lastKnownUserLocation
        focusAndScaleMap(on: focusPoint)
    }
    
    private func focusAndScaleMap(on location: Location?) {
        guard let location else { return }
        let region = MKCoordinateRegion(
            center: location.toCLCoordinate(),
            latitudinalMeters: CLLocationDistance(radius),
            longitudinalMeters: CLLocationDistance(radius))
        mapView.setRegion(region, animated: true)
    }
    
    private func showAlert(for error: Error) {
        AlertHelper.showAlert(
            title: R.networkErrorAlertTitle,
            message: error.localizedDescription,
            from: self)
    }
    
    // MARK: - Actions
    
    @IBAction private func onSliderValueChange(_ sender: UISlider, event: UIEvent) {
        radius = Int(sender.value)
        
        guard let touchEvent = event.allTouches?.first, touchEvent.phase == .ended else { return }
        fetchPlaces()
    }
}

private class Venue: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(latitide: Double, longitude: Double, title: String?, subtitle: String? = nil) {
        self.coordinate = .init(latitude: latitide, longitude: longitude)
        self.title = title
        self.subtitle = subtitle
    }
}

private extension Array where Element == PlaceItem {
    func toAnnotations() -> [MKAnnotation] {
        map { Venue(latitide: $0.latitude,
                    longitude: $0.longitude,
                    title: $0.name,
                    subtitle: $0.address) }
    }
}

private extension Location {
    func toCLCoordinate() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude,
                               longitude: longitude)
    }
}

extension MKAnnotation {
    func toLocation() -> Location {
        Location(latitude: coordinate.latitude,
                 longitude: coordinate.longitude)
    }
}
