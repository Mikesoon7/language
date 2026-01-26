//
//  EditVC.swift
//  Language
//
//  Created by Star Lord on 13/06/2023.
//
//TODO: Polished 

import UIKit
import Combine

class EditView: UIViewController {
    
    //MARK: Properties.
    private var displayName: Bool = false
    
    private var viewModel: EditViewModel
    private var viewModelFactory: ViewModelFactory
    
    private var cancellables = Set<AnyCancellable>()
    private var alertCoordinator = AlertCoordinator()
    private var keyboardListener: KeyboardListener!
    
    //MARK: - MAIN VIEWS
    private lazy var collectionAdapter: CollectionViewAdapter = {
        let adapter = CollectionViewAdapter()
        adapter.eventHandler = self
        return adapter
    }()

    //Cell by Cell display.
    private lazy var singleCellInputView: SingleModeInputView = {
        let view = SingleModeInputView(frame: view.bounds, contentInsets: contentInset, adapter: collectionAdapter)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.textColor = .label
        
        field.delegate = self
        field.font = .selectedFont.withSize(.titleSize)
        field.adjustsFontSizeToFitWidth = true
        field.contentScaleFactor = 0.8
        
        field.translatesAutoresizingMaskIntoConstraints = false
        field.textAlignment = .center
        field.contentMode = .scaleAspectFill
        return field
    }()
    
    private var singleInputButtonsView = SingleInputActionButtonsView()
    
    //MARK: SEARCH view's
    private lazy var collectionSearchToolBar: CollectionSearchToolBar = {
        let view = CollectionSearchToolBar()
        view.coordinator = self
        view.alpha = 0
        return view
    }()
    
    //MARK: Buttons
    private lazy var doneButton = UIBarButtonItem(
        title: "system.done".localized,
        style: .done,
        target: self,
        action: #selector(doneButTap(sender:))
    )
    
    private lazy var searchButton = UIBarButtonItem(
        barButtonSystemItem: .search,
        target: self,
        action: #selector(searchButDidTap(sender: ))
    )
    
    
    //MARK: Layout Properties
    private let contentInset = UIEdgeInsets.init(top: .longOuterSpacer, left: .outerSpacer, bottom: .outerSpacer * 2 + .genericButtonHeight, right: .outerSpacer)
    
    //MARK: - Inherited methods
    required init(dictionary: DictionariesEntity, factory: ViewModelFactory, oneByOne: Bool){
        self.viewModelFactory = factory
        viewModel = factory.configureEditViewModel(dictionary: dictionary)
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
        configureCollectionView()
        configureSearchView()
        configureNavBar()
        configureActionButtons()
        
        viewModel.viewIsReadyForTheDataDisplay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        singleCellInputView.adjustLayoutForSizeClass()
    }
    
    
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            singleCellInputView.applyColourAdjustment(traitCollection: traitCollection)
            singleInputButtonsView.responseToTraitStyleChange(trait: traitCollection)
        }
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            singleCellInputView.adjustLayoutForSizeClass()
        }
    }
    deinit { NotificationCenter.default.removeObserver(self) }
    
    //MARK: Binding View and ViewModel
    private func bind(){
        viewModel.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {
                case .shouldPresentAlert(let alert):
                    self?.presentAlert(for: alert)
                case .shouldPresentError(let error):
                    self?.presentError(error, sourceView: self?.view)
                case .shouldUpdateLabels:
                    self?.configureLabels()
                    self?.collectionSearchToolBar.configureLabels()
                    self?.singleCellInputView.adjustForLangugageAndFontChange()
                case .shouldUpdateFont:
                    self?.updateFont()
                    self?.singleCellInputView.adjustForLangugageAndFontChange()
                case .shouldPop:
                    self?.navigationController?.popViewController(animated: true)
                case .shouldUpdateName(let name):
                    self?.textField.text = name
                }
            }
            .store(in: &cancellables)
        viewModel.stateOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {
                case .searchStateChanged(let state):
                    switch state {
                    case .idle:
                        self?.changeSearchState(active: false)
                    case .searching:
                        break
                    }
                case .interuptSearchSession:
                    self?.interuptSearch()
                    
                case .continueSearchSession:
                    self?.changeSearchState(active: true)
                    
                }
            }
        .store(in: &cancellables)

        viewModel.collectionOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .shouldUpdateResult(let data):
                    collectionAdapter.update(
                        data,
                        name: displayName ? viewModel.currentName() : nil)
                case .shouldPresentAddImageView(let data):
                    presentImageViewPicker(data: data)
                case .shouldInsert(let entry):
                    collectionAdapter.insertAndScrollTo(entry: entry)
                }
            }
            .store(in: &cancellables)
        

    }
    
    func bindViewHelpers() {
        self.keyboardListener = KeyboardListener(view: self.view)
        alertCoordinator.action
            .sink { [weak self] action in
                switch action {
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
            .store(in: &cancellables)
        keyboardListener.events
            .sink { [weak self] event in
                self?.handleKeyboard(event: event)            }
            .store(in: &cancellables)
    }
    
    
    
    //MARK: - Subviews SetUp
    private func configureController(){
        NotificationCenter.default.addObserver(
            self, selector: #selector(appDidEnterBackground(sender: )), name: UIScene.didEnterBackgroundNotification, object: nil
        )
    }
    
    private func configureNavBar(){
        let containerView = UIView()
        containerView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textField.topAnchor.constraint(equalTo: containerView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        
        navigationItem.titleView = containerView
        updatePrimaryActionsFor(state: .idle)
        
        navigationItem.backAction = UIAction(title: "", image: UIImage(systemName: "chevron.left"), identifier: nil, handler: { [weak self] _ in
            self?.viewModel.viewRequestToClose()
        })
        
        textField.text = viewModel.currentName()
        //
        doneButton = UIBarButtonItem(
            title: "system.done".localized, style: .done,
            target: self, action: #selector(doneButTap(sender:)))
        textField.addTarget(
            self, action: #selector(nameFieldDidChange),
            for: .editingDidEnd)
        
    }
    
    private func configureActionButtons() {
        view.addSubview(singleInputButtonsView)
        
        NSLayoutConstraint.activate([
            singleInputButtonsView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            singleInputButtonsView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            singleInputButtonsView.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight + .innerSpacer * 2 ),
            singleInputButtonsView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor)
        ])
        
        singleInputButtonsView.onAddTapped = { [weak self] in
            self?.viewModel.addEmptyCell()
        }

        singleInputButtonsView.onSaveTapped = { [weak self] in
            self?.doneButTap(sender: self as Any)
            self?.viewModel.extendDictionary()

        }
    }
    
    private func configureCollectionView(){
        view.addSubview(singleCellInputView)
        
        NSLayoutConstraint.activate([
            singleCellInputView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            singleCellInputView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            singleCellInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            singleCellInputView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
        
    func configureSearchView(){
        view.addSubviews(collectionSearchToolBar)
        
        NSLayoutConstraint.activate([
            collectionSearchToolBar.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor),
            collectionSearchToolBar.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            collectionSearchToolBar.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            collectionSearchToolBar.heightAnchor.constraint(
                equalToConstant: 50)
        ])
        collectionSearchToolBar.backgroundColor = .selectedColourPalette.primaryBackgroundColour
    }
    
    //MARK: Activate search fucntionality
    /// Changing searchView appearence.
    private func changeSearchState(active: Bool) {
        if active {
            self.searchButton.tintColor = .systemGray4
            self.collectionSearchToolBar.activateSearchView()
        } else {
            self.searchButton.tintColor = .label
        }
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.collectionSearchToolBar.alpha = active ? 1 : 0
        }
    }
    private func interuptSearch(){
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.collectionSearchToolBar.alpha = 0
        }
    }
    
    //MARK: System
    ///Assigning string values to labels.
    private func configureLabels(){
        doneButton.title = "system.done".localized
        
        collectionSearchToolBar.configureLabels()
        singleInputButtonsView.updateForLanguageChange()
    }
    private func updateFont(){
        textField.font = .selectedFont.withSize(.titleSize)
        singleInputButtonsView.updateForFontChange()
    }
    
    private func presentImageViewPicker(data: SingleModeCellData) {
        let vc = AddImageController(data: data, delegate: self)
        self.present(vc, animated: true)
    }
    
    private func presentAlert(for alert: AlertType) {
        let alert = self.alertCoordinator.makeAlert(alertType: alert)
        self.present(alert, animated: true)
    }
    
    private func handleKeyboard(event: KeyboardListener.Event){
        switch event.presence {
        case .hidden, .accessoryOnly:
            self.singleCellInputView.adjustLayoutForKeyboard(isVisible: false, duration: event.duration, intersectingHeight: event.intersection.height)
        case .full:
            self.singleCellInputView.adjustLayoutForKeyboard(isVisible: true, duration: event.duration, intersectingHeight: event.intersection.height)
        }
        self.view.layoutIfNeeded()
    }

    private func updatePrimaryActionsFor(state: EditViewModel.EditState){
        switch state {
        case .editingText:
            guard navigationItem.rightBarButtonItems == [doneButton] else {
                navigationItem.setRightBarButtonItems([doneButton], animated: true)
                return
            }
        case .idle:
            guard navigationItem.rightBarButtonItems == [searchButton] else {
                self.navigationItem.rightBarButtonItems = [searchButton]
                return
            }
        }
    }
}

//MARK: - Actions
extension EditView {
    ///Finishes current first responder session.
    @objc private func doneButTap(sender: Any){
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        } else {
            view.endEditing(true)
        }
        self.navigationItem.rightBarButtonItems = [searchButton]
        viewModel.finishEditing()
    }
    
    ///Creating custom toolBar woth SearchBar. Attaching as textViews inputAccessory, and making searchBar first respodnder
    @objc private func searchButDidTap(sender: UIBarButtonItem){
        changeSearchState(active: true)
    }
    
    @objc func appDidEnterBackground(sender: Notification){
        if collectionSearchToolBar.isFirstResponder() {
            collectionSearchToolBar.enterBackgroundState()
        }
    }
}

//MARK: - TextFieldDelegate
extension EditView: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        updatePrimaryActionsFor(state: .editingText)
        viewModel.enteredEditingMode()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        updatePrimaryActionsFor(state: .idle)
        viewModel.exitedEditingMode()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }
    
    @objc func nameFieldDidChange(sender: UITextField){
        viewModel.updateName(name: sender.text ?? "")
    }
    
}
//MARK: CollectionAdapter Handler Delegate
extension EditView: CollectionViewCallBack {
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
//MARK: - Collection Image Delegate
extension EditView: AddImageDelegate {
    func didSelectAnImage(imageDetails: ImageDetailsCheck, data: SingleModeCellData) {
        viewModel.didSelectAnImage(imageDetails: imageDetails, data: data)
    }
}

//MARK: - SearchViewDelegate.
extension EditView: CollectionSearchToolBarEventHandler {
    func searchQueryDidChange(_ text: String) {
        viewModel.search(query: text)
    }

    func searchDidBegin() {
        viewModel.setSearchActive(true, query: "")
    }

    func searchDidEnd(_ query: String) {
        viewModel.setSearchActive(false, query: query)
    }
    
    func searchDidCancel() {
        viewModel.cancelSearch()
    }
}

//MARK: Gesture delegate
extension EditView: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if viewModel.requiresUpdate  {
            viewModel.viewRequestToClose()
            return false
        }
        return true
    }
}
