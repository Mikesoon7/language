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
    
    let randomizeCardsView : UIView = {
        var view = UIView()
        view.setUpBorderedView(true)
        return view
    }()
    let randomizeLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString().fontWithString(
            string: "randomize".localized,
            bold: true, size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let setTheGoalView : UIView = {
        var view = UIView()
        view.setUpBorderedView(true)
        return view
    }()
    
    let setTheGoalLabel : UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString().fontWithString(
            string: "goal".localized,
            bold: true, size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let addNewWordsBut : UIButton = {
        var button = UIButton()
        button.setUpCommotBut(true)
        button.setAttributedTitle(NSAttributedString().fontWithString(
            string: "addWords".localized,
            bold: true,
            size: 20), for: .normal)
                    return button
    }()
    
    let beginBut : UIButton = {
        var button = UIButton()
        button.setUpCommotBut(false)
        button.setAttributedTitle(NSAttributedString().fontWithString(
            string: "start".localized,
            bold: true,
            size: 20), for: .normal)
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
        beginButCustomization()
        addNewWordsCustomization()
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navController = self.navigationController{
            let menu = navController.viewControllers.first(where: { $0 is MenuVC}) as? MenuVC
            menu?.tableView.reloadData()
        }
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
        navigationItem.title = "detailsTitle".localized
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        
        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "chart.bar"),
            style: .plain,
            target: self,
            action: #selector(statisticButTap(sender:)))
        self.navigationItem.setRightBarButton(rightButton, animated: true)
        navigationController?.navigationBar.tintColor = .label
        navigationItem.backButtonDisplayMode = .minimal
    }
    
//MARK: - RandomCardView SetUp
    func randomizeCardCustomization(){
        view.addSubview(randomizeCardsView)
        
        let switchForState : UISwitch = {
            let switchForState = UISwitch()
            switchForState.onTintColor = .systemGray2
            switchForState.tintColor = .systemBackground
            switchForState.setOn(true, animated: true)
            switchForState.addTarget(self, action: #selector(randomSwitchToggle(sender:)), for: .valueChanged)
            return switchForState
        }()
        
        switchForState.translatesAutoresizingMaskIntoConstraints = false
        randomizeCardsView.addSubviews(randomizeLabel, switchForState)
        
        NSLayoutConstraint.activate([
            randomizeCardsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            randomizeCardsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            randomizeCardsView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            randomizeCardsView.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
            
            randomizeLabel.centerYAnchor.constraint(equalTo: randomizeCardsView.centerYAnchor),
            randomizeLabel.leadingAnchor.constraint(equalTo: randomizeCardsView.leadingAnchor, constant: 15),
            
            switchForState.centerYAnchor.constraint(equalTo: randomizeCardsView.centerYAnchor),
            switchForState.trailingAnchor.constraint(equalTo: randomizeCardsView.trailingAnchor, constant: -25)
        ])
        switchForState.addTarget(self, action: #selector(randomSwitchToggle(sender:)), for: .valueChanged)
    }
    
//MARK: - SetTheGoal SetUp
    func setTheGoalCustomization(){
        view.addSubview(setTheGoalView)

        picker.dataSource = self
        picker.delegate = self
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        setTheGoalView.addSubviews(setTheGoalLabel, picker)
        
        NSLayoutConstraint.activate([
            setTheGoalView.topAnchor.constraint(equalTo: self.randomizeCardsView.bottomAnchor, constant: 23),
            setTheGoalView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            setTheGoalView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            setTheGoalView.heightAnchor.constraint(equalToConstant: 60),
            
            setTheGoalLabel.leadingAnchor.constraint(equalTo: setTheGoalView.leadingAnchor, constant: 15),
            setTheGoalLabel.centerYAnchor.constraint(equalTo: setTheGoalView.centerYAnchor),
            
            picker.trailingAnchor.constraint(equalTo: setTheGoalView.trailingAnchor),
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

//MARK: - AddNewWord SetUp
    func addNewWordsCustomization(){
        view.addSubview(addNewWordsBut)
        addNewWordsBut.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addNewWordsBut.bottomAnchor.constraint(equalTo: self.beginBut.topAnchor, constant: -23),
            addNewWordsBut.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addNewWordsBut.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
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
            beginBut.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            beginBut.heightAnchor.constraint(equalToConstant: 55)
            ])
        beginBut.addTarget(self, action: #selector(startButtonTap(sender: )), for: .touchUpInside)
        beginBut.addTargetTouchBegin()
        beginBut.addTargetOutsideTouchStop()
        beginBut.addTargetInsideTouchStop()
    }

//MARK: - Actions
    @objc func statisticButTap(sender: Any){
        let vc = LoadDataVC()
        self.present(vc, animated: true)
    }
    @objc func randomSwitchToggle(sender: UISwitch){
        random = sender.isOn
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
    @objc func languageDidChange(sender: Any){
        self.navigationItem.title = "detailsTitle".localized
        randomizeLabel.text = "randomize".localized
        setTheGoalLabel.text = "goal".localized
        
        addNewWordsBut.setAttributedTitle(NSAttributedString().fontWithString(
            string: "addWords".localized,
            bold: true,
            size: 20), for: .normal)

        beginBut.setAttributedTitle(NSAttributedString().fontWithString(
            string: "start".localized,
            bold: true,
            size: 18), for: .normal)
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
