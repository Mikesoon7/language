//
//  AddWordsVC.swift
//  Language
//
//  Created by Star Lord on 05/03/2023.
//

import UIKit

class AddWordsVC: UIViewController {

    var editableDict = DictionaryDetails()
    var index = Int()
    
    let textView : UITextView = {
        let textView = TextViewToAdd()
        textView.backgroundColor = .systemGray5
        textView.layer.cornerRadius = 9
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        textView.clipsToBounds = true
        
        textView.textContainerInset = .init(top: 5, left: 5, bottom: 0, right: 5)
        textView.allowsEditingTextAttributes = true
        
        textView.textColor = .lightGray
        textView.font = UIFont(name: "TimesNewRomanPSMT", size: 15) ?? UIFont()
        textView.text = "Word - Meaning"
        return textView
    }()
    let submitButton : UIButton = {
        let button = UIButton()
        button.setUpCommotBut(false)
        button.setAttributedTitle(NSAttributedString().fontWithString(string: "Save",
                                                                      bold: true, size: 18), for: .normal)
        return button
    }()
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBarCustomization()
        textViewCustomization()
        submitButtonCustomization()
        keybaordAppears()
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        strokeCustomization()
    }
//MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                self.bottomStroke.strokeColor = UIColor.white.cgColor
                self.topStroke.strokeColor = UIColor.white.cgColor
            } else {
                self.bottomStroke.strokeColor = UIColor.black.cgColor
                self.topStroke.strokeColor = UIColor.black.cgColor
            }
        }
    }
//MARK: - Stroke SetUp
    func strokeCustomization(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
//MARK: - KeyboardObserver
    func keybaordAppears(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
//MARK: - NavBar SetUp
    func navBarCustomization(){
        navigationItem.title = "Text Uploading"
        self.navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        self.navigationItem.backButtonTitle = "Details"
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }
//MARK: - TextView SetUp
    func textViewCustomization(){
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
    }
//MARK: - Submit Button SetUp
    func submitButtonCustomization(){
        view.addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            submitButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -11),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            submitButton.heightAnchor.constraint(equalToConstant: 55),
        ])
        submitButton.addTargetTouchBegin()
        submitButton.addTargetInsideTouchStop()
        submitButton.addTargetOutsideTouchStop()
        submitButton.addTarget(self, action: #selector(submitButTap(sender: )), for: .touchUpInside)
    }
//MARK: - Actions
    @objc func rightBarButTap(sender: Any){
        navigationItem.rightBarButtonItem = nil
        textView.resignFirstResponder()
    }
    @objc func submitButTap(sender: UIButton){
        let alert = UIAlertController(title: "Enter the text", message: "Please, enter more than 1 pair of words.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Understand", style: .cancel)
        alert.addAction(action)
        action.setValue(UIColor.label, forKey: "titleTextColor")
        
        guard textView.hasText && textView.textColor != .lightGray else {return self.present(alert, animated: true)}
        
        editableDict.dictionary!.append(contentsOf: DataForDictionaries.shared.divider(text: textView.text))
        self.navigationController?.popViewController(animated: true)
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
        textView.text = LanguageChangeManager.shared.localizedString(forKey: "viewPlaceholder")
        self.navigationItem.title = "addWordTitle".localized
        submitButton.setAttributedTitle(NSAttributedString().fontWithString(
            string: "save".localized,
            bold: true,
            size: 18), for: .normal)
    }
}

extension AddWordsVC : UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = nil
            textView.font = nil
            textView.typingAttributes = [NSAttributedString.Key.font : UIFont(name: "Times New Roman", size: 17) ?? UIFont(), NSAttributedString.Key.backgroundColor : UIColor.clear, NSAttributedString.Key.foregroundColor : UIColor.label]
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(rightBarButTap(sender:)))
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
