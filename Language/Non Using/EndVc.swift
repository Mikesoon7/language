//
//  ClosureVC.swift
//  Language
//
//  Created by Star Lord on 05/03/2023.
//

import UIKit
//
//class EndVc: UIViewController {
//
//    
//    var topStroke = CAShapeLayer()
//    var bottomStroke = CAShapeLayer()
//    var label = UILabel()
//    var labelScore = UILabel()
//    var score = String()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.addSubviews(label, labelScore)
//        view.backgroundColor = .systemBackground
//        label.text = "Win"
//        label.center = view.center
//        label.backgroundColor = .lightGray
//        label.textColor = .label
//        
//        labelScore.text = "Your score is \(score)"
//        labelScore.translatesAutoresizingMaskIntoConstraints = false
//        labelScore.textColor = .label
//        
//        NSLayoutConstraint.activate([
//            labelScore.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
//            labelScore.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
//            labelScore.heightAnchor.constraint(equalToConstant: 100),
//            labelScore.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100)
//
//            
//        ])
//    }
////MARK: - NavBar SetUp
//    func navBarCustomization(){
//        // Title adjustment.
//        navigationItem.title = "Finish"
//        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
//        // Buttons
//        let rightButton = UIBarButtonItem(title: "Restart", style: .done, target: self, action: #selector(restart(sender:)))
//        let leftButton = UIBarButtonItem(
//            title: "Menu",
//            image: UIImage(systemName: "chevron.left"),
//            target: self,
//            action: #selector(backToMenu(sender:)))
//        self.navigationItem.setRightBarButton(rightButton, animated: true)
//        self.navigationItem.setLeftBarButton(leftButton, animated: true)
//        self.navigationController?.navigationBar.tintColor = .label
//        self.navigationController?.navigationBar.isTranslucent = true
//    }
//
//    //MARK: - StyleChange Responding
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        
//        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
//            if traitCollection.userInterfaceStyle == .dark {
//                self.bottomStroke.strokeColor = UIColor.white.cgColor
//                self.topStroke.strokeColor = UIColor.white.cgColor
//            } else {
//                self.bottomStroke.strokeColor = UIColor.black.cgColor
//                self.topStroke.strokeColor = UIColor.black.cgColor
//            }
//        }
//    }
//    //MARK: - Stroke SetUp
//    func strokeCustomization(){
//        topStroke = UIView().addTopStroke(vc: self)
//        bottomStroke = UIView().addBottomStroke(vc: self)
//        
//        view.layer.addSublayer(topStroke)
//        view.layer.addSublayer(bottomStroke)
//    }
//    
//    @objc func backToMenu(sender: Any){
//        self.navigationController?.popToRootViewController(animated: true)
//    }
//    @objc func restart(sender: Any){
////        navigationController?.popToViewController(MainGameVC, animated: true)
//    }
//}
