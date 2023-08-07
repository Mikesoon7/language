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

class AddDictionaryVC: UIViewController {
    
    private lazy var model: AddDictionaryViewModel = {
        return AddDictionaryViewModel()
    }()
    private var cancellabel = Set<AnyCancellable>()
    
    //MARK: - Views
    var textView: UITextView = {
        var textView = TextViewToCreate()
        textView.setUpBorderedView(false)
        textView.layer.masksToBounds = true
        
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.black.cgColor
        
        textView.textContainerInset = .init(top: 5, left: 5, bottom: 5, right: 5)
        textView.allowsEditingTextAttributes = true
        return textView
    }()
    
    var nameView : UIView = {
        var view = UIView()
        view.setUpBorderedView(false)
        return view
    }()
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "dictionaryName".localized
        label.attributedText = NSAttributedString().fontWithString(
            string: "dictionaryName".localized,
            bold: true,
            size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let nameInputField : UITextField = {
        let field = UITextField()
        field.textColor = .label
        field.textAlignment = .right
        field.font =  UIFont(name: "Georgia-Italic", size: 15) ?? UIFont()
        field.placeholder = "fieldPlaceholder".localized
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    var saveButton : UIButton = {
        var button = UIButton()
        button.setUpCommotBut(false)
        button.setAttributedTitle(NSAttributedString().fontWithString(
            string: "system.save".localized,
            bold: true,
            size: 18), for: .normal)
        return button
    }()

    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()

    
    //MARK: - Prepare Func
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureController()
        configureTextView()
        configureNavBar()
        configureNameInputView()
        configureSaveButton()
        configureText()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureStrokes()
    }
    
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            self.bottomStroke.strokeColor = UIColor.label.cgColor
            self.topStroke.strokeColor = UIColor.label.cgColor
            if traitCollection.userInterfaceStyle == .dark{
                nameView.layer.shadowColor = shadowColorForDarkIdiom
                saveButton.layer.shadowColor = shadowColorForDarkIdiom
            } else {
                nameView.layer.shadowColor = shadowColorForLightIdiom
                saveButton.layer.shadowColor = shadowColorForLightIdiom
            }
        }
    }
    //MARK: - Bind
    private func bind(){
        model.output
            .sink { output in
                switch output {
                case .shouldPop:
                    self.navigationController?.popViewController(animated: true)
                case .shouldPresentError(let error):
                    self.presentError(error)
                case .shouldUpdatePlaceholder:
                    self.configureTextViewPlaceholder(textOnly: false)
                case .shouldUpdateText:
                    self.configureText()
                }
            }
            .store(in: &cancellabel)
    }
    //MARK: - Controleler SetUp
    func configureController(){
        view.backgroundColor = .systemBackground
        
        //Keyboard appearence
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        //Language change
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name:
                .appLanguageDidChange, object: nil)
        //Separator chagne
        NotificationCenter.default.addObserver(self, selector: #selector(separatorDidChange(sender:)), name:
                .appSeparatorDidChange, object: nil)
    }

    private func configureText(){
        self.navigationItem.title = "addDictTitle".localized
        
        if textView.textColor == .lightGray {
            configureTextViewPlaceholder(textOnly: true)
        }
        nameLabel.text = LanguageChangeManager.shared.localizedString(forKey: "dictionaryName")
        self.navigationItem.title = "addDictTitle".localized
        nameInputField.placeholder = "fieldPlaceholder".localized
        saveButton.setAttributedTitle(NSAttributedString().fontWithString(
            string: "system.save".localized,
            bold: true,
            size: 18), for: .normal)
    }

    //MARK: - Stroke SetUp
    func configureStrokes(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
    //MARK: - TextView SetUp
    func configureTextView(){
        view.addSubview(textView)
        textView.delegate = self
        textView.inputDelegate = self

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            textView.heightAnchor.constraint(equalTo: textView.widthAnchor, multiplier: 0.57)
        ])
        configureTextViewPlaceholder(textOnly: false)
    }
    
    func configureTextViewPlaceholder(textOnly: Bool){
        textView.text = LanguageChangeManager.shared.localizedString(forKey: "viewPlaceholderWord") + " \(UserSettings.shared.settings.separators.selectedValue) " + LanguageChangeManager.shared.localizedString(forKey: "viewPlaceholderMeaning")
        guard !textOnly else { return }
        textView.textColor = .lightGray
        textView.font = UIFont(name: "TimesNewRomanPSMT", size: 15) ?? UIFont()
    }

    //MARK: - NameView SetUp
    func configureNameInputView(){
        view.addSubview(nameView)
        nameView.addSubviews(nameLabel, nameInputField)
        nameInputField.delegate = self

        NSLayoutConstraint.activate([
            nameView.topAnchor.constraint(equalTo: self.textView.bottomAnchor, constant: 14),
            nameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            nameView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.leadingAnchor.constraint(equalTo: nameView.leadingAnchor, constant: 15),
            nameLabel.centerYAnchor.constraint(equalTo: nameView.centerYAnchor),
            
            nameInputField.trailingAnchor.constraint(equalTo: nameView.trailingAnchor, constant: -15),
            nameInputField.centerYAnchor.constraint(equalTo: nameView.centerYAnchor)
        ])
        //Action
        nameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nonAccurateNameFieldTap(sender:))))

    }
    //MARK: - SaveButton SetUp
    func configureSaveButton(){
        view.addSubview(saveButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -11),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            saveButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        //Action
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender:)), for: .touchUpInside)
        saveButton.addTargetTouchBegin()
        saveButton.addTargetOutsideTouchStop()
        saveButton.addTargetInsideTouchStop()
    }
    
    //MARK: - NavBar SetUp
    func configureNavBar(){
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
    }
    
    //MARK: - Validate input
    func validateName() -> String? {
        let insertNameAllert = UIAlertController(
            title: "nameAlert".localized,
            message: "nameInfo".localized,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: "agreeInformal".localized,
            style: .cancel)
        insertNameAllert.addAction(action)
        action.setValue(UIColor.label, forKey: "titleTextColor")
        
        guard nameInputField.hasText else {
            self.present(insertNameAllert, animated: true)
            return nil
        }
        return nameInputField.text
    }
    func validateText() -> String?{
        let insertTextAllert = UIAlertController(
            title: "textAlert".localized,
            message: "textInfo".localized ,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: "agreeInformal".localized,
            style: .cancel)
        insertTextAllert.addAction(action)
        action.setValue(UIColor.label, forKey: "titleTextColor")

        guard let text = textView.text, text != "" && textView.textColor != .lightGray else {
            self.present(insertTextAllert, animated: true)
            return nil
        }
        return text
    }
//MARK: - Actions
    @objc func saveButtonDidTap(sender: Any){
        guard let name = validateName() else { return }
        guard let text = validateText() else { return }
        
        model.createDictionary(name: name, text: text)
                                            
        navigationItem.rightBarButtonItem = nil
        view.becomeFirstResponder()
    }
    //Done buttom tap.
    @objc func rightBarButDidTap(sender: Any){
        navigationItem.rightBarButtonItem = nil
        if textView.isFirstResponder{
            textView.resignFirstResponder()
        } else if nameInputField.isFirstResponder{
            nameInputField.resignFirstResponder()
        }
    }
    @objc func nonAccurateNameFieldTap(sender: Any){
        nameInputField.becomeFirstResponder()
    }
    @objc func keyboardWillShow(sender: Notification){
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        bottomStroke.add(animation, forKey: "strokeOpacity")
    }
    @objc func keyboardWillHide(sender: Notification){
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        bottomStroke.add(animation, forKey: "strokeOpacity")
    }
    @objc func languageDidChange(sender: Any){
        if textView.textColor == .lightGray {
            configureTextViewPlaceholder(textOnly: true)
        }
        nameLabel.text = LanguageChangeManager.shared.localizedString(forKey: "dictionaryName")
        self.navigationItem.title = "addDictTitle".localized
        nameInputField.placeholder = "fieldPlaceholder".localized
        saveButton.setAttributedTitle(NSAttributedString().fontWithString(
            string: "system.save".localized,
            bold: true,
            size: 18), for: .normal)
    }
    @objc func separatorDidChange(sender: Any){
        if textView.textColor == .lightGray {
            configureTextViewPlaceholder(textOnly: true)
        }
    }
}

class TextViewToCreate: UITextView {

    override func paste(_ sender: Any?) {
        if let pasteboardString = UIPasteboard.general.string {
            let currentAttributes = typingAttributes

            let attributedString = NSAttributedString(string: pasteboardString, attributes: currentAttributes)

            textStorage.insert(attributedString, at: selectedRange.location)

            selectedRange = NSRange(location: selectedRange.location + pasteboardString.count, length: 0)
        }
    }
}


//MARK: - UITextViewDelegate
extension AddDictionaryVC: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = nil
            textView.font = nil
            textView.typingAttributes = [NSAttributedString.Key.font : UIFont(name: "Times New Roman", size: 17) ?? UIFont(), NSAttributedString.Key.backgroundColor : UIColor.clear, NSAttributedString.Key.foregroundColor : UIColor.label]
        }
        //Showing button for keyboard dismissing
        if self.navigationController?.navigationItem.rightBarButtonItem == nil{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(rightBarButDidTap(sender:)))
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            configureTextViewPlaceholder(textOnly: false)
        }
    }
}
extension AddDictionaryVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Showing button for keyboard dismissing
        if self.navigationController?.navigationItem.rightBarButtonItem == nil{
            self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(rightBarButDidTap(sender:))), animated: true)
        }
    }
}
//MARK: - UITextInputTraits
extension AddDictionaryVC: UITextInputTraits{

}
//MARK: - UITextInputDelegate
extension AddDictionaryVC: UITextInputDelegate{
    func selectionWillChange(_ textInput: UITextInput?) {
        return
    }
    
    func selectionDidChange(_ textInput: UITextInput?) {
        return
    }
    
    func textWillChange(_ textInput: UITextInput?) {
        return
    }
    
    func textDidChange(_ textInput: UITextInput?) {
        return
    }
    
    
}

