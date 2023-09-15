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
        static let maxSearchRadius = 5000
        static let defaultSearchRadius = 1000
    }

    private var lastKnownUserLocation: Location?
    var radius: Int = Constants.defaultSearchRadius {
        didSet {
            updateSearchRadiusLabel(radius)
            focusAndScaleMap(on: lastKnownUserLocation)
        }
    }
    
    private let loader: PlacesLoader
    private var locationController: LocationController
    
    init(loader: PlacesLoader,
         locationController: LocationController) {
        
        self.locationController = locationController
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        locationController.requestAuthorization()
        locationController.startUpdating { [weak self] location in
            self?.handleFirstLocationUpdate(location: location)
        }
        
        fetchPlaces()
    }
    
    // MARK - Private
    
    private func fetchPlaces() {
        loader.load(location: lastKnownUserLocation, radius: radius) { [weak self] result in
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
        locationController.stopUpdating()
        lastKnownUserLocation = location

        fetchPlaces()
    }
    
    // MARK: - UI
    
    lazy var mapView = MKMapView()
    lazy var minSearchRadiusLabel = UILabel()
    lazy var maxSearchRadiusLabel = UILabel()
    lazy var currentRadiusLabel = UILabel()
    lazy var radiusSlider = {
        let view = UISlider()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.minimumValue = Float(Constants.minSearchRadius)
        view.maximumValue = Float(Constants.maxSearchRadius)
        view.value = Float(Constants.defaultSearchRadius)
        return view
    }()
    
    lazy var rootStackView = {
        let view = UIStackView(arrangedSubviews: [mapView, settingsView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
       
    lazy var settingsView = {
        let view = UIStackView(arrangedSubviews: [currentRadiusLabel, radiusSliderStackView])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 10
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        return view
    }()
    
    lazy var radiusSliderStackView = {
        let view = UIStackView(arrangedSubviews: [minSearchRadiusLabel, radiusSlider, maxSearchRadiusLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 20
        return view
    }()

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addFillingSubview(rootStackView)

        mapView.showsUserLocation = true
        
        minSearchRadiusLabel.text = "\(Constants.minSearchRadius)"
        maxSearchRadiusLabel.text = "\(Constants.maxSearchRadius)"

        radiusSlider.addTarget(self, action: #selector(onSliderValueChange(_:event:)), for: .valueChanged)
        
        updateSearchRadiusLabel(radius)
    }

    private func updateSearchRadiusLabel(_ radius: Int) {
        let template = NSLocalizedString(
            "places_screen_current_radius_label",
            comment: "Places screen - `Current radius (in meters)` label")
        currentRadiusLabel.text = String(format: template, radius)
    }

    // MARK: - Map
    
    private func renderAnnotations(_ annotations: [MKAnnotation]) {
        mapView.addAnnotations(annotations)
        let focusPoint = lastKnownUserLocation ?? annotations.last?.toLocation()
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
