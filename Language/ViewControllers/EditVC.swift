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
import Differ

class EditVC: UIViewController {
    
    var currentDictionary: DictionariesEntity! 
    var currentDictionaryPairs: [WordsEntity]!
    
    //Text representaition of existing words for comparison
    var oldText: [String]!
    var newText: [String]!
        
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
        configureStrokes()
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.bottomStroke.strokeColor = UIColor.label.cgColor
            self.topStroke.strokeColor = UIColor.label.cgColor
        }
    }
    func configureStrokes(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)

        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
    
    func configureController(){
        view.backgroundColor = .systemBackground
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
        textField.frame = CGRect(x: 0, y: 0, width: view.bounds.width * 0.6,
                                 height: navigationController?.navigationBar.bounds.height ?? 30)
    }
    //MARK: - NavBar SetUp
    func configureNavBar(){
        self.navigationItem.titleView = textField
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                 target: self,
                                                                 action: #selector(saveButTap(sender:)))
        navigationItem.backButtonDisplayMode = .minimal
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true

    }
    //MARK: - Actions
    @objc func saveButTap(sender: Any){
        guard textView.text != "" else {
            //TODO: Add alert if text or name was vanished.
            return
        }
        
        let actualNumber = currentDictionaryPairs.count
        let lines = textView.text.split(separator: "\n", omittingEmptySubsequences: true)
        newText = lines.map({ String($0) })
        let patch = patch(from: oldText, to: newText)
        for i in patch{
            switch i {
            case .deletion(index: let index):
                currentDictionaryPairs.remove(at: index)
            case .insertion(index: let index, element: let text):
                currentDictionaryPairs.insert(CoreDataHelper.shared.pairDividerFor(dictionary: currentDictionary, text: text, index: index), at: index)
            }
        }
        if currentDictionaryPairs.count != actualNumber {
            for (index, pair) in currentDictionaryPairs.enumerated(){
                pair.order = Int64(index)
            }
        }
        CoreDataHelper.shared.update(dictionary: currentDictionary, words: currentDictionaryPairs, name: self.textField.text)
        self.navigationController?.popViewController(animated: true)
    }
    //Done button
    @objc func rightBarButDidTap(sender: Any){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(saveButTap(sender:)))

        if textView.isFirstResponder{
            textView.resignFirstResponder()
        } else if textField.isFirstResponder{
            textField.resignFirstResponder()
        }
    }
}

//MARK: - TextViewDelegate
extension EditVC: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = nil
            textView.font = nil
            textView.typingAttributes = [NSAttributedString.Key.font : UIFont(name: "Times New Roman", size: 17) ?? UIFont(), NSAttributedString.Key.backgroundColor : UIColor.clear, NSAttributedString.Key.foregroundColor : UIColor.label]
        }
        if self.navigationController?.navigationItem.rightBarButtonItem == nil{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(rightBarButDidTap(sender:)))
        }
    }
    
    
}

//MARK: - TextFieldDelegate
extension EditVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.navigationController?.navigationItem.rightBarButtonItem == nil{
            self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(rightBarButDidTap(sender:))), animated: true)
        }
    }
}
