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
    
    var initialShadowValue = CGSize(width: 2, height: 2)
    var finalShadowValue = CGSize()
    
    let shadowOpacity = Float(0.3)
    
    var staticCardSize : CGSize!
    
    var word: UILabel = {
        let label = UILabel()
        label.font = .georgianBoldItalic.withSize(20)
        label.numberOfLines = 0
        label.textColor = .label
        label.text = "???"
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        return label
    }()
    var translation: UILabel = {
        let label = UILabel()
        label.font = .georgianItalic.withSize(17)
        label.numberOfLines = 0
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.9
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        return label
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
    lazy var cardShadowView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        view.layer.shadowOpacity = shadowOpacity
        view.layer.shadowOffset = initialShadowValue
        view.layer.shadowRadius = 5.0
        return view
    }()
    
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
        translation.text = nil
        word.text = nil
        self.gestureRecognizers = nil
    }
    func cardViewCustomiation(){
        self.contentView.addSubview(cardShadowView)
        cardShadowView.addSubview(cardView)
        cardView.addSubviews(word, translation)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            cardView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            cardView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
        ])
        
        if translation.text != "" {
            print("word only")
            NSLayoutConstraint.activate([
                word.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
                word.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 5),
                word.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -5),
                word.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -5),
            ])
        } else {
            print("word and text")
            NSLayoutConstraint.activate([
                word.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
                word.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 5),
                word.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -5),
                
                translation.topAnchor.constraint(equalTo: word.bottomAnchor, constant: 20),
                translation.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 5),
                translation.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -5),
                translation.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -5)
            ])
        }
    }
        
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
        
    func configure(with data: WordsEntity){
        word.text = data.word
        translation.text = data.meaning
    }
}
