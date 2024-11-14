//
//  DetailsVC.swift
//  Language
//
//  Created by Star Lord on 21/02/2023.
//


import UIKit
import Combine

protocol Presenter{
    func startTheGame(vc: UIViewController)
}
//MARK: - Custom Segment control with adjustable corner radius
class UICustomSegmentedControl: UISegmentedControl {
    
    let cornerRadius: CGFloat
    
    required init(cornerRadius: CGFloat){
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn'r imported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
}

class DetailsView: UIViewController {
    
    //MARK: - ViewModel related
    private var viewModel: DetailsViewModel?
    private var viewModelFactory: ViewModelFactory
    private var cancellable = Set<AnyCancellable>()
    
    //MARK: - Views
    //View fot changing cards order
//    private let randomizeCardsView : UIView = {
//        var view = UIView()
//        view.setUpCustomView()
//        return view
//    }()
//    
//    private let randomizeLabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .selectedFont.withSize(18)
//        label.text = "details.randomize".localized
//        return label
//    }()
//    
//    private let randomizeSwitch : UISwitch = {
//        let switcher = UISwitch()
//        switcher.setUpCustomSwitch(isOn: false)
//        return switcher
//    }()
    
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
    
    private let isOneSideModeView: UIView = {
        let view = UIView()
        view.setUpCustomView()
        view.layer.masksToBounds = true
        return view
    }()
    
    private let isOneSideModeLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .selectedFont.withSize(18)
        label.text = "details.showTranslation".localized
        return label
    }()
    
    private let isOneSideModeSwitch : UISwitch = {
        let switcher = UISwitch()
        switcher.setUpCustomSwitch(isOn: false)
        return switcher
    }()
    
    private let testSegwayView: UICustomSegmentedControl = {
        var control = UICustomSegmentedControl(cornerRadius: 9)
        control.insertSegment(withTitle: "details.cardsOrder.noraml".localized, at: 0, animated: false)
        control.insertSegment(withTitle: "details.cardsOrder.random".localized, at: 1, animated: false)
        control.insertSegment(withTitle: "details.cardsOrder.reverse".localized, at: 2, animated: false)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 1
        
        return control
    }()
    private let testSegwayLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .selectedFont.withSize(18)
        label.text = "details.cardsOrder".localized
        return label
        
    }()
    
    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "system.save".localized,
            style: .done,
            target: self,
            action: #selector(rightBarButDidTap(sender:))
        )
        return button
    }()

    lazy var textView: TextInputView = {
        let view = TextInputView(delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textView.layer.borderColor = UIColor.clear.cgColor
        return view
    }()
    

    let settingView = {
        let view = UIView()
        view.setUpCustomView()
        view.layer.masksToBounds = true
        return view
    }()

    let testSettingsShadowView: UIView = {
        let view = UIView()
        view.setUpCustomView()
        return view
    }()
    let testTextViewShadowView: UIView = {
        let view = UIView()
        view.setUpCustomView()
        return view
    }()
    let testGoalShadowView: UIView = {
        let view = UIView()
        view.setUpCustomView()
        return view
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
    private var selectedCardsOrder: DictionariesSettings.CardOrder = .normal
    private var hideTransaltionIsOn: Bool = false
    

    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    var textViewActiveConstraints: [NSLayoutConstraint] = []
    var textViewInactiveConstraints: [NSLayoutConstraint] = []
    
    var textViewActiveHorConstraints: [NSLayoutConstraint] = []
    var textViewInactiveHorConstraints: [NSLayoutConstraint] = []


//    var textViewHeightVert: NSLayoutConstraint!
//    var textViewHeightHor: NSLayoutConstraint!
//    var textViewWidthAnchor: NSLayoutConstraint!
//    var textViewPortraitWidth: NSLayoutConstraint!
    
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
        
        //Version number one
//        configureRandomizeView()
//        configureGoalView()
//        configureHideTransaltionView()
//        configureController()
        configureNavBar()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            setUpCommonViews()
            applyConstraints(for: traitCollection)
        } else {
            setUpIphoneViews()
//            configureDetailsView()
//            configureGoalViewTest()
        }
        configureSettingsView()
        configureGoalView()

        //Version number 2
//        testRandomSetUp()
        configureStartButton()

        
//        configureAddWordsButton()
        configureLabels()
        retrieveDetailsData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.saveDetails(orderSelection: DictionariesSettings.CardOrder(rawValue: Int64(self.testSegwayView.selectedSegmentIndex)) ?? .normal  , isOneSideMode: isOneSideModeSwitch.isOn)
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.userInterfaceIdiom == .pad {
            applyConstraints(for: traitCollection)
        }
    }

    //MARK: Layout adjust methods.
    ///Update textView layout.
    private func updateTextViewConstraits(keyboardIsVisable: Bool){
        let isLandscape = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { [weak self] in
            guard let self = self else {return}
            if keyboardIsVisable {
                NSLayoutConstraint.deactivate(
                    (isLandscape ? textViewInactiveHorConstraints : textViewInactiveConstraints)
                )
                NSLayoutConstraint.activate(
                    (isLandscape ? textViewActiveHorConstraints : textViewActiveConstraints)
                )
            } else {
                NSLayoutConstraint.deactivate(
                    (isLandscape ? textViewActiveHorConstraints : textViewActiveConstraints)
                    
                )
                NSLayoutConstraint.activate(
                    (isLandscape ? textViewInactiveHorConstraints : textViewInactiveConstraints)
                )
            }
            view.layoutIfNeeded()
        }
    }
    ///Updating the constraints depending on the orientation and first responder status.
    private func applyConstraints(for traitCollection: UITraitCollection) {
        NSLayoutConstraint.deactivate(portraitConstraints)
        NSLayoutConstraint.deactivate(landscapeConstraints)
        
        let isTextViewActive = textView.textView.isFirstResponder
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            NSLayoutConstraint.deactivate(isTextViewActive ? textViewActiveConstraints : textViewInactiveConstraints)
            NSLayoutConstraint.activate(isTextViewActive ? textViewActiveHorConstraints : textViewInactiveHorConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        } else {
            NSLayoutConstraint.deactivate(isTextViewActive ? textViewActiveHorConstraints : textViewInactiveHorConstraints)
            NSLayoutConstraint.activate(isTextViewActive ? textViewActiveConstraints : textViewInactiveConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        }
    }

    
        

    //MARK: - ViewModel bind
    func bind(){
        viewModel?.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else {return}
                switch output{
                case .shouldUpdateLangauge:
                    configureLabels()
                case .shouldUpdateFont:
                    updateFont()
                case .error(let error):
                    presentError(error)
                case .shouldUpdatePicker:
                    picker.reloadAllComponents()
                case .shouldPresentAddWordsView(let dict):
                    presentAddWordsViewWith(dictionary: dict)
                case .shouldPresentGameView(let dict, let number):
                    presentMainGameViewWith(dictionary: dict, selectedNumber: number)
                }
            }
            .store(in: &cancellable)
    }
    //MARK: - NavBar setUp
    func configureNavBar() {
        let addNewWordsButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addNavButtonTap(sender:)))

        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "stopwatch"),
            style: .plain,
            target: self,
            action: #selector(clockedSession(sender:)))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.navigationItem.setRightBarButton(rightButton, animated: true)
        } else {
            self.navigationItem.setRightBarButtonItems([rightButton, addNewWordsButton], animated: true)
        }
        
    }
    //MARK: - Views SetUp
    private func configureSettingsView(){
        view.addSubviews(settingView)
        settingView.addSubviews(testSegwayLabel, testSegwayView)
        settingView.addSubviews( isOneSideModeLabel, isOneSideModeSwitch)
        
        NSLayoutConstraint.activate([
            
            settingView.topAnchor.constraint(equalTo: testSettingsShadowView.topAnchor) ,
            settingView.leadingAnchor.constraint(equalTo: testSettingsShadowView.leadingAnchor),
            settingView.bottomAnchor.constraint(equalTo: testSettingsShadowView.bottomAnchor),
            settingView.trailingAnchor.constraint(equalTo: testSettingsShadowView.trailingAnchor),
            
            isOneSideModeLabel.centerYAnchor.constraint(equalTo: settingView.centerYAnchor, constant: -45),
            isOneSideModeLabel.leadingAnchor.constraint(equalTo: settingView.leadingAnchor, constant: 15),
            
            isOneSideModeSwitch.centerYAnchor.constraint(equalTo: isOneSideModeLabel.centerYAnchor),
            isOneSideModeSwitch.trailingAnchor.constraint(equalTo: settingView.trailingAnchor, constant: -25),
            
            testSegwayLabel.topAnchor.constraint(equalTo: settingView.centerYAnchor),
            testSegwayLabel.leadingAnchor.constraint(equalTo: settingView.leadingAnchor, constant: 15),

            testSegwayView.widthAnchor.constraint(equalTo: settingView.widthAnchor, constant: -15),
            testSegwayView.bottomAnchor.constraint(equalTo: settingView.bottomAnchor, constant: -10),
            testSegwayView.centerXAnchor.constraint(equalTo: settingView.centerXAnchor)

        ])
//        randomizeSwitch.addTarget(self, action: #selector(randomSwitchToggle(sender:)), for: .valueChanged)
        testSegwayView.addTarget(self, action: #selector(orderSegwayToggle(sender: )), for: .valueChanged)
        isOneSideModeSwitch.addTarget(self, action: #selector(hideTransaltionSwitchToggle(sender:)), for: .valueChanged)

    }

    private func configureGoalView(){
        view.addSubviews(goalView)
        
        picker.dataSource = self
        picker.delegate = self
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        goalView.addSubviews(goalLabel, picker)
        
        NSLayoutConstraint.activate([
            goalView.topAnchor.constraint(equalTo: testGoalShadowView.topAnchor) ,
            goalView.leadingAnchor.constraint(equalTo: testGoalShadowView.leadingAnchor),
            goalView.bottomAnchor.constraint(equalTo: testGoalShadowView.bottomAnchor),
            goalView.trailingAnchor.constraint(equalTo: testGoalShadowView.trailingAnchor),
            
            goalLabel.leadingAnchor.constraint(equalTo: goalView.leadingAnchor, constant: 15),
            goalLabel.centerYAnchor.constraint(equalTo: goalView.centerYAnchor),
            
            picker.trailingAnchor.constraint(equalTo: goalView.trailingAnchor),
            picker.centerYAnchor.constraint(equalTo: goalView.centerYAnchor),
            picker.widthAnchor.constraint(equalTo: goalView.widthAnchor, multiplier: 0.3)
        ])
    }
        // MARK: - View's containers SetUp
        /// Configures and adds views to the hierarchy.
    private func setUpIphoneViews() {
        view.addSubviews(testSettingsShadowView, testGoalShadowView)
        
        NSLayoutConstraint.activate([
            //Settings
            testSettingsShadowView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 35),
            testSettingsShadowView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            testSettingsShadowView.heightAnchor.constraint(
                equalToConstant: 150),
            testSettingsShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),

            //Goal
            testGoalShadowView.topAnchor.constraint(
                equalTo: testSettingsShadowView.bottomAnchor,
                constant: 23),
            testGoalShadowView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor ),
            testGoalShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor,
                multiplier: .widthMultiplerFor(type: .forViews)),
            testGoalShadowView.heightAnchor.constraint(
                equalToConstant: 60),

        ])
    }
    private func setUpCommonViews() {
        view.addSubviews(testSettingsShadowView, testTextViewShadowView, testGoalShadowView)
        
        testTextViewShadowView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: testTextViewShadowView.topAnchor) ,
            textView.leadingAnchor.constraint(equalTo: testTextViewShadowView.leadingAnchor),
            textView.bottomAnchor.constraint(equalTo: testTextViewShadowView.bottomAnchor),
            textView.trailingAnchor.constraint(equalTo: testTextViewShadowView.trailingAnchor),
        ])
        
        let height = max(view.bounds.height, view.bounds.width)
        let width = min(view.bounds.height, view.bounds.width)
        
        let insetSpaceVertical = (width - ( width * .widthMultiplerFor(type: .forViews))) / 2
        let insetSpaceHorizontal = (height - ( height * .widthMultiplerFor(type: .forViews))) / 2
        
        //IPad textView constraints for portrait mode with text view being the first responder.
        textViewActiveConstraints = [
            testTextViewShadowView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: insetSpaceVertical),
            testTextViewShadowView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -insetSpaceVertical),
            testTextViewShadowView.heightAnchor.constraint(equalToConstant: 300),
            testTextViewShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor,
                multiplier: .widthMultiplerFor(type: .forViews)),
        ]
        
        //IPad textView constraints for portrait mode.
        textViewInactiveConstraints = [
            testTextViewShadowView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: insetSpaceVertical),
            testTextViewShadowView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -insetSpaceVertical),
            testTextViewShadowView.heightAnchor.constraint(
                equalToConstant: 150),
            testTextViewShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor,
                multiplier: .widthMultiplerFor(type: .forViews) / 2,
                constant: -insetSpaceVertical / 4 ),
        ]
        
        //IPad textView constraints for landscape mode with text view being the first responder.
        //Using vertical inset to archive more visibility with the text view.
        textViewActiveHorConstraints = [
            testTextViewShadowView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: insetSpaceVertical / 2),
            testTextViewShadowView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -insetSpaceVertical / 2),
            testTextViewShadowView.heightAnchor.constraint(
                equalTo: testSettingsShadowView.heightAnchor),
            testTextViewShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor,
                constant: -insetSpaceVertical ),
            
        ]
        
        //IPad textView constraints for lanscape mode.
        textViewInactiveHorConstraints = [
            testTextViewShadowView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: insetSpaceHorizontal),
            testTextViewShadowView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -insetSpaceHorizontal),
            testTextViewShadowView.heightAnchor.constraint(
                equalToConstant: 150 + insetSpaceHorizontal / 2 + 60),
            testTextViewShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor,
                multiplier: .widthMultiplerFor(type: .forViews) / 2,
                constant: -insetSpaceHorizontal / 4 ),
        ]
        
        
        //Ipad Contraints for portrait mode. TextView's constraits activates first.
        portraitConstraints = [
            //Settings
            testSettingsShadowView.topAnchor.constraint(
                equalTo: testTextViewShadowView.topAnchor),
            testSettingsShadowView.trailingAnchor.constraint(
                equalTo: testTextViewShadowView.leadingAnchor,
                constant: -insetSpaceVertical / 2),
            testSettingsShadowView.heightAnchor.constraint(
                equalToConstant: 150),
            testSettingsShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor,
                multiplier: .widthMultiplerFor(type: .forViews) / 2,
                constant: -insetSpaceVertical / 4),
            
            //Goal
            testGoalShadowView.topAnchor.constraint(
                equalTo: testTextViewShadowView.bottomAnchor,
                constant: insetSpaceVertical / 2),
            testGoalShadowView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor ),
            testGoalShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor,
                multiplier: .widthMultiplerFor(type: .forViews)),
            testGoalShadowView.heightAnchor.constraint(
                equalToConstant: 60),
        ]
        
        //Ipad Contraints for landscape mode.
        landscapeConstraints = [
            //Settings
            testSettingsShadowView.topAnchor.constraint(
                equalTo: testTextViewShadowView.topAnchor),
            testSettingsShadowView.trailingAnchor.constraint(
                equalTo: testTextViewShadowView.leadingAnchor,
                constant: -insetSpaceHorizontal / 2),
            testSettingsShadowView.heightAnchor.constraint(
                equalToConstant: 150),
            testSettingsShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor,
                multiplier: .widthMultiplerFor(type: .forViews) / 2,
                constant: -insetSpaceHorizontal / 4 ),
            
            //Goal
            testGoalShadowView.topAnchor.constraint(
                equalTo: testTextViewShadowView.bottomAnchor,
                constant: -60),
            testGoalShadowView.leadingAnchor.constraint(
                equalTo: testSettingsShadowView.leadingAnchor),
            testGoalShadowView.widthAnchor.constraint(
                equalTo: testSettingsShadowView.widthAnchor),
            testGoalShadowView.heightAnchor.constraint(
                equalToConstant: 60),
        ]
    }
    
    //MARK: - AddNewWord SetUp
    func configureAddWordsButton(){
        view.addSubview(addWordsBut)
        
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
        addWordsBut.isHidden = true
    }
    //MARK: - StartBut SetUp
    func configureStartButton(){
        view.addSubview(beginBut)
        
        NSLayoutConstraint.activate([
            beginBut.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -23),
            beginBut.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            beginBut.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            beginBut.heightAnchor.constraint(equalToConstant: 55)
        ])
        beginBut.addTarget(self, action: #selector(startButtonTap(sender: )), for: .touchUpInside)
        beginBut.addTargetTouchBegin()
        beginBut.addTargetOutsideTouchStop()
        beginBut.addTargetInsideTouchStop()
    }


//    //MARK: - RandomCardView SetUp
//    func configureRandomizeView(){
//        view.addSubview(randomizeCardsView)
//        
//        randomizeSwitch.translatesAutoresizingMaskIntoConstraints = false
//        randomizeCardsView.addSubviews(randomizeLabel, randomizeSwitch)
//        
//        NSLayoutConstraint.activate([
//            randomizeCardsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
//            randomizeCardsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            randomizeCardsView.widthAnchor.constraint(equalTo: view.widthAnchor,
//                                                      multiplier: CGFloat.widthMultiplerFor(type: .forViews)),
//            randomizeCardsView.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
//            
//            randomizeLabel.centerYAnchor.constraint(equalTo: randomizeCardsView.centerYAnchor),
//            randomizeLabel.leadingAnchor.constraint(equalTo: randomizeCardsView.leadingAnchor, constant: 15),
//            
//            randomizeSwitch.centerYAnchor.constraint(equalTo: randomizeCardsView.centerYAnchor),
//            randomizeSwitch.trailingAnchor.constraint(equalTo: randomizeCardsView.trailingAnchor, constant: -25)
//        ])
//        randomizeSwitch.addTarget(self, action: #selector(randomSwitchToggle(sender:)), for: .valueChanged)
//    }
//    
//    //MARK: - HideTranslationView SetUp
//    func configureHideTransaltionView(){
//        
//        let shadowView = UIView()
//        shadowView.setUpCustomView()
//        
//        view.addSubviews(shadowView)
//        shadowView.addSubview(isOneSideModeView)
//
//        isOneSideModeSwitch.translatesAutoresizingMaskIntoConstraints = false
//        
//        isOneSideModeView.addSubviews(isOneSideModeLabel, isOneSideModeSwitch)
//        
//        NSLayoutConstraint.activate([
//            shadowView.topAnchor.constraint(equalTo: self.goalView.bottomAnchor, constant: 23),
//            shadowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            shadowView.widthAnchor.constraint(equalTo: view.widthAnchor,
//                                              multiplier: CGFloat.widthMultiplerFor(type: .forViews)),
//            shadowView.heightAnchor.constraint(equalToConstant: 60),
//
//            isOneSideModeView.topAnchor.constraint(equalTo: shadowView.topAnchor),
//            isOneSideModeView.centerXAnchor.constraint(equalTo: shadowView.centerXAnchor),
//            isOneSideModeView.widthAnchor.constraint(equalTo: shadowView.widthAnchor),
//            isOneSideModeView.heightAnchor.constraint(equalTo: shadowView.heightAnchor),
//            
//            isOneSideModeLabel.centerYAnchor.constraint(equalTo: isOneSideModeView.centerYAnchor),
//            isOneSideModeLabel.leadingAnchor.constraint(equalTo: isOneSideModeView.leadingAnchor, constant: 15),
//            
//            isOneSideModeSwitch.centerYAnchor.constraint(equalTo: isOneSideModeView.centerYAnchor),
//            isOneSideModeSwitch.trailingAnchor.constraint(equalTo: isOneSideModeView.trailingAnchor, constant: -25)
//        ])
//        isOneSideModeSwitch.addTarget(self, action: #selector(hideTransaltionSwitchToggle(sender:)), for: .valueChanged)
//    }
//
//    //MARK: - SetTheGoal SetUp
//    func configureGoalViewa(){
//        //Cause of picker to archive desirable appearence, we need to set bounds masking, blocking shadow view. So we need to add custom one.
//        let shadowView = UIView()
//        shadowView.setUpCustomView()
//        
//        view.addSubviews(shadowView, goalView)
//        
//        picker.dataSource = self
//        picker.delegate = self
//        
//        picker.translatesAutoresizingMaskIntoConstraints = false
//        
//        goalView.addSubviews(goalLabel, picker)
//        
//        NSLayoutConstraint.activate([
//            shadowView.topAnchor.constraint(equalTo: self.randomizeCardsView.bottomAnchor, constant: 23),
//            shadowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            shadowView.widthAnchor.constraint(equalTo: view.widthAnchor,
//                                              multiplier: CGFloat.widthMultiplerFor(type: .forViews)),
//            shadowView.heightAnchor.constraint(equalToConstant: 60),
//            
//            goalView.topAnchor.constraint(equalTo: shadowView.topAnchor) ,
//            goalView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
//            goalView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor),
//            goalView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
//            
//            goalLabel.leadingAnchor.constraint(equalTo: goalView.leadingAnchor, constant: 15),
//            goalLabel.centerYAnchor.constraint(equalTo: goalView.centerYAnchor),
//            
//            picker.trailingAnchor.constraint(equalTo: goalView.trailingAnchor),
//            picker.centerYAnchor.constraint(equalTo: goalView.centerYAnchor),
//            picker.widthAnchor.constraint(equalTo: goalView.widthAnchor, multiplier: 0.3)
//        ])
//    }

    
    //MARK: - Test
    func retrieveDetailsData(){
        self.selectedCardsOrder = viewModel?.selectedCardsOrder() ?? .normal
        self.testSegwayView.selectedSegmentIndex = Int(selectedCardsOrder.rawValue)
        self.isOneSideModeSwitch.isOn = viewModel?.isHideTranslationOn() ?? false
    
        picker.selectRow(viewModel?.selectedRowForPicker() ?? 1, inComponent: 0, animated: true)
    }
    
//    func testRandomSetUp(){
//        view.addSubviews(randomizeLabel, randomizeSwitch)
//        
//        NSLayoutConstraint.activate([
//            randomizeLabel.centerYAnchor.constraint(equalTo: settingView.centerYAnchor, constant: 30),
//            randomizeLabel.leadingAnchor.constraint(equalTo: settingView.leadingAnchor, constant: 15),
//            
//            randomizeSwitch.centerYAnchor.constraint(equalTo: settingView.centerYAnchor, constant: 30),
//            randomizeSwitch.trailingAnchor.constraint(equalTo: settingView.trailingAnchor, constant: -25),
//        ])
//    }

    //Assigning text on initializing and if language changes
    func configureLabels(){
        self.navigationItem.title = "details.title".localized
        self.testSegwayLabel.text = "details.cardsOrder".localized
        self.goalLabel.text = "details.goal".localized
        configureButtons()
    }
    func updateFont(){
        testSegwayLabel.font = .selectedFont.withSize(18)
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
//        let selectedOrder = viewModel?.selectedCardsOrder()
        let number = viewModel?.selectedNumberOfCards()
//        let hide = viewModel?.isHideTranslationOn()
        let vc = MainGameVC(viewModelFactory: viewModelFactory, dictionary: dictionary, selectedOrder: selectedCardsOrder, hideTransaltion: /*hide ??*/ self.isOneSideModeSwitch.isOn, selectedNumber: number ?? selectedNumber)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
//MARK: - Actions
extension DetailsView{
    @objc func addNavButtonTap(sender: UIBarButtonItem){
        let vc = AddWordsPartitialController(factory: self.viewModelFactory, dictionary: viewModel?.dictionary ?? DictionariesEntity())
        present(vc, animated: true)
    }

    @objc func clockedSession(sender: UIBarButtonItem){
        let vc = TimedDetailView(viewModelFactory: self.viewModelFactory, viewModel: self.viewModel, delegate: self)
        self.present(vc, animated: true)
    }
    
    @objc func orderSegwayToggle(sender: UISegmentedControl){
        selectedCardsOrder = DictionariesSettings.CardOrder(rawValue: Int64(sender.selectedSegmentIndex)) ?? .normal
    }

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
    
    @objc func rightBarButDidTap(sender: Any){
        navigationItem.rightBarButtonItems?.removeAll(where: { button in
            button == saveButton
        })
        textView.textView.resignFirstResponder()
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
extension DetailsView: PlaceholderTextViewDelegate{
    func textViewDidBeginEditing() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            updateTextViewConstraits(keyboardIsVisable: true)
        }
        navigationItem.rightBarButtonItems?.append(saveButton)
    }
    func textViewDidEndEditing() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            updateTextViewConstraits(keyboardIsVisable: false)
        }

        navigationItem.rightBarButtonItems?.removeAll(where: { button in
            button == saveButton
        })
    }
    
    func configurePlaceholderText() -> String? {
        viewModel?.configureTextPlaceholder()
    }
}
extension DetailsView: Presenter {
    func startTheGame(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
