//
//  SettingsVC.swift
//  Language
//
//  Created by Star Lord on 11/02/2023.
//

import UIKit

class AddDictionaryVC: UIViewController {
    
    var textView: UITextView = {
        var textView = UITextView()
        textView.backgroundColor = .systemGray5
        textView.layer.cornerRadius = 9
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        textView.clipsToBounds = true
        
        textView.textContainerInset = .init(top: 10, left: 5, bottom: 5, right: 5)
        textView.allowsEditingTextAttributes = true
        
        textView.textColor = .lightGray
        textView.text = "- [ ] Word - Meaning"
        return textView
    }()
    
    var nameView : UIView = {
        var view = UIView()
        view.backgroundColor = .systemGray5
        
        view.layer.cornerRadius = 9
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.clipsToBounds = true
        
        return view
    }()
    
    var submitButton : UIButton = {
        var button = UIButton()
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 9
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        
        button.setAttributedTitle(NSAttributedString(string: "Add dictionary", attributes: [
            NSAttributedString.Key.font : UIFont(name: "Georgia-BoldItalic", size: 18) ?? UIFont()
        ]), for: .normal)
        return button
    }()
    let nameInputField : UITextField = {
        let field = UITextField()
        field.textColor = .label
        field.font =  UIFont(name: "Georgia-Italic", size: 15) ?? UIFont()
        field.placeholder = "Name"
        field.textAlignment = .right
        return field
    }()


//MARK: - Prepare Func
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.navigationController?.isToolbarHidden = true
        textViewCustomization()
        navBarCustomization()
        nameViewCustomization()
        submitButtonCustomization()
    }
//MARK: - TextView SetUp
    func textViewCustomization(){
        view.addSubview(textView)
        textView.delegate = self
        textView.inputDelegate = self
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 126),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            textView.widthAnchor.constraint(lessThanOrEqualToConstant: view.bounds.width - 45),
            textView.heightAnchor.constraint(lessThanOrEqualToConstant: ((view.bounds.width - 45) * 0.6))
        ])
    }
//MARK: - NameView SetUp
    func nameViewCustomization(){
        let nameLabel : UILabel = {
            let label = UILabel()
            label.font = UIFont(name: "Georgia-BoldItalic", size: 18) ?? UIFont()
            label.textColor = .label
            label.text = "Dictionary name:"
            return label
        }()
        nameInputField.delegate = self
        view.addSubview(nameView)
        nameView.addSubview(nameLabel)
        nameView.addSubview(nameInputField)
        
        nameView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameInputField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameView.topAnchor.constraint(equalTo: self.textView.bottomAnchor, constant: 11),
            nameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameView.widthAnchor.constraint(equalToConstant: view.bounds.width - 45),
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
            submitButton.heightAnchor.constraint(equalToConstant: 60),
            submitButton.widthAnchor.constraint(equalToConstant: view.bounds.width - 45)
        ])
    }
    
//MARK: - NavBar SetUp
        func navBarCustomization(){
        self.navigationItem.title = "Text uploading"
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font : UIFont(name: "Georgia-BoldItalic", size: 20) ?? UIFont(),
        ]
            self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
            self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.navigationItem.backButtonTitle = "Menu"
            self.navigationItem.backBarButtonItem?.setTitleTextAttributes([
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .bold)
            ], for: .normal)

        navigationController?.navigationBar.tintColor = .label
    }
//MARK: - Actions
    @objc func userViewTap(sender: Any){
        textView.resignFirstResponder()
        view.becomeFirstResponder()
    }
    
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
}

//MARK: - UITextViewDelegate
extension AddDictionaryVC: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray{
            textView.text = nil
            textView.textColor = .label
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(rightBarButTap(sender:)))
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
