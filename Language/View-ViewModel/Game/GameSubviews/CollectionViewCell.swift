//
//  Language
//
//  Created by Star Lord on 21/03/2023.
//
//TODO: Polish

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
    
    var imageData: Data?
    
    //MARK: Views
    let cardView : UIView = {
        let view = UIView()
        view.backgroundColor = .systemSecondary_WhiteColour
        view.layer.cornerRadius = .outerCornerRadius
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
    
    let imageView: UIImageView = {
        
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = .cornerRadius
        view.layer.cornerCurve = .continuous
        
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()

    private var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.spacing = 10.0
        view.distribution = .fill
        view.layer.cornerRadius = .cornerRadius
        view.layer.cornerCurve = .continuous
//        view.layer.masksToBounds = true
        view.axis = .vertical
        view.alignment = .fill
        
        view.layer.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5).cgColor
        
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(
            top: .innerSpacer,
            left: .innerSpacer,
            bottom: .innerSpacer,
            right: .innerSpacer
        )

        
        return view
    }()


    //MARK: Labels
    var word: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.subtitleSize)
        label.numberOfLines = 0
        label.textColor = .label
        label.text = ""
        label.textAlignment = .center
        
        label.layer.cornerRadius = .cornerRadius

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
        label.font = .selectedFont.withSize(.bodyTextSize)
        label.numberOfLines = 0
        label.textColor = .label
        
        label.layer.cornerRadius = .cornerRadius

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
        label.font = .selectedFont.withSize(.bodyTextSize)
        label.numberOfLines = 0
        label.textColor = .label
        label.transform = CGAffineTransform(scaleX: -1, y: 1)
        label.text = ""
        
        label.layer.cornerRadius = .cornerRadius
        
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
        imageView.image = nil
        imageData = nil
        
        word.layer.backgroundColor = nil
        translationBacksideLabel.layer.backgroundColor = nil
        self.gestureRecognizers = nil
    }
    
    
    //MARK: Configure subviews.
    ///Assigning passed values to labels and asks stackView to layout subviews.
    func configure(with data: HashableWordsEntity, oneSideMode: Bool){
        self.isOneSideMode = oneSideMode
        
        word.text = data.wordEntity.word
        word.isHidden = false
        
        word.font = .selectedFont.withSize(.subtitleSize)
        translation.font = .selectedFont.withSize(.bodyTextSize)
        
        if let image = data.wordEntity.image {
            self.imageData = image
//            loadImageLazily(from: data.wordEntity, at: indexPath) // ⬅️ new method
        }
//        if let imageData = data.wordEntity.image, let imageDetails = try? JSONDecoder().decode(ImageDetailsCheck.self, from: imageData), let image = imageDetails.image {
//            let processedImage = imageDetails.filterValue.original ? image : image.applyBlackAndWhiteFilter()
//            imageView.image = processedImage
//            imageView.contentMode = imageDetails.contentMode.uiViewContentMode
//        }
        
        
        // Set the visibility based on whether there is a meaning to display
        if !data.wordEntity.meaning.isEmpty {
            if data.globalyFliped {
                translationBacksideLabel.text = data.wordEntity.word
                translation.text = data.wordEntity.word
                word.text = data.wordEntity.meaning
            } else {
                translationBacksideLabel.text = data.wordEntity.meaning
                translation.text = data.wordEntity.meaning
            }
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
    
    func loadImageLazily() {
        guard let imageData = imageData else { return }
        if let imageDetails = try? JSONDecoder().decode(ImageDetailsCheck.self, from: imageData), let image = imageDetails.image {
            let processedImage = imageDetails.filterValue.original ? image : image.applyBlackAndWhiteFilter()
            imageView.image = processedImage
            imageView.contentMode = imageDetails.contentMode.uiViewContentMode
        }
    }
//    func loadImageLazily(from wordEntity: WordsEntity, at indexPath: IndexPath) {
//        let key = wordEntity.word as NSString
//        if let cached = imageCache.object(forKey: key) {
//            self.imageView.image = cached
//            return
//        }
//
//        self.imageView.image = nil // Reset
//
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let imageData = wordEntity.image,
//                  let imageDetails = try? JSONDecoder().decode(ImageDetailsCheck.self, from: imageData),
//                  let image = imageDetails.image else { return }
//
//            let finalImage = imageDetails.filterValue.original ? image : image.applyBlackAndWhiteFilter()
//            self?.imageCache.setObject(finalImage, forKey: key)
//
//            DispatchQueue.main.async {
//                // Ensure cell is still visible and hasn't been reused for another index
//                guard let strongSelf = self,
//                      strongSelf.isRepresenting(wordEntity: wordEntity) else { return }
//
//                strongSelf.imageView.image = finalImage
//            }
//        }
//    }

    
    private func configureTextDisplay(){
        if isOneSideMode {
            configureStackView()
        } else {
            
            cardView.addSubview(word)
            NSLayoutConstraint.activate([
                word.topAnchor.constraint(greaterThanOrEqualTo: cardView.topAnchor, constant: .innerSpacer),
                word.leadingAnchor.constraint(greaterThanOrEqualTo: cardView.leadingAnchor,
                                              constant: .outerSpacer),
                word.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor,
                                               constant: -.outerSpacer),
                word.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor,
                                             constant: -.innerSpacer),
                word.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
                word.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
            ])
            word.layer.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7).cgColor
            translationBacksideLabel.layer.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7).cgColor
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
        cardView.addSubviews(translationBacksideLabel, imageView)

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
            
            
            imageView.topAnchor.constraint(equalTo: cardShadowView.topAnchor, constant: .innerSpacer),
            
            imageView.leadingAnchor.constraint(equalTo: cardShadowView.leadingAnchor, constant: .innerSpacer),
            
            imageView.bottomAnchor.constraint(equalTo: cardShadowView.bottomAnchor, constant: -.innerSpacer),
            
            imageView.trailingAnchor.constraint(equalTo: cardShadowView.trailingAnchor, constant: -.innerSpacer),


        ])
    }
}
