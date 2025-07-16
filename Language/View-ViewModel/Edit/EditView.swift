//
//  EditVC.swift
//  Language
//
//  Created by Star Lord on 13/06/2023.
//
//  REFACTORING STATE:  CHECKED

import UIKit
import Combine

class EditView: UIViewController {
    
    //MARK: Properties.
    private var viewModel: EditViewModel?
    private var viewModelFactory: ViewModelFactory
    
    private var cancellables = Set<AnyCancellable>()
    let input =  PassthroughSubject<EditViewModel.Input, Never>()
    
//    private var textViewShouldBecomeActive = false
//    private var searchViewShouldBecomeActive = false
    
    var isInSearchMode = false
    var isInOneByOneMode = false
    
    
    //MARK: - MAIN VIEWS
    private lazy var singleCellInputView: SingleModeInputView = {
        let view = SingleModeInputView(frame: view.bounds, delegate: viewModel!, addDelegate: self, nameDelegate: nil, contentInsets: textInsets)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    lazy var textInputView: TextInputView = {
        let view = TextInputView(frame: .zero,
                                 delegate: self,
                                 textContainerInsets: textInsets )
        view.textView.allowsEditingTextAttributes = true
        view.textView.textColor = .label
        view.textView.backgroundColor = .systemBackground
        view.textView.font = .selectedFont.withSize(.subtitleSize)
        view.layer.cornerRadius = 0
        view.textView.alwaysBounceVertical = true
        view.textView.isEditable = false
        view.textView.inputAccessoryView = nil
        view.textView.textContainer.lineBreakMode = .byWordWrapping
        view.textView.translatesAutoresizingMaskIntoConstraints = false
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
        
        field.textAlignment = .center
        return field
    }()

    //MARK: SEARCH view's
    private lazy var customSearchToolBar: CustomSearchToolBar = {
        let view = CustomSearchToolBar(textView: textInputView.textView, layoutManager: textInputView.layoutManager)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    private lazy var collectionSearchToolBar: CollectionSearchToolBar = {
        let view = CollectionSearchToolBar()
        view.delegate = self
        view.alpha = 0
        return view
        
    }()
    
    
    //Buttons
//    private var saveButton   = UIBarButtonItem()
    private var doneButton   = UIBarButtonItem()

    private lazy var textSearchButton = UIBarButtonItem(
        barButtonSystemItem: .search,
        target: self,
        action: #selector(searchButDidTap(sender: ))
    )
//    private lazy var collectionSearchButtton = UIBarButtonItem(
//        barButtonSystemItem: .search,
//        target: self,
//        action: #selector(collectionSearchButtonDidTap(sender: ))
//    )

    
//    private lazy var switchModeButton: UIBarButtonItem = {
//        let button = UIBarButtonItem(
//            image: UIImage(systemName: isInOneByOneMode ? "list.clipboard" : "pencil.and.list.clipboard"),
//            style: .done,
//            target: self,
//            action: #selector(sigleModeWasEngaged(sender: )))
//        button.tag = 0
//        return button
//    }()
    
    
    //Dimensions
    private let textInsets = UIEdgeInsets(top: .outerSpacer, left: .outerSpacer, bottom: .outerSpacer + .customSearchAccessoryView , right: .outerSpacer)
    
    private var regularModeConstraints: [NSLayoutConstraint] = .init()
    private var oneByOneModeConstraints: [NSLayoutConstraint] = .init()
    
    //MARK: - Inherited methods
    required init(dictionary: DictionariesEntity, factory: ViewModelFactory, oneByOne: Bool){
        self.isInOneByOneMode = oneByOne
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
        configureController()
        configureTextView()
        configureEditView()
        configureSearchView()
        configureNavBar()
        
        isInOneByOneMode ? {
            NSLayoutConstraint.activate(oneByOneModeConstraints)
            singleCellInputView.adjustLayoutForSizeClass()
        }() : {
            NSLayoutConstraint.activate(regularModeConstraints)

        }()
//        NSLayoutConstraint.activate(regularModeConstraints)
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    //MARK: Binding View and ViewModel
    private func bind(){
        viewModel?.$data
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.configure(with: data.unsafelyUnwrapped)
            })
            .store(in: &cancellables)
        
        viewModel?.$collectionData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.singleCellInputView.collectionView.reloadData()
            })
            .store(in: &cancellables)
        
        let output = viewModel?.transform(input: input.eraseToAnyPublisher())
        output?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {
                case .shouldPresentData(let parsedDictionary):
                    self?.configure(with: parsedDictionary)
                case .shouldPresentError(let error):
                    self?.presentError(error, sourceView: self?.view)
                case .shouldPresentAlert(let alert):
                    self?.present(alert, animated: true)
                case .shouldUpdateLabels:
                    self?.configureLabels()
                    self?.customSearchToolBar.configureLabels()
                case .shouldUpdateFont:
                    self?.updateFont()
                case .editSucceed:
                    self?.navigationController?.popViewController(animated: true)
                case .shouldHighlightErrorLine(let word):
                    self?.higlightErrorFor(word)
                case .shouldPresentController(let vc):
                    self?.present(vc, animated: true)
                case .shouldUpdateResults:
                    self?.singleCellInputView.collectionView.reloadData()
                }
            }
            .store(in: &cancellables)
        
    }
    //MARK: - Initial controller SetUp
    private func configureController(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground(sender: )),
            name: UIScene.didEnterBackgroundNotification,
            object: nil
        )
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(appDidActivate(sender: )),
//            name: UIScene.didActivateNotification,
//            object: nil
//        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        
        //Keyboard appearence
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    ///Assigning recieved data to text view and field.
    private func configure(with data: ParsedDictionary){
        self.textField.text = data.name
        self.textInputView.textView.text = data.text
    }
    
    
    //MARK: Subviews SetUp
    private func configureTextView(){
        view.addSubview(textInputView)
        
        regularModeConstraints.append(contentsOf: [
            textInputView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            textInputView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textInputView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
        ])
        
        oneByOneModeConstraints.append(contentsOf: [
            textInputView.heightAnchor.constraint(
                equalTo: view.heightAnchor),
            textInputView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            textInputView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    private func configureEditView(){
        view.addSubview(singleCellInputView)
        
        oneByOneModeConstraints.append(contentsOf: [
            singleCellInputView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            singleCellInputView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            singleCellInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            singleCellInputView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
        ])
        
        regularModeConstraints.append(contentsOf: [
            singleCellInputView.heightAnchor.constraint(
                equalTo: view.heightAnchor),
            singleCellInputView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            singleCellInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            singleCellInputView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func switchMode(isOneByOne: Bool){
        if isOneByOne {
            NSLayoutConstraint.activate(oneByOneModeConstraints)
            NSLayoutConstraint.deactivate(regularModeConstraints)
        } else {
            NSLayoutConstraint.activate(regularModeConstraints)
            NSLayoutConstraint.deactivate(oneByOneModeConstraints)
        }
//        navigationItem.rightBarButtonItems = [textSearchButton, switchModeButton]
        navigationItem.rightBarButtonItems = [textSearchButton]

        
        isInOneByOneMode = isOneByOne
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    func configureSearchView(){
        view.addSubviews(customSearchToolBar, collectionSearchToolBar)
        
        NSLayoutConstraint.activate([
            customSearchToolBar.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor),
            customSearchToolBar.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            customSearchToolBar.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            customSearchToolBar.heightAnchor.constraint(
                equalToConstant: 44),
            
            collectionSearchToolBar.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor),
            collectionSearchToolBar.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            collectionSearchToolBar.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            collectionSearchToolBar.heightAnchor.constraint(
                equalToConstant: 50)
        ])
        
//        regularModeConstraints.append(contentsOf: [
//            collectionSearchToolBar.bottomAnchor.constraint(
//                equalTo: view.keyboardLayoutGuide.topAnchor),
//            collectionSearchToolBar.leadingAnchor.constraint(
//                equalTo: view.leadingAnchor),
//            collectionSearchToolBar.trailingAnchor.constraint(
//                equalTo: view.trailingAnchor),
//            collectionSearchToolBar.heightAnchor.constraint(
//                equalToConstant: 50)
//        ])
        
        
        collectionSearchToolBar.backgroundColor = .selectedColourPalette.primaryBackgroundColour
//        collectionSearchToolBar.configureStrokes()
    }
    
    private func configureNavBar(){
//        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        textField.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
//        let containerView = UIView()
//        containerView.addSubview(textField)
//        textField.delegate = self
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            textField.leadingAnchor.constraint(
//                equalTo: containerView.leadingAnchor),
//            textField.trailingAnchor.constraint(
//                equalTo: containerView.trailingAnchor),
//            textField.topAnchor.constraint(
//                equalTo: containerView.topAnchor),
//            textField.bottomAnchor.constraint(
//                equalTo: containerView.bottomAnchor),
//        ])
        
        navigationItem.titleView = textField
        
//        self.saveButton = UIBarButtonItem(title: "system.save".localized, style: .done, target: self, action: #selector(saveButTap(sender:)))
        self.doneButton = UIBarButtonItem(title: "system.done".localized, style: .done, target: self, action: #selector(doneButTap(sender:)))
        
        self.navigationItem.rightBarButtonItems = [ textSearchButton /*switchModeButton*/ ]
    }
    
    ///Assigning string values to labels.
    private func configureLabels(){
        doneButton.title = "system.done".localized
        
        textInputView.updatePlaceholder()
        customSearchToolBar.configureLabels()
        collectionSearchToolBar.configureLabels()
    }
    private func updateFont(){
        textField.font = .selectedFont.withSize(.titleSize)
        textInputView.textView.font = .selectedFont.withSize(.subtitleSize)
    }
    
    //MARK: Activate search fucntionality
    /// Changing searchView appearence.
    
    private func changeSearchState(activate: Bool){
        if isInOneByOneMode {
            changeCollectionViewSearch(activate: activate)
        } else {
            changeTextViewSearch(activate: activate)
        }
        isInSearchMode = activate
    }
    
    private func changeTextViewSearch(activate: Bool) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.customSearchToolBar.alpha = activate ? 1 : 0
        }
        
        if activate {
            self.navigationItem.rightBarButtonItems = [doneButton]
            self.customSearchToolBar.beginSearchSession()
        } else {
            customSearchToolBar.endSearchSession()
            customSearchToolBar.enterBackgroundState()
        }

    }
    private func changeCollectionViewSearch(activate: Bool) {
        if activate {
            self.navigationItem.rightBarButtonItems = [doneButton]
            self.collectionSearchToolBar.searchBar.becomeFirstResponder()
            
            self.collectionSearchToolBar.animateTransitionTo(isActivated: true, time: 0.3)
        } else {
            collectionSearchToolBar.cancelButtonDidTap(sender: UIButton())
            self.collectionSearchToolBar.animateTransitionTo(isActivated: false, time: 0.3)

//            textInputView.textView.backgroundColor = .systemBackground
        }
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.collectionSearchToolBar.alpha = activate ? 1 : 0
        }
    }
    
    
    //MARK: Error Responding
    /// Defines error range and tells layout manager to draw glyph for it
    private func higlightErrorFor(_ word: String){
        guard let text = self.textInputView.textView.text, let range = text.range(of: word, options: .caseInsensitive, range: text.startIndex..<text.endIndex) else   {
            return
        }
        
        let NSRAnge = NSRange(range, in: text)
        self.textInputView.textView.scrollRangeToVisible(NSRAnge)
        self.textInputView.layoutManager.errorRange = NSRAnge
        self.textInputView.textView.setNeedsDisplay()
    }
}

//MARK: - Actions
extension EditView {
    @objc func sigleModeWasEngaged(sender: UIBarButtonItem) {
        if sender.tag == 0 {
            self.switchMode(isOneByOne: true)
            UIView.animate(withDuration: 0.3) {
                self.textInputView.alpha = 0
                self.singleCellInputView.alpha = 1
                sender.image = UIImage(systemName: "list.clipboard")
                self.view.layoutIfNeeded()
                
            }
            self.singleCellInputView.collectionView.reloadData()
            self.singleCellInputView.adjustLayoutForSizeClass()
            
            isInOneByOneMode = true
            sender.tag = 1
        } else if sender.tag == 1 {
            switchMode(isOneByOne: false)
            UIView.animate(withDuration: 0.3) {
                self.textInputView.alpha = 1
                self.singleCellInputView.alpha = 0
                
                sender.image = UIImage(systemName: "pencil.and.list.clipboard")
                self.view.layoutIfNeeded()
            }
            
            isInOneByOneMode = false
            sender.tag = 0
            
        }
    }
    ///Calling update methods and passing current text values.
    @objc private func saveButTap(sender: Any){
        guard let text = textInputView.validateText() else { return }
        let name = textField.text
        
        viewModel?.updateDictionaryWith(name: name, text: text)
    }
    
    ///Finishes current first responder session.
    @objc private func doneButTap(sender: Any){
        if isInSearchMode {
            changeSearchState(activate: false)
        } else if textField.isFirstResponder {
            textField.resignFirstResponder()
        } else {
            view.endEditing(true)
        }
        
        self.navigationItem.rightBarButtonItems = [textSearchButton /*switchModeButton*/]
    }
    
    
    
    ///Adjusting textView content offset to avoid overlaing by keyboard.
    @objc private func keyboardWillChangeFrame(_ sender: Notification) {
        if !isInOneByOneMode {
            if let userInfo = sender.userInfo,
               let keyboardEndFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let convertedEndFrame = view.convert(keyboardEndFrame, from: view.window)
                let overlap = textInputView.frame.maxY - convertedEndFrame.minY
                
                if overlap > 0 {
                    textInputView.textView.contentInset.bottom = overlap
                } else {
                    textInputView.textView.contentInset.bottom = 0
                }
                
                textInputView.textView.scrollIndicatorInsets = textInputView.textView.contentInset
            }
        }
    }
    
    @objc func keyboardWillShow(sender: Notification){
        guard navigationItem.rightBarButtonItems == [doneButton] else {
            navigationItem.setRightBarButtonItems([doneButton], animated: true) 
            return
        }

    }
    @objc func keyboardWillHide(sender: Notification){
        guard navigationItem.rightBarButtonItems == [textSearchButton /*switchModeButton*/ ] else {
            self.navigationItem.rightBarButtonItems = [textSearchButton /*switchModeButton*/ ]
            return
        }
    }

    ///Creating custom toolBar woth SearchBar. Attaching as textViews inputAccessory, and making searchBar first respodnder
    @objc private func searchButDidTap(sender: UIBarButtonItem){
        changeSearchState(activate: true)
    }
    
    @objc func appDidEnterBackground(sender: Notification){
        if textInputView.textView.isFirstResponder {
            textInputView.textView.resignFirstResponder()
//            /*textViewShouldBecomeActive*/ = true
        } else if customSearchToolBar.isFirstResponder() {
            customSearchToolBar.enterBackgroundState()
//            searchViewShouldBecomeActive = true
        }
    }
//    @objc func appDidActivate(sender: Notification){
//        if searchViewShouldBecomeActive {
//            customSearchToolBar.beginSearchSession()
//            searchViewShouldBecomeActive = false
//        } else if textViewShouldBecomeActive {
//            textInputView.textView.becomeFirstResponder()
//            textViewShouldBecomeActive = false
//        }
//    }
    
    
}

//MARK: - TextFieldDelegate
extension EditView: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if isInSearchMode {
            changeSearchState(activate: false)
        }
        navigationItem.rightBarButtonItems = [doneButton]
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }
    
}

//MARK: - TextViewDelegate
extension EditView: PlaceholderTextViewDelegate {
    ///Reloading input accessory view, finishing search session or cleaning error glyph.
    func textViewDidBeginEditing(sender: UITextView)  {
        if isInSearchMode {
            changeSearchState(activate: false)
        } else if textInputView.layoutManager.errorRange != nil {
            textInputView.layoutManager.errorRange = nil
            textInputView.textView.setNeedsDisplay()
        }
        self.navigationItem.rightBarButtonItems = [textSearchButton, doneButton]
        
    }
    func presentErrorAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    func textViewDidEndEditing(sender: UITextView)    { }
    func textViewDidChange(sender: UITextView)        { }
    
    func textViewDidScroll() {
        if isInSearchMode {
            textInputView.textView.setNeedsDisplay()
        }
    }
    
    func currentSeparatorSymbol() -> String? {
        viewModel?.textSeparator() ?? " "
    }
    func configurePlaceholderText(sender: UITextView) -> String? {
        viewModel?.configureTextPlaceholder() ?? " "
    }
}
extension EditView: SingleModeAddDelegate {
    func didAddCell() {
        guard let model = viewModel else { return }
        model.addEmptyCell()
        singleCellInputView.collectionView.insertItems(at: [IndexPath(item: model.numberOfCells() - 1, section: 0)])
        
    }
    
    func didSave() {
        

        viewModel?.extendDictionaryWithSingleData(name: textField.text)
        //FINISh
        //        let text = viewModel?.uniteTheText()
        //        textInputView.assignText(text: text)
        //        guard let name = validateName(), let text = textInputView.validateText() else { return }
        //
        //        viewModel?.createDictionaryByCards(name: name)
    }
    
}

//MARK: - SearchResults updating.
extension EditView: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController?){
        let text = collectionSearchToolBar.searchBar.text ?? ""
        input.send(.reciveText(text))
    }
}

//MARK: - SearchBar delegate.
//Since i havent found a way to implement custom bottomSearchBar with controller, i should trigger custom search results updater ecery time the customSearchBar calls its delegate.
extension EditView: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: nil)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        updateSearchResults(for: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        updateSearchResults(for: nil)
        collectionSearchToolBar.searchBar.resignFirstResponder()
        
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.isFirstResponder {
            searchBar.becomeFirstResponder()
            searchBar.text = nil
        }
    }
}
