//
//  SeparatorsExampleView.swift
//  Language
//
//  Created by Star Lord on 17/08/2023.
//

//in this view we have a lot of labels, just for the purpose of more controll on their appearence and position. By assigning text value to the CLTypingLabel we triggering its typing animation. So we need each to start after previous.
import UIKit
import CLTypingLabel

class SeparatorsExampleView: UIView {
    
    private var separator: String?
    
    //MARK: Views
    private var textForFirstLine: [String] = []
    private var textForSecondLine: [String] = []
    
    private let firstLineStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalSpacing
        view.spacing = 0
        return view
    }()
    private let secondLineStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 0
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
    
    private lazy var firstLineLeadingLabel: CLTypingLabel = configureLabel()
    private lazy var firstLineTrailingLabel: CLTypingLabel = configureLabel()
    private lazy var firstLineSeparatorLabel: CLTypingLabel = configureLabel()
    
    private lazy var secondLineLeadingLabel: CLTypingLabel = configureLabel()
    private lazy var secondLineSeparatorLabel: CLTypingLabel = configureLabel()
    private lazy var secondLineMiddleLabel: CLTypingLabel = configureLabel()
    private lazy var secondLineSeparatorLastLabel: CLTypingLabel = configureLabel()
    private lazy var secondLineTrailingLabel: CLTypingLabel = configureLabel()

    //In order to draw user's attention, we need to change attributes of some text, which is impossible to be smooth, so we revieling bold version behind original.
    private lazy var firstLineBoldLeadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeueBold.withSize(15)
        label.text = self.textForFirstLine[0]
        label.alpha = 0
        return label
    }()
    private lazy var secondLineBoldLeadingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeueBold.withSize(15)
        label.text = self.textForSecondLine[0]
        label.alpha = 0
        return label
    }()
    
    //MARK: Constaints and related
    private var firstLineStackViewTopAnchor: NSLayoutConstraint!
    private var firstLineBoldLabelTopAnchor: NSLayoutConstraint!
    
    private var secondLineStackViewBottomAnchor: NSLayoutConstraint!
    private var secondLineBoldLabelBottomAnchor: NSLayoutConstraint!
    
    //MARK: - Inherited
    init(frame: CGRect, separator: String){
        self.separator = separator
        super.init(frame: frame)
        configureView()
        configureExampleText()
        configureExampleSubviews()
        animateText()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Coder wasn't imported")
    }
    //MARK:  View setUp
    private func configureView(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.secondarySystemBackground
//        ((traitCollection.userInterfaceStyle == .dark)
//                                ? UIColor.secondarySystemBackground
//                                : UIColor.clear)
        self.layer.cornerRadius = 9
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true
    }
    
    //MARK:  ExampleSubviews SetUp.
    //View containt 3 stackViews and 2 label outside of the stack.
    //Labels are used to initate smooth transition to bold version for first labels in Stacks.
    //In order to visualy separate "separators" labels, we passing another stackView, which won't change its spacing.
    private func configureExampleSubviews(){
        self.addSubviews(firstLineBoldLeadingLabel, secondLineBoldLeadingLabel, firstLineStackView, secondLineStackView)
        
        firstLineStackView.addArrangedSubviews(firstLineLeadingLabel, firstLineSeparatorLabel, firstLineTrailingLabel)
        secondLineTrailingStackView.addArrangedSubviews(secondLineMiddleLabel, secondLineSeparatorLastLabel, secondLineTrailingLabel)
        secondLineStackView.addArrangedSubviews(secondLineLeadingLabel, secondLineSeparatorLabel, secondLineTrailingStackView)
        
        firstLineBoldLabelTopAnchor = firstLineBoldLeadingLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14.5)
        secondLineBoldLabelBottomAnchor = secondLineBoldLeadingLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15.5)
        
        firstLineStackViewTopAnchor = firstLineStackView.topAnchor.constraint(equalTo: topAnchor, constant: 15)
        secondLineStackViewBottomAnchor = secondLineStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15)
        
        
        NSLayoutConstraint.activate([
            firstLineBoldLabelTopAnchor,
            firstLineBoldLeadingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 9.5),
            
            secondLineBoldLabelBottomAnchor,
            secondLineBoldLeadingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 9.5),
            
            firstLineStackViewTopAnchor,
            firstLineStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
            secondLineStackViewBottomAnchor,
            secondLineStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            
        ])
    }
    
    //MARK: Animate text method.
    //Due to the usage of CLTypingLabel, when we assigning text, it will automaticaly start it's typing animation. So we use secuence to trigger animation successively.
    private func animateText(){
        
        firstLineLeadingLabel.text = textForFirstLine[0]
        
        firstLineLeadingLabel.onTypingAnimationFinished = { [weak self] in
            self?.firstLineSeparatorLabel.text = self?.textForFirstLine[1]
        }
        firstLineSeparatorLabel.onTypingAnimationFinished = { [weak self] in
            self?.firstLineTrailingLabel.text = self?.textForFirstLine[2]
            self?.firstLineSeparatorLabel.onTypingAnimationFinished = {}
            self?.firstLineSeparatorLabel.charInterval = 0.15
        }
        firstLineTrailingLabel.onTypingAnimationFinished = { [weak self] in
            self?.secondLineLeadingLabel.text = self?.textForSecondLine[0]
        }
        secondLineLeadingLabel.onTypingAnimationFinished = { [weak self] in
            self?.secondLineSeparatorLabel.text = self?.textForSecondLine[1]
        }
        secondLineSeparatorLabel.onTypingAnimationFinished = { [weak self] in
            self?.secondLineMiddleLabel.text = self?.textForSecondLine[2]
            self?.secondLineSeparatorLabel.onTypingAnimationFinished = {}
            self?.secondLineSeparatorLabel.charInterval = 0.15
        }
        secondLineMiddleLabel.onTypingAnimationFinished = { [weak self] in
            self?.secondLineSeparatorLastLabel.text = self?.textForSecondLine[3]
        }
        secondLineSeparatorLastLabel.onTypingAnimationFinished = { [weak self] in
            self?.secondLineTrailingLabel.text = self?.textForSecondLine[4]
            self?.secondLineSeparatorLastLabel.onTypingAnimationFinished = {}
            self?.secondLineSeparatorLastLabel.charInterval = 0.15

        }
        secondLineTrailingLabel.onTypingAnimationFinished = { [weak self] in
            UIView.animate(withDuration: 0.4) {
                self?.firstLineStackViewTopAnchor.constant -= 5
                self?.secondLineStackViewBottomAnchor.constant += 5
                self?.firstLineBoldLabelTopAnchor.constant -= 5
                self?.secondLineBoldLabelBottomAnchor.constant += 5
                //
                UIView.animate(withDuration: 0.5) {
                    self?.firstLineLeadingLabel.alpha = 0
                    self?.firstLineBoldLeadingLabel.alpha = 1
                    self?.secondLineLeadingLabel.alpha = 0
                    self?.secondLineBoldLeadingLabel.alpha = 1
                }
                self?.layoutIfNeeded()
                
            } completion: { _ in
                self?.firstLineSeparatorLabel.textColor = .systemRed
                self?.secondLineSeparatorLabel.textColor = .systemRed
                self?.secondLineSeparatorLastLabel.textColor = .systemBlue
                
                UIView.animate(withDuration: 0.3, delay: 0.5) {
                    self?.firstLineStackView.spacing = 15
                    self?.secondLineStackView.spacing = 15
                }
            }
        }
    }
    //MARK: Configuring all textProperties
    private func configureExampleText(){
        self.textForFirstLine = [
            "World ",
            "\(separator ?? "")",
            " good place to live."
        ]
        self.textForSecondLine = [
            "Apple ",
            "\(separator ?? "")",
            " red as well as ",
            "\(separator ?? "")",
             " sweet."
        ]
    }
    //MARK: Update separator.
    //Passing new separator from parent view. Updating allText properties and replacing separators, if the've appeared on a screen.
    func updateSeparatorWith(_ separator: String){
        self.separator = separator
        configureExampleText()
        if !firstLineSeparatorLabel.text.isEmpty{
            firstLineSeparatorLabel.text = "\(separator)"
        }
        if secondLineSeparatorLabel.text != nil {
            secondLineSeparatorLabel.text = "\(separator)"
        }
        if secondLineSeparatorLastLabel.text != nil {
            secondLineSeparatorLastLabel.text = "\(separator)"
        }
    }
    //MARK: Configurator method for labels
    private func configureLabel() -> CLTypingLabel{
        let label = CLTypingLabel()
        label.charInterval = 0.07
        label.font = .helveticaNeue.withSize(15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
