//
//  SingleModeNameCell.swift
//  Learny
//
//  Created by Star Lord on 21/04/2025.
//

import UIKit

class SingleModeNameCell: UICollectionViewCell {
   
    static var identifier = "SingleModeName"
    
    var delegate: SingleModeNameDelegate?
    
    private let nameView : UIView = {
        var view = UIView()
        view.layer.cornerRadius = 9

        view.backgroundColor = .selectedColourPalette.primaryBackgroundColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.bodyTextSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var nameInputField : UITextField = {
        let field = UITextField()
        field.textColor = .label
        field.textAlignment = .right
        field.font = .selectedFont.withSize(.assosiatedTextSize)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.delegate = self
        return field
    }()

    
    //MARK: - Inherited Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCell()
        configureNameInputView()
    }
    func configureCellWith(name: String, delegate: SingleModeNameDelegate){
        self.nameInputField.text = name
        self.delegate = delegate
    }
    
    
    deinit { NotificationCenter.default.removeObserver(self) }

    required init?(coder: NSCoder) {
        fatalError("coder wasn't imported")
    }
    
    private func configureCell() {
        self.addCenterShadows()
    }

    private func configureNameInputView(){
        contentView.addSubview(nameView)
        nameView.addSubviews(nameLabel, nameInputField)
        
        nameLabel.text = "dictionaryName".localized

        nameInputField.placeholder = "fieldPlaceholder".localized

        NSLayoutConstraint.activate([
            nameView.topAnchor.constraint(
                equalTo: topAnchor),
            nameView.leadingAnchor.constraint(
                equalTo: leadingAnchor),
            nameView.trailingAnchor.constraint(
                equalTo: trailingAnchor),
            nameView.heightAnchor.constraint(
                equalTo: heightAnchor),
            
            nameLabel.leadingAnchor.constraint(
                equalTo: nameView.leadingAnchor, constant: .innerSpacer),
            nameLabel.centerYAnchor.constraint(
                equalTo: nameView.centerYAnchor),
            
            
            nameInputField.trailingAnchor.constraint(
                equalTo: nameView.trailingAnchor, constant: -.innerSpacer),
            nameInputField.centerYAnchor.constraint(
                equalTo: nameView.centerYAnchor)
        ])
        //Action
        nameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nonAccurateNameFieldTap(sender:))))
    }

    @objc func nonAccurateNameFieldTap(sender: Any){
        nameInputField.becomeFirstResponder()
    }

}

extension SingleModeNameCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            delegate?.didTypeName(text: text)
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }
}
