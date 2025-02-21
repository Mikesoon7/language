//
//  SettingsVC.swift
//  Language
//
//  Created by Star Lord on 11/02/2023.
//
//  REFACTORING STATE: CHECKED

//TODO: Add limit for name
import UIKit
import CoreData
import Combine

class AddDictionaryView: UIViewController {
    //MARK: Properties
    private var viewModel: AddDictionaryViewModel?
    private var viewModelFactory: ViewModelFactory
    private var cancellabel = Set<AnyCancellable>()
    
//    var isFirstLaunch = false
    
//    private var tutorialVC: TutorialSecondPart!
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
            action: #selector(rightBarButDidTap(sender:))
        )
        return button
    }()
    
    
    //MARK: - Constraints and related.
    private var textInputViewHeightAnchor: NSLayoutConstraint = .init()
    private var nameFieldViewBottomAnchor: NSLayoutConstraint = .init()
    
    required init(factory: ViewModelFactory){
        self.viewModelFactory = factory
        self.viewModel = viewModelFactory.configureAddDictionaryModel()
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported")
    }

    
    //MARK: - Inherited
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureController()
        configureTextInputView()
        configureNameInputView()
        configureSaveButton()
        configureText()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        if isFirstLaunch {
//            animateTutorialView()
//        }
//    }
        
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
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
    //MARK: Bind
    private func bind(){
        viewModel?.output
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
                case .shouldUpdateText:
                    self?.textInputView.updatePlaceholder()
                    self?.configureText()
                case .shouldUpdateFont:
                    self?.textInputView.updatePlaceholder()
                    self?.configureFont()
                }
            
            }
            .store(in: &cancellabel)
    }
    //MARK: Controller SetUp
    private func configureController(){        
        //Keyboard appearence
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureTextInputView(){
        view.addSubview(textInputView)
        
            
        textInputViewHeightAnchor = textInputView.heightAnchor.constraint(equalToConstant: .textViewGenericSize)

        NSLayoutConstraint.activate([
            textInputView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: .longOuterSpacer),
            textInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: .outerSpacer),
            textInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                    constant: -.outerSpacer),
            textInputView.heightAnchor.constraint(lessThanOrEqualTo: textInputView.widthAnchor),
            
            textInputViewHeightAnchor
        ])
    }
    private func configureNameInputView(){
        view.addSubview(nameView)
        nameView.addSubviews(nameLabel, nameInputField)
        nameInputField.delegate = self
        
        nameFieldViewBottomAnchor = nameView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -.innerSpacer )

        
        NSLayoutConstraint.activate([
            nameView.topAnchor.constraint(equalTo: self.textInputView.bottomAnchor, 
                                          constant: .innerSpacer),
            nameView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                              constant: .outerSpacer),
            nameView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                               constant: -.outerSpacer),
            nameView.heightAnchor.constraint(equalToConstant: .genericButtonHeight),
            
            
            
            
            nameLabel.leadingAnchor.constraint(equalTo: nameView.leadingAnchor,
                                               constant: .innerSpacer),
            nameLabel.centerYAnchor.constraint(equalTo: nameView.centerYAnchor),
            
            
            nameInputField.trailingAnchor.constraint(equalTo: nameView.trailingAnchor,
                                                     constant: -.innerSpacer),
            nameInputField.centerYAnchor.constraint(equalTo: nameView.centerYAnchor)
        ])
        //Action
        nameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nonAccurateNameFieldTap(sender:))))
    }

    private func configureSaveButton(){
        view.addSubview(saveButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: UIDevice.isIPadDevice
                                               ? view.safeAreaLayoutGuide.bottomAnchor
                                               : view.keyboardLayoutGuide.topAnchor ,
                                               constant: -.innerSpacer),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                constant: .outerSpacer),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                 constant: -.outerSpacer),
            saveButton.topAnchor.constraint(greaterThanOrEqualTo: nameView.bottomAnchor,
                                            constant: .innerSpacer),
            saveButton.heightAnchor.constraint(equalToConstant: .genericButtonHeight),

        ])
        //Action
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender:)), for: .touchUpInside)
    }
    //MARK: System
    /// Congifure all text properties of the view.
    private func configureText(){
        nameLabel.text =  "dictionaryName".localized

        saveButton.setAttributedTitle(
            .attributedString(string: "system.save".localized,
                              with: .selectedFont,
                              ofSize: .bodyTextSize), for: .normal)
        
        self.navigationItem.title = "addDict.title".localized
        nameInputField.placeholder = "fieldPlaceholder".localized
        doneButton.title = "system.done".localized
        textInputView.updatePlaceholder()
    }
    private func configureFont(){
        nameLabel.font = .selectedFont.withSize(.bodyTextSize)
        saveButton.setAttributedTitle(
            .attributedString(string: "system.save".localized,
                              with: .selectedFont,
                              ofSize: .bodyTextSize), for: .normal)
        nameInputField.font = .selectedFont.withSize(.assosiatedTextSize)
    }
    
    ///Returns textFiled value. If value equals nil, return nil and present an error.
    private func validateName() -> String? {
        guard let text = nameInputField.text,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let insertNameAllert = UIAlertController.alertWithAction(alertTitle: "nameAlert".localized, alertMessage: "nameInfo".localized, alertStyle: .actionSheet, action1Title: "system.agreeInformal".localized, action1Handler: nil, action1Style: .cancel, sourceView: self.nameView, sourceRect: nameInputField.frame )
            self.present(insertNameAllert, animated: true)
            return nil
        }
        return text
    }
    ///Update textView layout.
    private func updateTextViewConstraits(keyboardIsVisable: Bool){
        textInputViewHeightAnchor.isActive = !keyboardIsVisable
        if UIDevice.isIPadDevice {
            nameFieldViewBottomAnchor.isActive = keyboardIsVisable
        }
        view.layoutIfNeeded()
    }
    
    private func highlightErrorFor(_ word: String){
        guard let text = self.textInputView.textView.text, let range = text.range(of: word, options: .caseInsensitive, range: word.startIndex..<text.endIndex) else {
            return
        }
        
        let NSRAnge = NSRange(range, in: text)
        self.textInputView.highlightError(NSRAnge)
    }
}
//MARK: - Actions

//extension AddDictionaryView: TutorialSecondPartDelegate{
//    func activateKeyboard() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
//            self.textInputView.textView.becomeFirstResponder()
//        })        
//    }
//}
extension AddDictionaryView {
    @objc func saveButtonDidTap(sender: Any){
        guard let name = validateName(), let text = textInputView.validateText() else { return }
        
        viewModel?.createDictionary(name: name, text: text)
                        
        navigationItem.rightBarButtonItem = nil
        view.becomeFirstResponder()
    }
    //Done buttom tap
    @objc func rightBarButDidTap(sender: Any){
        navigationItem.rightBarButtonItem = nil
        
        if nameInputField.isFirstResponder{
            nameInputField.resignFirstResponder()
        } else {
            textInputView.textView.resignFirstResponder()
        }
    }
    @objc func nonAccurateNameFieldTap(sender: Any){
        nameInputField.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(sender: Notification){
        updateTextViewConstraits(keyboardIsVisable: true)
        guard navigationItem.rightBarButtonItem == doneButton else {
            navigationItem.setRightBarButton(doneButton, animated: true)
            return
        }
    }
    @objc func keyboardWillHide(sender: Notification){
        updateTextViewConstraits(keyboardIsVisable: false)
        guard navigationItem.rightBarButtonItem != doneButton else {
            navigationItem.setRightBarButton(nil, animated: true)
            return
        }
    }
}

//MARK: - Extending for PlaceholderTextView
extension AddDictionaryView: PlaceholderTextViewDelegate{
    ///Delegate method. Activating navigation bar bautton item.
    func textViewDidBeginEditing()  { }
    func textViewDidEndEditing()    { }
    func textViewDidChange()        { }

    func presentErrorAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    ///Delegate method. Retrieving and returns placeholder text
    func configurePlaceholderText() -> String? {
        viewModel?.configureTextPlaceholder()
    }
    func currentSeparatorSymbol() -> String? {
        viewModel?.textSeparator()
    }
}

//MARK: - TextField delegate
extension AddDictionaryView: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }
}
