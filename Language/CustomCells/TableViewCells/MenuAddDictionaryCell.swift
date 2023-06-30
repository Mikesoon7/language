//
//  AddDictionaryCell.swift
//  Language
//
//  Created by Star Lord on 15/02/2023.
//

import UIKit

class MenuAddDictionaryCell: UITableViewCell {
    
    let identifier = "addCell"

    var importLabel: UILabel = {
        var label = UILabel()
        label.attributedText = NSAttributedString().fontWithString(
            string: LanguageChangeManager.shared.localizedString(forKey: "tableCellImport"),
            bold: true,
            size: 20)
        return label
    }()
    var addButton : UIButton = {
        var button = UIButton()
        button.backgroundColor = .systemGray3
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.imageView?.center = button.center
        button.tintColor = .label
        
        button.layer.cornerRadius = 9
        button.clipsToBounds = true
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged(sender:)), name: .appLanguageDidChange, object: nil)
        self.backgroundColor = .systemGray5
        self.layer.cornerRadius = 9
        self.clipsToBounds = true
        
        setUpAccessories()
    }
    required init?(coder: NSCoder) {
        fatalError("coder wasn't imported")
    }
    
    func setUpAccessories(){
        self.addSubviews(importLabel, addButton)
        importLabel.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            importLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            importLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            importLabel.heightAnchor.constraint(equalToConstant: 25),
            
            addButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            addButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    @objc func languageChanged(sender: Any){
        importLabel.text = LanguageChangeManager.shared.localizedString(forKey: "tableCellImport")
    }
}
