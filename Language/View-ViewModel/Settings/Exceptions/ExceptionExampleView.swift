//
//  ExceptionExampleView.swift
//  Language
//
//  Created by Star Lord on 11/10/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit

class ExceptionExampleView: UIView {
    
    //MARK: Properties
    private var exceptionSymbols: String
    private var separatorSymbol : String
    
    private var firstLabelFinished = false
    private var secondLabelFinished = false
    
    lazy var typingController1: TypingEffectController? = TypingEffectController(label: firstLineLabel, interval: 0.05)
    lazy var typingController2: TypingEffectController? = TypingEffectController(label: secondLineLabel, interval: 0.05)
    
    private lazy var firstLineText = "1 \(separatorSymbol) First law \(separatorSymbol) an object will not change \nits motion unless a force acts on it"
    private lazy var secondLineText = "2 \(separatorSymbol) Second law \(separatorSymbol) the force on an object \nis equal to its mass times its acceleration"
    
    //MARK: Views
    private lazy var firstLineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = ""
        label.font = .helveticaNeue.withSize(15)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    private lazy var secondLineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = ""
        label.font = .helveticaNeue.withSize(15)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    
    //MARK: Constaints and related
    private let contentInset: CGFloat = 10
    
    //MARK: - Inherited
    init(exception: String, separator: String){
        self.exceptionSymbols = exception
        self.separatorSymbol = separator
        super.init(frame: .zero)
        configureView()
        configureExampleSubviews()
        animateTextTyping(exception: exception)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Coder wasn't imported")
    }
    deinit {
        typingController1?.cancelTypingEffect()
        typingController2?.cancelTypingEffect()
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
    
    //MARK: Subviews SetUp.
    private func configureExampleSubviews(){
        self.addSubviews(firstLineLabel, secondLineLabel)
    
        NSLayoutConstraint.activate([
            firstLineLabel.topAnchor.constraint(
                equalTo: topAnchor, constant: .innerSpacer),
            firstLineLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .innerSpacer),
            firstLineLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor, constant: -.innerSpacer),
            
            secondLineLabel.topAnchor.constraint(
                equalTo: centerYAnchor, constant: .innerSpacer),
            secondLineLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .innerSpacer),
            secondLineLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor, constant: -.innerSpacer),
        ])
    }
    
    //MARK: Animate text method.
    private func animateTextTyping(exception: String){
        let firstLine = trim(text: firstLineText, with: exception)
        let secondLine = trim(text: secondLineText, with: exception)
        
        typingController1?.simulateTypingEffectWith(
            text: firstLine, completion: {self.firstLabelFinished = true})
        
        typingController2?.simulateTypingEffectWith(
            text: secondLine, completion: {self.secondLabelFinished = true })
    }
    
    //MARK: Update separator.
    ///Trims example text with passed exception string. Manualy adding \n symbol and upercased version of a text.
    func updateSeparatorWith(_ exception: String){
        self.exceptionSymbols = exception
        
        let firstLine = trim(text: firstLineText, with: exception)
        let secondLine = trim(text: secondLineText, with: exception)

        if secondLabelFinished && firstLabelFinished {
            firstLineLabel.text = firstLine
            secondLineLabel.text = secondLine
        } else {
            typingController1?.updateTypingEffectWith(text: firstLine, completion: {self.firstLabelFinished = true})
            typingController2?.updateTypingEffectWith(text: secondLine, completion: {self.secondLabelFinished = true})
        }
    }
    
    private func trim(text: String, with exception: String) -> String {
        text.trimmingCharacters(in: CharacterSet(charactersIn: exception + "\n" + exception.uppercased())) + " "
    }
}

