//
//  TestCell.swift
//  Language
//
//  Created by Star Lord on 21/03/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit

enum Section: CaseIterable{
    case cards
}

class CollectionViewCell: UICollectionViewCell {
    
    //MARK: Public properties.
    var isFlipped = false
    var isAccessable = false
    
    var isOneSideMode = false
    var shadowOpacity: Float = 0.1
    
    //MARK: Views
    let cardView : UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground_Secondary
        view.layer.cornerRadius = 13
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        view.layer.shouldRasterize = false
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let cardShadowView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        view.layer.shadowRadius = 40.0
        return view
    }()
    
    private var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.spacing = 10.0
        view.distribution = .fill
        
        view.axis = .vertical
        view.alignment = .fill
        return view
    }()


    //MARK: Labels
    var word: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(20)
        label.numberOfLines = 0
        label.textColor = .label
        label.text = ""
        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
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
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    let translationBacksideLabel: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(17)
        label.numberOfLines = 0
        label.textColor = .label
        label.transform = CGAffineTransform(scaleX: -1, y: 1)
        label.text = ""
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.alpha = 0
        return label
    }()

    
    //MARK: Inherited
    override init(frame: CGRect) {
        super.init(frame: frame)
        cardViewCustomiation()
    }
    required init?(coder: NSCoder) {
        fatalError("Faild to present cells")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        word.isHidden = true
        translation.isHidden = true
        translationBacksideLabel.isHidden = true
        self.gestureRecognizers = nil
    }
    
    
    //MARK: Configure subviews.
    ///Assigning passed values to labels and asks stackView to layout subviews.
    func configure(with data: HashableWordsEntity, oneSideMode: Bool){
        self.isOneSideMode = oneSideMode
        word.text = data.wordEntity.word
        word.isHidden = false
        word.font = .selectedFont.withSize(20)
        translation.font = .selectedFont.withSize(17)
        // Set the visibility based on whether there is a meaning to display
        if !data.wordEntity.meaning.isEmpty {
            translationBacksideLabel.text = data.wordEntity.meaning
            translation.text = data.wordEntity.meaning
            isAccessable = true
            translation.isHidden = false
            translationBacksideLabel.isHidden = false
        } else {
            isAccessable = false
            translation.isHidden = true
            translationBacksideLabel.isHidden = true
        }
        configureTextDisplay()
    }
    
    
    private func configureTextDisplay(){
        if isOneSideMode {
            configureStackView()
        } else {
            cardView.addSubview(word)
            NSLayoutConstraint.activate([
                word.topAnchor.constraint(equalTo: cardView.topAnchor, 
                                          constant: .innerSpacer),
                word.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, 
                                              constant: .innerSpacer),
                word.trailingAnchor.constraint(equalTo: cardView.trailingAnchor,
                                               constant: -.innerSpacer),
                word.bottomAnchor.constraint(equalTo: cardView.bottomAnchor,
                                             constant: -.innerSpacer),
            ])
        }
    }

    private func configureStackView(){
        stackView.addArrangedSubviews(word, translation)
        cardView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            
            stackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            
            stackView.widthAnchor.constraint(lessThanOrEqualToConstant:
                                                contentView.bounds.width - .innerSpacer * 2 ),
            stackView.heightAnchor.constraint(lessThanOrEqualToConstant:
                                                contentView.bounds.height - .innerSpacer * 2 )
        ])
    }
    
    private func cardViewCustomiation(){
        self.contentView.addSubview(cardShadowView)
        cardShadowView.layer.shadowOpacity = 0.1
        cardShadowView.addSubview(cardView)
        cardView.addSubview(translationBacksideLabel)

        contentView.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            cardShadowView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            
            cardShadowView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            
            cardShadowView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            cardShadowView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            

            translationBacksideLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                          constant: .innerSpacer),
            translationBacksideLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, 
                                                              constant: .innerSpacer),
            translationBacksideLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, 
                                                               constant: -.innerSpacer),
            translationBacksideLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                             constant: -.innerSpacer),

            cardView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            
            cardView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            
            cardView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            cardView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
        ])
    }
}
