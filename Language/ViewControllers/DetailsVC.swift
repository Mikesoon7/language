//
//  DetailsVC.swift
//  Language
//
//  Created by Star Lord on 21/02/2023.
//

import UIKit

class DetailsVC: UIViewController {

    var dictionary = DictionaryDetails()
    var random : Bool!
    var numberOfCards : Int!
    var preselectedPickerNumber = Int()
    
    let randomiseCardsView : UIView = {
        var view = UIView()
        view.setUpBorderedView(true)
        return view
    }()
    
    let setTheGoalView : UIView = {
        var view = UIView()
        view.setUpBorderedView(true)
        return view
    }()

    let usePictureView : UIView = {
        var view = UIView()
        view.setUpBorderedView(true)
        return view
    }()
    
    let addNewWordsBut : UIButton = {
        var button = UIButton()
        button.setUpCommotBut(true)
        button.setAttributedTitle(NSAttributedString().fontWithString(string: "Add new words", bold: true, size: 20), for: .normal)
                    return button
    }()
    
    let beginBut : UIButton = {
        var button = UIButton()
        button.setUpCommotBut(false)
        button.setAttributedTitle(NSAttributedString().fontWithString(string: "Start", bold: true, size: 20), for: .normal)
        return button
    }()
    
    let picker = UIPickerView()

    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBarCustomization()
        randomizeCardCustomization()
        setTheGoalCustomization()
        usePictureCustomization()
        beginButCustomization()
        addNewWordsCustomization()
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.picker.reloadAllComponents()
        self.numberOfCards = Int(dictionary.numberOfCards)
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
    //MARK: - Stroke SetUp
    func strokeCustomization(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
//MARK: - NavigationBar SetUp
    func navBarCustomization(){
        navigationItem.title = "Source Details"
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        
        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsButTap(sender:)))
        self.navigationItem.setRightBarButton(rightButton, animated: true)
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationItem.backButtonTitle = "Menu"
        }
    
//MARK: - RandomCardView SetUp
    func randomizeCardCustomization(){
        view.addSubview(randomiseCardsView)
                
        let label : UILabel = {
            let label = UILabel()
            label.attributedText = NSAttributedString().fontWithString(string: "Randomize cards", bold: true, size: 18)
            return label
        }()
        
        let switchForState : UISwitch = {
            let switchForState = UISwitch()
            switchForState.onTintColor = .systemGray2
            switchForState.tintColor = .systemBackground
            switchForState.setOn(true, animated: true)
            switchForState.addTarget(self, action: #selector(randomSwitchToggle(sender:)), for: .valueChanged)
            return switchForState
        }()
        
        randomiseCardsView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        switchForState.translatesAutoresizingMaskIntoConstraints = false
        
        randomiseCardsView.addSubviews(label, switchForState)
        
        NSLayoutConstraint.activate([
            randomiseCardsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
            randomiseCardsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            randomiseCardsView.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
            randomiseCardsView.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
            
            label.centerYAnchor.constraint(equalTo: randomiseCardsView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: randomiseCardsView.leadingAnchor, constant: 15),
            
            switchForState.centerYAnchor.constraint(equalTo: randomiseCardsView.centerYAnchor),
            switchForState.trailingAnchor.constraint(equalTo: randomiseCardsView.trailingAnchor, constant: -25)
        ])
        switchForState.addTarget(self, action: #selector(randomSwitchToggle(sender:)), for: .valueChanged)
    }
    
//MARK: - SetTheGoal SetUp
    func setTheGoalCustomization(){
        view.addSubview(setTheGoalView)

        picker.dataSource = self
        picker.delegate = self
        
        let label : UILabel = {
            let label = UILabel()
            label.attributedText = NSAttributedString(
                string: "Set the goal",
                attributes: [NSAttributedString.Key.font :
                                UIFont(name: "Georgia-BoldItalic", size: 18) ?? UIFont(),
                             NSAttributedString.Key.foregroundColor :
                                UIColor.label
                            ])
            return label
        }()
        
        setTheGoalView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        setTheGoalView.addSubviews(label, picker)
        
        NSLayoutConstraint.activate([
            setTheGoalView.topAnchor.constraint(equalTo: self.randomiseCardsView.bottomAnchor, constant: 23),
            setTheGoalView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            setTheGoalView.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
            setTheGoalView.heightAnchor.constraint(equalToConstant: 60),
            
            label.leadingAnchor.constraint(equalTo: setTheGoalView.leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: setTheGoalView.centerYAnchor),
            
            picker.trailingAnchor.constraint(equalTo: setTheGoalView.trailingAnchor, constant: 0),
            picker.centerYAnchor.constraint(equalTo: setTheGoalView.centerYAnchor),
            picker.widthAnchor.constraint(equalTo: setTheGoalView.widthAnchor, multiplier: 0.3)
        ])
        preselectedPickerNumber = {
            if Int(dictionary.numberOfCards)! <= 49{
                return Int(dictionary.numberOfCards)!
            } else {
                return 50
            }
        }()
    }

//MARK: - UsePicture SetUp
    func usePictureCustomization(){
        view.addSubview(usePictureView)
        usePictureView.translatesAutoresizingMaskIntoConstraints = false
        
        let label : UILabel = {
            let label = UILabel()

            label.attributedText = NSAttributedString(
                string: "Use pictures",
                attributes: [NSAttributedString.Key.font :
                                UIFont(name: "Georgia-BoldItalic", size: 18) ?? UIFont(),
                             NSAttributedString.Key.foregroundColor :
                                UIColor.label
                            ])
            return label
        }()
        
        let switchForState : UISwitch = {
            let switchForState = UISwitch()
            switchForState.onTintColor = .systemGray2
            switchForState.tintColor = .systemBackground
            switchForState.setOn(false, animated: true)
            switchForState.addTarget(self, action: #selector(usePicturesSwitchToggle(sender:)), for: .valueChanged)
            return switchForState
        }()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        switchForState.translatesAutoresizingMaskIntoConstraints = false
        
        usePictureView.addSubviews(label, switchForState)
        
        NSLayoutConstraint.activate([
            usePictureView.topAnchor.constraint(equalTo: self.setTheGoalView.bottomAnchor, constant: 23),
            usePictureView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usePictureView.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
            usePictureView.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
            
            label.centerYAnchor.constraint(equalTo: usePictureView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: usePictureView.leadingAnchor, constant: 15),
            
            switchForState.centerYAnchor.constraint(equalTo: usePictureView.centerYAnchor),
            switchForState.trailingAnchor.constraint(equalTo: usePictureView.trailingAnchor, constant: -25)
        ])

    }
//MARK: - AddNewWord SetUp
    func addNewWordsCustomization(){
        view.addSubview(addNewWordsBut)
        addNewWordsBut.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addNewWordsBut.bottomAnchor.constraint(equalTo: self.beginBut.topAnchor, constant: -23),
            addNewWordsBut.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addNewWordsBut.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
            addNewWordsBut.heightAnchor.constraint(equalToConstant: 55)
        ])
        addNewWordsBut.addTargetTouchBegin()
        addNewWordsBut.addTargetOutsideTouchStop()
        addNewWordsBut.addTargetInsideTouchStop()
        addNewWordsBut.addTarget(self, action: #selector(addWordsButtonTap(sender:)), for: .touchUpInside)
    }
//MARK: - Toolbar SetUp
    func beginButCustomization(){
        view.addSubview(beginBut)
        beginBut.translatesAutoresizingMaskIntoConstraints = false
    
        NSLayoutConstraint.activate([
            beginBut.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -11),
            beginBut.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            beginBut.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
            beginBut.heightAnchor.constraint(equalToConstant: 55)
            ])
        beginBut.addTarget(self, action: #selector(startButtonTap(sender: )), for: .touchUpInside)
        beginBut.addTargetTouchBegin()
        beginBut.addTargetOutsideTouchStop()
        beginBut.addTargetInsideTouchStop()
    }

//MARK: - Actions
    @objc func settingsButTap(sender: Any){
        let vc = LoadDataVC()
        self.present(vc, animated: true)
    }
    @objc func randomSwitchToggle(sender: UISwitch){
        random = sender.isOn
    }
    @objc func usePicturesSwitchToggle(sender: Any){
        
    }
    
    
    @objc func startButtonTap(sender: UIButton){
        let vc = MainGameVC()
        if self.numberOfCards == nil{
            self.numberOfCards = preselectedPickerNumber
        }
        if self.random == nil{
            self.random = true
        }
        vc.currentDictionary = self.dictionary
        vc.currentRandomDictionary = self.dictionary.dictionary?.shuffled()
        vc.random = self.random
        vc.numberOFCards = self.numberOfCards
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func addWordsButtonTap(sender: UIButton){
        let vc = AddWordsVC()
        vc.editableDict = dictionary
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension DetailsVC: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if Int(dictionary.numberOfCards)! <= 50{
            numberOfCards = Int(dictionary.numberOfCards)!
        } else if row == pickerView.numberOfRows(inComponent: component) - 1{
            numberOfCards = Int(dictionary.numberOfCards)!
        } else {
            numberOfCards = (row + 1) * 50
        }
    }
}
extension DetailsVC: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if ((Int(dictionary.numberOfCards)!) / 50) > 0{
           return ((Int(dictionary.numberOfCards)!) / 50) + 1
        } else {
            return 1
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row != (pickerView.numberOfRows(inComponent: component) - 1)  {
            return "\((row + 1) * 50)"
        } else {
            return dictionary.numberOfCards
        }
    }
}
