//
//  EditVC.swift
//  Language
//
//  Created by Star Lord on 13/06/2023.
//

import UIKit

class EditVC: UIViewController {
    
    let textView: UITextView = {
        let view = UITextView()
        view.textContainerInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        view.allowsEditingTextAttributes = true
        view.textColor = .label
        view.backgroundColor = .systemBackground
        view.font = UIFont(name: "Times New Roman", size: 17) ?? UIFont()
        view.text = "some very important text"
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
    
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
        configureTextField()
        configureTextView()

        configureNavBar()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        strokeCustomization()
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.bottomStroke.strokeColor = UIColor.label.cgColor
            self.topStroke.strokeColor = UIColor.label.cgColor
        }
    }
    func strokeCustomization(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)

        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
    
    func configureController(){
        view.backgroundColor = .systemBackground
    }

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
    func configureTextField(){
        textField.delegate = self
        textField.frame = CGRect(x: 0, y: 0, width: view.bounds.width * 0.6,
                                 height: navigationController?.navigationBar.bounds.height ?? 30)
    }
    func configureNavBar(){
        self.navigationItem.titleView = textField
        
        navigationItem.backButtonDisplayMode = .minimal
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true

    }
    //Done button
    @objc func rightBarButTap(sender: Any){
        navigationItem.rightBarButtonItem = nil
        if textView.isFirstResponder{
            textView.resignFirstResponder()
        } else if textField.isFirstResponder{
            textField.resignFirstResponder()
        }
    }

}
extension EditVC: UITextViewDelegate{
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
extension EditVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.navigationController?.navigationItem.rightBarButtonItem == nil{
            self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(rightBarButTap(sender:))), animated: true)
        }
    }
}
