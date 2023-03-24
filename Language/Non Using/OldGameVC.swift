//
//  GameVC.swift
//  Language
//
//  Created by Star Lord on 01/03/2023.
//

import UIKit

class OldGameVC: UIViewController {

    var randomize = Bool()
    var cardGoal = Int()
    var usePicture = Bool()

    var dictionaryToPerform = DictionaryDetails()
    var currentPair : DataForCells! = nil
    var currentWord = String()
    var currentTranslation = String()
    
    let scrollView : UIScrollView = {
        let view = UIScrollView()
        
        return view
    }()
    let holderView: UIView = {
        let view = UIView()
        view.setUpBorderedView(true)
        view.backgroundColor = .systemBackground
        
        return view
    }()
    let labelWordView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        view.backgroundColor = .init(white: 1, alpha: 0.8)
        view.layer.opacity = 0.75
        
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 3)
        view.layer.shadowRadius = 1
        view.layer.shadowOpacity = 0.7
        return view
    }()
    let labelTranslationView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 9
        view.backgroundColor = .systemBackground
        view.clipsToBounds = true
        return view
    }()
    
    let nextButton : UIButton = {
        let button = UIButton()
        button.setUpCommotBut(false)
        button.setAttributedTitle(NSAttributedString(
            string: "Next",
            attributes: [ NSAttributedString.Key.font:
                            UIFont(name: "Georgia-BoldItalic",
                                   size: 18) ?? UIFont()]), for: .normal)
        return button
    } ()
    
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        currentPair = (dictionaryToPerform.dictionary?.removeFirst())!
        currentWord = currentPair.word
        currentTranslation = currentPair.translation ?? "   "
        navigationBarCustomization()
        mainViewCustomization()
        
        strokeCustomization()
        nextButCustomization()
        labelTranslationViewCustomization()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    //MARK: - Stroke SetUp
    func strokeCustomization(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
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
//MARK: - WordView SetUp
    func labelViewCustomization(){
        holderView.addSubview(labelWordView)
        
        labelWordView.translatesAutoresizingMaskIntoConstraints = false
        
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
        labelWordView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelWordView.topAnchor.constraint(equalTo: self.holderView.topAnchor, constant: 10),
            labelWordView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelWordView.heightAnchor.constraint(equalTo: self.holderView.heightAnchor, constant: -20),
            labelWordView.widthAnchor.constraint(equalTo: self.holderView.widthAnchor, constant: -20),
            
            label.centerXAnchor.constraint(equalTo: labelWordView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: labelWordView.centerYAnchor),
            label.widthAnchor.constraint(equalTo: labelWordView.widthAnchor, constant: -20)
        ])
        
    }
//MARK: - TranslationView SetUp
    func labelTranslationViewCustomization(){
                
        let label : UILabel = {
            let label = UILabel()
            label.attributedText = NSAttributedString(
                string: currentTranslation,
                attributes: [NSAttributedString.Key.font:
                                UIFont(name: "Georgia-Italic",
                                       size: 18) ?? UIFont()])
            label.numberOfLines = 0
            label.textAlignment = .center
            return label
        }()
        
        view.addSubview(labelTranslationView)
        labelTranslationView.addSubview(label)

        
        labelTranslationView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelTranslationView.bottomAnchor.constraint(equalTo: self.nextButton.topAnchor, constant: -20),
            labelTranslationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelTranslationView.heightAnchor.constraint(equalTo: self.holderView.heightAnchor),
            labelTranslationView.widthAnchor.constraint(equalToConstant: view.bounds.width - 45),
            
            label.centerXAnchor.constraint(equalTo: labelTranslationView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: labelTranslationView.centerYAnchor),
            label.widthAnchor.constraint(equalTo: labelTranslationView.widthAnchor),
            label.heightAnchor.constraint(equalTo: labelTranslationView.heightAnchor)
        ])
        
    }
    
//MARK: - NextButton SetUp
    func nextButCustomization(){
        view.addSubview(nextButton)
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -11),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: view.bounds.width - 45),
            nextButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }

//MARK: - Actions
    @objc func finish(sender: UIBarButtonItem){
        
    }
}
