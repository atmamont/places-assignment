//
//  ViewController.swift
//  PlacesUIKit
//
//  Created by Yurii Zadoianchuk on 03/05/2023.
//

import UIKit
import Places

import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var label: UILabel!
    
    // TODO: Inject from outside
    var loader: PlacesLoader? = PlacesLoaderAssembly.foursquareLoader()
    lazy var locationController: LocationController = {
        let controller = CoreLocationController()
        controller.locationUpdateHandler = self.handleLocationUpdate
        return controller
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationController.requestAuthorization()
        locationController.startUpdating()
        
        loader?.load(completion: { [weak self] result in
            switch result {
            case let .success(items):
                self?.renderAnnotations(items.toAnnotations())
            case let .failure(error):
                self?.label.text = error.localizedDescription
            }
        })
    }
    
    func handleLocationUpdate(location: LocationController.Location) {
        print(location)
        locationController.stopUpdating()
    }

    // MARK: - Map rendering
    
    private func renderAnnotations(_ annotations: [MKAnnotation]) {
        mapView.addAnnotations(annotations)
        
        if let lastAnnotation = annotations.last {
            focusMap(on: lastAnnotation)
        }
    }
    
    private func focusMap(on annotation: MKAnnotation) {
        let region = MKCoordinateRegion(center: annotation.coordinate,
                                        span: mapView.region.span)
        mapView.setRegion(region, animated: true)
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
    func toString() -> String {
        (self as NSArray).componentsJoined(by: ", ")
    }
    
    func toAnnotations() -> [MKAnnotation] {
        map { Venue(latitide: $0.latitude,
                    longitude: $0.longitude,
                    title: $0.name,
                    subtitle: $0.address) }
    }
}
