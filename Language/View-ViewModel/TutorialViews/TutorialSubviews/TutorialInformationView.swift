//
//  TutorialInformationView.swift
//  Language
//
//  Created by Star Lord on 29/09/2023.
//

import UIKit

class TutorialInformationView: UIView {

    private let subviewsVerticalInset = CGFloat(20)
    private let subviewsHorisontalInset = CGFloat(30)
    private var subviewsInset = CGFloat(50)
    
    private let titleText: String?
    private let mainText: String?
    //MARK: Views
    // Charter
    private let topLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Charter-Bold", size: 25)
        label.tintColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let middleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Charter-Roman", size: 21)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.tintColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    private let textStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.spacing = 25
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    //MARK: Inherited
    init(titleText: String?, mainText: String){
        self.titleText = titleText
        self.mainText = mainText
        super.init(frame: .zero)
        configureView()
        configureSubviews()
        configureLabels()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Subviews SetUp
    private func configureView(){
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureSubviews(){
        self.addSubviews(textStack)

        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: topAnchor, constant: subviewsVerticalInset),
            textStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: subviewsHorisontalInset),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -subviewsVerticalInset),
            textStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -subviewsHorisontalInset)
        ])
    }
    
    ///Assigning text properties from initializer. Checking optionality of title label.
    private func configureLabels(){
        self.middleLabel.text = mainText?.localized
        
        guard let title = titleText else {
            textStack.addArrangedSubview(middleLabel)
            return
            
        }
        
        self.topLabel.text = title.localized
        textStack.addArrangedSubviews(topLabel, middleLabel)
    }

}
