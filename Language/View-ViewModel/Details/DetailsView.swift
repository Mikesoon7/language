//
//  DetailsVC.swift
//  Language
//
//  Created by Star Lord on 21/02/2023.
//
//TODO: Polished


import UIKit
import Combine

protocol GameViewPresenter{
    func presentGameControllerWithCustomParameter(selectedTime: Int)
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
    
    enum EditState {
        case idle
        case editingText
    }

    //MARK: - ViewModel related
    private var dictionary: DictionariesEntity
    private var viewModel: DetailsViewModel
    
    private var viewModelFactory: ViewModelFactory
    private var cancellable = Set<AnyCancellable>()
    
    private var alertCoordinator: AlertCoordinator = AlertCoordinator()
    private var keyboardListener: KeyboardListener!
    
    private var horizontalSizeClass: CustomLayoutContext!
    private var viewEditState: EditState = .idle
    private var isInModalMode: Bool = false


    //MARK: - Subviews
    //SHADOWS
    private let settingsShadowView: UIView = {
        let view = UIView()
        view.setUpCustomView()
        view.tag = 1
        return view
    }()
    private let textViewShadowView: UIView = {
        let view = UIView()
        view.setUpCustomView()
        view.tag = 2
        return view
    }()
    private let goalShadowView: UIView = {
        let view = UIView()
        view.setUpCustomView()
        view.tag = 3
        return view
    }()
    
    
    //VIEWS
    private let settingView = {
        let view = UIView()
        view.setUpCustomView()
        view.layer.masksToBounds = true
        return view
    }()
    
    private let goalView : UIView = {
        var view = UIView()
        view.setUpCustomView()
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var textInputView: TextInputView = {
        let view = TextInputView(delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.clear.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowColor = UIColor.clear.cgColor
        view.layer.shadowOpacity = 0
        return view
    }()
    
    
    //SUBVIEWS
    private let isOneSideModeLabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .selectedFont.withSize(.bodyTextSize)
        label.text = "details.showTranslation".localized
        return label
    }()
    
    private let isOneSideModeSwitch : UISwitch = {
        let switcher = UISwitch()
        switcher.setUpCustomSwitch(isOn: false)
        return switcher
    }()
    
    
    private let orderOptionsLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .selectedFont.withSize(.bodyTextSize)
        label.text = "details.cardsOrder".localized
        return label
    }()
    
    private let orderOptionSegmentedControl: UICustomSegmentedControl = {
        var control = UICustomSegmentedControl(cornerRadius: .cornerRadius)
        control.insertSegment(withTitle: "details.cardsOrder.noraml".localized, at: 0, animated: false)
        control.insertSegment(withTitle: "details.cardsOrder.random".localized, at: 1, animated: false)
        control.insertSegment(withTitle: "details.cardsOrder.reverse".localized, at: 2, animated: false)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 1
        return control
    }()
    
    
    private let goalLabel : UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.bodyTextSize)
        label.text = "details.goal".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let goalPicker = UIPickerView()
    
    
    //MARK: NAV Buttons
    lazy var addNewWordsButton = UIBarButtonItem(
        image: UIImage(systemName: "plus"),
        style: .plain,
        target: self,
        action: #selector(addNavButtonTap(sender:)))
    
    lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "system.save".localized,
            style: .done,
            target: self,
            action: #selector(saveButtonDidTap(sender:))
        )
        return button
    }()
    lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "system.done".localized,
            style: .done,
            target: self,
            action: #selector(doneButtonDidTap(sender:)))
        return button
    }()
    
    //Button for ipad version to access single Mode input view.
    private lazy var switchModeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "doc.richtext"),
                                     style: .done,
                                     target: self,
                                     action: #selector(sigleModeWasEngaged(sender: )))
        button.tag = 0
        return button
    }()

    
    //MARK: Buttons
    lazy var timedButton: UIButton = {
        let button = UIButton()
        button.setUpCustomButton()
        button.setImage(UIImage(systemName: "stopwatch",
                                withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)),
                        for: .normal)
        button.addTarget(self, action: #selector(clockedSession(sender:)), for: .touchUpInside)
        return button
    }()
    lazy var beginBut : UIButton = {
        var button = UIButton()
        button.setUpCustomButton()
        button.addTarget(self, action: #selector(startButtonTap(sender: )), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: Constraints.
    private var generalConstraints:           [NSLayoutConstraint] = [] //Permanent
    private var regularWidthClassConstraints: [NSLayoutConstraint] = [] //Wide screen
    private var compactWidthClassConstraints: [NSLayoutConstraint] = [] //Small screen
    
    private var regularWidthClassTextViewActiveConstraints: [NSLayoutConstraint] = []
    private var regularWidthClassTextViewConstraints:       [NSLayoutConstraint] = []
    
    
    //MARK: Inherited and initialization.
    required init(factory: ViewModelFactory, dictionary: DictionariesEntity){
        self.viewModelFactory = factory
        self.dictionary = dictionary
        self.viewModel = factory.configureDetailsViewModel(dictionary: dictionary)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        bindViewHelpers()
        
        configureController()
        configureShadowViews()
        configureStartButton()
        
        configureSettingsView()
        configureTextView()
        configureGoalView()
    
        updateForLanguageChange()
        retrieveDetailsData()
        
        NSLayoutConstraint.activate(generalConstraints)
//        viewModel.performInitialSetUp(selectedMode: layoutMode(for: view.bounds.width))
        applyLayout(for: view.bounds.size)
        
//        updateNavBar(state: viewModel.primaryAction)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = textInputView.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //Ensuring that the size is correct.
        applyLayout(for: view.bounds.size)
    }
    
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            let interfaceStyle = traitCollection.userInterfaceStyle
            view.subviews.forEach { view in
                view.layer.shadowColor = interfaceStyle == .dark ? shadowColorForDarkIdiom : shadowColorForLightIdiom
            }
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        applyLayout(for: size)
    }
    
        
    //MARK: - ViewModel bind
    func bind(){
        viewModel.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else {return}
                switch output{
                case .shouldUpdateLangauge:
                    updateForLanguageChange()
                    textInputView.updatePlaceholder()
                case .shouldUpdateFont:
                    updateForFontChange()
                    textInputView.updatePlaceholder()
                case .shouldUpdatePicker:
                    goalPicker.reloadAllComponents()
                    goalPicker.selectRow(viewModel.selectedRowForPicker(), inComponent: 0, animated: true)
                case .shouldUpdatePlaceholder:
                    textInputView.updatePlaceholder()
                }
            }
            .store(in: &cancellable)
        viewModel.editOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else {return}
                switch output {
                case .presentModalEditor(let mode, let text):
                    self.textInputView.clearTextView()
                    presentAddWordsController(with: text, mode: mode)
                    self.isInModalMode = true
                case .shouldPresentAlert(let alertType):
                    self.presentAlert(for: alertType)
                case .shouldPresentError(let error):
                    self.presentError(error, sourceView: self.view)
                case .editFinishedSuccessfully:
                    self.textInputView.clearTextView()
                }
            }
            .store(in: &cancellable)

    }
    
    func bindViewHelpers() {
        keyboardListener = KeyboardListener(view: self.view)
        
        keyboardListener.events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleKeyboard(event)
            }
            .store(in: &cancellable)
        
        alertCoordinator.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                    switch output {
                    case .save:
                        self?.viewModel.extendDictionary()
                    case .delete:
                        self?.navigationController?.popViewController(animated: true)
                    case .edit:
                        fallthrough
                    case .cancel:
                        break
                    }
            }
            .store(in: &cancellable)
    }
    
    //MARK: - Subviews SetUp
    private func configureController() {
        self.view.backgroundColor = .systemBackground
        
//        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    
    //MARK: Shadow view's setUp
    // Shadow views takes a role of view holder, which helps to optimize the code.
    private func configureShadowViews(){
        view.addSubviews(textViewShadowView, settingsShadowView, goalShadowView)
        
        regularWidthClassTextViewConstraints.append(contentsOf:[
            textViewShadowView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: .longOuterSpacer),
            textViewShadowView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.longInnerSpacer),
            textViewShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: 0.5,
                constant: -.longInnerSpacer - .longInnerSpacer / 2),
            textViewShadowView.heightAnchor.constraint(
                equalToConstant: .textViewGenericSize + .longInnerSpacer + .genericButtonHeight),
        ])
        
        
        regularWidthClassTextViewActiveConstraints.append(contentsOf: [
            textViewShadowView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            textViewShadowView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            textViewShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor),
            textViewShadowView.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor),
            textViewShadowView.bottomAnchor.constraint(
                lessThanOrEqualTo: beginBut.topAnchor,
                constant: -.longInnerSpacer),
        ])
        
        generalConstraints.append(contentsOf: [
            settingsShadowView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .longOuterSpacer),
            settingsShadowView.heightAnchor.constraint(
                equalToConstant: .textViewGenericSize),

            goalShadowView.topAnchor.constraint(
                equalTo: settingsShadowView.bottomAnchor, constant: .longInnerSpacer),
            goalShadowView.trailingAnchor.constraint(
                equalTo: settingsShadowView.trailingAnchor),
            goalShadowView.leadingAnchor.constraint(
                equalTo: settingsShadowView.leadingAnchor),
            goalShadowView.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight)
        ])
        
        regularWidthClassConstraints.append(contentsOf: [
            settingsShadowView.trailingAnchor.constraint(
                equalTo: textViewShadowView.leadingAnchor, constant: -.innerSpacer),
            settingsShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: 0.5,  constant: -.longInnerSpacer - .longInnerSpacer / 2),
        ])
        
        
        compactWidthClassConstraints.append(contentsOf:[
            textViewShadowView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .longOuterSpacer),
            textViewShadowView.leadingAnchor.constraint(
                equalTo: view.trailingAnchor, 
                constant: .longInnerSpacer),
            textViewShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: 0.5,
                constant: -.longInnerSpacer - .longInnerSpacer / 2),
            textViewShadowView.heightAnchor.constraint(
                equalToConstant: .textViewGenericSize),
            
            settingsShadowView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.longInnerSpacer),
            settingsShadowView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .longInnerSpacer),
        ])
    }
    //MARK: - View's SetUp
    private func configureTextView() {
        textViewShadowView.addSubview(textInputView)
        
        generalConstraints.append(contentsOf: [
            textInputView.topAnchor.constraint(
                equalTo: textViewShadowView.topAnchor) ,
            textInputView.leadingAnchor.constraint(
                equalTo: textViewShadowView.leadingAnchor),
            textInputView.bottomAnchor.constraint(
                equalTo: textViewShadowView.bottomAnchor),
            textInputView.trailingAnchor.constraint(
                equalTo: textViewShadowView.trailingAnchor),
        ])
    }
    
    private func configureSettingsView(){
        view.addSubviews(settingView)
        settingView.addSubviews(orderOptionsLabel, orderOptionSegmentedControl)
        settingView.addSubviews( isOneSideModeLabel, isOneSideModeSwitch)
        
        generalConstraints.append(contentsOf: [
            settingView.topAnchor.constraint(
                equalTo: settingsShadowView.topAnchor),
            settingView.leadingAnchor.constraint(
                equalTo: settingsShadowView.leadingAnchor),
            settingView.bottomAnchor.constraint(
                equalTo: settingsShadowView.bottomAnchor),
            settingView.trailingAnchor.constraint(
                equalTo: settingsShadowView.trailingAnchor),
            
            
            isOneSideModeLabel.centerYAnchor.constraint(
                equalTo: settingView.centerYAnchor, 
                constant: -45),
            isOneSideModeLabel.leadingAnchor.constraint(
                equalTo: settingView.leadingAnchor,
                constant: .innerSpacer),
            
            
            isOneSideModeSwitch.trailingAnchor.constraint(
                equalTo: settingView.trailingAnchor, 
                constant: -.outerSpacer),
            isOneSideModeSwitch.centerYAnchor.constraint(
                equalTo: isOneSideModeLabel.centerYAnchor),
            
            
            orderOptionsLabel.leadingAnchor.constraint(
                equalTo: settingView.leadingAnchor, 
                constant: .innerSpacer),
            orderOptionsLabel.topAnchor.constraint(
                equalTo: settingView.centerYAnchor),
            
            
            orderOptionSegmentedControl.widthAnchor.constraint(
                equalTo: settingView.widthAnchor, constant: -.nestedSpacer * 2),
            orderOptionSegmentedControl.bottomAnchor.constraint(
                equalTo: settingView.bottomAnchor, constant: -.nestedSpacer),
            orderOptionSegmentedControl.centerXAnchor.constraint(equalTo: settingView.centerXAnchor)
            
        ])
        orderOptionSegmentedControl.addTarget(self, action: #selector(orderSegwayToggle(sender: )), for: .valueChanged)
        isOneSideModeSwitch.addTarget(self, action: #selector(hideTransaltionSwitchToggle(sender:)), for: .valueChanged)
    }
    
    private func configureGoalView(){
        view.addSubviews(goalView)
        
        goalPicker.dataSource = self
        goalPicker.delegate = self
        
        goalPicker.translatesAutoresizingMaskIntoConstraints = false
        goalView.addSubviews(goalLabel, goalPicker)
        
        generalConstraints.append(contentsOf: [
            goalView.topAnchor.constraint(
                equalTo: goalShadowView.topAnchor) ,
            goalView.leadingAnchor.constraint(
                equalTo: goalShadowView.leadingAnchor),
            goalView.bottomAnchor.constraint(
                equalTo: goalShadowView.bottomAnchor),
            goalView.trailingAnchor.constraint(
                equalTo: goalShadowView.trailingAnchor),
            
            goalLabel.leadingAnchor.constraint(
                equalTo: goalView.leadingAnchor, constant: .innerSpacer),
            goalLabel.centerYAnchor.constraint(
                equalTo: goalView.centerYAnchor),
            
            goalPicker.trailingAnchor.constraint(
                equalTo: goalView.trailingAnchor),
            goalPicker.centerYAnchor.constraint(
                equalTo: goalView.centerYAnchor),
            goalPicker.widthAnchor.constraint(
                equalTo: goalView.widthAnchor, multiplier: 0.3)
        ])
    }
    
    //MARK:  StartBut SetUp
    private func configureStartButton(){
        view.addSubviews(timedButton, beginBut)
        
        generalConstraints.append(contentsOf: [
            timedButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -.longInnerSpacer),
            timedButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -.longInnerSpacer),
            timedButton.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            
            beginBut.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -.longInnerSpacer),
            beginBut.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: .longInnerSpacer),
            beginBut.trailingAnchor.constraint(
                equalTo: timedButton.leadingAnchor,
                constant: -.innerSpacer),
            beginBut.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight)
        ])
        
        regularWidthClassConstraints.append(contentsOf: [
            timedButton.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: 0.2),
        ])
        
        compactWidthClassConstraints.append(contentsOf: [
            timedButton.widthAnchor.constraint(
                equalToConstant: .genericButtonHeight),
        ])
    }
    
    //MARK: - Load details data.
    private func retrieveDetailsData(){
        let selectedOrder = viewModel.selectedCardsOrder()
        
        self.orderOptionSegmentedControl.selectedSegmentIndex = Int(selectedOrder.rawValue)
        self.isOneSideModeSwitch.isOn = viewModel.isHideTranslationOn()
        goalPicker.selectRow(viewModel.selectedRowForPicker(), inComponent: 0, animated: true)
    }
    
    
    //MARK: Layout and animation
    private func applyLayout(for size: CGSize) {
        let newMode = view.layoutContext()
        guard newMode != horizontalSizeClass else { return }
        
        horizontalSizeClass = newMode
        updateLayout(for: newMode)
        recomputePrimaryAction()
        
        viewModel.layoutDidChange(to: newMode)

    }
    
    private func updateLayout(for sizeClass: CustomLayoutContext){
        switch sizeClass {
        case .compact:
            NSLayoutConstraint.deactivate(regularWidthClassConstraints)
            NSLayoutConstraint.deactivate(regularWidthClassTextViewConstraints)
            NSLayoutConstraint.activate(compactWidthClassConstraints)
        case .regular:
            NSLayoutConstraint.deactivate(compactWidthClassConstraints)
            NSLayoutConstraint.activate(regularWidthClassTextViewConstraints)
            NSLayoutConstraint.activate(regularWidthClassConstraints)
        }
        view.layoutIfNeeded()
    }

    //MARK: TextViewLayout
        
    private func updateTextViewLayoutForState(state: KeyboardListener.KeyboardVisibility){
        let isVisible = state == .visible
        NSLayoutConstraint.deactivate(
            isVisible
            ? regularWidthClassTextViewConstraints
            : regularWidthClassTextViewActiveConstraints)
        NSLayoutConstraint.activate(
            isVisible
            ? regularWidthClassTextViewActiveConstraints
            : regularWidthClassTextViewConstraints
        )
        self.textInputView.layer.cornerRadius = (
            isVisible ? 0 : .cornerRadius)
        self.textInputView.backgroundColor = (
            isVisible
            ? .systemBackground
            : .selectedColourPalette.primaryBackgroundColour)
        self.textViewShadowView.layer.shadowOpacity = (
            isVisible ? 0 : 0.8)
    }
    
    
    private func handleKeyboard(_ event: KeyboardListener.Event) {
        guard !isInModalMode else { return }
        UIView.animate(
            withDuration: event.duration,
            delay: 0,
            options: event.curve
        ) {
            switch event.presence {
            case .hidden, .accessoryOnly:
                self.updateTextViewLayoutForState(state: .hidden)
            case .full:
                self.updateTextViewLayoutForState(state: .visible)
            }
            self.view.layoutIfNeeded()
        }
    }
    private func recomputePrimaryAction() {
        let isEmpty = textInputView.currentText().isEmpty

        let newAction: DetailsViewPrimaryActions = {
            switch viewEditState {
            case .editingText:
                return isEmpty ? .doneAndSwitch : .saveAndSwitch
            case .idle:
                switch horizontalSizeClass {
                case .compact:
                    return .addButton
                case .regular:
                    return isEmpty ? .switchButton : .saveAndSwitch
                case .none:
                    return .undefined
                }
            }
        }()
        updateNavBar(state: newAction)
    }


    
    //MARK: - System
    ///Adding save button to navigation bar.
    private func updateNavBar(state: DetailsViewPrimaryActions) {
        guard UIDevice.isIPadDevice else {
            navigationItem.rightBarButtonItems = [addNewWordsButton]
            return
        }
        switch state {
        case .saveAndSwitch:
            navigationItem.rightBarButtonItems = [saveButton, switchModeButton]
        case .doneAndSwitch:
            navigationItem.rightBarButtonItems = [doneButton, switchModeButton]
        case .addButton:
            navigationItem.rightBarButtonItems = [addNewWordsButton]
        case .switchButton:
            navigationItem.rightBarButtonItems = [switchModeButton]
        case .undefined:
            break
        }
    }
    
    func presentAlert(for alert: AlertType) {
        let alert = self.alertCoordinator.makeAlert(alertType: alert)
        self.present(alert, animated: true)
    }
    

    //Assigning text on initializing and if language changes
    private func updateForLanguageChange(){
        self.navigationItem.title = "details.title".localized
        self.isOneSideModeLabel.text = "details.showTranslation".localized
        self.orderOptionsLabel.text = "details.cardsOrder".localized
        self.goalLabel.text = "details.goal".localized
        
        self.orderOptionSegmentedControl.setTitle("details.cardsOrder.noraml".localized,
                                                  forSegmentAt: 0)
        self.orderOptionSegmentedControl.setTitle("details.cardsOrder.random".localized,
                                                  forSegmentAt: 1)
        self.orderOptionSegmentedControl.setTitle("details.cardsOrder.reverse".localized,
                                                  forSegmentAt: 2)
        
        configureButtons()
    }
    
    private func updateForFontChange(){
        isOneSideModeLabel.font = .selectedFont.withSize(.bodyTextSize)
        orderOptionsLabel.font = .selectedFont.withSize(.bodyTextSize)
        goalLabel.font = .selectedFont.withSize(.bodyTextSize)
        textInputView.updateFont(font: .selectedFont.withSize(.subBodyTextSize))
        
        configureButtons()
    }
    
    //Easiest way to update button's title or font is to set new attributes.This function called in case of langauge or font chagne.
    private func configureButtons(){
        beginBut.setAttributedTitle(
            .attributedString(
                string: "details.start".localized,
                with: .selectedFont,
                ofSize: .subtitleSize), for: .normal
        )
        saveButton.title = "system.save".localized
    }
    
    //MARK: View Presenters
    private func presentAddWordsController(with text: String? = nil, mode: DataInputMode ){
        let vc = AddWordsPartitialController(
            factory:        self.viewModelFactory,
            dictionary:     viewModel.dictionary,
            text:           text,
            inputMode:      mode
        )
        vc.modalPresentationStyle = .pageSheet
        vc.sheetPresentationController?.detents = [.large()]

        self.navigationController?.present(vc, animated: true)
    }
    private func presentTimedDetailsController(){
        let vc = TimedDetailView(delegate: self,
                                 timeIntervalUpTo:  60)
        vc.modalPresentationStyle = .formSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
        }
        self.navigationController?.present(vc, animated: true)
    }
    private func presentGameController(selectedTime: Int? = nil){
        let vc = MainGameVC(viewModelFactory:   viewModelFactory,
                            dictionary:         viewModel.dictionary,
                            selectedOrder:      viewModel.selectedCardsOrder(),
                            isOneSideModeOn:    viewModel.isHideTranslationOn(),
                            selectedNumber:     viewModel.selectedNumberOfCards(),
                            selectedTime:       selectedTime,
                            isFirstLaunch: false)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK: - Actions
extension DetailsView{
    //MARK: PRESENT ADD WORDS
    @objc func addNavButtonTap(sender: UIBarButtonItem){
        viewModel.userTappedAdd()
    }
    
    @objc func sigleModeWasEngaged(sender: UIButton) {
        viewModel.userTappedSingleAdd()
    }

    @objc func clockedSession(sender: UIBarButtonItem){
        presentTimedDetailsController()
    }
    
    @objc func startButtonTap(sender: UIButton){
        presentGameController()
    }

    @objc func orderSegwayToggle(sender: UISegmentedControl){
        viewModel.cardOrderDidChange(order: DictionariesSettings.CardOrder(rawValue: Int64(sender.selectedSegmentIndex)) ?? .normal)
    }
    
    @objc func doneButtonDidTap(sender: Any){
       _ = textInputView.resignFirstResponder()
    }

    @objc func saveButtonDidTap(sender: Any) {
        viewModel.extendDictionary()
    }

    @objc func hideTransaltionSwitchToggle(sender: UISwitch){
        viewModel.hideTranslationDidChange(on: sender.isOn)
    }
}


//MARK: - UPPicker delegate & dataSource
extension DetailsView: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.didSelectPickerRow(row: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.numberOfRowsInComponent()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel.titleForPickerAt(row: row)
     }
}

//MARK: - TextView Placeholder Delegate
extension DetailsView: PlaceholderTextViewDelegate{
    func textViewDidBeginEditing(sender: UITextView)  {
        self.isInModalMode = false
        self.viewEditState = .editingText
        self.recomputePrimaryAction()
        
        viewModel.userBeganEditing()
    }
    
    func textViewDidEndEditing(sender: UITextView)    {
        self.viewEditState = .idle
        self.recomputePrimaryAction()
        
        viewModel.userFinishedEditing()

    }
    func presentErrorAlert(alert: UIAlertController) {
        self.presentErrorAlert(alert: alert)
    }
    
    func textViewDidChange(sender: UITextView)        {
        self.recomputePrimaryAction()

        viewModel.userDidType(text: sender.text)
    }
    
    func configurePlaceholderText(sender: UITextView) -> String? {
        viewModel.configureTextPlaceholder()
    }
    
    func currentSeparatorSymbol() -> String? {
        viewModel.textSeparator()
    }
}

//MARK: - Presenter Delegate
extension DetailsView: GameViewPresenter {
    func presentGameControllerWithCustomParameter(selectedTime: Int) {
        self.presentGameController(selectedTime: selectedTime)
    }
}

extension DetailsView: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
