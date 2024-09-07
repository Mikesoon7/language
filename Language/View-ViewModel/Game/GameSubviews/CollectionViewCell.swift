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
    let shadowOpacity = Float(0.1)
    
    var isFlipped = false
    var isAccessable = false
    
    var oneSideMode = false {
        didSet {
            print(oneSideMode)
        }
    }
    
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
        label.transform = CGAffineTransform(scaleX: -1, y: 1)
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
        view.layer.shouldRasterize = false
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let cardShadowViewTest : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        view.layer.shadowRadius = 40.0
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
        translationTestLabel.isHidden = true
        isFlipped = false
        self.gestureRecognizers = nil
    }
    
    
    //MARK: Configure subviews.
    ///Assigning passed values to labels and asks stackView to layout subviews.
    func configure(with data: WordsEntity, oneSideMode: Bool){
        self.oneSideMode = oneSideMode
        word.text = data.word
        word.isHidden = false
        word.font = .selectedFont.withSize(20)
        translation.font = .selectedFont.withSize(17)
        // Set the visibility based on whether there is a meaning to display
        if !data.meaning.isEmpty {
            translationTestLabel.text = data.meaning
            translation.text = data.meaning
            isAccessable = true
            translation.isHidden = false
            translationTestLabel.isHidden = false
        } else {
            isAccessable = false
            translation.isHidden = true
            translationTestLabel.isHidden = true
        }
        configureTextDisplay()
    }
    private func configureTextDisplay(){
        print("already setting up")
        if oneSideMode {
            configureStackView()
        } else {
            cardView.addSubview(word)
            NSLayoutConstraint.activate([
                        word.topAnchor.constraint(equalTo: cardView.topAnchor, constant: subviewsInsets),
                        word.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: subviewsInsets),
                        word.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -subviewsInsets),
                        word.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -subviewsInsets),
            ])
        }
    }

    private func configureStackView(){
        cardView.addSubview(stackView)
        
        stackView.addArrangedSubviews(word, translation)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            stackView.widthAnchor.constraint(lessThanOrEqualToConstant: contentView.bounds.width - subviewsInsets * 2 ),
            stackView.heightAnchor.constraint(lessThanOrEqualToConstant: contentView.bounds.height - subviewsInsets * 2 )
            
//            stackView.topAnchor.constraint(greaterThanOrEqualTo: cardView.topAnchor, constant: subviewsInsets ),
////            equalTo: cardView.topAnchor, constant: subviewsInsets),
//            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: subviewsInsets),
//            stackView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -subviewsInsets),
//            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -subviewsInsets),

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
//        self.contentView.addSubview(cardShadowView)
//        cardShadowView.layer.shadowOpacity = shadowOpacity
//        cardShadowView.layer.shadowOffset = initialShadowValue
//        cardShadowView.addSubview(cardView)
//        cardView.addSubview(translationTestLabel)
        self.contentView.addSubview(cardShadowViewTest)
        cardShadowViewTest.layer.shadowOpacity = 0.1
        cardShadowViewTest.addSubview(cardView)
        cardView.addSubview(translationTestLabel)

        contentView.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
//            cardShadowView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
//            cardShadowView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
//            cardShadowView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
//            cardShadowView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            cardShadowViewTest.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            cardShadowViewTest.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            cardShadowViewTest.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            cardShadowViewTest.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),

//            backView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
//            backView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
//            backView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
//            backView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
//            translationTestLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
//            translationTestLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
//            translationTestLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
//            translationTestLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            translationTestLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: subviewsInsets),
            translationTestLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: subviewsInsets),
            translationTestLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -subviewsInsets),
            translationTestLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -subviewsInsets),

            cardView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            cardView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            cardView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
        ])
//        configureTextDisplay()
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
