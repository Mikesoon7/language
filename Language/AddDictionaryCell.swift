//
//  AddDictionaryCell.swift
//  Language
//
//  Created by Star Lord on 15/02/2023.
//

import UIKit

class AddDictionaryCell: UITableViewCell {
    
    var importLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Georgia-BoldItalic", size: 20)
        label.text = "Import new Note"
        return label
    }()
    var addButton : UIButton = {
        var button = UIButton()
        button.backgroundColor = .systemGray3
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.imageView?.center = button.center
        button.tintColor = .black
        
        button.layer.cornerRadius = 9
        button.clipsToBounds = true
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .systemGray5
        self.layer.cornerRadius = 9
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
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
}
