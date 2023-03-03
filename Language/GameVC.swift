//
//  GameVC.swift
//  Language
//
//  Created by Star Lord on 01/03/2023.
//

import UIKit

class GameVC: UIViewController {

    var dictionaryToPerform = DictionaryDetails()
    var currentPair = [String: String]()
    var currentWord = String()
    var currentTranslation = String()
    
    let holderView: UIView = {
        let view = UIView()
        view.setUpBorderedView(true)
        view.backgroundColor = .systemBackground
        
        return view
    }()
    let labelView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.alpha = 0.85
        view.layer.cornerRadius = 9
        view.layer.masksToBounds = true
        
        view.layer.shadowColor = UIColor.systemBackground.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 3)
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.7
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        currentPair = (dictionaryToPerform.dictionary?.removeFirst())!
        for (key, value) in currentPair{
            currentWord = key
            currentTranslation = value
        }
        navigationBarCustomization()
        mainViewCustomization()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
//MARK: - NavBar SetUp
    func navigationBarCustomization(){
        navigationItem.title = "Learning"
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Georgia-BoldItalic", size: 23) ?? UIFont()]
        navigationItem.backButtonTitle = "Source Details"
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Finish", style: .plain, target: self, action: #selector(finish(sender: ))), animated: true)
    }
//MARK: - HolderView SetUp
    func mainViewCustomization(){
        view.addSubview(holderView)
        
        holderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            holderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 23),
            holderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            holderView.heightAnchor.constraint(equalToConstant: 226),
            holderView.widthAnchor.constraint(equalToConstant: 330)
        ])
        
        labelViewCustomization()
    }
//MARK: - LabelView SetUp
    func labelViewCustomization(){
        holderView.addSubview(labelView)
        
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        let label : UILabel = {
            let label = UILabel()
            label.attributedText = NSAttributedString(string: currentWord,
                                                      attributes: [NSAttributedString.Key.font:
                                                                    UIFont(name: "Georgia-Italic",
                                                                           size: 20) ?? UIFont()])
            label.tintColor = UIColor.label
            label.numberOfLines = 0
            label.lineBreakStrategy = .standard
            label.textAlignment = .center
            return label
        }()
        labelView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelView.topAnchor.constraint(equalTo: self.holderView.topAnchor, constant: 10),
            labelView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelView.heightAnchor.constraint(equalTo: self.holderView.heightAnchor, constant: -20),
            labelView.widthAnchor.constraint(equalTo: self.holderView.widthAnchor, constant: -20),
            
            label.centerXAnchor.constraint(equalTo: labelView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: labelView.centerYAnchor),
            label.widthAnchor.constraint(equalTo: labelView.widthAnchor, constant: -20)
        ])
        
    }

//MARK: - Actions
    @objc func finish(sender: UIBarButtonItem){
        
    }
}
