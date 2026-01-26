//
//  AddWordsPartitialController.swift
//  Learny
//
//  Created by Star Lord on 13/11/2024.
//
//TODO: Polished

import UIKit
import Combine

class AddWordsPartitialController: UIViewController {
    
    enum EditState {
        case idle
        case editingText
    }
    
    enum AddWordsPrimaryActions {
        case doneButton
        case switchButton
        case empty
    }

    private var viewModel: AddWordsViewModel
    private var viewModelFactory: ViewModelFactory
    private var cancellable = Set<AnyCancellable>()
    
    private var displayWithText: String?
    private var inputMode: DataInputMode
    
    private var alertCoordinator = AlertCoordinator()
    private var keyboardListener: KeyboardListener!
    private var viewEditState: EditState = .idle
    
    private lazy var collectionAdapter: CollectionViewAdapter = {
        let adapter = CollectionViewAdapter()
        adapter.eventHandler = self
        return adapter
    }()
    //MARK: Views
    private var fakeNavView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private var addNewWordsLabel: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.subtitleSize)
        label.text = "addWord.title".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textInputView: TextInputView = TextInputView(delegate: self)
    
    //Navigation bar button to dismiss keyboard.
    private lazy var doneButton = UIButton.configureNavButtonWith(title: "system.done".localized)
    
    private let saveButton : UIButton = {
        let button = UIButton()
        button.setUpCustomButton()
        button.backgroundColor = .popoverSubviewsBackgroundColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    //MARK: Single Mode View's
    let contentInset = UIEdgeInsets.init(top: .innerSpacer, left: .outerSpacer, bottom: .genericButtonHeight * 2, right: .outerSpacer)
    
    lazy var singleModeInputView: SingleModeInputView = {
        let view = SingleModeInputView(frame: view.bounds,  contentInsets: contentInset, adapter: collectionAdapter)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var switchModeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "photo.badge.plus"), for: .normal)
        button.tintColor = .label
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(sigleModeWasEngaged(sender: )), for: .touchUpInside)
        button.tag = 0
        return button
    }()
    
    lazy var singleModeButtons = SingleInputActionButtonsView()
        
    //MARK: Constraints related
    private var idleConstraints:                [NSLayoutConstraint] = []
    private var editingConstraints:             [NSLayoutConstraint] = []
    
    private var regularModeConstraints:         [NSLayoutConstraint] = []
    private var singleModeConstraints:          [NSLayoutConstraint] = []
        
    private var doneButtonTrailingInactive :    NSLayoutConstraint = .init()
    private var doneButtonTrailingActive :      NSLayoutConstraint = .init()
    private var switchButtonTrailingInactive :  NSLayoutConstraint = .init()
    private var switchButtonTrailingActive :    NSLayoutConstraint = .init()
    
    //MARK: Inherited
    required init(factory: ViewModelFactory, dictionary: DictionariesEntity, text: String?, inputMode: DataInputMode){
        self.viewModelFactory = factory
        self.viewModel = factory.configureAddWordsViewModel(dictionary: dictionary)
        self.viewModel.updateText(text: text ?? "")
        self.displayWithText = text
        self.inputMode = inputMode
        
        super.init(nibName:  nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("Coder wasn't imported")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        bindViewHelpers()
        
        configureView()
        configureNavBarButton()
        configureSaveButton()
        configureTextInputView()
        configureText()
        configureSingleModeCollectionView()
        configureSingleModeActionButtons()
        
        viewModel.preselectInputMode(mode: inputMode)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        singleModeInputView.adjustLayoutForSizeClass()
    }

    
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            singleModeInputView.applyColourAdjustment(traitCollection: traitCollection)
            singleModeButtons.responseToTraitStyleChange(trait: traitCollection)
            
            if traitCollection.userInterfaceStyle == .dark {
                textInputView.layer.shadowColor = shadowColorForDarkIdiom
                saveButton.layer.shadowColor = shadowColorForDarkIdiom
            } else {
                textInputView.layer.shadowColor = shadowColorForLightIdiom
                saveButton.layer.shadowColor = shadowColorForLightIdiom
            }
        }
    }
    
    //MARK: Binding
    private func bind(){
        viewModel.output
            .sink { [weak self] output in
                guard let self = self else {return}
                switch output {
                case .shouldPresentError(let error):
                    self.presentError(error, sourceView: view)
                case .shouldPop:
                    self.dismiss(animated: true)
                case .shouldUpdatePlaceholder:
                    self.textInputView.updatePlaceholder()
                case .shouldHighlightError(let word):
                    self.highlightErrorFor(word)
                case .shouldPresentAlert(let alertType):
                    self.presentAlert(for: alertType)
                case .shouldReflectModeSwitch(let state):
                    self.inputMode = state
                    self.updateInputViewsLayout(mode: state)
                    updatePrimaryActionsLayout()
                }
            }
            .store(in: &cancellable)
        viewModel.singleOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else {return}
                switch output {
                case .shouldPresentAddImageView(let data):
                    presentImageViewPicker(data: data)

                case .shouldUpdateResult(let data):
                    collectionAdapter.update(
                        data,
                        name: nil)
                case .shouldInsert(let data):
                    collectionAdapter.insertAndScrollTo(entry: data)
                }
            }
            .store(in: &cancellable)
    }
    func bindViewHelpers() {
        self.keyboardListener = KeyboardListener(view: self.view)
        
        alertCoordinator.action
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {
                case .save:
                    self?.viewModel.extendDictionary()
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
    
    //MARK: View Setup
    private func configureView(){
        view.backgroundColor = .systemSecondary_WhiteColour
        
        if let sheetPresentationController = self.presentationController as? UISheetPresentationController {
            sheetPresentationController.delegate = self
        }
    }
    
    //MARK: Subviews SetUp
    private func configureTextInputView(){
        
        textInputView.setUpCustomView()
        textInputView.updateText(text: displayWithText ?? "")
        
        textInputView.backgroundColor = .popoverSubviewsBackgroundColour

        view.addSubviews(textInputView)
        
        let textViewHeightInactive = textInputView.heightAnchor.constraint(
            equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews) * 0.66)
        
        let textViewHeightActive = textInputView.bottomAnchor.constraint(
            equalTo: ( UIDevice.isIPadDevice
                       ? view.keyboardLayoutGuide.topAnchor
                       : saveButton.topAnchor ),
            constant: -.longInnerSpacer)

        idleConstraints.append(textViewHeightInactive)
        editingConstraints.append(textViewHeightActive)
        
        singleModeConstraints.append(contentsOf: [
            textInputView.bottomAnchor.constraint(
                equalTo: view.topAnchor, constant: -.outerSpacer),
            textInputView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .longInnerSpacer),
            textInputView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.longInnerSpacer),
            textInputView.heightAnchor.constraint(equalToConstant: .largeButtonHeight * 2 )
            
        ])
        
        regularModeConstraints.append(contentsOf: [
            textInputView.topAnchor.constraint(
                equalTo: addNewWordsLabel.bottomAnchor, constant: .outerSpacer),
            textInputView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .longInnerSpacer),
            textInputView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.longInnerSpacer),
            textViewHeightInactive
        ])
        
    }
    private func configureSingleModeCollectionView(){
        self.view.addSubviews(singleModeInputView)
        
        singleModeConstraints.append(contentsOf: [
            singleModeInputView.topAnchor.constraint(
                equalTo: fakeNavView.bottomAnchor),
            singleModeInputView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            singleModeInputView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor),
            singleModeInputView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
        ])
        
        regularModeConstraints.append(contentsOf: [
            singleModeInputView.heightAnchor.constraint(
                equalTo: view.heightAnchor),
            singleModeInputView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            singleModeInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            singleModeInputView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        view.bringSubviewToFront(fakeNavView)
    }
    
    private func configureSingleModeActionButtons(){
        view.addSubview(singleModeButtons)
        
        singleModeConstraints.append(contentsOf: [
            singleModeButtons.leadingAnchor.constraint(
                        equalTo: view.leadingAnchor),
            singleModeButtons.trailingAnchor.constraint(
                        equalTo: view.trailingAnchor),
            singleModeButtons.heightAnchor.constraint(
                        equalToConstant: .genericButtonHeight * 2 ),
            singleModeButtons.bottomAnchor.constraint(
                        equalTo: view.bottomAnchor),
                    ])

        regularModeConstraints.append(contentsOf: [

            singleModeButtons.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .longInnerSpacer),
            singleModeButtons.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.longInnerSpacer),
            singleModeButtons.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            singleModeButtons.topAnchor.constraint(equalTo: view.bottomAnchor, constant: .outerSpacer),
        ])
        
        singleModeButtons.onAddTapped = { [weak self] in
            self?.viewModel.addEmptyCell()
        }

        singleModeButtons.onSaveTapped = { [weak self] in
            self?.rightBarButDidTap(sender: self as Any)
            self?.viewModel.extendDictionary()

        }
    }

    private func configureNavBarButton(){
        view.addSubviews(fakeNavView )
        fakeNavView.addSubviews(addNewWordsLabel, doneButton, switchModeButton)
        
        doneButtonTrailingInactive = doneButton.leadingAnchor.constraint(
            equalTo: view.trailingAnchor, constant: .longInnerSpacer)
        doneButtonTrailingActive = doneButton.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,  constant: -.longInnerSpacer)
        
        switchButtonTrailingInactive = switchModeButton.leadingAnchor.constraint(
            equalTo: view.trailingAnchor, constant: .longInnerSpacer)
        switchButtonTrailingActive = switchModeButton.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,  constant: -.longInnerSpacer)
                
        NSLayoutConstraint.activate([
            fakeNavView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            fakeNavView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            fakeNavView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: .longOuterSpacer),
            fakeNavView.heightAnchor.constraint(equalToConstant: .genericButtonHeight),
            
            
            addNewWordsLabel.centerYAnchor.constraint(
                equalTo: fakeNavView.centerYAnchor),
            addNewWordsLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer ),
            addNewWordsLabel.heightAnchor.constraint(
                equalTo: fakeNavView.heightAnchor),
            
            doneButton.centerYAnchor.constraint(
                equalTo: addNewWordsLabel.centerYAnchor),
            doneButtonTrailingInactive,
            
            switchModeButton.centerYAnchor.constraint(
                equalTo: addNewWordsLabel.centerYAnchor),
            switchButtonTrailingActive
            
        ])
       
        doneButton.addTarget(self, action: #selector(rightBarButDidTap(sender: )), for: .touchUpInside)
    }
    
    
    
    private func configureSaveButton(){
        view.addSubviews(saveButton)
        
        let saveButtonBottomInactive = saveButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.longInnerSpacer)
        let saveButtonBottomActive = saveButton.bottomAnchor.constraint(
            equalTo: view.keyboardLayoutGuide.topAnchor, constant: -.longInnerSpacer)
        
        
        if !UIDevice.isIPadDevice {
            idleConstraints.append(contentsOf: [ saveButtonBottomInactive ])
            editingConstraints.append(contentsOf: [ saveButtonBottomActive ]  )
        }
        
        singleModeConstraints.append(contentsOf: [
            saveButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .longInnerSpacer),
            saveButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.longInnerSpacer),
            saveButton.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            saveButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: .outerSpacer),
        ])
        
        regularModeConstraints.append(contentsOf: [
            saveButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .longInnerSpacer),
            saveButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.longInnerSpacer),
            saveButton.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            saveButtonBottomInactive
        ])
        
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender: )), for: .touchUpInside)
    }
    
    
    //MARK: Layout and UI change
    private func updateInputViewsLayout(mode: DataInputMode){
        UIView.animate(withDuration: 0.4, delay: 0.0, animations: { [weak self] in
            guard let self = self else {return}
            switch mode {
            case .regular:
                NSLayoutConstraint.deactivate(singleModeConstraints)
                NSLayoutConstraint.activate(regularModeConstraints)
                
                textInputView.changeViewsVisibility(visible: true)
                saveButton.changeViewsVisibility(visible: true)
                singleModeButtons.changeViewsVisibility(visible: false)
                singleModeInputView.changeViewsVisibility(visible: false)
                
            case .single:
                NSLayoutConstraint.deactivate(regularModeConstraints)
                NSLayoutConstraint.activate(singleModeConstraints)
                
                textInputView.changeViewsVisibility(visible: false)
                saveButton.changeViewsVisibility(visible: false)
                singleModeButtons.changeViewsVisibility(visible: true)
                singleModeInputView.changeViewsVisibility(visible: true)
        }
        })
    }
    
    private func updateTextViewLayoutForState(state: KeyboardListener.KeyboardVisibility){
        let isVisible = state == .visible
            NSLayoutConstraint.deactivate(
                isVisible ? self.idleConstraints : self.editingConstraints )
            NSLayoutConstraint.activate(
                isVisible ? self.editingConstraints : self.idleConstraints)
    }
    
    private func updatePrimaryActionsLayout() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
                    
            switch (inputMode, viewEditState) {
                
            case (.regular, .idle):
                showSwitchMode()
                hideDone()
            case (.regular, .editingText):
                hideSwitchMode()
                showDone()
            case (.single, .idle):
                hideDone()
                hideSwitchMode()
            case (.single, .editingText):
                showDone()
            }
            self.view.layoutIfNeeded()
        })
    }

    private func showDone() {
            NSLayoutConstraint.deactivate([self.doneButtonTrailingInactive])
            NSLayoutConstraint.activate([self.doneButtonTrailingActive])
    }

    private func hideDone() {
            NSLayoutConstraint.deactivate([self.doneButtonTrailingActive])
            NSLayoutConstraint.activate([self.doneButtonTrailingInactive])
    }

    private func showSwitchMode() {
        NSLayoutConstraint.deactivate([switchButtonTrailingInactive])
        NSLayoutConstraint.activate([switchButtonTrailingActive])
    }

    private func hideSwitchMode() {
        NSLayoutConstraint.deactivate([switchButtonTrailingActive])
        NSLayoutConstraint.activate([switchButtonTrailingInactive])
    }
    
    //MARK: System
    /// Congifure all text properties of the view.
    private func configureText(){
        navigationItem.title = "addWord.title".localized
        saveButton.setAttributedTitle(
            .attributedString(string: "system.save".localized, with: .selectedFont, ofSize: .bodyTextSize), for: .normal)
        doneButton.setAttributedTitle(
            .attributedString(string: "system.done".localized, with: .systemBold, ofSize: .assosiatedTextSize), for: .normal)
        textInputView.updatePlaceholder()
    }
    
    ///Defines the range of passed word in textView and highlighting it.
    private func highlightErrorFor(_ word: String){
        let text = self.textInputView.currentText()
        guard let range = text.range(of: word, options: .caseInsensitive, range: word.startIndex..<text.endIndex) else {
            return
        }
        
        let NSRAnge = NSRange(range, in: text)
        self.textInputView.highlightError(NSRAnge)
        self.textInputView.resignFirstResponder()
        
    }
    func presentImageViewPicker(data: SingleModeCellData) {
        let vc = AddImageController(data: data, delegate: self)
        self.present(vc, animated: true)

    }
    func presentAlert(for alert: AlertType) {
        let alert = self.alertCoordinator.makeAlert(alertType: alert)
        self.present(alert, animated: true)
    }
    
    private func handleKeyboard(_ event: KeyboardListener.Event) {
        UIView.animate(
            withDuration: event.duration,
            delay: 0,
            options: event.curve
        
        ) {
            switch event.presence {
            case .hidden, .accessoryOnly:
                if self.inputMode == .regular {
                    self.updateTextViewLayoutForState(state: .hidden)
                } else {
                    self.singleModeInputView.adjustLayoutForKeyboard(isVisible: false, duration: event.duration, intersectingHeight: event.intersection.height)
                }
            case .full:
                if self.inputMode == .regular {
                    self.updateTextViewLayoutForState(state: .visible)
                } else {
                    self.singleModeInputView.adjustLayoutForKeyboard(isVisible: true, duration: event.duration, intersectingHeight: event.intersection.height)
                }
            }
            self.view.layoutIfNeeded()
        }
    }
}






//MARK: - Actions
extension AddWordsPartitialController {
    //Done button, which appears when user activate keyboard.
    @objc func rightBarButDidTap(sender: Any){
        if textInputView.isFirstResponder() {
            textInputView.resignFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
    //Addding input text to the dictionary.
    @objc func saveButtonDidTap(sender: UIButton){
        viewModel.extendDictionary()
    }
    
    @objc func sigleModeWasEngaged(sender: UIButton) {
        viewModel.prepareModeSwitch()
        singleModeInputView.adjustLayoutForSizeClass()
    }
    @objc func singleDidSave(sender: Any){
        viewModel.extendDictionary()
    }
    @objc func singleDidAdd(sender: Any){
        viewModel.addEmptyCell()
    }
}

extension AddWordsPartitialController: CollectionViewCallBack {
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
        viewModel.enteredEditingMode()
        viewEditState = .editingText
        self.updatePrimaryActionsLayout()
    }
    
    func exitedEditingMode() {
        viewModel.exitedEditingMode()
        viewEditState = .idle
        self.updatePrimaryActionsLayout()
    }
    
    func requestedImagePicker(id: UUID) {
        viewModel.requestAddImage(id: id)
    }
    
    func requestedDeletion(id: UUID) {
        viewModel.requestedDeletion(id: id)
    }

}
//MARK: SingleMode ImageDelegate
extension AddWordsPartitialController: AddImageDelegate {
    func didSelectAnImage(imageDetails: ImageDetailsCheck, data: SingleModeCellData) {
        viewModel.imageDidAdd(imageDetails: imageDetails, data: data)
    }
}
//MARK: - PlaceholderTextViewDelegate delegate
extension AddWordsPartitialController: PlaceholderTextViewDelegate{
    func textViewDidBeginEditing(sender: UITextView)  {
        viewModel.enteredEditingMode()
        viewEditState = .editingText
        self.updatePrimaryActionsLayout()
    }
    func textViewDidEndEditing(sender: UITextView)    {
        viewModel.exitedEditingMode()
        viewEditState = .idle
        self.updatePrimaryActionsLayout()
    }
    func textViewDidChange(sender: UITextView)        {
        viewModel.updateText(text: sender.text)
    }
    func presentErrorAlert(alert: UIAlertController) {
        self.presentErrorAlert(alert: alert)
    }
    func configurePlaceholderText(sender: UITextView) -> String? {
        viewModel.configureTextPlaceholder()
    }
    func currentSeparatorSymbol() -> String? {
        viewModel.textSeparator()
    }
}

//MARK: UISheetPresentationController delegate.
extension AddWordsPartitialController: UISheetPresentationControllerDelegate {
    ///Insures, that view won't be accedentaly dismissed without saving the data.
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        if viewModel.requiresUpdate  {
            viewModel.viewRequestToClose()
            return false
        }
        return true
    }
}



