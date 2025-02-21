//
//  AddDictionaryCell.swift
//  Language
//
//  Created by Star Lord on 15/02/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit

//MARK: For future import support
protocol MenuAddCellDelegate: AnyObject {
    func importButtonDidTap()
}
class MenuAddDictionaryCVCell: UICollectionViewCell {
    
    private weak var delegate: MenuAddCellDelegate?
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
        button.setUpCustomButton()
        button.backgroundColor = .systemGray5
        button.setImage(UIImage(systemName: "square.and.arrow.down", withConfiguration: UIImage.SymbolConfiguration(weight: UIFont.selectedFont.fontWeight.symbolWeight())), for: .normal)
        button.imageView?.center = button.center
        button.tintColor = .label
        
        button.layer.cornerRadius = .cornerRadius
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
    deinit { NotificationCenter.default.removeObserver(self) }

    //MARK: Configuring views properties.
    func configureCellView(){
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = .cornerRadius
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fontDidChange(sender:)), name: .appFontDidChange, object: nil)
    }
    
    func configureCellWith(delegate: MenuAddCellDelegate) {
        self.delegate = delegate
    }

    //MARK: Configuring and laying out subviews.
    func configureSubviews(){
        self.addSubviews(importLabel, addButton)
        importLabel.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            importLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .longInnerSpacer),
            importLabel.centerYAnchor.constraint(
                equalTo: centerYAnchor),
            
            addButton.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -.longInnerSpacer),
            addButton.centerYAnchor.constraint(
                equalTo: centerYAnchor),
            addButton.widthAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            addButton.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight)
        ])
    }
    //MARK: Configuring views labels.
    func configureLabels(){
        importLabel.attributedText =
            .attributedString(
                string: "menu.cell.import".localized,
                with: FontChangeManager.shared.currentFont(),
                ofSize: .subtitleSize)
    }
    
    @objc func languageDidChange(sender: Any){
        configureLabels()
    }
    @objc func fontDidChange(sender: Any){
        importLabel.font = .selectedFont.withSize(.subtitleSize)
        addButton.setImage(UIImage(systemName: "square.and.arrow.down", withConfiguration: UIImage.SymbolConfiguration(weight: UIFont.selectedFont.fontWeight.symbolWeight())), for: .normal)
    }
}
