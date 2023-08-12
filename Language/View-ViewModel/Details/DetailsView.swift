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
    private var viewModel: DetailsViewModel!
    private var cancellable = Set<AnyCancellable>()
    
    //MARK: - Views
    //View fot changing cards order
    let randomizeCardsView : UIView = {
        var view = UIView()
        view.setUpCustomView()
        return view
    }()
    
    let randomizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let randmizeSwitch : UISwitch = {
        let switcher = UISwitch()
        switcher.setUpCustomSwitch(isOn: false)
        return switcher
    }()
    
    //View to define number of cards
    let goalView : UIView = {
        var view = UIView()
        view.setUpCustomView()
        view.layer.masksToBounds = true
        return view
    }()
    
    let goalLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let addWordsBut : UIButton = {
        var button = UIButton()
        button.setUpCustomButton()
        return button
    }()
    
    let beginBut : UIButton = {
        var button = UIButton()
        button.setUpCustomButton()
        return button
    }()
    
    let picker = UIPickerView()

    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    //MARK: - Local variables.
    private var randomIsOn: Bool = false
    
    private var numberOfCards: Int!
    private var selectedNumberOfCards : Int!
    
    //MARK: - Inherited methods
    required init(dictionary: DictionariesEntity){
        viewModel = DetailsViewModel(dictionary: dictionary)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureController()
        configureNavBar()
        configureRandomizeView()
        configureGoalView()
        configureStartButton()
        configureAddWordsButton()
        configureText()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureStrokes()
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
    //MARK: - ViewModel bind
    func bind(){
        viewModel.output
            .sink { output in
                switch output{
                case .shouldUpdateText:
                    self.configureText()
                case .error(let error):
                    self.presentError(error)
                }
            }
            .store(in: &cancellable)
        viewModel.$dataForView
            .sink { [weak self] data in
                self?.numberOfCards = data?.pickerNumber
                self?.picker.reloadAllComponents()
            }
            .store(in: &cancellable)
    }
    //MARK: - Stroke SetUp
    func configureStrokes(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
    //MARK: - Controller SetUp
    func configureController(){
        view.backgroundColor = .systemBackground
        
    }
    //MARK: - NavigationBar SetUp
    func configureNavBar(){
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    //MARK: - RandomCardView SetUp
    func configureRandomizeView(){
        view.addSubview(randomizeCardsView)
        
        randmizeSwitch.translatesAutoresizingMaskIntoConstraints = false
        randomizeCardsView.addSubviews(randomizeLabel, randmizeSwitch)
        
        NSLayoutConstraint.activate([
            randomizeCardsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            randomizeCardsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            randomizeCardsView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            randomizeCardsView.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
            
            randomizeLabel.centerYAnchor.constraint(equalTo: randomizeCardsView.centerYAnchor),
            randomizeLabel.leadingAnchor.constraint(equalTo: randomizeCardsView.leadingAnchor, constant: 15),
            
            randmizeSwitch.centerYAnchor.constraint(equalTo: randomizeCardsView.centerYAnchor),
            randmizeSwitch.trailingAnchor.constraint(equalTo: randomizeCardsView.trailingAnchor, constant: -25)
        ])
        randmizeSwitch.addTarget(self, action: #selector(randomSwitchToggle(sender:)), for: .valueChanged)
    }
    
//MARK: - SetTheGoal SetUp
    func configureGoalView(){
        //Cause of picker to archive desirable appearence, we need to set bounds masking, blocking shadow view. So we need to add custom one.
        let shadowView = UIView()
        shadowView.setUpCustomView()

        view.addSubviews(shadowView, goalView)
        view.addSubviews( goalView)

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
        selectedNumberOfCards = {
            if numberOfCards <= 49{
                return numberOfCards
            } else {
                return 50
            }
        }()
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
    func configureText(){
        self.navigationItem.title = "detailsTitle".localized
        
        randomizeLabel.attributedText = NSAttributedString().fontWithString(
            string: "randomize".localized,
            bold: true, size: 18)

        goalLabel.attributedText = NSAttributedString().fontWithString(
            string: "goal".localized,
            bold: true, size: 18)
        
        addWordsBut.setAttributedTitle(NSAttributedString().fontWithString(
            string: "addWords".localized,
            bold: true,
            size: 20), for: .normal)

        beginBut.setAttributedTitle(NSAttributedString().fontWithString(
            string: "start".localized,
            bold: true,
            size: 18), for: .normal)
    }
    
//MARK: - Actions
    @objc func randomSwitchToggle(sender: UISwitch){
        randomIsOn = sender.isOn
    }
    
    @objc func startButtonTap(sender: UIButton){
        let vc = viewModel.provideGameView(with: randomIsOn, numberOfCards: selectedNumberOfCards)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @objc func addWordsButtonTap(sender: UIButton){
        let vc = viewModel.provideAddWordsView()
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension DetailsView: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if numberOfCards <= 50 || row == pickerView.numberOfRows(inComponent: component) - 1 {
            selectedNumberOfCards = numberOfCards
        } else {
            selectedNumberOfCards = (row + 1) * 50
        }
    }
}

extension DetailsView: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let number = numberOfCards else { return 0}
        switch number % 50{
        case 0: return number / 50
        default: return (number / 50) + 1
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let number = numberOfCards else { return " " }
        let overal = pickerView.numberOfRows(inComponent: 0)
        if row != overal - 1{
            return String((row + 1) * 50)
        } else {
            return String(number)

        }
     }
}
