//
//  SettingsVC.swift
//  Language
//
//  Created by Star Lord on 11/02/2023.
//
//TODO: Polished

import UIKit
import CoreData
import Combine

class AddDictionaryView: UIViewController {
    
    enum EditState {
        case idle
        case editingText
    }

    //MARK: Properties
    private var viewModel: AddDictionaryViewModel
    private var viewModelFactory: ViewModelFactory
    private var cancellable = Set<AnyCancellable>()

//    private var isInRegularMode = true
    private var savedRightBarButtons: [UIBarButtonItem]? = []
    
    private var alertCoordinator = AlertCoordinator()
    private var keyboardListener: KeyboardListener!
    private var inputMode: DataInputMode = .regular
    
    private let displayName = true
    
    private lazy var collectionAdapter: CollectionViewAdapter = {
        let adapter = CollectionViewAdapter()
        adapter.eventHandler = self
        return adapter
    }()

    //MARK: Views
    private lazy var textInputView: TextInputView = TextInputView(delegate: self)
    
    private let nameView : UIView = {
        var view = UIView()
        view.setUpCustomView()
        return view
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.bodyTextSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let nameInputField : UITextField = {
        let field = UITextField()
        field.textColor = .label
        field.textAlignment = .right
        field.font = .selectedFont.withSize(.assosiatedTextSize)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private var saveButton : UIButton = {
        var button = UIButton()
        button.setUpCustomButton()
        return button
    }()
    
    private lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "system.done".localized,
            style: .done,
            target: self,
            action: #selector(doneButtonDidTap(sender:))
        )
        return button
    }()
    
    //MARK: Info views
    var infoPopOver: InfoPopoverViewController?
    
    lazy var informationButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .done,
            target: self,
            action: #selector(showPopover))
        return button
    }()
    
    var lineInfoShouldBeShown: Bool {
        get {
            UserDefaults.standard.value(forKey: "shouldShowLineInfo") as? Bool ?? true
        } set {
            UserDefaults.standard.setValue(false, forKey: "shouldShowLineInfo")
        }
    }
    var singleInfoShouldBeShown: Bool {
        get {
            UserDefaults.standard.value(forKey: "shouldShowSingleInfo") as? Bool ?? true
        } set {
            UserDefaults.standard.setValue(false, forKey: "shouldShowSingleInfo")

        }
    }


    //MARK: Single mode view's
    let contentInset = UIEdgeInsets.init(top: .longOuterSpacer, left: .outerSpacer, bottom: .outerSpacer * 2 + .genericButtonHeight, right: .outerSpacer)
    
    lazy var singleModeInputView: SingleModeInputView = {
        let view = SingleModeInputView(frame: view.bounds, contentInsets: contentInset, adapter: collectionAdapter)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var switchModeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "doc.richtext"),
            style: .done,
            target: self,
            action: #selector(sigleModeWasEngaged(sender: )))
        button.tag = 0
        return button
    }()
    
    private var singleModeButtons = SingleInputActionButtonsView()
    
    //MARK: - Constraints and related.
    private var textInputViewFixedHeightAnchor:  NSLayoutConstraint = .init()
    private var nameInoutViewToKeyboardAcnhor:   NSLayoutConstraint = .init()
    
    private var regularModeConstraints: [NSLayoutConstraint] = []
    private var singleModeConstraints:  [NSLayoutConstraint] = []
    private var commonConstraints:      [NSLayoutConstraint] = []
    
    
    //MARK: - Inherited
    required init(factory: ViewModelFactory){
        self.viewModelFactory = factory
        self.viewModel = viewModelFactory.configureAddDictionaryModel()
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
        configureTextInputView()
        configureNameInputView()
        configureSaveButton()
        configureText()
        configureCollectionView()
        configureActionButtons()
        
        NSLayoutConstraint.activate(commonConstraints/* + regularModeConstraints*/)
        viewModel.preselectInputMode(mode: .regular)
//        NSLayoutConstraint.activate(regularModeConstraints)
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        singleModeInputView.adjustLayoutForSizeClass()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }


    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            singleModeInputView.applyColourAdjustment(traitCollection: traitCollection)
            singleModeButtons.responseToTraitStyleChange(trait: traitCollection)
            if traitCollection.userInterfaceStyle == .dark{
                nameView.layer.shadowColor = shadowColorForDarkIdiom
                textInputView.layer.shadowColor = shadowColorForDarkIdiom
                saveButton.layer.shadowColor = shadowColorForDarkIdiom
            } else {
                nameView.layer.shadowColor = shadowColorForLightIdiom
                textInputView.layer.shadowColor = shadowColorForLightIdiom
                saveButton.layer.shadowColor = shadowColorForLightIdiom
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //Insure proper sizing and positioning of pop up view
        if infoPopOver != nil{
            coordinator.animate { _ in
                self.dismisPopUp()
            } completion: { _ in
                self.showPopover()
            }
        }
    }
    

    //MARK: Bind
    private func bind(){
        viewModel.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {
                case .shouldPop:
                    self?.navigationController?.popViewController(animated: true)
                case .shouldPresentError(let error):
                    self?.presentError(error, sourceView: self?.view)
                case .shouldHighlightError(let word):
                    self?.highlightErrorFor(word)
                case .shouldUpdatePlaceholder:
                    self?.textInputView.updatePlaceholder()
                case .shouldReflectLanugageChange:
                    self?.configureText()
                    self?.textInputView.updatePlaceholder()
                    self?.singleModeInputView.adjustForLangugageAndFontChange()
                case .shouldReflectFontChange:
                    self?.configureFont()
                    self?.textInputView.updatePlaceholder()
                    self?.singleModeInputView.adjustForLangugageAndFontChange()
                case .shouldPresentAlert(let alert):
                    self?.presentAlert(for: alert)
                case .shouldReflectInputModeChange(let mode):
                    self?.inputMode = mode
                    self?.updateInputViewsLayout(mode: mode)
                }
            }
            .store(in: &cancellable)

        viewModel.singleOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .shouldPresentAddImageView(let data):
                    presentImageViewPicker(data: data)
                case .shouldReloadData(let data):
                    collectionAdapter.update(
                        data,
                        name: displayName ? viewModel.currentName() : nil)
                case .shouldInsert(let data):
                    collectionAdapter.insertAndScrollTo(entry: data)
                }
            }
            .store(in: &cancellable)
        
    }
    
    func bindViewHelpers() {
        self.keyboardListener = KeyboardListener(view: self.view)
        
        alertCoordinator.action
            .sink { [weak self] action in
                switch action {
                case .save:
                    self?.viewModel.createDictionary()
                case .delete:
                    self?.viewModel.userPermitedToClose()
                case .edit:
                    fallthrough
                case .cancel:
                    break
                }
            }
            .store(in: &cancellable)
        
        keyboardListener.events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleKeyboard(event)
            }
            .store(in: &cancellable)
    }
        
    
    //MARK: Controller SetUp
    private func configureController(){    
        self.view.backgroundColor = .systemBackground
        
        if (lineInfoShouldBeShown && singleInfoShouldBeShown) == false{
            self.navigationItem.rightBarButtonItems = [ switchModeButton ]
        } else {
            self.navigationItem.rightBarButtonItems = [ switchModeButton,  informationButton ]
        }
        
        navigationItem.backAction = UIAction(title: "", image: UIImage(systemName: "chevron.left"), identifier: nil, handler: { [weak self] _ in
            self?.viewModel.viewRequestedToClose()
        })
    }

    private func configureCollectionView(){
        view.addSubviews(singleModeInputView)

        commonConstraints.append(contentsOf: [
            singleModeInputView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            singleModeInputView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])

        singleModeConstraints.append(contentsOf: [
            
            singleModeInputView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            singleModeInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        regularModeConstraints.append(contentsOf: [
            singleModeInputView.heightAnchor.constraint(
                equalTo: view.heightAnchor),
            singleModeInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
    }
    
    private func configureActionButtons() {
        view.addSubview(singleModeButtons)
        
        commonConstraints.append(contentsOf: [
            singleModeButtons.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            singleModeButtons.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            singleModeButtons.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight + .innerSpacer * 2 ),
        ])
        
        singleModeConstraints.append(contentsOf: [
            singleModeButtons.bottomAnchor.constraint(
                equalTo: view.bottomAnchor)
        ])
        
        regularModeConstraints.append(contentsOf: [
            singleModeButtons.topAnchor.constraint(
                equalTo: view.bottomAnchor)
        ])

        
        singleModeButtons.onAddTapped = { [weak self] in
            self?.viewModel.addEmptyCell()
        }
        singleModeButtons.onSaveTapped = { [weak self] in
            self?.view.becomeFirstResponder()
            self?.viewModel.createDictionary()
        }
    }

    
    private func configureTextInputView(){
        view.addSubview(textInputView)
        
        textInputViewFixedHeightAnchor = textInputView.heightAnchor.constraint(
            equalToConstant: .textViewGenericSize)

        commonConstraints.append(contentsOf: [
            textInputView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer),
            textInputView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.outerSpacer),
            textInputView.heightAnchor.constraint(
                lessThanOrEqualTo: textInputView.widthAnchor),
            textInputViewFixedHeightAnchor
        ])

        regularModeConstraints.append(contentsOf: [
            textInputView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .longOuterSpacer),
        ])
        singleModeConstraints.append(contentsOf: [
            textInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -.longOuterSpacer),
        ])
    }
    private func configureNameInputView(){
        view.addSubview(nameView)
        nameView.addSubviews(nameLabel, nameInputField)
        nameInputField.delegate = self
        
        nameInoutViewToKeyboardAcnhor = nameView.bottomAnchor.constraint(
            equalTo: view.keyboardLayoutGuide.topAnchor, constant: -.innerSpacer )

        commonConstraints.append(contentsOf: [
            nameView.topAnchor.constraint(
                equalTo: textInputView.bottomAnchor, constant: .innerSpacer),
            nameView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer),
            nameView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.outerSpacer),
            nameView.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            
            nameLabel.leadingAnchor.constraint(
                equalTo: nameView.leadingAnchor, constant: .innerSpacer),
            nameLabel.centerYAnchor.constraint(
                equalTo: nameView.centerYAnchor),
            
            
            nameInputField.trailingAnchor.constraint(
                equalTo: nameView.trailingAnchor, constant: -.innerSpacer),
            nameInputField.centerYAnchor.constraint(
                equalTo: nameView.centerYAnchor)
        ])

        //Action
        nameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nonAccurateNameFieldTap(sender:))))
        nameInputField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    private func configureSaveButton(){
        view.addSubview(saveButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        commonConstraints.append(contentsOf: [
            saveButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer),
            saveButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.outerSpacer),
            saveButton.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),

        ])

        regularModeConstraints.append(contentsOf:[
            saveButton.bottomAnchor.constraint(
                equalTo: UIDevice.isIPadDevice ? view.safeAreaLayoutGuide.bottomAnchor
                                               : view.keyboardLayoutGuide.topAnchor ,
                constant: -.innerSpacer),
            saveButton.topAnchor.constraint(
                greaterThanOrEqualTo: nameView.bottomAnchor, constant: .innerSpacer),

        ])
        
        singleModeConstraints.append(contentsOf: [
            saveButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: .innerSpacer),
        ])
        //Action
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender:)), for: .touchUpInside)
    }
    
    //MARK: System
    /// Congifure all text properties of the view.
    private func configureText(){
        nameLabel.text =  "dictionaryName".localized
        nameInputField.placeholder = "fieldPlaceholder".localized
        doneButton.title = "system.done".localized
        navigationItem.title = "addDict.title".localized

        saveButton.setAttributedTitle(
            .attributedString(string: "system.save".localized,
                              with: .selectedFont,
                              ofSize: .bodyTextSize), for: .normal)
        singleModeButtons.updateForLanguageChange()
        textInputView.updatePlaceholder()
    }
    
    private func configureFont(){
        nameLabel.font = .selectedFont.withSize(.bodyTextSize)
        nameInputField.font = .selectedFont.withSize(.assosiatedTextSize)
        saveButton.setAttributedTitle(
            .attributedString(string: "system.save".localized,
                              with: .selectedFont,
                              ofSize: .bodyTextSize), for: .normal)
        singleModeButtons.updateForFontChange()
    }
    
    private func highlightErrorFor(_ word: String){
        let text = self.textInputView.currentText()
        guard let range = text.range(of: word, options: .caseInsensitive, range: word.startIndex..<text.endIndex) else {
            return
        }
        
        let NSRAnge = NSRange(range, in: text)
        self.textInputView.highlightError(NSRAnge)
    }
    
    func presentImageViewPicker(data: SingleModeCellData) {
        let vc = AddImageController(data: data, delegate: self)
        self.present(vc, animated: true)

    }
    func presentAlert(for alert: AlertType) {
        let alert = self.alertCoordinator.makeAlert(alertType: alert)
        self.present(alert, animated: true)
    }
    
    func updatePrimaryActionsFor(state: EditState){
        switch state {
        case .editingText:
            guard navigationItem.rightBarButtonItem == doneButton else {
                savedRightBarButtons = navigationItem.rightBarButtonItems
                navigationItem.setRightBarButton(doneButton, animated: true)
                return
            }
        case .idle:
            guard navigationItem.rightBarButtonItems == savedRightBarButtons else {
                self.navigationItem.rightBarButtonItems = savedRightBarButtons
                return
            }
        }
    }
    
    //MARK: Layout
    private func handleKeyboard(_ event: KeyboardListener.Event) {
        var isKeyboardVisible = false
        UIView.animate(
            withDuration: event.duration,
            delay: 0,
            options: event.curve
        ) {
            switch event.presence {
            case .hidden, .accessoryOnly:
                isKeyboardVisible = false
            case .full:
                isKeyboardVisible = true
            }
            
            if self.inputMode == .regular {
                self.updateTextViewConstraits(keyboardIsVisable: isKeyboardVisible)
            } else {
                self.singleModeInputView.adjustLayoutForKeyboard(isVisible: isKeyboardVisible, duration: event.duration, intersectingHeight: event.intersection.height)
            }

            self.view.layoutIfNeeded()
        }
    }

    ///Update textView layout.
    private func updateTextViewConstraits(keyboardIsVisable: Bool){
        textInputViewFixedHeightAnchor.isActive = !keyboardIsVisable
            if UIDevice.isIPadDevice {
                self.nameInoutViewToKeyboardAcnhor.isActive = keyboardIsVisable
            }
        
    }
    
    private func updateInputViewsLayout(mode: DataInputMode){
        UIView.animate(withDuration: 0.4, animations: { [weak self] in
            guard let self = self else { return }
            switch mode {
            case .regular:
                NSLayoutConstraint.deactivate(singleModeConstraints)
                NSLayoutConstraint.activate(regularModeConstraints)
                
                textInputView.changeViewsVisibility(visible: true)
                saveButton.changeViewsVisibility(visible: true)
                nameView.changeViewsVisibility(visible: true)
                singleModeButtons.changeViewsVisibility(visible: false)
                singleModeInputView.changeViewsVisibility(visible: false)
                
            case .single:
                NSLayoutConstraint.deactivate(regularModeConstraints)
                NSLayoutConstraint.activate(singleModeConstraints)

                textInputView.changeViewsVisibility(visible: false)
                nameView.changeViewsVisibility(visible: false)
                saveButton.changeViewsVisibility(visible: false)
                singleModeButtons.changeViewsVisibility(visible: true)
                singleModeInputView.changeViewsVisibility(visible: true)
                
        
                view.layoutIfNeeded()
        }
        })
    }

}

//MARK: - Actions
extension AddDictionaryView{
    @objc func sigleModeWasEngaged(sender: UIBarButtonItem) {
        viewModel.prepareModeSwitch()
        singleModeInputView.adjustLayoutForSizeClass()

        self.navigationItem.rightBarButtonItems?.removeAll(where: {$0 == sender})
    }

    @objc func addButtonDidTap(sender: Any) {
        viewModel.addEmptyCell()
    }
        
    @objc func saveButtonDidTap(sender: Any){
        viewModel.createDictionary()
                        
        view.becomeFirstResponder()
    }
    //Done buttom tap
    @objc func doneButtonDidTap(sender: Any){
        
        if nameInputField.isFirstResponder{
            nameInputField.resignFirstResponder()
        } else if textInputView.isFirstResponder(){
            textInputView.resignFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
    @objc func nonAccurateNameFieldTap(sender: Any){
        nameInputField.becomeFirstResponder()
    }
}

//MARK: Info ViewDelegate & Actions
extension AddDictionaryView: InfoViewDelegate {
    
    func viewDidDismiss() {
        self.infoPopOver?.removeFromSuperview()
        self.infoPopOver = nil
    }

    @objc private func showPopover() {
        guard infoPopOver == nil else {
            self.dismisPopUp()
            return
        }
        
        let infoText = switchModeButton.tag == 0 ? "addDict.lineMode".localized : "addDict.singleMode".localized
        
        if switchModeButton.tag == 0 {
            lineInfoShouldBeShown = false
        } else {
            singleInfoShouldBeShown = false
        }
        
        let infoPopOver = InfoPopoverViewController(frame: view.frame, infoText: infoText, safeAreaInsets: view.safeAreaInsets, delegate: self)
        if let window = view.window {
            window.addSubview(infoPopOver)
            NSLayoutConstraint.activate([
                infoPopOver.topAnchor.constraint(equalTo: window.topAnchor),
                infoPopOver.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                infoPopOver.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                infoPopOver.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])
        }
        self.infoPopOver = infoPopOver
        infoPopOver.present()
    }
    
    @objc private func dismisPopUp(){
        self.infoPopOver?.dismiss {
            self.infoPopOver?.removeFromSuperview()
            self.infoPopOver = nil
        }
    }
}



//MARK: - Extending for PlaceholderTextView
extension AddDictionaryView: PlaceholderTextViewDelegate{
    ///Delegate method. Activating navigation bar bautton item.
    func textViewDidBeginEditing(sender: UITextView)  {
        updatePrimaryActionsFor(state: .editingText)
        viewModel.enteredEditingMode()
    }
    func textViewDidEndEditing(sender: UITextView)    {
        updatePrimaryActionsFor(state: .idle)
        viewModel.exitedEditingMode()
    }
    func textViewDidChange(sender: UITextView)        {
        viewModel.updateText(text: sender.text)
    }

    func presentErrorAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    ///Delegate method. Retrieving and returns placeholder text
    func configurePlaceholderText(sender: UITextView) -> String? {
        viewModel.configureTextPlaceholder()
    }
    func currentSeparatorSymbol() -> String? {
        viewModel.textSeparator()
    }
}

//MARK: - TextField delegate
extension AddDictionaryView: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        updatePrimaryActionsFor(state: .idle)
        viewModel.exitedEditingMode()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updatePrimaryActionsFor(state: .editingText)
        viewModel.enteredEditingMode()
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }
    @objc func textDidChange(_ textField: UITextField) {
        viewModel.updateName(name: textField.text ?? "")
    }
}

//MARK: CollectionAdapter Handler Delegate
extension AddDictionaryView: CollectionViewCallBack {
    func wordDidType(id: UUID, text: String) {
        viewModel.wordDidType(id: id, text: text)
    }
    
    func definitionDidType(id: UUID, text: String) {
        viewModel.definitionDidType(id: id, text: text)
    }
    
    func nameDidType(text: String) {
        viewModel.nameDidType(text: text)
    }
    
    func enteredEditingMode() {
        updatePrimaryActionsFor(state: .editingText)
        viewModel.enteredEditingMode()
    }
    
    func exitedEditingMode() {
        updatePrimaryActionsFor(state: .idle)
        viewModel.exitedEditingMode()
    }
    
    func requestedImagePicker(id: UUID) {
        viewModel.requestAddImage(id: id)
    }
        
    func requestedDeletion(id: UUID) {
        viewModel.requestedDeletion(id: id)
    }
}
//MARK: CollectionView ImageDelegate
extension AddDictionaryView: AddImageDelegate {
    func didSelectAnImage(imageDetails: ImageDetailsCheck, data: SingleModeCellData) {
        viewModel.didSelectAnImage(imageDetails: imageDetails, data: data)
    }
    
}

//MARK: Dismiss swipe override delegate.
extension AddDictionaryView: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if viewModel.requiresUpdate  {
            viewModel.viewRequestedToClose()
            return false
        }
        return true
    }
}
