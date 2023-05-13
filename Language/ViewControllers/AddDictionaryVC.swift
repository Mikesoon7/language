//
//  SettingsVC.swift
//  Language
//
//  Created by Star Lord on 11/02/2023.
//

import UIKit
import CoreData

class AddDictionaryVC: UIViewController {
    
    var textView: UITextView = {
        var textView = TextViewToCreate()
        textView.setUpBorderedView(false)
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.black.cgColor
        
        textView.textContainerInset = .init(top: 5, left: 5, bottom: 5, right: 5)
        textView.allowsEditingTextAttributes = true
          
        textView.font = UIFont(name: "Times New Roman", size: 17) ?? UIFont()
        textView.text = "viewPlaceholder".localized
        textView.textColor = .lightGray
        textView.layer.shadowColor = UIColor.clear.cgColor
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
    var submitButton : UIButton = {
        var button = UIButton()
        button.setUpCommotBut(false)
        button.setAttributedTitle(NSAttributedString().fontWithString(
            string: "save".localized,
            bold: true,
            size: 18), for: .normal)
        return button
    }()

    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    

    //MARK: - Prepare Func
    override func viewDidLoad() {
        super.viewDidLoad()
        controllerCustomization()
        textViewCustomization()
        navBarCustomization()
        nameViewCustomization()
        submitButtonCustomization()
        keybaordAppears()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.view.becomeFirstResponder()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        strokeCustomization()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if textView.isFirstResponder{
            textView.resignFirstResponder()
        }
        if let navController = self.navigationController{
            let menu = navController.viewControllers.first(where: { $0 is MenuVC}) as? MenuVC
            menu?.fetchDictionaries()
            menu?.tableView.reloadData()
        }
    }
    
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            self.bottomStroke.strokeColor = UIColor.label.cgColor
            self.topStroke.strokeColor = UIColor.label.cgColor
            if traitCollection.userInterfaceStyle == .dark{
                nameView.layer.shadowColor = shadowColorForDarkIdiom
                submitButton.layer.shadowColor = shadowColorForDarkIdiom
            } else {
                nameView.layer.shadowColor = shadowColorForLightIdiom
                submitButton.layer.shadowColor = shadowColorForLightIdiom
            }
        }
    }
    //MARK: - Controleler SetUp
    func controllerCustomization(){
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
    }

    //MARK: - Stroke SetUp
    func strokeCustomization(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
//MARK: - TextView SetUp
    func textViewCustomization(){
        view.addSubview(textView)
        textView.delegate = self
        textView.inputDelegate = self

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            textView.heightAnchor.constraint(equalTo: textView.widthAnchor, multiplier: 0.57)
        ])
    }
//MARK: - KeyboardObserver
    func keybaordAppears(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
//MARK: - NameView SetUp
    func nameViewCustomization(){
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
    //MARK: - SubmitButton SetUp
    func submitButtonCustomization(){
        view.addSubview(submitButton)
        
        submitButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            submitButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -11),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            submitButton.heightAnchor.constraint(equalToConstant: 55)
        ])
//Action
        submitButton.addTarget(self, action: #selector(submitButTap(sender:)), for: .touchUpInside)
        submitButton.addTargetTouchBegin()
        submitButton.addTargetOutsideTouchStop()
        submitButton.addTargetInsideTouchStop()
    }
    
//MARK: - NavBar SetUp
    func navBarCustomization(){
        navigationItem.title = "addDictTitle".localized
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
    }
    
    private func saveDictionary(name: String, content: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newDictionary = NSEntityDescription.insertNewObject(forEntityName: "DictionaryEntity", into: context) as! DictionariesEntity
        
        do {
            try context.save()
        } catch {
            print("Failed to save dictionary: \(error)")
        }
    }

//MARK: - Actions
    @objc func submitButTap(sender: Any){
        let insertTextAllert = UIAlertController(
            title: "textAlert".localized,
            message: "textInfo".localized ,
            preferredStyle: .alert)
        let insertNameAllert = UIAlertController(
            title: "nameAlert".localized,
            message: "nameInfo".localized,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: "agreeInformal".localized,
            style: .cancel)
        insertNameAllert.addAction(action)
        insertTextAllert.addAction(action)
        action.setValue(UIColor.label, forKey: "titleTextColor")
        
        guard textView.hasText && textView.textColor != .lightGray else {return self.present(insertTextAllert, animated: true)}
        guard nameInputField.hasText else { return self.present(insertNameAllert, animated: true)}
        
        CoreDataHelper.shared.addDictionary(language: nameInputField.text!,
                                            text: textView.text!)
        
        navigationItem.rightBarButtonItem = nil
        view.becomeFirstResponder()
        navigationController?.popViewController(animated: true)
    }
    //Done buttom tap.
    @objc func rightBarButTap(sender: Any){
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
        textView.text = LanguageChangeManager.shared.localizedString(forKey: "viewPlaceholder")
        nameLabel.text = LanguageChangeManager.shared.localizedString(forKey: "dictionaryName")
        self.navigationItem.title = "addDictTitle".localized
        nameInputField.placeholder = "fieldPlaceholder".localized
        submitButton.setAttributedTitle(NSAttributedString().fontWithString(
            string: "save".localized,
            bold: true,
            size: 18), for: .normal)
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
        if self.navigationController?.navigationItem.rightBarButtonItem == nil{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(rightBarButTap(sender:)))
        }
    }
}
extension AddDictionaryVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.navigationController?.navigationItem.rightBarButtonItem == nil{
            self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(rightBarButTap(sender:))), animated: true)
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

