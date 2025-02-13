//
//  SeparatorsExampleView.swift
//  Language
//
//  Created by Star Lord on 17/08/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit

class SeparatorsExampleView: UIView {
    
    private var separator: String?
    
    //MARK: Views
    private let firstLineStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalSpacing
        view.spacing = 1
        return view
    }()
    private let secondLineStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalSpacing
        return view
    }()
    private let secondLineTrailingStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalSpacing
        return view
    }()
    
    //MARK: Labels
    private lazy var firstLineLeadingLabel: UILabel = configureLabelWith(
        text: "World ")
    private lazy var firstLineSeparatorLabel: UILabel = configureLabelWith(
        text: separator ?? " ")
    private lazy var firstLineTrailingLabel: UILabel = configureLabelWith(
        text: " the best place to live.")
    
    private lazy var secondLineLeadingLabel: UILabel = configureLabelWith(
        text: "Apple ")
    private lazy var secondLineSeparatorLabel: UILabel = configureLabelWith(
        text: separator ?? " ")
    private lazy var secondLineMiddleLabel: UILabel = configureLabelWith(
        text: " red as well as ")
    private lazy var secondLineSeparatorLastLabel: UILabel = configureLabelWith(
        text: separator ?? " ")
    private lazy var secondLineTrailingLabel: UILabel = configureLabelWith(
        text: " sweet.")

    
    //MARK: Bold Labels
    //I couldnt archive smooth transition from one font to another with one label, so ended up replacing normal with bold label.
    private lazy var firstLineBoldLeadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeueBold.withSize(15)
        label.text = "World "
        label.alpha = 0
        return label
    }()
    private lazy var secondLineBoldLeadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeueBold.withSize(15)
        label.text = "Apple "
        label.alpha = 0
        return label
    }()

    //MARK: Constaints and related
    private var firstLineStackViewTopAnchor: NSLayoutConstraint = .init()
    private var secondLineStackViewBottomAnchor: NSLayoutConstraint = .init()
    
    private var firstLineBoldLabelTopAnchor: NSLayoutConstraint = .init()
    private var secondLineBoldLabelBottomAnchor: NSLayoutConstraint = .init()

    //MARK: - Inherited
    init(frame: CGRect, separator: String){
        self.separator = separator
        super.init(frame: frame)
        configureView()
        configureExampleSubviews()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Coder wasn't imported")
    }
    
    //MARK:  View setUp
    private func configureView(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.secondarySystemBackground

        self.layer.cornerRadius = .cornerRadius
        self.layer.cornerCurve = .continuous
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true
    }
    
    //MARK:  ExampleSubviews SetUp.
    //View containt 3 stackViews and 2 label outside of the stack.
    //Labels are used to initate smooth transition to bold version for first labels in Stacks.
    //In order to visualy separate "separators" labels, we passing another stackView, which won't change its spacing.
    private func configureExampleSubviews(){
        self.addSubviews(firstLineStackView, secondLineStackView, firstLineBoldLeadingLabel, secondLineBoldLeadingLabel)
        
        firstLineStackView.addArrangedSubviews(firstLineLeadingLabel, firstLineSeparatorLabel, firstLineTrailingLabel)
        secondLineTrailingStackView.addArrangedSubviews(secondLineMiddleLabel, secondLineSeparatorLastLabel, secondLineTrailingLabel)
        secondLineStackView.addArrangedSubviews(secondLineLeadingLabel, secondLineSeparatorLabel, secondLineTrailingStackView)

        firstLineStackViewTopAnchor = firstLineStackView.topAnchor.constraint(
            equalTo: topAnchor, constant: .longInnerSpacer)
        secondLineStackViewBottomAnchor = secondLineStackView.bottomAnchor.constraint(
            equalTo: bottomAnchor, constant: -.longInnerSpacer)
        
        firstLineBoldLabelTopAnchor = firstLineBoldLeadingLabel.topAnchor.constraint(
            equalTo: topAnchor, constant: .longInnerSpacer)
        secondLineBoldLabelBottomAnchor = secondLineBoldLeadingLabel.bottomAnchor.constraint(
            equalTo: bottomAnchor, constant: -.longInnerSpacer)

        
        NSLayoutConstraint.activate([
            firstLineStackViewTopAnchor,
            firstLineStackView.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .nestedSpacer),
            
            secondLineStackViewBottomAnchor,
            secondLineStackView.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .nestedSpacer),
            
            firstLineBoldLabelTopAnchor,
            firstLineBoldLeadingLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .nestedSpacer - 1),
            
            secondLineBoldLabelBottomAnchor,
            secondLineBoldLeadingLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .nestedSpacer - 1),

        ])
    }
    
    //MARK: Animate text method.
     func animateText(){
         UIView.animate(withDuration: 0.5, delay: 0, animations: { [weak self] in
             guard let self = self else { return }
             self.firstLineLeadingLabel.alpha = 0
             self.firstLineBoldLeadingLabel.alpha = 1
             self.secondLineLeadingLabel.alpha = 0
             self.secondLineBoldLeadingLabel.alpha = 1

             self.firstLineSeparatorLabel.textColor = .systemRed
             self.secondLineSeparatorLabel.textColor = .systemRed
             self.secondLineSeparatorLastLabel.textColor = .systemBlue
             
         }, completion: { [weak self ] _ in
             guard let self = self else { return }
             UIView.animate(withDuration: 0.3, delay: 0.5) {
                 self.firstLineStackViewTopAnchor.constant = .nestedSpacer
                 self.secondLineStackViewBottomAnchor.constant = -.nestedSpacer
                 self.firstLineBoldLabelTopAnchor.constant = .nestedSpacer
                 self.secondLineBoldLabelBottomAnchor.constant = -.nestedSpacer
                 
                 self.firstLineStackView.spacing = .nestedSpacer
                 self.secondLineStackView.spacing = .nestedSpacer
                 self.layoutIfNeeded()
             }
         })
     }
    
    //MARK: Update separator.
    //Passing new separator from parent view. Updating allText properties and replacing separators, if the've appeared on a screen.
    func updateSeparatorWith(_ separator: String){
        self.separator = separator
        
        firstLineSeparatorLabel.text =      separator
        secondLineSeparatorLabel.text =     separator
        secondLineSeparatorLastLabel.text = separator
    }
    
   //MARK: Configurator method for labels
    private func configureLabelWith(text: String) -> UILabel{
        let label = UILabel()
        label.text = text
        label.font = .helveticaNeue.withSize(15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
