//
//  SceneDelegate.swift
//  PlacesUIKit
//
//  Created by Yurii Zadoianchuk on 03/05/2023.
//

import UIKit
import Places

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let viewController = PlacesViewController(
            loader: PlacesLoaderAssembly.foursquareLoader(),
            locationController: CoreLocationController())
        let navigation = UINavigationController(rootViewController: viewController)
        
        window.rootViewController = navigation
        
        self.window = window
        window.makeKeyAndVisible()
    }
}
