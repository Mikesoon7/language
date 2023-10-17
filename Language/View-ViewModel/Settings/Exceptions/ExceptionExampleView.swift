//
//  ExceptionExampleView.swift
//  Language
//
//  Created by Star Lord on 11/10/2023.
//

import UIKit
import CLTypingLabel

class ExceptionExampleView: UIView {
    
    //MARK: Properties
    private var exceptionSymbols: String
    private var separatorSymbol : String
    
    private var initialAnimationFinished = false
    
    private lazy var firstLineText = "1 \(separatorSymbol) First law \(separatorSymbol) an object will not change \nits motion unless a force acts on it"
    private lazy var secondLineText = "2 \(separatorSymbol) Second law \(separatorSymbol) the force on an object \nis equal to its mass times its acceleration"
    
    //MARK: Views
    private lazy var firstLineLabel : CLTypingLabel = configureLabel()
    private lazy var secondLineLabel: CLTypingLabel = configureLabel()
    
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
    //MARK:  View setUp
    private func configureView(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.secondarySystemBackground
        self.layer.cornerRadius = 9
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.masksToBounds = true
    }
    
    //MARK: Subviews SetUp.
    private func configureExampleSubviews(){
        self.addSubviews(firstLineLabel, secondLineLabel)
    
        NSLayoutConstraint.activate([
            firstLineLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentInset),
            firstLineLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInset),
            firstLineLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -contentInset),
            
            secondLineLabel.topAnchor.constraint(equalTo: centerYAnchor, constant: contentInset),
            secondLineLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInset),
            secondLineLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -contentInset),
        ])
    }
    
    //MARK: Animate text method.
    //Due to the usage of CLTypingLabel, when we assigning text, it will automaticaly start it's typing animation. So we use secuence to trigger animation successively.
    private func animateTextTyping(exception: String){
        let firstLine = firstLineText.trimmingCharacters(in: CharacterSet(charactersIn: exception + "\n" + exception.uppercased()))
        let secondLine = secondLineText.trimmingCharacters(in: CharacterSet(charactersIn: exception + "\n" + exception.uppercased()))
        
        self.firstLineLabel.text = firstLine
        self.firstLineLabel.onTypingAnimationFinished = {
            self.secondLineLabel.text = secondLine
            self.initialAnimationFinished = true
            self.firstLineLabel.onTypingAnimationFinished = { }
        }
        self.secondLineLabel.onTypingAnimationFinished = { self.initialAnimationFinished = true }
    }

    //MARK: Update separator.
    ///Trims example text with passed exception string. Manualy adding \n symbol and upercased version of a text.
    func updateSeparatorWith(_ exception: String){
        self.exceptionSymbols = exception
        //" " is added to perform typing even with an empty text.
        let firstException = firstLineText
            .trimmingCharacters(in: CharacterSet(charactersIn: exception + "\n" + exception.uppercased())) + " "
        let secondException = secondLineText
            .trimmingCharacters(in: CharacterSet(charactersIn: exception  + "\n" + exception.uppercased())) + " "
        
        if !initialAnimationFinished {
            firstLineLabel.onTypingAnimationFinished = {}
        }
        self.firstLineLabel.text = firstException
        self.secondLineLabel.text = secondException
    }

    
    //MARK: Configurator method for labels
    private func configureLabel() -> CLTypingLabel{
        let label = CLTypingLabel()
        label.charInterval = 0.03
        label.numberOfLines = 2
        label.font = .helveticaNeue.withSize(15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
}
