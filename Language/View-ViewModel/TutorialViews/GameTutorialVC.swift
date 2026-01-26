//
//  GameTutorialVC.swift
//  Learny
//
//  Created by Star Lord on 15/08/2025.
//
//TODO: Polished

import UIKit

class GameTutorialVC: UIViewController {
    
    private weak var delegate: TutorialModifier?
    private var isTutorialAnimated: Bool = false
    
    private var tutorialViewHeight: CGFloat = .largeButtonHeight - .innerSpacer
    //MARK: Base view's
    let tutorialLabel: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.subtitleSize)
        label.text = "game.tutorial.title".localized
        label.numberOfLines = 0
        label.textAlignment = .left
        label.tintColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let secondaryTutorialLabel: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.subBodyTextSize)
        label.text = "game.tutorial.subtitle".localized
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
        
    }()
    
    //MARK: Content View's
    private lazy var touchCard: UIView = createCardViewWith(text: "game.tutorial.tap".localized, image: UIImage(systemName: "hand.rays") ?? UIImage(systemName: "hand.point.up.left"))
    private lazy var longTouchCard: UIView = createCardViewWith(text: "game.tutorial.press".localized, image: UIImage(systemName: "hand.tap"))
    private lazy var timerCard: UIView = createCardViewWith(text: "game.tutorial.timer".localized, image: nil, textImage: "00:05")
    private lazy var flipCards: UIView = createCardViewWith(text: "game.tutorial.flip".localized, image: UIImage(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90") ?? UIImage(systemName: "arrow.2.circlepath"))

    
        
    //MARK: Layout prop
    private var longTouchCardTopAnchor: NSLayoutConstraint = .init()
    private var timerCardTopAnchor:     NSLayoutConstraint = .init()
    private var revertCardTopAnchor:    NSLayoutConstraint = .init()
    

    
    
    //MARK: Inherited
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLabels()
        setUpTutorialViews()
        
        self.view.backgroundColor = .systemBackground
    }
    
    
    override func viewDidLayoutSubviews() {
        sheetPresentationController?.detents = [.custom(resolver: { context in
            return context.maximumDetentValue * (UIDevice.isDeviceLarge ? 1 : 0.8)
        })]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.animateCardsFalling()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { context in
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    //MARK: Base view's SetUp
    private func setUpLabels() {
        view.addSubviews(tutorialLabel, secondaryTutorialLabel)
        
        NSLayoutConstraint.activate([
            tutorialLabel.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            tutorialLabel.topAnchor.constraint(
                equalTo: view.topAnchor, constant: .outerSpacer),
            tutorialLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            tutorialLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: .outerSpacer),
            
            secondaryTutorialLabel.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            secondaryTutorialLabel.topAnchor.constraint(
                equalTo: tutorialLabel.bottomAnchor, constant: .longInnerSpacer),
            secondaryTutorialLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            
        ])
    }
    
    private func setUpTutorialViews() {
        view.addSubviews(flipCards, timerCard, longTouchCard, touchCard )
        
        longTouchCardTopAnchor  = longTouchCard.topAnchor.constraint(
            equalTo: touchCard.topAnchor)
        timerCardTopAnchor  = timerCard.topAnchor.constraint(
            equalTo: longTouchCard.topAnchor)
        revertCardTopAnchor = flipCards.topAnchor.constraint(
            equalTo: timerCard.topAnchor)
        
        NSLayoutConstraint.activate([
            
            touchCard.topAnchor.constraint(
                equalTo: secondaryTutorialLabel.bottomAnchor, constant: .outerSpacer),
            touchCard.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            touchCard.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            touchCard.heightAnchor.constraint(
                equalToConstant: tutorialViewHeight),
            
            longTouchCard.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            longTouchCard.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            longTouchCard.heightAnchor.constraint(equalToConstant: tutorialViewHeight),
            longTouchCardTopAnchor,
            
            timerCard.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            timerCard.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            timerCard.heightAnchor.constraint(
                equalToConstant: tutorialViewHeight),
            timerCardTopAnchor,
            
            flipCards.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            flipCards.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            flipCards.heightAnchor.constraint(
                equalToConstant: tutorialViewHeight),
            revertCardTopAnchor,
            
            //For expanding the view on the ipad
            flipCards.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.outerSpacer)
        ])
    }
    

    
    //MARK: Animation
    func animateCardsFalling() {
        guard !isTutorialAnimated else { return }
        isTutorialAnimated = true
        
        // Each card and its top constraint for movement
        let cards: [(view: UIView, topConstraint: NSLayoutConstraint?)] = [
            (touchCard, nil),
            (longTouchCard, longTouchCardTopAnchor),
            (timerCard, timerCardTopAnchor),
            (flipCards, revertCardTopAnchor)
        ]
        
        // Starting offset for animation
        let dropDistance: CGFloat = tutorialViewHeight + .outerSpacer
        let baseDelay: TimeInterval = 0.15
        let duration: TimeInterval = 0.5
        
        for (index, card) in cards.enumerated() {
            card.view.alpha = 0
            card.topConstraint?.constant = 0
            UIView.animate(
                withDuration: duration,
                delay: baseDelay * Double(index),
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.curveEaseOut]
            ) {
                card.view.alpha = 1
                card.topConstraint?.constant = dropDistance
                self.view.layoutIfNeeded()
            }
        }
    }

    
    //MARK: System
    private func createCardViewWith(text: String, image: UIImage?, textImage: String? = nil) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .systemGray6.withAlphaComponent(0.9)
        cardView.layer.cornerRadius = 16
        cardView.alpha = 0
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addCenterShadows()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont.selectedFont.withSize(15)
        label.numberOfLines = 0
        label.textColor = .label
        label.adjustsFontSizeToFitWidth = true
        
        let iconView: UIView
        if let image = image {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .label
            imageView.translatesAutoresizingMaskIntoConstraints = false
            iconView = imageView
        } else {
            let timerLabel = UILabel()
            timerLabel.text = textImage
            timerLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            timerLabel.textAlignment = .center
            timerLabel.textColor = .label
            timerLabel.translatesAutoresizingMaskIntoConstraints = false
            iconView = timerLabel
        }
        
        let hStack = UIStackView(arrangedSubviews: [iconView, label])
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = .outerSpacer
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        cardView.addSubview(hStack)
        
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: .longInnerSpacer),
            hStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -.longInnerSpacer),
            hStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: .innerSpacer),
            hStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -.innerSpacer),
            
            iconView.heightAnchor.constraint(equalTo: cardView.heightAnchor, multiplier: 0.5),
            iconView.widthAnchor.constraint(equalTo: cardView.heightAnchor, multiplier: 0.7)
        ])
        
        return cardView
    }
}



