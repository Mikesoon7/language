//
//  AddDictionaryCell.swift
//  Language
//
//  Created by Star Lord on 15/02/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit


class MenuAddDictionaryCVCell: UICollectionViewCell {
    
    static let identifier = "addCell"
    
    //MARK: Views
    private let importLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    //TODO: - Add import information functionality.
    private let addButton : UIButton = {
        var button = UIButton()
        button.backgroundColor = .systemGray5
        button.setImage(UIImage(systemName: "square.and.arrow.down", withConfiguration: UIImage.SymbolConfiguration(weight: UIFont.selectedFont.fontWeight.symbolWeight())), for: .normal)
        button.imageView?.center = button.center
        button.tintColor = .label
        
        button.layer.cornerRadius = 9
        button.clipsToBounds = true
        
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: Inherited and initializers.
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = .cornerRadius
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fontDidChange(sender:)), name: .appFontDidChange, object: nil)
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
                with: FontChangeManager.shared.currentFont(),
                ofSize: 20)
    }
    
    @objc func languageDidChange(sender: Any){
        configureLabels()
    }
    @objc func fontDidChange(sender: Any){
        importLabel.font = .selectedFont.withSize(20)
        addButton.setImage(UIImage(systemName: "square.and.arrow.down", withConfiguration: UIImage.SymbolConfiguration(weight: UIFont.selectedFont.fontWeight.symbolWeight())), for: .normal)
    }
}
