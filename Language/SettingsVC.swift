//
//  SettingsVC.swift
//  Language
//
//  Created by Star Lord on 05/03/2023.
//

import UIKit

class SettingsVC: UIViewController {
    
    let firstParamView: UIView = {
        let view = UIView()
        view.setUpBorderedView(true)
        return view
    }()
    
    let secondParamView: UIView = {
        let view = UIView()
        view.setUpBorderedView(true)
        return view
    }()
    
    let thirdParamView: UIView = {
        let view = UIView()
        view.setUpBorderedView(true)
        return view
    }()
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        self.title = "Settings"
        strokeCustomization()
    }
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                self.bottomStroke.strokeColor = UIColor.white.cgColor
                self.topStroke.strokeColor = UIColor.white.cgColor
            } else {
                self.bottomStroke.strokeColor = UIColor.black.cgColor
                self.topStroke.strokeColor = UIColor.black.cgColor
            }
        }
    }
    //MARK: - Stroke SetUp
    func strokeCustomization(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }

    func firstViewCustomization(){
        view.addSubview(firstParamView)
    }
    
    func secondViewCustomization(){
        view.addSubview(secondParamView)
    }
    func thirdViewCustomization(){
        view.addSubview(thirdParamView)
    }

}
