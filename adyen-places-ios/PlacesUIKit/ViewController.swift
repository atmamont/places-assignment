//
//  ViewController.swift
//  PlacesUIKit
//
//  Created by Yurii Zadoianchuk on 03/05/2023.
//

import UIKit
import MapKit

import Places

class ViewController: UIViewController {
    @IBOutlet private weak var mapView: MKMapView! {
        didSet {
            mapView.showsUserLocation = true
        }
    }
    
    private var lastKnownUserLocation: Location?
    private var radius: Int = 1000 {
        didSet {
            focusAndScaleMap(on: lastKnownUserLocation)
            fetchPlaces()
        }
    }
    
    // TODO: Inject from outside
    var loader: PlacesLoader? = PlacesLoaderAssembly.foursquareLoader()
    lazy var locationController: LocationController = {
        let controller = CoreLocationController()
        controller.locationUpdateHandler = self.handleFirstLocationUpdate
        return controller
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationController.requestAuthorization()
        locationController.startUpdating()
    }
    
    // MARK - Private
    
    private func fetchPlaces() {
        loader?.load(location: lastKnownUserLocation,
                     radius: radius)
        { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success(items):
                self.renderAnnotations(items.toAnnotations())
            case let .failure(error):
                AlertHelper.showAlert(
                    title: R.networkErrorAlertTitle,
                    message: error.localizedDescription,
                    from: self)
            }
        }
    }
    
    private func handleFirstLocationUpdate(location: Location) {
        locationController.stopUpdating()
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
    
    // MARK: - Actions
    
    @IBAction private func onSliderValueChange(_ sender: UISlider) {
        radius = Int(sender.value)
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
