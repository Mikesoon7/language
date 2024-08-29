//
//  TestCell.swift
//  Language
//
//  Created by Star Lord on 21/03/2023.
//

import UIKit

enum Section: CaseIterable{
    case cards
}

class CollectionViewCell: UICollectionViewCell {
    
    //MARK: Properties
    let initialShadowValue = CGSize(width: 2, height: 2)
    var finalShadowValue = CGSize()
    let shadowOpacity = Float(0.3)
    
    private let subviewsInsets: CGFloat = 10
    private var staticCardSize = CGSize()
    
    //MARK: Views
    var word: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(20)
        label.numberOfLines = 0
        label.textColor = .label
        label.text = ""
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        return label
    }()
    var translation: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(17)
        label.numberOfLines = 0
        label.textColor = .label
        
        label.text = ""
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.9
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        return label
    }()
    let translationTestLabel: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(17)
        label.numberOfLines = 0
        label.textColor = .label
//        label.transform = CGAffineTransform(scaleX: -1, y: 1)
        label.text = ""
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.9
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.alpha = 0
        return label
    }()

    let backView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 13
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let cardView : UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground_Secondary
        view.layer.cornerRadius = 13
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let cardShadowView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
    
        view.layer.shadowRadius = 5.0
        return view
    }()
    
    private var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.spacing = 10.0
        view.distribution = .fillProportionally
        
        view.axis = .vertical
        view.alignment = .center
        return view
    }()
    
    //MARK: Inherited
    override init(frame: CGRect) {
        super.init(frame: frame)
        cardViewCustomiation()
        staticCardSize = CGSize(width: UIWindow().frame.width * 0.64, height: UIWindow().frame.height * 0.48)
    }
    required init?(coder: NSCoder) {
        fatalError("Faild to present cells")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        word.isHidden = true
        translation.isHidden = true
        
        self.gestureRecognizers = nil
    }
    
    
    //MARK: Configure subviews.
    ///Assigning passed values to labels and asks stackView to layout subviews.
    func configure(with data: WordsEntity){
        word.text = data.word
        word.isHidden = false
        word.font = .selectedFont.withSize(20)
        translation.font = .selectedFont.withSize(17)
        // Set the visibility based on whether there is a meaning to display
        if !data.meaning.isEmpty {
            translationTestLabel.text = data.meaning
            translation.text = data.meaning
            translation.isHidden = false
        } else {
            translation.isHidden = true
        }
    }

    private func configureStackView(){
        cardView.addSubview(stackView)
        
        stackView.addArrangedSubviews(word, translation)

        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: subviewsInsets),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: subviewsInsets),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -subviewsInsets),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -subviewsInsets),

        ])
    }
    
//    private func configureLabels(){
//        cardView.addSubviews(word, translation)
//        
//        NSLayoutConstraint.activate([
//            word.topAnchor.constraint(equalTo: cardView.topAnchor, constant: subviewsInsets),
//            word.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: subviewsInsets),
//            word.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -subviewsInsets),
//            word.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -subviewsInsets),
//            
//            translation.topAnchor.constraint(lessThanOrEqualTo: word.bottomAnchor, constant: subviewsInsets),
//            translation.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: subviewsInsets),
//            translation.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -subviewsInsets),
//            translation.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -subviewsInsets),
//        ])
//    }

    private func cardViewCustomiation(){
//        self.backView.addSubview(translationTestLabel)
        self.contentView.addSubview(cardShadowView)
        cardShadowView.layer.shadowOpacity = shadowOpacity
        cardShadowView.layer.shadowOffset = initialShadowValue
        cardShadowView.addSubview(cardView)
        cardView.addSubview(translationTestLabel)
        
        contentView.backgroundColor = .systemBackground
        
        
        NSLayoutConstraint.activate([
            cardShadowView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            cardShadowView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            cardShadowView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            cardShadowView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            

//            backView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
//            backView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
//            backView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
//            backView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            translationTestLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            translationTestLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            translationTestLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            translationTestLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            cardView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            cardView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            cardView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
        ])
        configureStackView()
    }
    
    //MARK: Other
    ///Changing shadows appearence to reflect change in size and position of the cell. Dynamic Shadows.
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let size = CGSize(
            width: max(((layoutAttributes.frame.width - staticCardSize.width) / 4) , initialShadowValue.width),
            height: max(((layoutAttributes.frame.height - staticCardSize.height) / 3), initialShadowValue.height))
        if cardShadowView.layer.shadowOffset == initialShadowValue {
            UIView.animate(withDuration: 0.2, delay: 0) {
                self.cardShadowView.layer.shadowOffset = size
            }
        } else {
            cardShadowView.layer.shadowOffset = size

        }
        if finalShadowValue.width < size.width{
            finalShadowValue = size
        }
    }
        
}
