//
//  PopUpTimerView.swift
//  Learny
//
//  Created by Star Lord on 13/01/2025.
//
//  REFACTORING STATE: CHECKED

import UIKit

protocol PopUpTimerViewDelegate: AnyObject {
    func continueButtonDidTap()
    func finishButtonDidTap()
    func viewDidDismiss()
}
class PopUpTimerView: UIView {
    
    var delegate: PopUpTimerViewDelegate
    
    var learnedNumber: Int
    var sourceViewRect: CGRect
    var sourceSafeArea: UIEdgeInsets
    
    let popover: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground_Secondary
        view.layer.cornerRadius = .cornerRadius + 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = true
        view.alpha = 0
        return view
    }()
    
    //MARK: Lablels
    let partitialResultLabel: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(18)
        label.textColor = .label
        label.text = "system.checked".localized + ":"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var partitialResultNumber: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(16)
        label.textColor = .label
        label.text = "\(learnedNumber)"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: Buttons
    let continueButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setUpCustomButton()
        button.backgroundColor = .popoverSubviewsBackgroundColour
        button.setTitleColor(.label, for: .normal)
        button.setAttributedTitle(
            .attributedString(
                string: "system.continue".localized,
                with: .selectedFont,
                ofSize: 17), for: .normal
        )
        button.addTarget(self, action: #selector(continueButDidTap) , for: .touchUpInside)
        return button
    }()
    
    let finishButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setUpCustomButton()
        button.backgroundColor = .popoverSubviewsBackgroundColour
        button.setTitleColor(.label, for: .normal)
        button.setAttributedTitle(
            .attributedString(
                string: "system.finish".localized,
                with: .selectedFont,
                ofSize: 17), for: .normal
        )
        button.addTarget(self, action: #selector(finishButDidTap) , for: .touchUpInside)
        return button
    }()


    
    init(frame: CGRect, safeAreaInsets: UIEdgeInsets, number: Int, delegate: PopUpTimerViewDelegate) {
        self.learnedNumber = number
        self.delegate = delegate
        self.sourceViewRect = frame
        self.sourceSafeArea = safeAreaInsets
        super.init(frame: .zero)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.alpha = 0
        self.translatesAutoresizingMaskIntoConstraints = false
        
        configureGestures()
        configureSubviews()
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Add tap gesture recognizer to dismiss popover when tapping outside
    func configureGestures(){
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(viewDidDismiss))
        self.addGestureRecognizer(dismissTap)
        let dismissSwipe = UISwipeGestureRecognizer(target: self, action: #selector(viewDidDismiss))
        self.addGestureRecognizer(dismissSwipe)
    }
    
    func configureSubviews(){
        if traitCollection.isRegularWidth  {
            popover.frame = CGRect(x: sourceViewRect.width / 2 + .innerSpacer ,
                                   y: sourceSafeArea.top + .longInnerSpacer,
                                   width:   (sourceViewRect.width / 2) - (.innerSpacer * 2),
                                   height:  ((sourceViewRect.width / 2) - (.innerSpacer * 2)) * 0.66 )
        } else {
            popover.frame = CGRect(x: .innerSpacer,
                                   y: sourceSafeArea.top + .longInnerSpacer,
                                   width:  (sourceViewRect.width - (.innerSpacer * 2)),
                                   height: (sourceViewRect.width - (.innerSpacer * 2)) * 0.66 )
        }
        popover.center = CGPoint(x: sourceViewRect.width - .innerSpacer,
                                 y: sourceSafeArea.top + .longInnerSpacer)
        popover.anchorPoint = CGPoint(x: 1, y: 0)
        popover.transform = .init(scaleX: 0.2, y: 0.2).concatenating(.init(translationX: -30, y: -10))
        
        
        self.addSubview(popover)
        
        popover.addSubviews(partitialResultLabel, partitialResultNumber, continueButton, finishButton)
        
        
        NSLayoutConstraint.activate([
            partitialResultLabel.topAnchor.constraint(
                equalTo: popover.topAnchor, constant: .longInnerSpacer),
            partitialResultLabel.leadingAnchor.constraint(
                equalTo: popover.leadingAnchor, constant: .longInnerSpacer),
            
            partitialResultNumber.trailingAnchor.constraint(
                equalTo: popover.trailingAnchor, constant: -.longInnerSpacer),
            partitialResultNumber.centerYAnchor.constraint(
                equalTo: partitialResultLabel.centerYAnchor),
            
            continueButton.bottomAnchor.constraint(
                equalTo: popover.bottomAnchor, constant: -.longInnerSpacer),
            continueButton.leadingAnchor.constraint(
                equalTo: popover.leadingAnchor, constant: .longInnerSpacer),
            continueButton.widthAnchor.constraint(
                equalTo: popover.widthAnchor, multiplier: 0.5, constant: -30),
            continueButton.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            
            finishButton.bottomAnchor.constraint(
                equalTo: popover.bottomAnchor, constant: -.longInnerSpacer),
            finishButton.trailingAnchor.constraint(
                equalTo: popover.trailingAnchor, constant: -.longInnerSpacer),
            finishButton.widthAnchor.constraint(
                equalTo: popover.widthAnchor, multiplier: 0.5, constant: -30),
            finishButton.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight)
        ])
    }
    func present(){
        UIView.animate(withDuration: 0.3) {
            self.popover.transform = .identity
            self.popover.alpha = 1
            self.alpha = 1
        }
    }
    
    func dismiss(completion: @escaping () -> () ){
        UIView.animate(withDuration: 0.3, animations: {
            self.popover.transform = .init(scaleX: 0.2, y: 0.2).concatenating(.init(translationX: -50, y: -20))
            self.popover.alpha = 0
            self.alpha = 0
        }) { _ in completion() }
    }
}
//MARK: - Actions
extension PopUpTimerView{
    @objc func continueButDidTap(){
        dismiss(completion: delegate.continueButtonDidTap)
    }
    @objc func finishButDidTap(){
        dismiss(completion: delegate.finishButtonDidTap)
        
    }
    @objc func viewDidDismiss(){
        dismiss(completion: delegate.viewDidDismiss)
    }
}
