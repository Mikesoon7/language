//
//  SettingsVC.swift
//  Language
//
//  Created by Star Lord on 11/02/2023.
//

//TODO: Add limit for name
import UIKit
import CoreData
import Combine

class AddDictionaryView: UIViewController {
    //MARK: Properties
    private var viewModel: AddDictionaryViewModel?
    private var viewModelFactory: ViewModelFactory
    private var cancellabel = Set<AnyCancellable>()
    
    var isFirstLaunch = false
    
    private var tutorialVC: TutorialSecondPart!
    //MARK: Views
    private lazy var textInputView: TextInputView = TextInputView(delegate: self)
    
    private let nameView : UIView = {
        var view = UIView()
        view.setUpCustomView()
        return view
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .georgianBoldItalic.withSize(18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let nameInputField : UITextField = {
        let field = UITextField()
        field.textColor = .label
        field.textAlignment = .right
        field.font = .georgianItalic.withSize(15)
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
    private var textInputViewHeightAnchor: NSLayoutConstraint!
    private var textInputViewBottomAnchor: NSLayoutConstraint!
    
    private var subviewsVerticalInset: CGFloat = 13
    private var buttonHeight: CGFloat = 60
    
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
    override func viewDidAppear(_ animated: Bool) {
        if isFirstLaunch {
            animateTutorialView()
        }
    }
        
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            if traitCollection.userInterfaceStyle == .dark{
                nameView.layer.shadowColor = shadowColorForDarkIdiom
                saveButton.layer.shadowColor = shadowColorForDarkIdiom
            } else {
                nameView.layer.shadowColor = shadowColorForLightIdiom
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
                    self?.presentError(error)
                case .shouldHighlightError(let word):
                    self?.highlightErrorFor(word)
                case .shouldUpdatePlaceholder:
                    self?.textInputView.updatePlaceholder()
                case .shouldUpdateText:
                    self?.textInputView.updatePlaceholder()
                    self?.configureText()
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
            
        textInputViewHeightAnchor = textInputView.heightAnchor.constraint(equalTo: textInputView.widthAnchor, multiplier: 0.66)
        textInputViewBottomAnchor = textInputView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -(subviewsVerticalInset * 2 + buttonHeight))
        NSLayoutConstraint.activate([
            textInputView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            textInputView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textInputView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            textInputViewHeightAnchor
        ])
    }
    private func configureNameInputView(){
        view.addSubview(nameView)
        nameView.addSubviews(nameLabel, nameInputField)
        nameInputField.delegate = self
        
        NSLayoutConstraint.activate([
            nameView.topAnchor.constraint(equalTo: self.textInputView.bottomAnchor, constant: subviewsVerticalInset),
            nameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            nameView.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            nameLabel.leadingAnchor.constraint(equalTo: nameView.leadingAnchor, constant: 15),
            nameLabel.centerYAnchor.constraint(equalTo: nameView.centerYAnchor),
            
            nameInputField.trailingAnchor.constraint(equalTo: nameView.trailingAnchor, constant: -15),
            nameInputField.centerYAnchor.constraint(equalTo: nameView.centerYAnchor)
        ])
        //Action
        nameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nonAccurateNameFieldTap(sender:))))
    }

    private func configureSaveButton(){
        view.addSubview(saveButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -subviewsVerticalInset),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            saveButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
        //Action
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender:)), for: .touchUpInside)
        saveButton.addTargetTouchBegin()
        saveButton.addTargetOutsideTouchStop()
        saveButton.addTargetInsideTouchStop()
    }
    func animateTutorialView(){
        self.tutorialVC = TutorialSecondPart(delegate: self, textViewBottom: self.nameView.frame.maxY)
        self.tutorialVC.modalPresentationStyle = .overFullScreen
        self.present(self.tutorialVC, animated: false)

    }
    //MARK: System
    /// Congifure all text properties of the view.
    private func configureText(){
        nameLabel.text =  "dictionaryName".localized

        saveButton.setAttributedTitle(
            .attributedString(string: "system.save".localized,
                              with: .georgianBoldItalic, ofSize: 18), for: .normal)
        
        self.navigationItem.title = "addDict.title".localized
        nameInputField.placeholder = "fieldPlaceholder".localized
        doneButton.title = "system.done".localized
        textInputView.textView.isTextUpdateRequired = true
    }
    ///Returns textFiled value. If value equals nil, return nil and present an error.
    private func validateName() -> String? {
        guard let text = nameInputField.text,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let insertNameAllert = UIAlertController(
                title: "nameAlert".localized,
                message: "nameInfo".localized,
                preferredStyle: .actionSheet)
            let action = UIAlertAction(
                title: "system.agreeInformal".localized,
                style: .cancel)
            insertNameAllert.addAction(action)
            action.setValue(UIColor.label, forKey: "titleTextColor")
            self.present(insertNameAllert, animated: true)
            return nil
        }
        return text
    }
    ///Returns textView value. If value equals nil, return nil and present an error.
    private func validateText() -> String?{
        guard let text = textInputView.textView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let insertTextAllert = UIAlertController(
                title: "textAlert".localized,
                message: "textInfo".localized ,
                preferredStyle: .actionSheet)
            let action = UIAlertAction(
                title: "system.agreeInformal".localized,
                style: .cancel)
            insertTextAllert.addAction(action)
            action.setValue(UIColor.label, forKey: "titleTextColor")
            self.present(insertTextAllert, animated: true)
            return nil
        }
                
        return text
    }
    ///Update textView layout.
    private func updateTextViewConstraits(keyboardIsVisable: Bool){
        textInputViewHeightAnchor.isActive = !keyboardIsVisable
        textInputViewBottomAnchor.isActive = keyboardIsVisable
        view.layoutIfNeeded()
    }
    
    private func highlightErrorFor(_ word: String){
        guard let text = self.textInputView.textView.text, let range = text.range(of: word, options: .caseInsensitive, range: word.startIndex..<text.endIndex) else {
            return
        }
        
        let NSRAnge = NSRange(range, in: text)
        print(range)
        self.textInputView.highlightError(NSRAnge)
    }
}
//MARK: - Actions

extension AddDictionaryView: TutorialSecondPartDelegate{
    func activateKeyboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            self.textInputView.textView.becomeFirstResponder()
            
        })        
    }
}
extension AddDictionaryView {
    @objc func saveButtonDidTap(sender: Any){
        guard let name = validateName(), let text = validateText() else { return }
        
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
    }
    @objc func keyboardWillHide(sender: Notification){
        updateTextViewConstraits(keyboardIsVisable: false)
    }
    
}

//MARK: - Extending for PlaceholderTextView
extension AddDictionaryView: PlaceholderTextViewDelegate{
    ///Delegate method. Activating navigation bar bautton item.
    func textViewWillAppear() {
        guard navigationItem.rightBarButtonItem == doneButton else {
            navigationItem.setRightBarButton(doneButton, animated: true)
            return
        }
    }
    ///Delegate method. Retrieving and returns placeholder text
    func configurePlaceholderText() -> String? {
        viewModel?.configureTextPlaceholder()
    }
}

//MARK: - TextField delegate
extension AddDictionaryView: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Showing button for keyboard dismissing
        guard navigationItem.rightBarButtonItem == doneButton else {
            navigationItem.setRightBarButton(doneButton, animated: true)
            return
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }
}
