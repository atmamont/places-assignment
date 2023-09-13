//
//  ViewController.swift
//  PlacesUIKit
//
//  Created by Yurii Zadoianchuk on 03/05/2023.
//

import UIKit
import Places

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    // TODO: Inject from outside
    var loader: PlacesLoader? = PlacesLoaderAssembly.foursquareLoader()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load(completion: { [weak self] result in
            switch result {
            case let .success(items):
                self?.label.text = items.toString()
            case let .failure(error):
                self?.label.text = error.localizedDescription
            }
        })
    }
}

private extension Array where Element == PlaceItem {
    func toString() -> String {
        (self as NSArray).componentsJoined(by: ", ")
    }
}
