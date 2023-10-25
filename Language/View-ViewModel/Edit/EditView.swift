//
//  EditVC.swift
//  Language
//
//  Created by Star Lord on 13/06/2023.
//

import UIKit
import Combine

class EditView: UIViewController {

    //MARK: Properties.
    private var viewModel: EditViewModel
    private var viewModelFactory: ViewModelFactory
    private var cancellables = Set<AnyCancellable>()
        
    private lazy var layoutManager = HighlightLayoutManager(textInsets: textInsets)
    private let textContainer = NSTextContainer()
    private let textStorage = NSTextStorage()

    private var isSearching = false

    //MARK: - Views
    private lazy var customSearchToolBar: CustomSearchToolBar = {
        let view = CustomSearchToolBar(textView: textView, layoutManager: layoutManager)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()

    lazy var textView: CustomTextView = {
        let view = CustomTextView(frame: .zero, textContainer: textContainer)
        view.textContainerInset = textInsets
        view.allowsEditingTextAttributes = true
        view.textColor = .label
        view.backgroundColor = .systemBackground
        view.font = .timesNewRoman.withSize(20)
        view.alwaysBounceVertical = true
        view.textContainer.lineBreakMode = .byWordWrapping
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.textColor = .label
        
        field.font = .georgianBoldItalic.withSize(23)
        field.adjustsFontSizeToFitWidth = true
        
        field.textAlignment = .center
        return field
    }()
    
    //Buttons
    private var saveButton   = UIBarButtonItem()
    private var doneButton   = UIBarButtonItem()
    private var searchButton = UIBarButtonItem()
    
    //Dimensions
    private let textInsets = UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
    
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
        configureTextField()
        configureTextView()
        print("Search view initialization")
        configureSearchView()
        configureNavBar()
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
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
                    self?.presentError(error)
                case .shouldPresentAlert(let alert):
                    self?.present(alert, animated: true)
                case .shouldUpdateLabels:
                    self?.configureLabels()
                    self?.customSearchToolBar.configureLabels()
                case .editSucceed:
                    self?.navigationController?.popViewController(animated: true)
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
        self.textView.text = data.text
    }
    
    //MARK: Subviews SetUp
    private func configureTextView(){
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textView.delegate = self
                
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    func configureSearchView(){
        view.addSubview(customSearchToolBar)
        print("Layout in VC")
//        NSLayoutConstraint.activate([
            print("searchview 8")

        customSearchToolBar.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
//        customSearchToolBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true

            print("searchview 9")

            customSearchToolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            print("searchview 10")

            customSearchToolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            print("searchview 11")

            customSearchToolBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
//            print("searchview12")

//        ])
    }
    
    private func configureTextField(){
        textField.delegate = self
        
        NSLayoutConstraint.activate([
            textField.widthAnchor.constraint(equalToConstant: view.bounds.width * 0.35),
            textField.heightAnchor.constraint(equalToConstant: navigationController?.navigationBar.bounds.height ?? 30)
        ])
        
    }
    private func configureNavBar(){
        self.navigationItem.titleView = textField
        
        self.saveButton = UIBarButtonItem(title: "system.save".localized, style: .done, target: self, action: #selector(saveButTap(sender:)))
        self.doneButton = UIBarButtonItem(title: "system.done".localized, style: .done, target: self, action: #selector(doneButTap(sender:)))
        self.searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButDidTap(sender: )))

        self.navigationItem.rightBarButtonItems = [saveButton]
    }
    
    ///Assigning string values to labels.
    private func configureLabels(){
        saveButton.title = "system.save".localized
        doneButton.title = "system.done".localized

        textView.isTextUpdateRequired = true
        customSearchToolBar.configureLabels()
    }
    /// Changing searchView appearence.
    private func changeSearchSessionState(activate: Bool){
        textView.inputAccessoryView = activate ? nil : textView.customToolBar
        textView.reloadInputViews()
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.customSearchToolBar.alpha = activate ? 1 : 0
        }
        
        if activate {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, qos: .background, execute: {
                self.customSearchToolBar.beginSearchSession()
            })
        } else {
            customSearchToolBar.endSearchSession()
            textView.backgroundColor = .systemBackground
        }
        isSearching = activate
    }
}

//MARK: - Actions
extension EditView {
    ///Calling update methods and passing current text values.
    @objc private func saveButTap(sender: Any){
        let name = textField.text
        let text = textView.text
        viewModel.updateDictionaryWith(name: name, text: text)
    }
    
    ///Finishes current first responder session.
    @objc private func doneButTap(sender: Any){
        guard !isSearching else {
            textView.becomeFirstResponder()
            return
        }
        
        self.navigationItem.rightBarButtonItems = [saveButton]
        if textView.isFirstResponder{
            textView.resignFirstResponder()
        } else if textField.isFirstResponder{
            textField.resignFirstResponder()
        }
    }
    ///Adjusting textView content offset to avoid overlaing by keyboard.
    @objc private func keyboardWillChangeFrame(_ sender: Notification) {
        if let userInfo = sender.userInfo,
           let keyboardEndFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let convertedEndFrame = view.convert(keyboardEndFrame, from: view.window)
            var overlap = textView.frame.maxY - convertedEndFrame.minY
            
            if overlap > 0 {
                textView.contentInset.bottom = overlap
            } else {
                textView.contentInset.bottom = 0
            }
            
            textView.scrollIndicatorInsets = textView.contentInset
        }
    }
    ///Creating custom toolBar woth SearchBar. Attaching as textViews inputAccessory, and making searchBar first respodnder
    @objc private func searchButDidTap(sender: UIBarButtonItem){
        guard !isSearching else { return }
        changeSearchSessionState(activate: true)
    }
    
}

//MARK: - TextViewDelegate
extension EditView: UITextViewDelegate{
    ///Forcing layout manager to update existing glyphs.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isSearching {
            textView.setNeedsDisplay()
        }
    }
    
    ///Reloading input accessory view, finishing search session.
    func textViewDidBeginEditing(_ textView: UITextView) {
        if isSearching {
            changeSearchSessionState(activate: false)
        }
//        textView.contentInset.bottom -= textView.inputAccessoryView!.bounds.height
        self.navigationItem.rightBarButtonItems = [doneButton, searchButton]
        
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
