//
//  DetailsVC.swift
//  Language
//
//  Created by Star Lord on 21/02/2023.
//


import UIKit
import Combine

class DetailsView: UIViewController {
    
    //MARK: - ViewModel related
    private var viewModel: DetailsViewModel?
    private var viewModelFactory: ViewModelFactory
    private var cancellable = Set<AnyCancellable>()
        
    //MARK: - Views
    //View fot changing cards order
    private let randomizeCardsView : UIView = {
        var view = UIView()
        view.setUpCustomView()
        return view
    }()

    private let randomizeLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .selectedFont.withSize(18)
        label.text = "details.randomize".localized
        return label
    }()
    
    private let randmizeSwitch : UISwitch = {
        let switcher = UISwitch()
        switcher.setUpCustomSwitch(isOn: false)
        return switcher
    }()
    
    //View to define number of cards
    private let goalView : UIView = {
        var view = UIView()
        view.setUpCustomView()
        view.layer.masksToBounds = true
        return view
    }()
        
    private let goalLabel : UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(18)
        label.text = "details.goal".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let hideTransaltionView: UIView = {
        let view = UIView()
        view.setUpCustomView()
        view.layer.masksToBounds = true
        return view
    }()
    
    private let hideTransaltionLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .selectedFont.withSize(18)
        label.text = "details.hideTranslation".localized
        return label
    }()
    
    private let hideTransaltionSwitch : UISwitch = {
        let switcher = UISwitch()
        switcher.setUpCustomSwitch(isOn: false)
        return switcher
    }()

    private let addWordsBut : UIButton = {
        var button = UIButton()
        button.setUpCustomButton()
        return button
    }()
    
    private let beginBut : UIButton = {
        var button = UIButton()
        button.setUpCustomButton()
        return button
    }()
    
    private let picker = UIPickerView()
    
//    //MARK: Local variables.
    private var randomIsOn: Bool = false
    private var hideTransaltionIsOn: Bool = false

    
    
    
    //MARK: Inherited and initialization.
    required init(factory: ViewModelFactory, dictionary: DictionariesEntity){
        self.viewModelFactory = factory
        self.viewModel = factory.configureDetailsViewModel(dictionary: dictionary)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
//        configureRandomizeView()
//        configureGoalView()
//        configureHideTransaltionView()
        configureSwitchView()
        configureGoalViewTest()
        configureStartButton()
        configureAddWordsButton()
        configureLabels()
        retrieveDetailsData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.saveDetails(isRandom: randmizeSwitch.isOn, hideTransaltion: hideTransaltionSwitch.isOn)
    }
    
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
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
    
    //MARK: - ViewModel bind
    func bind(){
        viewModel?.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output{
                case .shouldUpdateLangauge:
                    self?.configureLabels()
                case .shouldUpdateFont:
                    self?.configureLabels()
                case .error(let error):
                    self?.presentError(error)
                case .shouldUpdatePicker:
                    self?.picker.reloadAllComponents()
                case .shouldPresentAddWordsView(let dict):
                    self?.presentAddWordsViewWith(dictionary: dict)
                case .shouldPresentGameView(let dict, let number):
                    self?.presentMainGameViewWith(dictionary: dict, selectedNumber: number)
                }
            }
            .store(in: &cancellable)
    }
    //MARK: - RandomCardView SetUp
    func configureRandomizeView(){
        view.addSubview(randomizeCardsView)
        
        randmizeSwitch.translatesAutoresizingMaskIntoConstraints = false
        randomizeCardsView.addSubviews(randomizeLabel, randmizeSwitch)
        
        NSLayoutConstraint.activate([
            randomizeCardsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            randomizeCardsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            randomizeCardsView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                      multiplier: CGFloat.widthMultiplerFor(type: .forViews)),
            randomizeCardsView.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
            
            randomizeLabel.centerYAnchor.constraint(equalTo: randomizeCardsView.centerYAnchor),
            randomizeLabel.leadingAnchor.constraint(equalTo: randomizeCardsView.leadingAnchor, constant: 15),
            
            randmizeSwitch.centerYAnchor.constraint(equalTo: randomizeCardsView.centerYAnchor),
            randmizeSwitch.trailingAnchor.constraint(equalTo: randomizeCardsView.trailingAnchor, constant: -25)
        ])
        randmizeSwitch.addTarget(self, action: #selector(randomSwitchToggle(sender:)), for: .valueChanged)
    }
    
    
    let testView = {
        let view = UIView()
        view.setUpCustomView()
        view.layer.masksToBounds = true
        return view
    }()
    func retrieveDetailsData(){
        self.randmizeSwitch.isOn = viewModel?.isRandomOn() ?? false
        self.hideTransaltionSwitch.isOn = viewModel?.isHideTranslationOn() ?? false
    
        picker.selectRow(viewModel?.selectedRowForPicker() ?? 1, inComponent: 0, animated: true)
    }
    func configureSwitchView(){
        //Cause of picker to archive desirable appearence, we need to set bounds masking, blocking shadow view. So we need to add custom one.
        let shadowView = UIView()
        shadowView.setUpCustomView()
        
        view.addSubviews(shadowView, testView)
                
        testView.addSubviews(randomizeLabel, randmizeSwitch, hideTransaltionLabel, hideTransaltionSwitch)
        
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            shadowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shadowView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                              multiplier: CGFloat.widthMultiplerFor(type: .forViews)),
            shadowView.heightAnchor.constraint(equalToConstant: 120),
            
            testView.topAnchor.constraint(equalTo: shadowView.topAnchor) ,
            testView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
            testView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor),
            testView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
            
            randomizeLabel.centerYAnchor.constraint(equalTo: testView.centerYAnchor, constant: -30),
            randomizeLabel.leadingAnchor.constraint(equalTo: testView.leadingAnchor, constant: 15),
            
            randmizeSwitch.centerYAnchor.constraint(equalTo: testView.centerYAnchor, constant: -30),
            randmizeSwitch.trailingAnchor.constraint(equalTo: testView.trailingAnchor, constant: -25),
            
            hideTransaltionLabel.centerYAnchor.constraint(equalTo: testView.centerYAnchor, constant: 30),
            hideTransaltionLabel.leadingAnchor.constraint(equalTo: testView.leadingAnchor, constant: 15),
            
            hideTransaltionSwitch.centerYAnchor.constraint(equalTo: testView.centerYAnchor, constant: 30 ),
            hideTransaltionSwitch.trailingAnchor.constraint(equalTo: testView.trailingAnchor, constant: -25)

        ])
        randmizeSwitch.addTarget(self, action: #selector(randomSwitchToggle(sender:)), for: .valueChanged)
        hideTransaltionSwitch.addTarget(self, action: #selector(hideTransaltionSwitchToggle(sender:)), for: .valueChanged)

    }
    func configureGoalViewTest(){
        //Cause of picker to archive desirable appearence, we need to set bounds masking, blocking shadow view. So we need to add custom one.
        let shadowView = UIView()
        shadowView.setUpCustomView()
        
        view.addSubviews(shadowView, goalView)
        
        picker.dataSource = self
        picker.delegate = self
        
        picker.translatesAutoresizingMaskIntoConstraints = false
//        print(picker.numberOfRows(inComponent: 1))
//        picker.selectRow(viewModel?.selectedRowForPicker() ?? 1, inComponent: 1, animated: true)
        goalView.addSubviews(goalLabel, picker)
        
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: self.testView.bottomAnchor, constant: 23),
            shadowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shadowView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                              multiplier: CGFloat.widthMultiplerFor(type: .forViews)),
            shadowView.heightAnchor.constraint(equalToConstant: 60),
            
            goalView.topAnchor.constraint(equalTo: shadowView.topAnchor) ,
            goalView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
            goalView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor),
            goalView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
            
            goalLabel.leadingAnchor.constraint(equalTo: goalView.leadingAnchor, constant: 15),
            goalLabel.centerYAnchor.constraint(equalTo: goalView.centerYAnchor),
            
            picker.trailingAnchor.constraint(equalTo: goalView.trailingAnchor),
            picker.centerYAnchor.constraint(equalTo: goalView.centerYAnchor),
            picker.widthAnchor.constraint(equalTo: goalView.widthAnchor, multiplier: 0.3)
        ])
    }


    //MARK: - SetTheGoal SetUp
    func configureGoalView(){
        //Cause of picker to archive desirable appearence, we need to set bounds masking, blocking shadow view. So we need to add custom one.
        let shadowView = UIView()
        shadowView.setUpCustomView()
        
        view.addSubviews(shadowView, goalView)
        
        picker.dataSource = self
        picker.delegate = self
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        goalView.addSubviews(goalLabel, picker)
        
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: self.randomizeCardsView.bottomAnchor, constant: 23),
            shadowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shadowView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                              multiplier: CGFloat.widthMultiplerFor(type: .forViews)),
            shadowView.heightAnchor.constraint(equalToConstant: 60),
            
            goalView.topAnchor.constraint(equalTo: shadowView.topAnchor) ,
            goalView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
            goalView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor),
            goalView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
            
            goalLabel.leadingAnchor.constraint(equalTo: goalView.leadingAnchor, constant: 15),
            goalLabel.centerYAnchor.constraint(equalTo: goalView.centerYAnchor),
            
            picker.trailingAnchor.constraint(equalTo: goalView.trailingAnchor),
            picker.centerYAnchor.constraint(equalTo: goalView.centerYAnchor),
            picker.widthAnchor.constraint(equalTo: goalView.widthAnchor, multiplier: 0.3)
        ])
    }
    
    //MARK: - HideTranslationView SetUp
    func configureHideTransaltionView(){
        
        let shadowView = UIView()
        shadowView.setUpCustomView()
        
        view.addSubviews(shadowView)
        shadowView.addSubview(hideTransaltionView)

        hideTransaltionSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        hideTransaltionView.addSubviews(hideTransaltionLabel, hideTransaltionSwitch)
        
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: self.goalView.bottomAnchor, constant: 23),
            shadowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shadowView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                              multiplier: CGFloat.widthMultiplerFor(type: .forViews)),
            shadowView.heightAnchor.constraint(equalToConstant: 60),

            hideTransaltionView.topAnchor.constraint(equalTo: shadowView.topAnchor),
            hideTransaltionView.centerXAnchor.constraint(equalTo: shadowView.centerXAnchor),
            hideTransaltionView.widthAnchor.constraint(equalTo: shadowView.widthAnchor),
            hideTransaltionView.heightAnchor.constraint(equalTo: shadowView.heightAnchor),
            
            hideTransaltionLabel.centerYAnchor.constraint(equalTo: hideTransaltionView.centerYAnchor),
            hideTransaltionLabel.leadingAnchor.constraint(equalTo: hideTransaltionView.leadingAnchor, constant: 15),
            
            hideTransaltionSwitch.centerYAnchor.constraint(equalTo: hideTransaltionView.centerYAnchor),
            hideTransaltionSwitch.trailingAnchor.constraint(equalTo: hideTransaltionView.trailingAnchor, constant: -25)
        ])
        hideTransaltionSwitch.addTarget(self, action: #selector(hideTransaltionSwitchToggle(sender:)), for: .valueChanged)
    }

    
    //MARK: - AddNewWord SetUp
    func configureAddWordsButton(){
        view.addSubview(addWordsBut)
        addWordsBut.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addWordsBut.bottomAnchor.constraint(equalTo: self.beginBut.topAnchor, constant: -23),
            addWordsBut.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addWordsBut.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            addWordsBut.heightAnchor.constraint(equalToConstant: 55)
        ])
        addWordsBut.addTargetTouchBegin()
        addWordsBut.addTargetOutsideTouchStop()
        addWordsBut.addTargetInsideTouchStop()
        addWordsBut.addTarget(self, action: #selector(addWordsButtonTap(sender:)), for: .touchUpInside)
    }
    //MARK: - StartBut SetUp
    func configureStartButton(){
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
    //Assigning text on initializing and if language changes
    func configureLabels(){
        self.navigationItem.title = "details.title".localized
        self.randomizeLabel.text = "details.randomize".localized
        self.goalLabel.text = "details.goal".localized
        configureButtons()
    }
    func updateFont(){
        randomizeLabel.font = .selectedFont.withSize(18)
        goalLabel.font = .selectedFont.withSize(18)
        configureButtons()
    }
    //Easiest way to update button's title or font is to set new attributes.This function called in case of langauge or font chagne.
    private func configureButtons(){
        addWordsBut.setAttributedTitle(
            .attributedString(
                string: "details.addWords".localized,
                with: .selectedFont,
                ofSize: 20), for: .normal
        )
                    
        beginBut.setAttributedTitle(
            .attributedString(
                string: "details.start".localized,
                with: .selectedFont,
                ofSize: 20), for: .normal
        )
    }

    
    //MARK: Configure and present child ViewControllers
    //Called after recieving the event with passed dictionary
    func presentAddWordsViewWith(dictionary: DictionariesEntity){
        let vc = AddWordsView(factory: viewModelFactory, dictionary: dictionary)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //Initializing
    func presentMainGameViewWith(dictionary: DictionariesEntity, selectedNumber: Int){
        let random = viewModel?.isRandomOn()
        let number = viewModel?.selectedNumberOfCards()
        let hide = viewModel?.isHideTranslationOn()
        print(hide)
        let vc = MainGameVC(viewModelFactory: viewModelFactory, dictionary: dictionary, isRandom:/* random ??*/ self.randmizeSwitch.isOn, hideTransaltion: /*hide ??*/ self.hideTransaltionSwitch.isOn, selectedNumber: number ?? selectedNumber)
        print (hideTransaltionIsOn)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
//MARK: - Actions
extension DetailsView{
    
    @objc func randomSwitchToggle(sender: UISwitch){
        randomIsOn = sender.isOn
    }
    
    @objc func hideTransaltionSwitchToggle(sender: UISwitch){
        hideTransaltionIsOn = sender.isOn
    }

    @objc func startButtonTap(sender: UIButton){
        viewModel?.startButtonTapped()
    }

    @objc func addWordsButtonTap(sender: UIButton){
        viewModel?.addWordsButtonTapped()
    }
}

//MARK: - UPPicker delegate & dataSource
extension DetailsView: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel?.didSelectPickerRow(row: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel?.numberOfRowsInComponent() ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel?.titleForPickerAt(row: row) ?? ""
     }
}
