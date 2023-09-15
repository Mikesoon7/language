//
//  EditVC.swift
//  Language
//
//  Created by Star Lord on 13/06/2023.
//

//TODO: Add convertion for inserted in textView or textField text
//TODO: Add limit for name.
//TODO: Add input pointer tracking

import UIKit
import Combine

class EditView: UIViewController {
    
    
    private var viewModel: EditViewModel?
    private var viewModelFactory: ViewModelFactory
    private var cancellables = Set<AnyCancellable>()
    
    //Text representaition of existing words for comparison
    var oldText: [String]!
    
    //MARK: - Views
    let textView: CustomTextView = {
        let view = CustomTextView()
        view.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
        view.allowsEditingTextAttributes = true
        view.textColor = .label
        view.backgroundColor = .systemBackground
        view.font = .timesNewRoman.withSize(17)
        
        view.alwaysBounceVertical = true
        view.textContainer.lineBreakMode = .byWordWrapping
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.textColor = .label
        
        field.font = .georgianBoldItalic.withSize(23)
        field.adjustsFontSizeToFitWidth = true
        field.textAlignment = .center
        return field
    }()
    
    
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
        configureNavBar()
        
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    private func bind(){
        viewModel?.$data
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.configure(with: data.unsafelyUnwrapped)
            })
            .store(in: &cancellables)
        
        viewModel?.output
            .sink { [weak self] output in
                switch output {
                case .shouldPresentData(let parsedDictionary):
                    self?.configure(with: parsedDictionary)
                case .shouldPresentError(let error):
                    self?.presentError(error)
                case .shouldPresentAlert(let alertType):
                    self?.configureAlertFor(alertType)
                case .shouldUpdateLabels:
                    self?.configureLabels()
                case .editSucceed:
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            .store(in: &cancellables)
        
    }
    //MARK: - Initial controller SetUp
    func configureController(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    //CustomStruct
    func configure(with data: ParsedDictionary){
        self.oldText = data.separatedText
        self.textField.text = data.name
        self.textView.text = data.text
    }
    
    //MARK: - TextView SetUp
    func configureTextView(){
        textView.delegate = self
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    //MARK: - TextField SetUp
    func configureTextField(){
        textField.delegate = self
        textField.frame = CGRect(x: 0, y: 0, width: view.bounds.width * 0.4,
                                 height: navigationController?.navigationBar.bounds.height ?? 30)
    }
    //MARK: - NavBar SetUp
    func configureNavBar(){
        self.navigationItem.titleView = textField
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "system.save".localized, style: .done, target: self, action: #selector(saveButTap(sender:)))
    }
    
    func configureAlertFor(_ errorType: EditViewModel.InvalidText){
        let isForEmtyText = errorType == .invalidText ? true : false
        let alert = UIAlertController
            .alertWithAction(
                alertTitle: (isForEmtyText ? "edit.emptyText.title" : "edit.emptyField.title").localized,
                alertMessage: (isForEmtyText ? "edit.emptyText.message" : "edit.emptyField.message").localized,
                alertStyle: .actionSheet,
                action1Title: "system.cancel".localized,
                action1Style: .cancel
            )
        if isForEmtyText {
            let deleteAction = UIAlertAction(title: "system.delete".localized, style: .destructive){ [weak self] _ in
                self?.viewModel?.deleteDictionary()
            }
            alert.addAction(deleteAction)
        }
        self.present(alert, animated: true)
    }
    func configureLabels(){
        if let saveButton =  navigationItem.rightBarButtonItem {
            saveButton.title = "system.save".localized
        }
    }
}

//MARK: - Actions
extension EditView {
    @objc func saveButTap(sender: Any){
        let text = textView.text
        viewModel?.parseTextToArray(name: textField.text ?? "", newText: text ?? "", oldCollection: oldText)
    }
    
    //Done button
    @objc func rightBarButDidTap(sender: Any){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "system.save".localized, style: .done, target: self, action: #selector(saveButTap(sender:)))

        if textView.isFirstResponder{
            textView.resignFirstResponder()
        } else if textField.isFirstResponder{
            textField.resignFirstResponder()
        }
    }
    @objc func keyboardWillChangeFrame(_ sender: Notification) {
        if let userInfo = sender.userInfo,
           let keyboardEndFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            
            let convertedEndFrame = view.convert(keyboardEndFrame, from: view.window)
            
            // Calculate the overlap between the keyboard and the text view
            let overlap = textView.frame.maxY - convertedEndFrame.minY
            
            // Adjust the content inset to keep the text visible
            if overlap > 0 {
                textView.contentInset.bottom = overlap
            } else {
                textView.contentInset.bottom = 0
            }
            
            textView.scrollIndicatorInsets = textView.contentInset
        }
    }

}

//MARK: - TextViewDelegate
extension EditView: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.textColor == .lightGray {
//            textView.text = nil
//            textView.textColor = nil
//            textView.font = nil
//            textView.typingAttributes = [NSAttributedString.Key.font : UIFont(name: "Times New Roman", size: 17) ?? UIFont(), NSAttributedString.Key.backgroundColor : UIColor.clear, NSAttributedString.Key.foregroundColor : UIColor.label]
//        }
        if self.navigationController?.navigationItem.rightBarButtonItem == nil{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "system.done".localized, style: .done, target: self, action: #selector(rightBarButDidTap(sender:)))
        }
    }
}

//MARK: - TextFieldDelegate
extension EditView: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.navigationController?.navigationItem.rightBarButtonItem == nil{
            self.navigationItem.setRightBarButton(UIBarButtonItem(title: "system.done".localized, style: .done, target: self, action: #selector(rightBarButDidTap(sender:))), animated: true)
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }

}
