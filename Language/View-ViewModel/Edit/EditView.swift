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
    
    private var cancellables = Set<AnyCancellable>()
    private var viewModel: EditViewModel!
    
    //Text representaition of existing words for comparison
    var oldText: [String]!
    
    //MARK: - Views
    let textView: UITextView = {
        let view = UITextView()
        view.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
        view.allowsEditingTextAttributes = true
        view.textColor = .label
        view.backgroundColor = .systemBackground
        view.font = UIFont(name: "Times New Roman", size: 17) ?? UIFont()
        view.text = "some very important text"
        
        view.alwaysBounceVertical = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.textColor = .label
        
        field.defaultTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        field.textAlignment = .center
        return field
    }()
    
    private var topStroke = CAShapeLayer()
    private var bottomStroke = CAShapeLayer()
    
    
    //MARK: - Inherited methods
    required init(dictionary: DictionariesEntity){
        viewModel = EditViewModel(dictionary: dictionary)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureController()
        configureTextField()
        configureTextView()
        configureNavBar()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureStrokes()
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.bottomStroke.strokeColor = UIColor.label.cgColor
            self.topStroke.strokeColor = UIColor.label.cgColor
        }
    }
    private func bind(){
        viewModel.$data
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.configure(with: data.unsafelyUnwrapped)
            })
            .store(in: &cancellables)
        
        viewModel.output
            .sink { [weak self] output in
                switch output {
                case .data(let parsedDictionary):
                    self?.configure(with: parsedDictionary)
                case .dictionaryError(let error):
                    self?.presentError(error)
                case .wordsError(let error):
                    self?.presentError(error)
                case .emtyText:
                    self?.configureAlertMessage()
                case .editSucceed:
                    self?.navigationController?.popViewController(animated: true)
                }
            }
            .store(in: &cancellables)
        
    }
    //MARK: - Stroke SetUp
    func configureStrokes(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
    //MARK: - Initial controller SetUp
    func configureController(){
        view.backgroundColor = .systemBackground
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
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
//                                                                 target: self,
//                                                                 action: #selector(saveButTap(sender:)))
        navigationItem.backButtonDisplayMode = .minimal
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func configureText(){
        
    }
    func configureAlertMessage(){
        let alert = UIAlertController().alertWithAction(
            alertTitle: "edit.emptyField.title".localized,
            alertMessage: "edit.emptyField.message".localized,
            alertStyle: .actionSheet,
            action2Title: "system.cancel".localized, action2Style: .cancel)
        let deleteAction = UIAlertAction(title: "system.delete".localized, style: .destructive){ [weak self] _ in
            self?.viewModel?.deleteDictionary()
        }
        alert.addAction(deleteAction)
        self.present(self, animated: true)
    }
}

//MARK: - Actions
extension EditView {
    @objc func saveButTap(sender: Any){
        let text = textView.text
        viewModel.parseTextToArray(name: textField.text, newText: text ?? "", oldCollection: oldText)
    }
    
    //Done button
    @objc func rightBarButDidTap(sender: Any){
//        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
//                                                            target: self,
//                                                            action: #selector(saveButTap(sender:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "system.save".localized, style: .plain, target: self, action: #selector(saveButTap(sender:)))

        if textView.isFirstResponder{
            textView.resignFirstResponder()
        } else if textField.isFirstResponder{
            textField.resignFirstResponder()
        }
    }
}

//MARK: - TextViewDelegate
extension EditView: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = nil
            textView.font = nil
            textView.typingAttributes = [NSAttributedString.Key.font : UIFont(name: "Times New Roman", size: 17) ?? UIFont(), NSAttributedString.Key.backgroundColor : UIColor.clear, NSAttributedString.Key.foregroundColor : UIColor.label]
        }
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
}
