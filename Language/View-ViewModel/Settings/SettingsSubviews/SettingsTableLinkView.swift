//
//  SettingsTableLinkView.swift
//  Learny
//
//  Created by Star Lord on 13/02/2025.
//

import UIKit

class SettingsTableLinkView: UIView {
    
    static var footerHeight: CGFloat = 80
    
    private var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually

        view.alignment = .center
        view.spacing = .innerSpacer
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var privacyPolicy: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray2
        label.font = .systemFont(ofSize: .captionTextSize)
        label.text = "settings.footer.policy".localized
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.tag = 1
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var contactSupport: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray2
        label.font = .systemFont(ofSize: .captionTextSize)
        label.text = "settings.footer.support".localized
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.tag = 2
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var buyCoffee: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray2
        label.font = .systemFont(ofSize: .captionTextSize)
        label.text = "settings.footer.buyCoffee".localized
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.tag = 3
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private var compactWidthConstraints: [NSLayoutConstraint] = []
    private var regularWidthConstraints: [NSLayoutConstraint] = []

    override init(frame: CGRect){
        super.init(frame: frame)
        configureSubviews()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            applyLayout()
        }
    }
    
    private func configureSubviews(){
        self.addSubviews(stackView, buyCoffee)
        stackView.addArrangedSubviews(privacyPolicy, contactSupport)
        
        compactWidthConstraints = [
            stackView.topAnchor.constraint(
                equalTo: topAnchor),
            stackView.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .outerSpacer),
            stackView.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -.outerSpacer),
            stackView.heightAnchor.constraint(
                equalTo: heightAnchor, multiplier: 0.66, constant: -.innerSpacer),
                                   
            buyCoffee.topAnchor.constraint(
                equalTo: stackView.bottomAnchor, constant: .innerSpacer),
            buyCoffee.centerXAnchor.constraint(
                equalTo: centerXAnchor),
            buyCoffee.bottomAnchor.constraint(
                equalTo: bottomAnchor, constant: -.innerSpacer)
        ]
        regularWidthConstraints = [
            stackView.topAnchor.constraint(
                equalTo: topAnchor),
            stackView.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .outerSpacer),
            stackView.widthAnchor.constraint(
                equalTo: widthAnchor, multiplier: 0.66, constant: -.outerSpacer * 2),
            stackView.heightAnchor.constraint(
                equalTo: heightAnchor),
                                   
            buyCoffee.centerYAnchor.constraint(
                equalTo: stackView.centerYAnchor),
            buyCoffee.leadingAnchor.constraint(
                equalTo: stackView.trailingAnchor),
            buyCoffee.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -.outerSpacer)
        ]
                
        let privacyTap = UITapGestureRecognizer(target: self, action: #selector(privacyPolicy(sender: )))
        let supportTap = UITapGestureRecognizer(target: self, action: #selector(contactSupport(sender: )))
        let coffeeTap = UITapGestureRecognizer(target: self, action: #selector(buyACoffee(sender: )))

        privacyPolicy.addGestureRecognizer(privacyTap)
        contactSupport.addGestureRecognizer(supportTap)
        buyCoffee.addGestureRecognizer(coffeeTap)
    }
    
    func updateLabels(){
        privacyPolicy.text = "settings.footer.policy".localized
        contactSupport.text = "settings.footer.support".localized
        buyCoffee.text = "settings.footer.buyCoffee".localized
    }
    
    func applyLayout(){
        if traitCollection.isRegularWidth {
            NSLayoutConstraint.deactivate(compactWidthConstraints)
            NSLayoutConstraint.activate(regularWidthConstraints)
        } else {
            NSLayoutConstraint.deactivate(regularWidthConstraints)
            NSLayoutConstraint.activate(compactWidthConstraints)
        }
        layoutIfNeeded()
    }
    
    //MARK: Actions
    @objc func privacyPolicy(sender: UITapGestureRecognizer){
        if let url = URL(string: AppLinks.privacyPolicyLink) {
            UIApplication.shared.open(url)
        }
    }
    @objc func contactSupport(sender: UITapGestureRecognizer){
        if let url = URL(string: AppLinks.supportLink) {
            UIApplication.shared.open(url)
        }
    }
    @objc func buyACoffee(sender: UITapGestureRecognizer){
        if let url = URL(string: AppLinks.supportAuthorLink) {
            UIApplication.shared.open(url)
        }
    }
}

