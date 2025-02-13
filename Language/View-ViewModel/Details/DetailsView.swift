//
//  DetailsVC.swift
//  Language
//
//  Created by Star Lord on 21/02/2023.
//
//  REFACTORING STATE: CHECKED


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
    private var dictionary: DictionariesEntity
    private var viewModel: DetailsViewModel?
    private var addWordsViewModel: AddWordsViewModel?
    private var viewModelFactory: ViewModelFactory
    private var cancellable = Set<AnyCancellable>()
    
    
    //MARK: - Variables
    private var randomIsOn: Bool = false
    private var selectedCardsOrder: DictionariesSettings.CardOrder = .normal
    private var hideTransaltionIsOn: Bool = false
    
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
        view.textView.layer.borderColor = UIColor.clear.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowColor = UIColor.clear.cgColor
        view.layer.shadowOpacity = 0
        return view
    }()
    
    
    //SUBVIEWS
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
    
    
    private let orderOptionsLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .selectedFont.withSize(18)
        label.text = "details.cardsOrder".localized
        return label
    }()
    
    private let orderOptionSegmentedControl: UICustomSegmentedControl = {
        var control = UICustomSegmentedControl(cornerRadius: 9)
        control.insertSegment(withTitle: "details.cardsOrder.noraml".localized, at: 0, animated: false)
        control.insertSegment(withTitle: "details.cardsOrder.random".localized, at: 1, animated: false)
        control.insertSegment(withTitle: "details.cardsOrder.reverse".localized, at: 2, animated: false)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 1
        return control
    }()
    
    
    private let goalLabel : UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(18)
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
    private var regularWidthClassConstraints: [NSLayoutConstraint] = []
    private var compactWidthClassConstraints: [NSLayoutConstraint] = []
    
    private var regularWidthClassTextViewActiveConstraints: [NSLayoutConstraint] = []
    private var regularWidthClassTextViewConstraints:       [NSLayoutConstraint] = []
    
    
    //MARK: Inherited and initialization.
    required init(factory: ViewModelFactory, dictionary: DictionariesEntity){
        self.viewModelFactory = factory
        self.dictionary = dictionary
        self.viewModel = factory.configureDetailsViewModel(dictionary: dictionary)
        self.addWordsViewModel = factory.configureAddWordsViewModel(dictionary: dictionary)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureView()
        configureShadowViews()
        configureStartButton()
        
        applyConstraints(for: self.traitCollection)
        
        configureSettingsView()
        configureTextView()
        configureGoalView()
        
        configureLabels()
        retrieveDetailsData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.saveDetails(orderSelection: DictionariesSettings.CardOrder(
            rawValue: Int64(self.orderOptionSegmentedControl.selectedSegmentIndex)) ?? .normal,
                               isOneSideMode: isOneSideModeSwitch.isOn)
        textInputView.textView.resignFirstResponder()
    }
    
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            applyConstraints(for: traitCollection)
        }
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                view.subviews.forEach { view in
                    view.layer.shadowColor = shadowColorForDarkIdiom
                }
                textInputView.layer.shadowColor = shadowColorForDarkIdiom
            } else {
                view.subviews.forEach { view in
                    view.layer.shadowColor = shadowColorForLightIdiom
                }
                textInputView.layer.shadowColor = shadowColorForLightIdiom
            }
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
                    textInputView.updatePlaceholder()
                case .shouldUpdateFont:
                    configureFont()
                case .error(let error):
                    presentError(error, sourceView: view)
                case .shouldUpdatePicker:
                    goalPicker.reloadAllComponents()
                    goalPicker.selectRow(viewModel?.selectedRowForPicker() ?? 1, inComponent: 0, animated: true)
                }
            }
            .store(in: &cancellable)
        addWordsViewModel?.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {
                case .shouldPresentError(let error):
                    self?.presentError(error, sourceView: self?.view)
                case .shouldUpdatePlaceholder:
                    self?.textInputView.updatePlaceholder()
                case .shouldHighlightError(let word):
                    self?.highlightErrorFor(word)
                case .shouldPop:
                    self?.textInputView.clearTextView()
                }
            }
            .store(in: &cancellable)
    }
    
    //MARK: - Subviews SetUp
    private func configureView() {
        self.view.backgroundColor = .systemBackground
    }
    
    //MARK: Shadow view's setUp
    // Shadow views takes a role of view holder, which helps to optimize the code.
    private func configureShadowViews(){
        view.addSubviews(textViewShadowView, settingsShadowView, goalShadowView)
        
        regularWidthClassTextViewConstraints.append(contentsOf:[
            textViewShadowView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                    constant: .longOuterSpacer),
            textViewShadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                         constant: -.longInnerSpacer),
            textViewShadowView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                      multiplier: 0.5,
                                                      constant: -.longInnerSpacer - .longInnerSpacer / 2),
            textViewShadowView.heightAnchor.constraint(equalToConstant:
                                                        150 + .innerSpacer + .genericButtonHeight),
        ])
        
        
        regularWidthClassTextViewActiveConstraints.append(contentsOf: [
            textViewShadowView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            textViewShadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            textViewShadowView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            textViewShadowView.bottomAnchor.constraint(lessThanOrEqualTo: beginBut.topAnchor,
                                                       constant: -.longInnerSpacer),
            textViewShadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
        
        
        regularWidthClassConstraints.append(contentsOf: [
            settingsShadowView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                    constant: .longOuterSpacer),
            settingsShadowView.trailingAnchor.constraint(equalTo: textViewShadowView.leadingAnchor,
                                                         constant: -.innerSpacer),
            settingsShadowView.heightAnchor.constraint(equalToConstant: 150),
            
            settingsShadowView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                      multiplier: 0.5,
                                                      constant: -.longInnerSpacer - .longInnerSpacer / 2),
            
            goalShadowView.topAnchor.constraint(equalTo: settingsShadowView.bottomAnchor,
                                                constant: .longInnerSpacer),
            goalShadowView.trailingAnchor.constraint(equalTo: settingsShadowView.trailingAnchor),
            
            goalShadowView.leadingAnchor.constraint(equalTo: settingsShadowView.leadingAnchor),
            
            goalShadowView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        
        compactWidthClassConstraints.append(contentsOf:[
            settingsShadowView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                    constant: .longOuterSpacer),
            settingsShadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                         constant: -.longInnerSpacer),
            settingsShadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                        constant: .longInnerSpacer),
            settingsShadowView.heightAnchor.constraint(equalToConstant: 150),
            
            
            textViewShadowView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                    constant: .longOuterSpacer),
            textViewShadowView.leadingAnchor.constraint(equalTo: view.trailingAnchor,
                                                        constant: .longInnerSpacer),
            textViewShadowView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5,
                                                      constant: -.longInnerSpacer - .longInnerSpacer / 2),
            textViewShadowView.heightAnchor.constraint(equalToConstant: 150),
            
            
            goalShadowView.topAnchor.constraint(equalTo: settingsShadowView.bottomAnchor,
                                                constant: .longInnerSpacer),
            goalShadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                    constant: .longInnerSpacer),
            goalShadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                     constant: -.longInnerSpacer),
            goalShadowView.heightAnchor.constraint(equalToConstant: .genericButtonHeight)
        ])
    }
    //MARK: - View's SetUp
    private func configureTextView() {
        textViewShadowView.addSubview(textInputView)
        
        NSLayoutConstraint.activate([
            textInputView.topAnchor.constraint(equalTo: textViewShadowView.topAnchor) ,
            textInputView.leadingAnchor.constraint(equalTo: textViewShadowView.leadingAnchor),
            textInputView.bottomAnchor.constraint(equalTo: textViewShadowView.bottomAnchor),
            textInputView.trailingAnchor.constraint(equalTo: textViewShadowView.trailingAnchor),
        ])
    }
    
    private func configureSettingsView(){
        view.addSubviews(settingView)
        settingView.addSubviews(orderOptionsLabel, orderOptionSegmentedControl)
        settingView.addSubviews( isOneSideModeLabel, isOneSideModeSwitch)
        
        NSLayoutConstraint.activate([
            settingView.topAnchor.constraint(equalTo: settingsShadowView.topAnchor),
            
            settingView.leadingAnchor.constraint(equalTo: settingsShadowView.leadingAnchor),
            
            settingView.bottomAnchor.constraint(equalTo: settingsShadowView.bottomAnchor),
            
            settingView.trailingAnchor.constraint(equalTo: settingsShadowView.trailingAnchor),
            
            
            isOneSideModeLabel.centerYAnchor.constraint(equalTo: settingView.centerYAnchor,
                                                        constant: -45),
            isOneSideModeLabel.leadingAnchor.constraint(equalTo: settingView.leadingAnchor,
                                                        constant: 15),
            
            isOneSideModeSwitch.trailingAnchor.constraint(equalTo: settingView.trailingAnchor,
                                                          constant: -25),
            isOneSideModeSwitch.centerYAnchor.constraint(equalTo: isOneSideModeLabel.centerYAnchor),
            
            
            orderOptionsLabel.leadingAnchor.constraint(equalTo: settingView.leadingAnchor,
                                                       constant: 15),
            orderOptionsLabel.topAnchor.constraint(equalTo: settingView.centerYAnchor),
            
            
            orderOptionSegmentedControl.widthAnchor.constraint(equalTo: settingView.widthAnchor,
                                                               constant: -15),
            orderOptionSegmentedControl.bottomAnchor.constraint(equalTo: settingView.bottomAnchor,
                                                                constant: -10),
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
        
        NSLayoutConstraint.activate([
            goalView.topAnchor.constraint(equalTo: goalShadowView.topAnchor) ,
            goalView.leadingAnchor.constraint(equalTo: goalShadowView.leadingAnchor),
            goalView.bottomAnchor.constraint(equalTo: goalShadowView.bottomAnchor),
            goalView.trailingAnchor.constraint(equalTo: goalShadowView.trailingAnchor),
            
            goalLabel.leadingAnchor.constraint(equalTo: goalView.leadingAnchor, constant: 15),
            goalLabel.centerYAnchor.constraint(equalTo: goalView.centerYAnchor),
            
            goalPicker.trailingAnchor.constraint(equalTo: goalView.trailingAnchor),
            goalPicker.centerYAnchor.constraint(equalTo: goalView.centerYAnchor),
            goalPicker.widthAnchor.constraint(equalTo: goalView.widthAnchor, multiplier: 0.3)
        ])
    }
    
    //MARK:  StartBut SetUp
    private func configureStartButton(){
        view.addSubviews(timedButton, beginBut)
        
        regularWidthClassConstraints.append(contentsOf: [
            timedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -.longInnerSpacer),
            timedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -.longInnerSpacer),
            timedButton.widthAnchor.constraint(equalTo: view.widthAnchor,
                                               multiplier: 0.2),
            timedButton.heightAnchor.constraint(equalToConstant: .genericButtonHeight),
            
            
            beginBut.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                             constant: -.longInnerSpacer),
            beginBut.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                              constant: .longInnerSpacer),
            beginBut.trailingAnchor.constraint(equalTo: timedButton.leadingAnchor,
                                               constant: -.innerSpacer),
            beginBut.heightAnchor.constraint(equalToConstant: .genericButtonHeight)
        ])
        
        compactWidthClassConstraints.append(contentsOf: [
            timedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -.longInnerSpacer),
            timedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -.longInnerSpacer),
            timedButton.widthAnchor.constraint(equalToConstant: .genericButtonHeight),
            
            timedButton.heightAnchor.constraint(equalToConstant: .genericButtonHeight),
            
            
            beginBut.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                             constant: -.longInnerSpacer),
            beginBut.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                              constant: .longInnerSpacer),
            beginBut.trailingAnchor.constraint(equalTo: timedButton.leadingAnchor,
                                               constant: -.innerSpacer),
            beginBut.heightAnchor.constraint(equalToConstant: .genericButtonHeight)
        ])
    }
    
    
    
    //MARK: - Load details data.
    private func retrieveDetailsData(){
        self.selectedCardsOrder = viewModel?.selectedCardsOrder() ?? .normal
        self.orderOptionSegmentedControl.selectedSegmentIndex = Int(selectedCardsOrder.rawValue)
        self.isOneSideModeSwitch.isOn = viewModel?.isHideTranslationOn() ?? false
        
        goalPicker.selectRow(viewModel?.selectedRowForPicker() ?? 1, inComponent: 0, animated: true)
    }
    
    //MARK: Layout adjust methods.
    ///Update textView layout and handles save button display
    private func updateTextViewConstraits(keyboardIsVisable: Bool){
        let isRegularWidth = self.traitCollection.horizontalSizeClass == .regular
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) { [weak self] in
            guard let self = self else {return}
            if isRegularWidth {
                NSLayoutConstraint.deactivate(keyboardIsVisable
                                              ? regularWidthClassTextViewConstraints
                                              : regularWidthClassTextViewActiveConstraints)
                
                NSLayoutConstraint.activate(keyboardIsVisable
                                            ? regularWidthClassTextViewActiveConstraints
                                            : regularWidthClassTextViewConstraints)
            }
            textInputView.layer.cornerRadius = keyboardIsVisable ? 0 : 9
            textInputView.backgroundColor = keyboardIsVisable ? .systemBackground : .secondarySystemBackground
            textViewShadowView.layer.shadowOpacity = keyboardIsVisable ? 0 : 0.8
            
            view.layoutIfNeeded()
        }
    }
    
    ///Updating the constraints depending on the orientation and first responder status.
    private func applyConstraints(for traitCollection: UITraitCollection) {
        NSLayoutConstraint.deactivate(regularWidthClassConstraints)
        NSLayoutConstraint.deactivate(compactWidthClassConstraints)
        
        let isTextViewActive = textInputView.textView.isFirstResponder
        let text = textInputView.textView.text
        
        if isTextViewActive || text?.isEmpty != true {
            textInputView.clearTextView()
            changeSaveButtonState(active: false)
            let vc = AddWordsPartitialController(factory: self.viewModelFactory,
                                                 dictionary: viewModel?.dictionary ?? dictionary,
                                                 text: text
            )
            present(vc, animated: true)
        }
        
        if traitCollection.horizontalSizeClass == .regular {
            navigationItem.rightBarButtonItems?.removeAll(where: { button in
                button == self.addNewWordsButton
            })
            
            NSLayoutConstraint.activate(regularWidthClassTextViewConstraints)
            NSLayoutConstraint.activate(regularWidthClassConstraints)
        } else {
            if navigationItem.rightBarButtonItems == nil {
                navigationItem.setRightBarButton(self.addNewWordsButton, animated: true)
            } else {
                navigationItem.rightBarButtonItems?.append(self.addNewWordsButton)
            }
            
            NSLayoutConstraint.deactivate(isTextViewActive
                                          ? regularWidthClassTextViewActiveConstraints
                                          : regularWidthClassTextViewConstraints)
            NSLayoutConstraint.activate(compactWidthClassConstraints)
        }
        view.layoutIfNeeded()
    }
    
    //MARK: - System
    ///Adding save button to navigation bar.
    private func changeSaveButtonState(active: Bool){
        guard UIDevice.isIPadDevice else { return }
        if active {
            if let text = textInputView.textView.text, text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                navigationItem.rightBarButtonItems?.removeAll(where: { button in
                    button == self.saveButton
                })
                guard let bar = navigationItem.rightBarButtonItems, !bar.contains(where: {$0 == doneButton}) else {
                    navigationItem.setRightBarButton(self.doneButton, animated: true)
                    return
                }
                navigationItem.rightBarButtonItems?.append(self.doneButton)
            } else {
                navigationItem.rightBarButtonItems?.removeAll(where: { button in
                    button == self.doneButton
                })
                guard let bar = navigationItem.rightBarButtonItems, !bar.contains(where: {$0 == saveButton}) else {
                    navigationItem.setRightBarButton(self.saveButton, animated: true)
                    return
                }
                navigationItem.rightBarButtonItems?.append(self.saveButton)
            }
        } else {
            if textInputView.textView.text.isEmpty {
                navigationItem.rightBarButtonItems?.removeAll(where: { button in
                    button == self.saveButton || button == self.doneButton
                })
            }
        }
    }
    
    private func highlightErrorFor(_ word: String){
        guard let text = self.textInputView.textView.text, let range = text.range(of: word, options: .caseInsensitive, range: word.startIndex..<text.endIndex) else {
            return
        }
        
        let NSRAnge = NSRange(range, in: text)
        self.textInputView.highlightError(NSRAnge)
    }
    
//    private func validateText() -> String?{
//        guard let text = textInputView.textView.text,
//                !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            let emptyTextAlert = UIAlertController.alertWithAction(alertTitle: "textAlert".localized,
//                                                                   alertMessage: "textInfo".localized,
//                                                                   alertStyle: .actionSheet,
//                                                                   action1Title: "system.agreeInformal".localized,
//                                                                   action1Handler: {_ in self.textInputView.textView.becomeFirstResponder()},
//                                                                   action1Style: .cancel)
//            self.present(emptyTextAlert, animated: true)
//            return nil
//        }
//        return text
//    }
    
    //Assigning text on initializing and if language changes
    private func configureLabels(){
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
    
    private func configureFont(){
        isOneSideModeLabel.font = .selectedFont.withSize(18)
        orderOptionsLabel.font = .selectedFont.withSize(18)
        goalLabel.font = .selectedFont.withSize(18)
        textInputView.textView.font = .selectedFont.withSize(17)
        
        configureButtons()
    }
    
    //Easiest way to update button's title or font is to set new attributes.This function called in case of langauge or font chagne.
    private func configureButtons(){
        beginBut.setAttributedTitle(
            .attributedString(
                string: "details.start".localized,
                with: .selectedFont,
                ofSize: 20), for: .normal
        )
        saveButton.title = "system.save".localized
    }
}
//MARK: - Actions
extension DetailsView{
    //MARK: PRESENT ADD WORDS
    @objc func addNavButtonTap(sender: UIBarButtonItem){
        let vc = AddWordsPartitialController(factory:       self.viewModelFactory,
                                             dictionary:    viewModel?.dictionary ?? dictionary,
                                             text:          textInputView.textView.text
        )
        vc.modalPresentationStyle = .pageSheet
        vc.sheetPresentationController?.detents = [.large()]

        self.navigationController?.present(vc, animated: true)
    }

    //MARK: PRESENT TIME DETAILS
    @objc func clockedSession(sender: UIBarButtonItem){
        let vc = TimedDetailView(viewModelFactory:  self.viewModelFactory,
                                 viewModel:         self.viewModel,
                                 delegate:          self,
                                 timeIntervalUpTo:  60
        )
        vc.modalPresentationStyle = .formSheet
        if let sheet = vc.sheetPresentationController {
            if self.traitCollection.horizontalSizeClass == .regular {
                    sheet.detents = [.large()]
                } else {
                    sheet.detents = [.medium()]
                }
            }
        self.navigationController?.present(vc, animated: true)
    }
    
    //MARK: PRESENT GAME
    @objc func startButtonTap(sender: UIButton){
        guard let selectedNumber = viewModel?.selectedNumberOfCards() else {
            return
        }
        
        let vc = MainGameVC(viewModelFactory:   viewModelFactory,
                            dictionary:         viewModel?.dictionary ?? dictionary,
                            selectedOrder:      selectedCardsOrder,
                            hideTransaltion:    self.isOneSideModeSwitch.isOn,
                            selectedNumber:     selectedNumber)
        
        self.navigationController?.pushViewController(vc, animated: true)

    }

    @objc func orderSegwayToggle(sender: UISegmentedControl){
        selectedCardsOrder = DictionariesSettings.CardOrder(rawValue: Int64(sender.selectedSegmentIndex)) ?? .normal
    }
    
    @objc func doneButtonDidTap(sender: Any){
        textInputView.textView.resignFirstResponder()
    }

    @objc func saveButtonDidTap(sender: Any){
        guard let text = textInputView.validateText() else { return }
        addWordsViewModel?.getNewWordsFrom(text)
    }

    @objc func hideTransaltionSwitchToggle(sender: UISwitch){
        hideTransaltionIsOn = sender.isOn
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

//MARK: - TextView Placeholder Delegate
extension DetailsView: PlaceholderTextViewDelegate{
    func textViewDidBeginEditing()  {     
        updateTextViewConstraits(keyboardIsVisable: true)
        changeSaveButtonState(active: true)
    }
    
    func textViewDidEndEditing()    {
        updateTextViewConstraits(keyboardIsVisable: false)
        changeSaveButtonState(active: false)
    }
    func presentErrorAlert(alert: UIAlertController) {
        self.presentErrorAlert(alert: alert)
    }
    
    func textViewDidChange()        {
        changeSaveButtonState(active: true)
    }
    
    func configurePlaceholderText() -> String? {
        addWordsViewModel?.configureTextPlaceholder()
    }
    
    func currentSeparatorSymbol() -> String? {
        addWordsViewModel?.textSeparator()
    }
}

//MARK: - Presenter Delegate
extension DetailsView: Presenter {
    func startTheGame(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
