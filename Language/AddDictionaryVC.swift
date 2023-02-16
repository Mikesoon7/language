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
        textView.backgroundColor = .lightGray
        textView.layer.cornerRadius = 9
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        textView.clipsToBounds = true
        textView.textContainerInset = .init(top: 5, left: 20, bottom: 5, right: 5)
        textView.allowsEditingTextAttributes = true
        return textView
    }()
    
        override func viewDidLoad() {
        super.viewDidLoad()
            view.backgroundColor = .white
            textViewLayout()

    }
    func textViewLayout(){
        view.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            textView.widthAnchor.constraint(greaterThanOrEqualToConstant: 330),
            textView.heightAnchor.constraint(lessThanOrEqualToConstant: 104)
        ])
    }


}
