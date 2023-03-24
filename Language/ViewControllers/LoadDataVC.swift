//
//  LoadDataVC.swift
//  Language
//
//  Created by Star Lord on 08/02/2023.
//

import UIKit

class LoadDataVC: UIViewController {
    
    var textField : UITextField = {
        var textField = UITextField()
        
        textField.placeholder = "what are you waiting?"
        textField.borderStyle = .roundedRect
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.cornerRadius = 7
        textField.clipsToBounds = true
        textField.backgroundColor = .lightGray
        return textField
    }()
    
    var textLabel : UILabel = {
        var textLabel = UILabel()
        textLabel.backgroundColor = .lightGray
        textLabel.layer.cornerRadius = 7
        textLabel.layer.borderWidth = 1
        textLabel.layer.borderColor = UIColor.black.cgColor
        textLabel.numberOfLines = 0
        textLabel.text = "Your imput is ..."
        textLabel.contentMode = .top
        textLabel.sizeToFit()
        textLabel.isUserInteractionEnabled = true
        textLabel.clipsToBounds = true
        
        return textLabel
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        elementsLayout()
        addOverlayButtons()

        
        
    }
    func addOverlayButtons(){
        let overlayButton = UIButton(type: .custom)
        let bookmarkImage = UIImage(systemName: "bookmark")
        overlayButton.setImage(bookmarkImage, for: .normal)
        overlayButton.addTarget(self, action: #selector(displayBookmarks),
                                for: .touchUpInside)
        overlayButton.sizeToFit()
        
        // Assign the overlay button to the text field
        textField.rightView = overlayButton
        textField.rightView?.clipsToBounds = false
        textField.rightViewMode = .unlessEditing
        textField.clearButtonMode = .whileEditing
    }
    func elementsLayout(){
        textFieldConstraits()
        labelConstraits()
    }
    func textFieldConstraits(){
        view.addSubview(textField)
        textField.delegate = self
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            textField.widthAnchor.constraint(equalToConstant: view.bounds.width - 40),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.heightAnchor.constraint(equalToConstant: textField.font!.pointSize + 10)
        
        ])
            }
    func labelConstraits(){
        view.addSubview(textLabel)
        
        textLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            textLabel.widthAnchor.constraint(equalToConstant: view.bounds.width - 40),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            textLabel.heightAnchor.constraint(equalToConstant: (textLabel.font.pointSize + 5) * 3)
        
        ])
    }
    @objc func displayBookmarks(){
        
    }
    

}
extension LoadDataVC: UITextFieldDelegate{
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textLabel.text = textField.text
        return true
    }

}
