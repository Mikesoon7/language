//
//  TutorialVC.swift
//  Learny
//
//  Created by Star Lord on 11/02/2025.
//
//REFACTORING STATE: CHECKED

import UIKit

protocol TutorialModifier: AnyObject {
    func displayCellActionView(activate: Bool)
}

class TutorialVCTest: UIViewController {
    
    private weak var delegate: TutorialModifier?
    private var isTutorialAnimated: Bool = false
    
    //MARK: Base view's
    let tutorialLabel: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.subtitleSize)
        label.text = "tutorial".localized
        label.numberOfLines = 0
        label.textAlignment = .left
        label.tintColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.contentInset = .init(top: 0, left: .outerSpacer, bottom: .outerSpacer, right: .outerSpacer)
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        
        view.register(MenuDictionaryCVCell.self, forCellWithReuseIdentifier: MenuDictionaryCVCell.identifier)
        view.register(MenuAddDictionaryCVCell.self, forCellWithReuseIdentifier: MenuAddDictionaryCVCell.identifier)
        return view
    }()
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = .innerSpacer
        return layout
    }()
    
    //MARK: Overlay View's
    //View for background dimming.
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //View, which holds replace main view of the controller for custom appearence animation.
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = .outerCornerRadius
        view.clipsToBounds = true
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = false
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .fill
        view.spacing = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: Example View's
    private var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground_Secondary
        view.layer.cornerRadius = .outerCornerRadius
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        view.layer.shouldRasterize = false
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var exampleTextView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.isFindInteractionEnabled = false
        view.isSelectable = false
        view.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 4, right: 5 )
        view.textAlignment = .center
        view.clipsToBounds = true
        view.backgroundColor = .clear
        view.attributedText = attributedText(stage: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: Text Information View's
    //Views with information labels.
    private var firstView = TutorialInformationView(
        titleText: "tutorial.firstViewLabel.title",
        mainText: "tutorial.firstViewLabel"
    )
    private var secondView = TutorialInformationView(
        titleText: nil,
        mainText: "tutorial.secondViewLabel"
    )
    private var thirdView = TutorialInformationView(
        titleText: nil,
        mainText: "tutorial.thirdViewLabel"
    )
    //Views with information labels.
    private var fourthView = TutorialInformationView(
        titleText: nil,
        mainText: "tutorial.fourthViewLabel"
    )
    private var fifthView = TutorialInformationView(
        titleText: nil,
        mainText: "tutorial.fifthViewLabel"
    )
    
    private var sixthView = TutorialInformationView(
        titleText: nil,
        mainText: "tutorial.translation"
    )
    private var seventhView = TutorialInformationView(
        titleText: nil,
        mainText: "tutorial.sixthViewLabel"
    )
    
    private lazy var tutorialPageViews = [firstView, secondView, thirdView, fourthView, fifthView, sixthView, seventhView]
    
    //MARK: Controll View's
    var newLineButton: UIButton = {
        let button = UIButton()
        button.setUpAccessoryViewButton(image: nil, title: "system.newLine".localized)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        button.contentVerticalAlignment = .center
        button.isUserInteractionEnabled = false
        return button
    }()
    
    var separatorButton: UIButton = {
        let button = UIButton()
        button.setUpAccessoryViewButton(image: nil, title: " - ")
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    var translateButton : UIButton = {
        let button = UIButton()
        button.setUpAccessoryViewButton(image: .init(systemName: "character.phonetic"))
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.masksToBounds = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    //View with buttons and pageController.
    private lazy var accessView = TutorialAccessView(
        pagesNumber: tutorialPageViews.count,
        currentPage: 0,
        delegate: self
    )
    
    //MARK: Dimensions
    //Properties for container animations.
    private var containerViewTopAnchor:         NSLayoutConstraint = .init()
    private var containerViewHeigthAnchor:      NSLayoutConstraint = .init()
    
    private var containerActiveBottomAnchor:    NSLayoutConstraint = .init()
    private var containerActiveTopAnchor:       NSLayoutConstraint = .init()
    private var containerActiveSecondStage:     NSLayoutConstraint = .init()
    private var containerActiveThirdStage:      NSLayoutConstraint = .init()
    
    private var scrollViewTopAnchor:            NSLayoutConstraint = .init()
    private var scrollViewHeightActive:         NSLayoutConstraint = .init()
    
    //Properties for main view animation.
    private var viewTopAnchor:              NSLayoutConstraint = .init()
    private var firstViewLeadingAnchor:     NSLayoutConstraint = .init()
    
    
    
    //MARK: Inherited
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        configureContainerView()
        setUpNewLineView()
        setupScrollView()
        setupStackView()
        setupTutorialViews()
        
        delegate = self
        self.view.backgroundColor = .systemBackground
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustLayoutForSizeClass()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isTutorialAnimated {
            isTutorialAnimated = true
            self.presentViewController()
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            collectionView.subviews.forEach { section in
                section.layer.shadowColor = (traitCollection.userInterfaceStyle == .dark
                                             ? shadowColorForDarkIdiom
                                             : shadowColorForLightIdiom)
            }
        }
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            adjustLayoutForSizeClass()
        }
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
    private func setupCollectionView() {
        view.addSubviews(tutorialLabel, collectionView)
        
        NSLayoutConstraint.activate([
            tutorialLabel.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: 0.9),
            tutorialLabel.topAnchor.constraint(
                equalTo: view.topAnchor, constant: .outerSpacer),
            tutorialLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(
                equalTo: tutorialLabel.bottomAnchor, constant: .outerSpacer),
            collectionView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor)
        ])
    }
    
    
    //MARK: Subviews SetUp
    private func configureContainerView(){
        view.addSubviews(dimView, containerView)
        
        containerViewTopAnchor = containerView.topAnchor.constraint(
            equalTo: view.bottomAnchor)
        containerViewHeigthAnchor = containerView.heightAnchor.constraint(equalTo: view.heightAnchor)
        
        
        containerActiveBottomAnchor = containerView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.outerSpacer)
        containerActiveTopAnchor = containerView.topAnchor.constraint(
            equalTo: tutorialLabel.bottomAnchor, constant: .outerSpacer)
        containerActiveSecondStage = containerView.topAnchor.constraint(
            equalTo: tutorialLabel.bottomAnchor, constant: .outerSpacer * 2 + .largeButtonHeight )
        containerActiveThirdStage = containerView.topAnchor.constraint(
            equalTo: tutorialLabel.bottomAnchor, constant: .outerSpacer * 3 + .largeButtonHeight * 2)
        
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(
                equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            dimView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor),
            dimView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            
            containerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .longInnerSpacer),
            containerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.longInnerSpacer),
            containerViewHeigthAnchor,
            containerViewTopAnchor,
        ])
    }
    private func setUpNewLineView(){
        containerView.addSubviews(newLineButton, separatorButton, translateButton, cardView)
        cardView.addSubview(exampleTextView)
        NSLayoutConstraint.activate([
            
            separatorButton.heightAnchor.constraint(
                equalToConstant: 50),
            separatorButton.widthAnchor.constraint(
                equalToConstant: 50),
            separatorButton.centerXAnchor.constraint(
                equalTo: containerView.centerXAnchor),
            separatorButton.topAnchor.constraint(
                equalTo: containerView.topAnchor, constant: .longOuterSpacer),
            
            newLineButton.heightAnchor.constraint(
                equalToConstant: 50),
            newLineButton.widthAnchor.constraint(
                equalToConstant: 120),
            newLineButton.centerYAnchor.constraint(
                equalTo: separatorButton.centerYAnchor),
            newLineButton.trailingAnchor.constraint(
                equalTo: separatorButton.leadingAnchor, constant: -.outerSpacer),
            
            translateButton.heightAnchor.constraint(
                equalToConstant: 50),
            translateButton.widthAnchor.constraint(
                equalToConstant: 120),
            translateButton.centerYAnchor.constraint(
                equalTo: separatorButton.centerYAnchor),
            translateButton.leadingAnchor.constraint(
                equalTo: separatorButton.trailingAnchor, constant: .outerSpacer),
            
            cardView.heightAnchor.constraint(
                equalTo: containerView.heightAnchor, multiplier: 0.4),
        
            cardView.widthAnchor.constraint(
                equalTo: cardView.heightAnchor, multiplier: 0.66),
            cardView.centerXAnchor.constraint(
                equalTo: containerView.centerXAnchor),
            cardView.topAnchor.constraint(
                equalTo: separatorButton.bottomAnchor, constant: .longOuterSpacer),
            
            exampleTextView.topAnchor.constraint(
                equalTo: cardView.topAnchor, constant: .innerSpacer),
            exampleTextView.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor, constant: .innerSpacer),
            exampleTextView.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor, constant: -.innerSpacer),
            exampleTextView.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor, constant: -.innerSpacer),
        ])
    }
    private func setupScrollView() {
        scrollView.delegate = self
        containerView.addSubviews(accessView, scrollView)
        
        scrollViewTopAnchor = scrollView.topAnchor.constraint(equalTo: containerView.topAnchor)
        scrollViewHeightActive = scrollView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.35, constant: -.outerSpacer)
        
        NSLayoutConstraint.activate([
            accessView.heightAnchor.constraint(
                equalToConstant: 40),
            accessView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor),
            accessView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor),
            accessView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor, constant: -.longInnerSpacer),
            
            scrollView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: accessView.topAnchor),
            scrollViewTopAnchor,
            
        ])
        
    }
    private func setupStackView() {
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }
    
    //MARK: System
    private func setupTutorialViews() {
        for view in tutorialPageViews {
            stackView.addArrangedSubview(view)
            
            NSLayoutConstraint.activate([
                view.heightAnchor.constraint(equalTo: stackView.heightAnchor),
                view.widthAnchor.constraint(equalTo: containerView.widthAnchor)
            ])
        }
    }
    
    private func adjustLayoutForSizeClass() {
        let itemWidth = ((self.view.bounds.width - (.outerSpacer * 2)))
        
        layout.itemSize = CGSize(width: itemWidth, height: .largeButtonHeight)
        layout.minimumLineSpacing = .outerSpacer
        layout.invalidateLayout()
    }
    
    private func attributedText(stage: Int) -> NSAttributedString{
        let word = "Education"
        let definition = " is the process of acquiring knowledge like:"
        let secondDefinition = "skills, values, and habits through teaching, training, or study"
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
                
        switch stage {
        case 1:
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: .bodyTextSize),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.label
            ]
            let boldAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: .bodyTextSize),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.label
            ]
            
            let attributedString = NSMutableAttributedString(string: word, attributes: normalAttributes)
            attributedString.append(NSAttributedString(string: definition, attributes: normalAttributes))
            attributedString.append(NSAttributedString(string: "\n" + secondDefinition, attributes: boldAttributes))
            
            return attributedString
        case 2:
            let boldLargeAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: .bodyTextSize),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.label
            ]
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: .subBodyTextSize),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.label
            ]
            
            let secondAttributedString = NSMutableAttributedString(
                string: word, attributes: boldLargeAttributes)
            secondAttributedString.append(NSAttributedString(
                string: "\n\n" + definition + "\n" + secondDefinition, attributes: normalAttributes))
            return secondAttributedString
        default:
            let highlightedBoldAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: .bodyTextSize),
                .backgroundColor: UIColor.systemBlue.withAlphaComponent(0.5),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.label
            ]
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: .subBodyTextSize),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.label
            ]
            
            let thirdAttributedString = NSMutableAttributedString(string: word, attributes: highlightedBoldAttributes)
            thirdAttributedString.append(NSAttributedString(string: "\n\n" + definition + "\n" + secondDefinition, attributes: normalAttributes))
            
            return thirdAttributedString
        }
        
    }
    
    //MARK: Animations
    private func presentViewController(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            UIView.animate(withDuration: 0.5) {
                self.containerViewTopAnchor.isActive = false
                self.containerViewHeigthAnchor.isActive = false
                self.containerActiveTopAnchor.isActive = true
                self.containerActiveBottomAnchor.isActive = true
                self.view.layoutIfNeeded()
            }
            self.animateDimmedView()
        })
    }
    
    ///Changing opacity for dimming view
    private func animateDimmedView(){
        UIView.animate(withDuration: 0.5) {
            self.dimView.alpha = 0.2
        }
    }
}

//MARK: CollectionViewDelegate
extension TutorialVCTest: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MenuDictionaryCVCell.identifier,
                for: indexPath) as? MenuDictionaryCVCell else {
                return UICollectionViewCell()
            }
            let tutorialData = DataForMenuCell(name: "Tutorial", numberOfCards: 38)
            cell.configureCellWith(data: tutorialData, delegate: self)
            cell.addCenterShadows()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MenuAddDictionaryCVCell.identifier,
                for: indexPath) as? MenuAddDictionaryCVCell
            cell?.addCenterShadows()
            return cell ?? UICollectionViewCell()
        }
    }
}

//MARK: Required Collection Cell Delegate
extension TutorialVCTest: MenuCellDelegate {
    func panningBegan(for cell: UICollectionViewCell)       {}
    
    func panningEnded(active: Bool)                         {}
    
    func deleteButtonDidTap(for cell: UICollectionViewCell) {}
    
    func editButtonDidTap(for cell: UICollectionViewCell)   {}
    
    func shareButtonDidTap(for cell: UICollectionViewCell)  {}
}

//MARK: PageController Delegate
extension TutorialVCTest: AccessViewDelegate {
    ///Depending on tutorial state calls delegate animation methods and animate main changes.
    ///Insuring, that view has a proper layout instructruction with both foward and backward scrolling.
    func didChangeCurrentPage(manually: Bool, with pointerOn: Int) {
        if manually {
            guard pointerOn < tutorialPageViews.count else {
                self.dismiss(animated: true)
                return
            }
            
            let nextOffset = CGPoint(x: scrollView.frame.width * CGFloat(pointerOn), y: 0)
            UIView.animate(withDuration: 0.5, delay: 0.0) {
                self.scrollView.contentOffset = nextOffset
            }
        }
        
        switch pointerOn {
        case 0:
            delegate?.displayCellActionView(activate: false)
            self.containerActiveSecondStage.isActive = false
            self.containerActiveTopAnchor.isActive = true

            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }

        case 1:
            delegate?.displayCellActionView(activate: true)
            self.containerActiveTopAnchor.isActive = false
            self.containerActiveThirdStage.isActive = false
            self.containerActiveSecondStage.isActive = true
            
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        case 2:
            delegate?.displayCellActionView(activate: false)
            self.containerActiveSecondStage.isActive = false
            self.containerActiveTopAnchor.isActive = false
            self.scrollViewHeightActive.isActive = false

            self.containerActiveBottomAnchor.isActive = true
            self.scrollViewTopAnchor.isActive = true

            self.containerActiveThirdStage.isActive = true

            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        case 3:
            self.containerActiveThirdStage.isActive = false
            self.scrollViewTopAnchor.isActive = false
            
            self.scrollViewHeightActive.isActive = true
            self.containerActiveTopAnchor.isActive = true

            self.newLineButton.layer.borderColor = UIColor.label.cgColor
            self.separatorButton.layer.borderColor = UIColor.clear.cgColor
            
            self.exampleTextView.attributedText = attributedText(stage: 1)
            
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        case 4:
            self.newLineButton.layer.borderColor = UIColor.clear.cgColor
            self.separatorButton.layer.borderColor = UIColor.label.cgColor
            self.translateButton.layer.borderColor = UIColor.clear.cgColor

            self.exampleTextView.attributedText = attributedText(stage: 2)

            UIView.animate(withDuration: 0.5) {
                
                self.view.layoutIfNeeded()
            }
        case 5 :
            self.separatorButton.layer.borderColor = UIColor.clear.cgColor
            self.translateButton.layer.borderColor = UIColor.label.cgColor

            self.containerActiveThirdStage.isActive = false
            self.scrollViewTopAnchor.isActive = false
            
            self.containerActiveTopAnchor.isActive = true
            self.scrollViewHeightActive.isActive = true

            self.exampleTextView.attributedText = attributedText(stage: 3)
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }

        case 6 :
            self.scrollViewHeightActive.isActive = false
            self.containerActiveTopAnchor.isActive = false

            self.scrollViewTopAnchor.isActive = true
            self.containerActiveThirdStage.isActive = true

            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        default:
            self.dismiss(animated: true)
        }
    }
    ///Dismiss tutorial view with animation.
    func shouldFinish() {
        self.dismiss(animated: true)
    }
}

//MARK: ScrollView delegate
//Handle user's actions if swipe was prefered over button
extension TutorialVCTest: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = round(self.scrollView.contentOffset.x / view.frame.width)
        accessView.pageDidChange(updatedIndex: Int(pageIndex))
    }
}

//MARK: Tutorial Cell Delegate
extension TutorialVCTest: TutorialModifier{
    func displayCellActionView(activate: Bool) {
        if let cell = collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? MenuDictionaryCVCell {
            cell.activate(activate)
        }
    }
}

