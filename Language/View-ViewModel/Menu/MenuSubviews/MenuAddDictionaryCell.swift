//
//  AddDictionaryCell.swift
//  Language
//
//  Created by Star Lord on 15/02/2023.
//

import UIKit

class MenuAddDictionaryCell: UITableViewCell {
    
    static let identifier = "addCell"
    
    //MARK: Views
    private let importLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    //Instead of ImageView i've used UIButton in case Apple will anounce API to work with Built in Notes.
    private let addButton : UIButton = {
        var button = UIButton()
        button.backgroundColor = .systemGray5
        button.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(weight: .medium)), for: .normal)
        button.imageView?.center = button.center
        button.tintColor = .label
        
        button.layer.cornerRadius = 9
        button.clipsToBounds = true
        
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: Inherited and initializers.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellView()
        configureSubviews()
        configureLabels()
    }
    required init?(coder: NSCoder) {
        fatalError("coder wasn't imported")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Configuring views properties.
    func configureCellView(){
        self.backgroundColor = .systemGray6
        self.layer.cornerRadius = 9
        self.clipsToBounds = true
        self.selectionStyle = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged(sender:)), name: .appLanguageDidChange, object: nil)
    }
    
    //MARK: Configuring and laying out subviews.
    func configureSubviews(){
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
    //MARK: Configuring views labels.
    func configureLabels(){
        importLabel.attributedText =
            .attributedString(
                string: "menu.cell.import".localized,
                with: .georgianBoldItalic,
                ofSize: 20)
    }
    
    @objc func languageChanged(sender: Any){
        configureLabels()
    }
}
