//
//  CustomNavigationController.swift
//  Language
//
//  Created by Star Lord on 12/09/2023.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.titleTextAttributes = NSAttributedString.textAttributesForNavTitle()
        self.navigationBar.tintColor = .label
        self.navigationBar.isTranslucent = true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpStrokes()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.topStroke.strokeColor = UIColor.label.cgColor
        self.bottomStroke.strokeColor = UIColor.label.cgColor
    }
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backButtonDisplayMode = .minimal
        viewController.view.backgroundColor = .systemBackground
        super.pushViewController(viewController, animated: animated)
    }
    
    func setUpStrokes(){
        topStroke = UIView().addStroke(x: navigationBar.bounds.maxX, y: navigationBar.bounds.maxY)
        self.navigationBar.layer.addSublayer(topStroke)

        guard let tabBar = self.tabBarController?.tabBar else { return }
        
        bottomStroke = UIView().addStroke(x: tabBar.frame.maxX, y: tabBar.frame.minY)
        bottomStroke.lineWidth = 1.5
        self.view.layer.addSublayer(bottomStroke)
    }
    
}
