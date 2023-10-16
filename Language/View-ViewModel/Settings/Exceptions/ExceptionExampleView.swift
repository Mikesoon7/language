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
    private var exception: String
    private var separator: String
    
    private lazy var firstLineText = "1 \(separator) First law \(separator) an object will not change \nits motion unless a force acts on it"
    private lazy var secondLineText = "2 \(separator) Second law \(separator) the force on an object \nis equal to its mass times its acceleration"
    
    //MARK: Views
    private lazy var firstLineException: CLTypingLabel = configureLabel()
    private lazy var secondLineException: CLTypingLabel = configureLabel()
    
    //MARK: Constaints and related
    private let contentInset: CGFloat = 10
    
    //MARK: - Inherited
    init(exception: String, separator: String){
        self.exception = exception
        self.separator = separator
        super.init(frame: .zero)
        configureView()
        configureExampleText()
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
        self.addSubviews(firstLineException, secondLineException)
    
        NSLayoutConstraint.activate([
            firstLineException.topAnchor.constraint(equalTo: topAnchor, constant: contentInset),
            firstLineException.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInset),
            firstLineException.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -contentInset),
            
            secondLineException.topAnchor.constraint(equalTo: centerYAnchor, constant: contentInset),
            secondLineException.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInset),
            secondLineException.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -contentInset),
        ])
    }
    
    //MARK: Animate text method.
    //Due to the usage of CLTypingLabel, when we assigning text, it will automaticaly start it's typing animation. So we use secuence to trigger animation successively.
    private func animateTextTyping(exception: String){
        let firstLine = firstLineText.trimmingCharacters(in: CharacterSet(charactersIn: exception + "\n" + exception.uppercased()))
        let secondLine = secondLineText.trimmingCharacters(in: CharacterSet(charactersIn: exception + "\n" + exception.uppercased()))
        
        self.firstLineException.text = firstLine
        self.firstLineException.onTypingAnimationFinished = {
            self.secondLineException.text = secondLine
            self.firstLineException.onTypingAnimationFinished = { }
        }
    }

    //MARK: Configuring all textProperties
    private func configureExampleText(){
        firstLineText = "1 \(separator) First law \(separator) an object will not change \nits motion unless a force acts on it"
        secondLineText = "2 \(separator) Second law \(separator) the force on an object \nis equal to its mass times its acceleration"
    }

//    MARK: Update separator.
    ///Trims example text with passed exception string. Manualy adding \n symbol and upercased version of a text.
    func updateSeparatorWith(_ exception: String){
        self.exception = exception
        let firstException = firstLineText
            .trimmingCharacters(in: CharacterSet(charactersIn: exception + "\n" + exception.uppercased())) + " "
        let secondException = secondLineText
            .trimmingCharacters(in: CharacterSet(charactersIn: exception  + "\n" + exception.uppercased())) + " "
        
        self.firstLineException.text = firstException
        self.secondLineException.text = secondException
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
