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
        
        textView.textContainerInset = .init(top: 5, left: 5, bottom: 5, right: 5)
        textView.allowsEditingTextAttributes = true
        
        textView.text = "- [ ] Word - Meaning"
        textView.tintColor = .lightGray
        return textView
    }()
    
        override func viewDidLoad() {
        super.viewDidLoad()
            view.backgroundColor = .systemBackground
            textViewCustomization()
            navBarCustomization()

    }
    func textViewCustomization(){
        view.addSubview(textView)
        textView.delegate = self
        textView.inputDelegate = self
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            textView.widthAnchor.constraint(greaterThanOrEqualToConstant: 330),
            textView.heightAnchor.constraint(lessThanOrEqualToConstant: 330)
        ])
    }
    
        func navBarCustomization(){
        self.navigationItem.title = "Text uploading"
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font : UIFont(name: "Georgia-BoldItalic", size: 20) ?? UIFont(),
        ]
        
        self.navigationItem.backButtonTitle = "Menu"
            self.navigationItem.backBarButtonItem?.setTitleTextAttributes([
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .bold)
            ], for: .normal)

        navigationController?.navigationBar.tintColor = .label
    }
    @objc func userViewTap(sender: Any){
        textView.resignFirstResponder()
        view.becomeFirstResponder()
    }
    

}

//MARK: - UITextViewDelegate
extension AddDictionaryVC: UITextViewDelegate{
    
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
