//
//  SingleModeAddCell.swift
//  Learny
//
//  Created by Star Lord on 21/04/2025.
//

import UIKit

class SingleModeAddCell: UICollectionViewCell {
    
    static var identifier = "SingleModeAdd"
    
    var delegate: SingleModeAddDelegate?
          
    var addNewCellButton: UIButton = {
        let button = UIButton()
        button.setUpCustomButton()
        button.setImage(UIImage(systemName: "plus.viewfinder")?.withTintColor(.label), for: .normal)
        return button
    }()

    var saveButton : UIButton = {
        var button = UIButton()
        button.setUpCustomButton()
        button.setAttributedTitle(
            .attributedString(string: "system.save".localized,
                              with: .selectedFont,
                              ofSize: .bodyTextSize), for: .normal)
        return button
    }()



    //MARK: - Inherited Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("coder wasn't imported")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.saveButton.layer.shadowColor = UIColor.shadowColour.cgColor
        self.addNewCellButton.layer.shadowColor = UIColor.shadowColour.cgColor
    }
    

    func configureCellWith(delegate: SingleModeAddDelegate){
        self.delegate = delegate
    }
    func configureSubviews() {
        self.contentView.addSubviews( saveButton, addNewCellButton)
        
        
        
        NSLayoutConstraint.activate([
            addNewCellButton.topAnchor.constraint(equalTo: topAnchor),
            addNewCellButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            addNewCellButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5, constant: -.innerSpacer / 2),
            addNewCellButton.bottomAnchor.constraint(equalTo: bottomAnchor),

            saveButton.topAnchor.constraint(equalTo: topAnchor),
            saveButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            saveButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5, constant: -.innerSpacer / 2),
            saveButton.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        addNewCellButton.addTarget(self, action: #selector(addButtonDidTap(sender: )), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender: )), for: .touchUpInside)
    }
    
    @objc func addButtonDidTap(sender: Any){
        delegate?.didAddCell()
    }
    @objc func saveButtonDidTap(sender: Any){
        delegate?.didSave()
    }
    @objc func appThemeDidChange(sender: Notification){
        self.addNewCellButton.layer.shadowColor = UIColor.shadowColour.cgColor
        self.saveButton.layer.shadowColor = UIColor.shadowColour.cgColor
    }

}
