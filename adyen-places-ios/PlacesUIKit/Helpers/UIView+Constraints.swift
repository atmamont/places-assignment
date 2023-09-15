//
//  UIView+Constraints.swift
//  PlacesUIKit
//
//  Created by Andrei on 15/09/2023.
//

import UIKit

extension UIView {
    func addFillingSubview(_ view: UIView) {
        addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
