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
        self.navigationBar.titleTextAttributes = FontChangeManager.shared.VCTitleAttributes()
        self.navigationBar.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        self.navigationBar.tintColor = .label
        self.navigationBar.isTranslucent = true
        NotificationCenter.default.addObserver(self, selector: #selector(updateFonts(sender: )), name: .appFontDidChange, object: nil)
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
    
    func calculateOptimalHeight(forText text: String, withFont font: UIFont, maxWidth: CGFloat) -> CGFloat {
            let maxSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
            let boundingBox = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
            let ascender = font.ascender
            let descender = font.descender
            return ceil(boundingBox.height + ascender - descender)
        }
        
        // Function to update label font and adjust label height
//        func updateLabelFontAndHeight(withFont font: UIFont) {
//            label.font = font
//            let optimalHeight = calculateOptimalHeight(forText: label.text ?? "", withFont: font, maxWidth: label.frame.width)
//            label.frame.size.height = optimalHeight
//        }
        
        // Example function to handle font change
//        func fontDidChange(newFont: UIFont) {
//            updateLabelFontAndHeight(withFont: newFont)
//        }

    
    @objc private func updateFonts(sender: Any){
        self.navigationBar.titleTextAttributes = FontChangeManager.shared.VCTitleAttributes()
    }
    
}
