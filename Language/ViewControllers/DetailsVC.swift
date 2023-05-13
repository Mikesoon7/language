//
//  DetailsVC.swift
//  Language
//
//  Created by Star Lord on 21/02/2023.
//

import UIKit

class DetailsVC: UIViewController {

    var dictionary : DictionariesEntity!
    var random : Bool!
    var numberOfCards : Int!
    var preselectedPickerNumber = Int()
    
    let randomizeCardsView : UIView = {
        var view = UIView()
        view.setUpBorderedView(false)
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
    
    lazy var setTheGoalView : UIView = {
        var view = UIView()
        view.setUpBorderedView(false)
        view.layer.masksToBounds = true
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
        button.setUpCommotBut(false)
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
        controllerCustomization()
        navBarCustomization()
        randomizeCardCustomization()
        setTheGoalCustomization()
        beginButCustomization()
        addNewWordsCustomization()
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.picker.reloadAllComponents()
        self.numberOfCards = dictionary.words?.count
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        strokeCustomization()
    }
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.bottomStroke.strokeColor = UIColor.label.cgColor
            self.topStroke.strokeColor = UIColor.label.cgColor
            if traitCollection.userInterfaceStyle == .dark {
                view.subviews.forEach { view in
                    view.layer.shadowColor = shadowColorForDarkIdiom
                }
            } else {
                view.subviews.forEach { view in
                    view.layer.shadowColor = shadowColorForLightIdiom
                }
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
    //MARK: - Controller SetUp
    func controllerCustomization(){
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
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
        navigationItem.backBarButtonItem?.menu = nil
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
        var shadowView = UIView()
        shadowView.setUpBorderedView(false)

        view.addSubviews(shadowView, setTheGoalView)

        picker.dataSource = self
        picker.delegate = self
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        setTheGoalView.addSubviews(setTheGoalLabel, picker)
        
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: self.randomizeCardsView.bottomAnchor, constant: 23),
            shadowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shadowView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            shadowView.heightAnchor.constraint(equalToConstant: 60),
            
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
            if dictionary.words!.count <= 49{
                return dictionary.words!.count
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
        if let randomDictionaries = dictionary.words?.allObjects as? [WordsEntity]{
            vc.currentRandomDictionary = randomDictionaries.shuffled()
            print("random getted")
        }
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
        if dictionary.words!.count <= 50{
            numberOfCards = dictionary.words!.count
        } else if row == pickerView.numberOfRows(inComponent: component) - 1{
            numberOfCards = dictionary.words!.count
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
        guard let number = dictionary.words?.count else { return 0}
        switch number % 50{
        case 0: return number / 50
        default: return (number / 50) + 1
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let number = dictionary.words?.count else { return " " }
        let overal = pickerView.numberOfRows(inComponent: 0)
        if row != overal - 1{
            return String((row + 1) * 50)
        } else {
            return String(number)

        }
        
            }
}
