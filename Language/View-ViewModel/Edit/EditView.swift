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
    private var viewModel: EditViewModel
    private var viewModelFactory: ViewModelFactory
    private var cancellables = Set<AnyCancellable>()
        
    private var isSearching = false
    private var textViewShouldBecomeActive = false
    private var searchViewShouldBecomeActive = false
    
    //MARK: - Views
    private lazy var customSearchToolBar: CustomSearchToolBar = {
        let view = CustomSearchToolBar(textView: textInputView.textView, layoutManager: textInputView.layoutManager)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
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
        
        field.textAlignment = .center
        return field
    }()
    
    //Buttons
    private var saveButton   = UIBarButtonItem()
    private var doneButton   = UIBarButtonItem()
    private var searchButton = UIBarButtonItem()
    
    //Dimensions
    private let textInsets = UIEdgeInsets(top: .outerSpacer, left: .outerSpacer, bottom: .nestedSpacer, right: .outerSpacer)
    
    //MARK: - Inherited methods
    required init(dictionary: DictionariesEntity, factory: ViewModelFactory){
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
        configureSearchView()
        configureNavBar()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground(sender: )),
            name: UIScene.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidActivate(sender: )),
            name: UIScene.didActivateNotification,
            object: nil
        )

    }
    deinit { NotificationCenter.default.removeObserver(self) }

    //MARK: Binding View and ViewModel
    private func bind(){
        viewModel.$data
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.configure(with: data.unsafelyUnwrapped)
            })
            .store(in: &cancellables)
        
        viewModel.output
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
                }
            }
            .store(in: &cancellables)
        
    }
    //MARK: - Initial controller SetUp
    private func configureController(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    ///Assigning recieved data to text view and field.
    private func configure(with data: ParsedDictionary){
        self.textField.text = data.name
        self.textInputView.textView.text = data.text
    }
    
    //MARK: Subviews SetUp
    private func configureTextView(){
        view.addSubview(textInputView)
        
        NSLayoutConstraint.activate([
            textInputView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            textInputView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textInputView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    func configureSearchView(){
        view.addSubview(customSearchToolBar)
        NSLayoutConstraint.activate([
            customSearchToolBar.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor),
            customSearchToolBar.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            customSearchToolBar.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            customSearchToolBar.heightAnchor.constraint(
                equalToConstant: 44)
            
        ])
    }
    
    private func configureNavBar(){
        textField.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let containerView = UIView()
        containerView.addSubview(textField)
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor),
            textField.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor),
            textField.topAnchor.constraint(
                equalTo: containerView.topAnchor),
            textField.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor),
        ])

        navigationItem.titleView = containerView
            
        self.saveButton = UIBarButtonItem(title: "system.save".localized, style: .done, target: self, action: #selector(saveButTap(sender:)))
        self.doneButton = UIBarButtonItem(title: "system.done".localized, style: .done, target: self, action: #selector(doneButTap(sender:)))
        self.searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButDidTap(sender: )))

        self.navigationItem.rightBarButtonItems = [ searchButton, saveButton ]
    }
    
    ///Assigning string values to labels.
    private func configureLabels(){
        saveButton.title = "system.save".localized
        doneButton.title = "system.done".localized

        textInputView.updatePlaceholder()
        customSearchToolBar.configureLabels()
    }
    private func updateFont(){
        textField.font = .selectedFont.withSize(.titleSize)
        textInputView.textView.font = .selectedFont.withSize(.subtitleSize)
    }
    
    //MARK: Activate search fucntionality
    /// Changing searchView appearence.
    private func changeSearchSessionState(activate: Bool){
        textInputView.textView.inputAccessoryView = activate ? nil : textInputView.customAccessoryView
        textInputView.textView.reloadInputViews()
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.customSearchToolBar.alpha = activate ? 1 : 0
        }
        
        if activate {
            self.navigationItem.rightBarButtonItems = [searchButton, doneButton]

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, qos: .background, execute: {
                self.customSearchToolBar.beginSearchSession()
            })
        } else {
            
            customSearchToolBar.endSearchSession()
            textInputView.textView.backgroundColor = .systemBackground
        }
        isSearching = activate
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
    ///Calling update methods and passing current text values.
    @objc private func saveButTap(sender: Any){
        guard let text = textInputView.validateText() else { return }
        let name = textField.text

        viewModel.updateDictionaryWith(name: name, text: text)
    }
    
    ///Finishes current first responder session.
    @objc private func doneButTap(sender: Any){
        guard !isSearching else {
            textInputView.textView.becomeFirstResponder()
            return
        }
        
        self.navigationItem.rightBarButtonItems = [searchButton, saveButton]
        if textInputView.textView.isFirstResponder {
            textInputView.textView.resignFirstResponder()
        } else if textField.isFirstResponder{
            textField.resignFirstResponder()
        }
    }
    ///Adjusting textView content offset to avoid overlaing by keyboard.
    @objc private func keyboardWillChangeFrame(_ sender: Notification) {
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
    ///Creating custom toolBar woth SearchBar. Attaching as textViews inputAccessory, and making searchBar first respodnder
    @objc private func searchButDidTap(sender: UIBarButtonItem){
        guard !isSearching else { return }
        changeSearchSessionState(activate: true)
    }
    
    @objc func appDidEnterBackground(sender: Notification){
        if textInputView.textView.isFirstResponder {
            textInputView.textView.resignFirstResponder()
            textViewShouldBecomeActive = true
        } else if customSearchToolBar.isFirstResponder() {
            customSearchToolBar.enterBackgroundState()
            searchViewShouldBecomeActive = true
        }
    }
    @objc func appDidActivate(sender: Notification){
        if searchViewShouldBecomeActive {
            customSearchToolBar.beginSearchSession()
            searchViewShouldBecomeActive = false
        } else if textViewShouldBecomeActive {
            textInputView.textView.becomeFirstResponder()
            textViewShouldBecomeActive = false
        }
    }

    
}

//MARK: - TextFieldDelegate
extension EditView: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if isSearching {
            changeSearchSessionState(activate: false)
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
        if isSearching {
            changeSearchSessionState(activate: false)
        } else if textInputView.layoutManager.errorRange != nil {
            textInputView.layoutManager.errorRange = nil
            textInputView.textView.setNeedsDisplay()
        }
        self.navigationItem.rightBarButtonItems = [searchButton, doneButton]
        
    }
    func presentErrorAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    func textViewDidEndEditing(sender: UITextView)    { }
    func textViewDidChange(sender: UITextView)        { }
    
    func textViewDidScroll() {
        if isSearching {
            textInputView.textView.setNeedsDisplay()
        }
    }
    
    func currentSeparatorSymbol() -> String? {
        viewModel.textSeparator()
    }
    func configurePlaceholderText(sender: UITextView) -> String? {
        viewModel.configureTextPlaceholder()
    }
}
