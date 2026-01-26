//
//  CustomTabBarController.swift
//  Learny
//
//  Created by Star Lord on 19/07/2025.
//
//TODO: Polish

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 18.0, *) {
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.traitOverrides.horizontalSizeClass = .compact
            }
        }
    }
}
