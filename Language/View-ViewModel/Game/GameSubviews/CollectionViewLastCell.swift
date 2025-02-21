//
//  LastCell.swift
//  Language
//
//  Created by Star Lord on 16/03/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit

//MARK: - Data for LastCell
class DataForLastCell: Hashable{
    var identifier = UUID()
    var score : Float
    var delegate : CustomCellDelegate?
    
    init(score: Float, delegate: CustomCellDelegate) {
        self.score = score
        self.delegate = delegate
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: DataForLastCell, rhs: DataForLastCell) -> Bool{
        lhs.identifier == rhs.identifier
    }
}

//MARK: - Protocol for VC pop
protocol CustomCellDelegate: AnyObject{
    func finishButtonTap()
}
//MARK: - CollectionViewCell
class CollectionViewLastCell: UICollectionViewCell {
    
//    private var staticCardSize : CGSize = .init()
    weak var delegate: CustomCellDelegate?
    
    //MARK: Views
    let cardView : UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground_Secondary
        view.layer.cornerRadius = .outerCornerRadius
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let cardShadowTestView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 40.0
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    
    //MARK: Labels
    private let scoreLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .selectedFont.withSize(40)
        label.textColor = .label
        label.text = "???"
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let finishButton : UIButton = {
        let button = UIButton(configuration: .gray())
        button.setUpCustomView()
        button.alpha = 0
        button.layer.borderWidth = 0
        button.transform = CGAffineTransform(scaleX: -1, y: 1)
        button.configuration?.baseBackgroundColor = .init(dynamicProvider: { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return .gray
            } else {
                return .secondarySystemBackground
            }
        })
        return button
    }()
    
    private let complimentLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: -1, y: 1)

        label.textAlignment = .center
        label.font = .selectedFont.withSize(.subtitleSize)
        label.textColor = .label
        label.text = "game.lastCell.congratulations".localized
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let learnedLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: -1, y: 1)

        label.textAlignment = .center
        label.font = .selectedFont.withSize(.subBodyTextSize)
        label.textColor = .label
        label.text = "game.lastCell.checked".localized
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let learnedResultsLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: -1, y: 1)

        label.textAlignment = .center
        label.font = .systemFont(ofSize: .assosiatedTextSize)
        label.textColor = .label
        label.text = "???"
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeSpentLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: -1, y: 1)

        label.textAlignment = .center
        label.font = .selectedFont.withSize(.subBodyTextSize)
        label.textColor = .label
        label.text = "game.lastCell.spending".localized
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let timeSpentResultLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: -1, y: 1)

        label.textAlignment = .center
        label.font = .systemFont(ofSize: .assosiatedTextSize)
        label.textColor = .label
        label.text = "???"
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: -1, y: 1)

        label.textAlignment = .center
        label.font = .selectedFont.withSize(.bodyTextSize)
        label.textColor = .label
        label.text = "???"
        label.numberOfLines = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    //MARK: Inhereted
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCardView()
        configureLabels()
        configureBackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Faild to present cells")
    }
    
    func configure(with data: DataForLastCell){
        scoreLabel.font = .selectedFont.withSize(40)
        scoreLabel.text = "\((data.score).rounded())%"
        delegate = data.delegate
    }

    //MARK: Subviews Configuration
    func configureCardView(){
        self.contentView.addSubview(cardShadowTestView)
        cardShadowTestView.addSubview(cardView)
        cardView.addSubviews(scoreLabel)
        
        NSLayoutConstraint.activate([
            cardShadowTestView.centerXAnchor.constraint(
                equalTo: self.contentView.centerXAnchor),
            cardShadowTestView.centerYAnchor.constraint(
                equalTo: self.contentView.centerYAnchor),
            cardShadowTestView.widthAnchor.constraint(
                equalTo: self.contentView.widthAnchor),
            cardShadowTestView.heightAnchor.constraint(
                equalTo: self.contentView.heightAnchor ),
                        
            cardView.centerXAnchor.constraint(
                equalTo: self.contentView.centerXAnchor),
            cardView.centerYAnchor.constraint(
                equalTo: self.contentView.centerYAnchor),
            cardView.widthAnchor.constraint(
                equalTo: self.contentView.widthAnchor),
            cardView.heightAnchor.constraint(
                equalTo: self.contentView.heightAnchor ),

            scoreLabel.centerXAnchor.constraint(
                equalTo: cardView.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(
                equalTo: cardView.centerYAnchor),
        
        ])
        finishButton.addTarget(self, action: #selector(buttonTap(sender:)), for: .touchUpInside)
    }
    
    func configureBackView(){
        cardView.addSubviews(complimentLabel, learnedLabel, learnedResultsLabel, timeSpentLabel, timeSpentResultLabel, summaryLabel, finishButton )
        
        NSLayoutConstraint.activate([
            complimentLabel.centerXAnchor.constraint(
                equalTo: self.contentView.centerXAnchor),
            complimentLabel.topAnchor.constraint(
                equalTo: self.contentView.topAnchor, constant: .longInnerSpacer),
            
            learnedResultsLabel.leadingAnchor.constraint(
                equalTo: self.contentView.leadingAnchor, constant: .longInnerSpacer),
            learnedResultsLabel.topAnchor.constraint(
                equalTo: self.complimentLabel.bottomAnchor, constant: .longOuterSpacer),
            
            learnedLabel.trailingAnchor.constraint(
                equalTo: self.contentView.trailingAnchor, constant: -.longInnerSpacer),
            learnedLabel.centerYAnchor.constraint(
                equalTo: self.learnedResultsLabel.centerYAnchor ),

            timeSpentResultLabel.leadingAnchor.constraint(
                equalTo: self.contentView.leadingAnchor, constant: .longInnerSpacer),
            timeSpentResultLabel.topAnchor.constraint(
                equalTo: self.learnedLabel.bottomAnchor, constant: .longOuterSpacer),
            
            timeSpentLabel.trailingAnchor.constraint(
                equalTo: self.contentView.trailingAnchor, constant: -.longInnerSpacer),
            timeSpentLabel.centerYAnchor.constraint(
                equalTo: self.timeSpentResultLabel.centerYAnchor ),

            summaryLabel.topAnchor.constraint(
                equalTo: timeSpentLabel.bottomAnchor, constant: .longOuterSpacer),
            summaryLabel.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor),
            summaryLabel.widthAnchor.constraint(
                equalTo: cardView.widthAnchor, multiplier: 0.8),
            
            finishButton.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor, constant: -30 ),
            finishButton.centerXAnchor.constraint(
                equalTo: cardView.centerXAnchor),
            finishButton.heightAnchor.constraint(
                equalTo: cardView.widthAnchor, multiplier: 0.2),
        ])
    }
    
    //MARK: Other
    func flipTheCell(numberOfCards: Int, timeSpent: String, amount: Double? ){
        learnedResultsLabel.text = String(numberOfCards) + " " + "game.lastCell.cards".localized
        timeSpentResultLabel.text = String(timeSpent) + " " + "game.lastCell.min".localized

        var summaryLabelText = String()
        if let amount = amount {
            
            summaryLabelText = "game.lastCell.avarageResult.firstPart".localized
            
            if amount == 0 {
                summaryLabelText += "game.lastCell.same".localized
            } else if amount > 0 {
                summaryLabelText += "\((abs(amount.binade)))%" + " " +  "game.lastCell.faster".localized
            } else {
                summaryLabelText += "\((abs(amount.binade)))%" + " " +  "game.lastCell.slower".localized
            }

            summaryLabelText += "game.lastCell.avarageResult.secondPart".localized
        } else {
            summaryLabelText = "game.lastCell.bestResult".localized
        }
        summaryLabel.text = summaryLabelText
        
        
        let duration = 0.6
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 5000.0
        
        let liftTransform = CATransform3DTranslate(perspective, 0, -50, 0)
        let initialTransfrom = CATransform3DTranslate(perspective, 0, 0, 0)
        
        let halfwayClockwiseTransform  = CATransform3DRotate(perspective, .pi / 2, 0, 1, 0)
        let finalClockwiseTransform    = CATransform3DRotate(perspective, .pi, 0, 1, 0)
                
        let animation = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            UIView.animate(withDuration: duration / 2, animations: {
                self.cardView.layer.transform = CATransform3DConcat(halfwayClockwiseTransform, liftTransform)

                
            }) { _ in
                UIView.animate(withDuration: duration / 2) {
                    self.cardView.layer.transform = CATransform3DConcat(finalClockwiseTransform, initialTransfrom)
                    
                }
            }        }
        animation.addCompletion { _ in
            self.scoreLabel.isHidden = true
            UIView.animateKeyframes(withDuration: 1.5, delay: 0, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
                    self.complimentLabel.alpha = 1
                }
                UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.2) {
                    self.learnedLabel.alpha = 1
                    self.learnedResultsLabel.alpha = 1
                }
                UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.2) {
                    self.timeSpentLabel.alpha = 1
                    self.timeSpentResultLabel.alpha = 1
                }
                UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.2) {
                    self.summaryLabel.alpha = 1
                }
                UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                    self.finishButton.alpha = 1
                }
            })
        }
        animation.startAnimation()

    }
    func configureLabels(){
        self.finishButton.setAttributedTitle(
            .attributedString(
                string: "system.great".localized,
                with: .georgianBoldItalic,
                ofSize: .subtitleSize
            ),
            for: .normal
        )
    }

    //MARK: Actions
    @objc func buttonTap(sender: Any){
        delegate?.finishButtonTap()
    }
}
