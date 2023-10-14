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
    private var exception: String?
    private var separator: String
    
    //MARK: Views
    private var textForFirstLine: [String] = []
    private var textForSecondLine: [String] = []
    var firstLineText = String()
    var secondLineText = String()
    
    private let firstLineStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fill
        view.spacing = 0
        view.alignment = .firstBaseline
        return view
    }()
    private let secondLineStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fill
        view.alignment = .firstBaseline
        return view
    }()

    
    private lazy var firstLineException: CLTypingLabel = configureLabel()
    private lazy var firstLineWord: CLTypingLabel = configureLabel()
    private lazy var firstLineSeparator: CLTypingLabel = configureLabel()
    private lazy var firstLineDefinition: CLTypingLabel = configureLabel()
    
    private lazy var secondLineException: CLTypingLabel = configureLabel()
    private lazy var secondLineWord: CLTypingLabel = configureLabel()
    private lazy var secondLineSeparator: CLTypingLabel = configureLabel()
    private lazy var secondLineDefinition: CLTypingLabel = configureLabel()

    
    //MARK: Constraints and related.
//    private var secondLineStackTopAnchor: NSLayoutConstraint!
//    private let contentInset: CGFloat = 10
//
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
    private var secondLineStackTopAnchor: NSLayoutConstraint!
    private let contentInset: CGFloat = 10

//    private var firstLineStackViewTopAnchor: NSLayoutConstraint!
//    private var firstLineBoldLabelTopAnchor: NSLayoutConstraint!
//
//    private var secondLineStackViewBottomAnchor: NSLayoutConstraint!
//    private var secondLineBoldLabelBottomAnchor: NSLayoutConstraint!
    
    //MARK: - Inherited
    init(exception: String, separator: String){
        self.exception = exception
        self.separator = separator
        super.init(frame: .zero)
        configureView()
        configureExampleText()
        configureExampleSubviews()
        animateTextTyping(exception: exception)
//        animateText()
//        animateText(exception: exception)
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
    
    //MARK:  ExampleSubviews SetUp.
    //View containt 3 stackViews and 2 label outside of the stack.
    //Labels are used to initate smooth transition to bold version for first labels in Stacks.
    //In order to visualy separate "separators" labels, we passing another stackView, which won't change its spacing.
    private func configureExampleSubviews(){
//        self.addSubviews(firstLineStackView, firstLineDefinition, secondLineStackView, secondLineSeparator, secondLineDefinition)
//        self.addSubviews(firstLineStackView, secondLineStackView)
        self.addSubviews(firstLineException, secondLineException)

        
        secondLineDefinition.adjustsFontForContentSizeCategory = true
        firstLineDefinition.adjustsFontForContentSizeCategory = true
        firstLineDefinition.contentScaleFactor = 0.5
        secondLineDefinition.contentScaleFactor = 0.5
        
        secondLineException.numberOfLines = 2
        firstLineException.numberOfLines = 2

//        firstLineStackView.addArrangedSubviews(firstLineException, firstLineWord, firstLineSeparator)
//        firstLineStackView.addArrangedSubviews(firstLineException)
//        secondLineStackView.addArrangedSubviews(secondLineException, secondLineWord, secondLineSeparator)
//        secondLineStackView.addArrangedSubviews(secondLineException)


//        secondLineStackTopAnchor = secondLineStackView.topAnchor.constraint(equalTo: firstLineStackView.bottomAnchor, constant: 10)

        secondLineStackTopAnchor = secondLineException.topAnchor.constraint(equalTo: centerYAnchor, constant: 10)

        NSLayoutConstraint.activate([
            firstLineException.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            firstLineException.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            firstLineException.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),
            

            secondLineStackTopAnchor,
            secondLineException.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            secondLineException.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),
        ])
    }
    
    //MARK: Animate text method.
    //Due to the usage of CLTypingLabel, when we assigning text, it will automaticaly start it's typing animation. So we use secuence to trigger animation successively.
//    private func animateText(exception: String){
//        let firstException = textForFirstLine[0]
//            .trimmingCharacters(in: CharacterSet(charactersIn: exception  + exception.uppercased())) + " "
//        let secondException = textForSecondLine[0]
//            .trimmingCharacters(in: CharacterSet(charactersIn: exception  + exception.uppercased())) + " "
//
//        self.firstLineException.text = firstException
//        self.firstLineException.onTypingAnimationFinished = {
//            self.secondLineException.text = secondException
//            self.firstLineException.onTypingAnimationFinished = { }
//        }
//    }
    private func animateTextTyping(exception: String){
        let firstLine = firstLineText.trimmingCharacters(in: CharacterSet(charactersIn: exception + exception.uppercased()))
        let secondLine = secondLineText.trimmingCharacters(in: CharacterSet(charactersIn: exception  + exception.uppercased()))
        
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
//        self.textForFirstLine = [
//            "1 \(separator) First law \(separator) an object will not change \nits motion unless a force acts on it",
//            " \(separator) ",
//            "an object will not change ",
//            "its motion unless a force acts on it."
//        ]
//        self.textForSecondLine = [
//            "2 \(separator) Second law \(separator) the force on an object \nis equal to its mass times its acceleration",
//            " \(separator) ",
//            "the force on an object \n is equal to its mass times its acceleration",
//            "is equal to its mass times its acceleration."
//        ]
    }

    // 1 First law - an object will not change its motion unless a force acts on it"
//    MARK: Update separator.
//    Passing new separator from parent view. Updating allText properties and replacing separators, if the've appeared on a screen.
//    func updateSeparatorWith(_ exception: String){
//        let firstException = textForFirstLine[0].trimmingCharacters(in: CharacterSet(charactersIn: exception)) + " "
//        let secondException = textForSecondLine[0].trimmingCharacters(in: CharacterSet(charactersIn: exception)) + " "
//
//        print(firstException)
//
//        self.firstLineException.text = firstException
//        self.secondLineException.text = secondException
//
//    }
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
        label.font = .helveticaNeue.withSize(15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
}
