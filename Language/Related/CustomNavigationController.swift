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
    
    var initialLaunch = true

    var didCreateStrokeForLandscapePosition: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.titleTextAttributes = FontChangeManager.shared.VCTitleAttributes()
        self.navigationBar.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        self.navigationBar.tintColor = .label
        self.navigationBar.isTranslucent = true
        NotificationCenter.default.addObserver(self, selector: #selector(updateFonts(sender: )), name: .appFontDidChange, object: nil)
    }
    
    //The CAShapeLayer stroke, being added to the tabBarController, displayes on every view. By the design, SearchView need its own logic for any stroke diplay, so any added stroke with name "Stroke" will be removed on the appearence.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.viewControllers.first is SearchView {
            self.navigationBar.layer.sublayers?.removeAll(where: { stroke in
                return stroke.name == "Stroke"
            })
            self.tabBarController?.tabBar.layer.sublayers?.removeAll(where: { stroke in
                return stroke.name == "Stroke"
            })
        } else {
            if let sublayers = self.tabBarController?.tabBar.layer.sublayers, !sublayers.contains(where: { stroke in
                return stroke.name == "Stroke"
            }){
                self.setUpBottomStroke()
            } 
            if let sub = self.navigationBar.layer.sublayers, !sub.contains(where: {stroke in
                return stroke.name == "Stroke"
            } ){
                self.setUpTopStroke()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if initialLaunch && !(self.viewControllers.first is SearchView){
            setUpStrokes()
            initialLaunch.toggle()
        }
    }
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if viewControllerToPresent.modalPresentationStyle == .formSheet {
            var multiplier: CGFloat
            if traitCollection.horizontalSizeClass == .regular && (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight) {
                multiplier = 0.6
            } else {
                multiplier = 0.9
            }
                
            let screenWidth = UIScreen.main.bounds.width
            
            viewControllerToPresent.preferredContentSize = CGSize(width: screenWidth * multiplier,
                                               height: screenWidth * multiplier)
        }

        super.present(viewControllerToPresent, animated: flag, completion: completion)
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
    
    private func setUpTopStroke(){
        let screenBounds = UIWindow().bounds
        topStroke = UIView().addStroke(
            x: max(screenBounds.width, screenBounds.height),
            y: navigationBar.bounds.maxY
        )
        self.navigationBar.layer.addSublayer(topStroke)
    }
    private func setUpBottomStroke(){
        let screenBounds = UIWindow().bounds
        bottomStroke = UIView().addStroke(
            x: max(screenBounds.width, screenBounds.height),
            y: 0
        )

        guard let tabBar = self.tabBarController?.tabBar else { return }
        tabBar.layer.addSublayer(bottomStroke)

    }
    private func setUpStrokes() {
        setUpTopStroke()
        setUpBottomStroke()
    }
    func calculateOptimalHeight(forText text: String, withFont font: UIFont, maxWidth: CGFloat) -> CGFloat {
            let maxSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
            let boundingBox = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
            let ascender = font.ascender
            let descender = font.descender
            return ceil(boundingBox.height + ascender - descender)
        }
    
    @objc private func updateFonts(sender: Any){
        self.navigationBar.titleTextAttributes = FontChangeManager.shared.VCTitleAttributes()
    }
    
}
