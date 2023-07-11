//
//  AddWordsVC.swift
//  Language
//
//  Created by Star Lord on 05/03/2023.
//

//TODO: Add localization for alerts.
import UIKit

class AddWordsVC: UIViewController {

    var editableDict : DictionariesEntity!
    var wordsArray = [WordsEntity]()
    
    var index = Int()
    
    let textView : UITextView = {
        let textView = TextViewToAdd()
        textView.setUpBorderedView(false)
        textView.layer.masksToBounds = true

        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.black.cgColor
        
        textView.textContainerInset = .init(top: 5, left: 5, bottom: 0, right: 5)
        textView.allowsEditingTextAttributes = true
        
        return textView
    }()
    let saveButton : UIButton = {
        let button = UIButton()
        button.setUpCommotBut(false)
        button.setAttributedTitle(NSAttributedString().fontWithString(
            string: "Save",
            bold: true,
            size: 18), for: .normal)
        return button
    }()
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
        configureNavBar()
        configureTextView()
        configureSaveButton()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureStrokes()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if textView.isFirstResponder{
            textView.resignFirstResponder()
        }
    }
//MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.bottomStroke.strokeColor = UIColor.label.cgColor
            self.topStroke.strokeColor = UIColor.label.cgColor
            if traitCollection.userInterfaceStyle == .dark {
                saveButton.layer.shadowColor = shadowColorForDarkIdiom
            } else {
                saveButton.layer.shadowColor = shadowColorForLightIdiom
            }
        }
    }
    //MARK: - Controller SetUp
    func configureController(){
        view.backgroundColor = .systemBackground
        
        //Observer on keyboard.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        //Language change
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
        //Separator change
        NotificationCenter.default.addObserver(self, selector: #selector(separatorDidChagne(sender:)), name: .appSeparatorDidChange, object: nil)
    }

    //MARK: - Stroke SetUp
    func configureStrokes(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
//MARK: - NavBar SetUp
    func configureNavBar(){
        navigationItem.title = "Text Uploading"
        self.navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        self.navigationItem.backButtonTitle = "Details"
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }
//MARK: - TextView SetUp
    func configureTextView(){
        view.addSubview(textView)
        textView.delegate = self
        textView.inputDelegate = self
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            textView.heightAnchor.constraint(equalTo: textView.widthAnchor, multiplier: 0.79)
        ])
        configureTextViewPlaceholder(textOnly: false)
    }
    func configureTextViewPlaceholder(textOnly: Bool){
        textView.text = LanguageChangeManager.shared.localizedString(forKey: "viewPlaceholderWord") + " \(UserSettings.shared.settings.separators.selectedValue) " + LanguageChangeManager.shared.localizedString(forKey: "viewPlaceholderMeaning")
        guard !textOnly else { return }
        textView.textColor = .lightGray
        textView.font = UIFont(name: "TimesNewRomanPSMT", size: 15) ?? UIFont()
    }
//MARK: - Save Button SetUp
    func configureSaveButton(){
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -11),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            saveButton.heightAnchor.constraint(equalToConstant: 55),
        ])
        saveButton.addTargetTouchBegin()
        saveButton.addTargetInsideTouchStop()
        saveButton.addTargetOutsideTouchStop()
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender: )), for: .touchUpInside)
    }
//MARK: - Actions
    @objc func rightBarButDidTap(sender: Any){
        navigationItem.rightBarButtonItem = nil
        textView.resignFirstResponder()
    }
    //Addding input text to the dictionary.
    @objc func saveButtonDidTap(sender: UIButton){
        let alert = UIAlertController(
            title: "textAlert".localized,
            message: "textInfo".localized ,
            preferredStyle: .alert)
        let action = UIAlertAction(title: "Understand", style: .cancel)
        
        alert.addAction(action)
        action.setValue(UIColor.label, forKey: "titleTextColor")
        
        guard textView.hasText && textView.textColor != .lightGray else {
            return self.present(alert, animated: true)
        }
        
        let numberOfCards = editableDict.words?.count
        let lines = textView.text.split(separator: "\n", omittingEmptySubsequences: true).map( {String($0)} )
        for (index, line) in lines.enumerated() {
            wordsArray.append(CoreDataHelper.shared.createWordFromLine(for: editableDict, text: line, index: numberOfCards ?? 0 + index)) 
        }
        CoreDataHelper.shared.addWordsTo(dictionary: editableDict, words: wordsArray)
        self.navigationController?.popViewController(animated: true)
    }
    //For changing save button position
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
    
        self.navigationItem.title = "addWordTitle".localized
        saveButton.setAttributedTitle(NSAttributedString().fontWithString(
            string: "save".localized,
            bold: true,
            size: 18), for: .normal)
    }
    @objc func separatorDidChagne(sender: Any){
        if textView.textColor == .lightGray {
            configureTextViewPlaceholder(textOnly: true)
        }
    }
}

extension AddWordsVC : UITextViewDelegate{
    //Vanishing placeholder imitation
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = nil
            textView.font = nil
            textView.typingAttributes = [NSAttributedString.Key.font : UIFont(name: "Times New Roman", size: 17) ?? UIFont(), NSAttributedString.Key.backgroundColor : UIColor.clear, NSAttributedString.Key.foregroundColor : UIColor.label]
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(rightBarButDidTap(sender:)))
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            configureTextViewPlaceholder(textOnly: false)
        }
    }
}
extension AddWordsVC : UITextInputDelegate{
    func selectionWillChange(_ textInput: UITextInput?) {
        
    }
    
    func selectionDidChange(_ textInput: UITextInput?) {
        
    }
    
    func textWillChange(_ textInput: UITextInput?) {
        
    }
    
    func textDidChange(_ textInput: UITextInput?) {
        
    }
    
    
}
class TextViewToAdd: UITextView {

    override func paste(_ sender: Any?) {
        if let pasteboardString = UIPasteboard.general.string {
            let currentAttributes = typingAttributes

            let attributedString = NSAttributedString(string: pasteboardString, attributes: currentAttributes)

            textStorage.insert(attributedString, at: selectedRange.location)

            selectedRange = NSRange(location: selectedRange.location + pasteboardString.count, length: 0)
        }
    }
}
