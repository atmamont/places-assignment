//
//  AlertHelper.swift
//  PlacesUIKit
//
//  Created by Andrei on 14/09/2023.
//

import UIKit

struct R {
    static let commonOk = NSLocalizedString("common_ok", comment: "Common contextless OK used across the app")
    
    static let networkErrorAlertTitle = NSLocalizedString("generic_network_error_alert_title", comment: "Generic network error alert title")
}

class AlertHelper {
    
    static func showAlert(title: String?, message: String?, from viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: R.commonOk, style: .default, handler: nil)
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showAlertWithAction(title: String?, message: String?, actionTitle: String, from viewController: UIViewController, actionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let customAction = UIAlertAction(title: actionTitle, style: .default) { (_) in
            actionHandler()
        }
        
        alertController.addAction(customAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
