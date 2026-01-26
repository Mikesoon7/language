//
//  SingleInputActionButtons.swift
//  Learny
//
//  Created by Star Lord on 02/01/2026.
//

import UIKit

final class SingleInputActionButtonsView: UIView {
    
    //MARK: View's
    private lazy var singleButtonsStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [saveButton, addNewCellButton])
        view.axis = .horizontal
        view.spacing = .innerSpacer / 2
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var addNewCellButton: UIButton = {
        let button = UIButton()
        button.setUpCustomButton()
        button.setImage(UIImage(systemName: "plus.viewfinder")?.withTintColor(.label), for: .normal)
        return button
    }()
    
    private var saveButton : UIButton = {
        var button = UIButton()
        button.setUpCustomButton()
        return button
    }()
    
    //MARK: Methods
    var onAddTapped: (() -> Void)?
    var onSaveTapped: (() -> Void)?

    
    init() {
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .systemBackground.withAlphaComponent(0.7)
        
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView(){
        self.addSubviews(singleButtonsStack)
        
        NSLayoutConstraint.activate([
            singleButtonsStack.leadingAnchor.constraint(
                equalTo: self.leadingAnchor, constant: .longInnerSpacer),
            singleButtonsStack.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,  constant: -.longInnerSpacer),
            singleButtonsStack.topAnchor.constraint(
                equalTo: self.topAnchor, constant: .innerSpacer),
            singleButtonsStack.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),
        ])
        
        addNewCellButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        self.updateForLanguageChange()
    }
    
    func responseToTraitStyleChange(trait: UITraitCollection){
        if trait.userInterfaceStyle == .dark{
            saveButton.layer.shadowColor = shadowColorForDarkIdiom
            addNewCellButton.layer.shadowColor = shadowColorForDarkIdiom
        } else {
            saveButton.layer.shadowColor = shadowColorForLightIdiom
            addNewCellButton.layer.shadowColor = shadowColorForLightIdiom
        }
    }
        
    @objc private func addTapped() {
        onAddTapped?()
    }

    @objc private func saveTapped() {
        onSaveTapped?()
    }

    
}

extension SingleInputActionButtonsView: LanguageUpdatable, FontUpdatable {
    func updateForFontChange() {
        saveButton.setAttributedTitle(
            .attributedString(string: "system.save".localized,
                              with: .selectedFont,
                              ofSize: .bodyTextSize), for: .normal)
    }
    
    func updateForLanguageChange() {
        saveButton.setAttributedTitle(
            .attributedString(string: "system.save".localized,
                              with: .selectedFont,
                              ofSize: .bodyTextSize), for: .normal)
    }
}
