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
struct InsetsForLabel {
    var top = 15.0
    var wordSide = 15.0
    var transSide = 10.0
    var transBottom = 10.0
}

class CollectionViewCell: UICollectionViewCell {

    var insets = InsetsForLabel()
    
    var staticCardSize : CGSize!
    
    var word: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Georgia-BoldItalic", size: 20)
        label.numberOfLines = 0
        label.textColor = .black
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
        label.font = UIFont(name: "Georgia-Italic", size: 17)
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.text = "???"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        return label
    }()
    
    let cardView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 9
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var cardShadowView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
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
            
            word.topAnchor.constraint(equalTo: cardView.topAnchor, constant: insets.top),
            word.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            word.widthAnchor.constraint(equalTo: cardView.widthAnchor, constant: -insets.wordSide * 2),
            word.bottomAnchor.constraint(lessThanOrEqualTo: cardView.topAnchor, constant: 200),
                            
            translation.topAnchor.constraint(equalTo: word.bottomAnchor, constant: insets.top),
            translation.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            translation.widthAnchor.constraint(equalTo: cardView.widthAnchor, constant: -insets.transSide * 2),
            translation.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -insets.transBottom)
        ])
            
    }
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        cardShadowView.layer.shadowOffset = CGSize(
            width: (layoutAttributes.frame.width - staticCardSize.width) / 4 ,
            height: ( layoutAttributes.frame.height - staticCardSize.height) / 3)
    }
        
    func configure(with data: DataForCells){
        word.text = data.word
        translation.text = data.translation
        
    }
    
}
