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
    private var word: UILabel = {
        let label = UILabel()
        label.font = .georgianBoldItalic.withSize(20)
        label.numberOfLines = 0
        label.textColor = .label
        label.text = "???"
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        return label
    }()
    private var translation: UILabel = {
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
//        staticCardSize = CGSize(width: UIWindow().frame.width * 0.8, height: UIWindow().frame.height * 0.8)

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
    
    
    //MARK: Configure subviews.
    ///Assigning passed values to labels and asks stackView to layout subviews.
    func configure(with data: WordsEntity){
        word.text = data.word
        if !data.meaning.isEmpty {
            translation.text = data.meaning
            stackView.addArrangedSubview(translation)
        }
        stackView.layoutIfNeeded()
    }

    private func configureStackView(){
        stackView.addArrangedSubviews(word)
        cardView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: subviewsInsets),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: subviewsInsets),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -subviewsInsets),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -subviewsInsets),

        ])
    }
    
    private func cardViewCustomiation(){
        self.contentView.addSubview(cardShadowView)
        cardShadowView.layer.shadowOpacity = shadowOpacity
        cardShadowView.layer.shadowOffset = initialShadowValue
        cardShadowView.addSubview(cardView)
        
        cardView.addSubviews(word, translation)
        
        NSLayoutConstraint.activate([
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
