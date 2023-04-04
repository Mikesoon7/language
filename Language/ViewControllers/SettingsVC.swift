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
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let secondParamView: UIView = {
        let view = UIView()
        view.setUpBorderedView(true)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let thirdParamView: UIView = {
        let view = UIView()
        view.setUpBorderedView(true)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBarCustomization()
        firstViewCustomization()
        secondViewCustomization()
        thirdViewCustomization()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
    func navBarCustomization(){
        navigationItem.title = "Setting"
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }

    //MARK: - Stroke SetUp
    func strokeCustomization(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }

    func firstViewCustomization(){
                
        let label = {
            let label = UILabel()
            label.attributedText = NSAttributedString().fontWithString(string: "Preffered mode", bold: false, size: 18)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        let segment = {
            let segment = UISegmentedControl()
            segment.isSpringLoaded = true
            
            segment.insertSegment(withTitle: "Light", at: 0, animated: true)
            segment.insertSegment(withTitle: "Dark", at: 1, animated: true)
            segment.addTarget(self, action: #selector(self.segmentTap(sender: )), for: .valueChanged)
            segment.translatesAutoresizingMaskIntoConstraints = false
            return segment
        }()
        
        view.addSubview(firstParamView)
        firstParamView.addSubviews(label, segment)

        NSLayoutConstraint.activate([
            firstParamView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
            firstParamView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstParamView.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
            firstParamView.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
            
            label.leadingAnchor.constraint(equalTo: firstParamView.leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: firstParamView.centerYAnchor),
            
            segment.trailingAnchor.constraint(equalTo: firstParamView.trailingAnchor, constant: -15),
            segment.centerYAnchor.constraint(equalTo: firstParamView.centerYAnchor),
            segment.widthAnchor.constraint(equalTo: firstParamView.widthAnchor, multiplier: 0.4),
            segment.heightAnchor.constraint(equalTo: firstParamView.heightAnchor, multiplier: 0.5)
        ])
    }
    
    func secondViewCustomization(){
        view.addSubview(secondParamView)
        NSLayoutConstraint.activate([
        secondParamView.topAnchor.constraint(equalTo: firstParamView.bottomAnchor, constant: 23),
        secondParamView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        secondParamView.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
        secondParamView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    func thirdViewCustomization(){
        view.addSubview(thirdParamView)
        NSLayoutConstraint.activate([
        thirdParamView.topAnchor.constraint(equalTo: secondParamView.bottomAnchor, constant: 23),
        thirdParamView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        thirdParamView.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
        thirdParamView.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
        ])
    }
    @objc func segmentTap(sender: UISegmentedControl){
        
    }
}
