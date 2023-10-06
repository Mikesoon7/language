//
//  Tutorial.swift
//  Language
//
//  Created by Star Lord on 20/09/2023.
//

import Foundation
import UIKit

//MARK: Protocol for Binding with MainView
protocol TutorialCellHintProtocol: AnyObject{
    func needToShowHint()
    func stopShowingHint()
    func openAddDictionary()
}

class TutorialVC: UIViewController{
    
    //MARK: Properties
    private var numberOfViews = 6
    private var currentViewIndex: Int = 0
    
    private weak var delegate: TutorialCellHintProtocol?

    //MARK: Views
    
        
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
        view.layer.cornerRadius = 13
        view.clipsToBounds = true
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
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
    
    //View with buttons and pageController.
    private lazy var accessView = TutorialAccessView(
        pagesNumber: numberOfViews,
        currentPage: currentViewIndex,
        delegate: self
    )


    
    //MARK: Dimensions
    //Properties for container animations.
    private var containerInitialBottomConstant:  CGFloat!
    private var containerFinalBottomConstant:   CGFloat!
    private var containerBottomAnchor:    NSLayoutConstraint!
    
    //Properties for main view animation.
    private var viewTopAnchor: NSLayoutConstraint!
    private var firstViewLeadingAnchor: NSLayoutConstraint!
    
    //Safe area insets from parent VC
    private var topInset: CGFloat
    private var bottomInset: CGFloat
    
    
    private let subviewsInset = CGFloat(15)

    //MARK: Inherited
    init(delegate: TutorialCellHintProtocol?, topInset: CGFloat, bottomInset: CGFloat) {
        self.delegate = delegate
        self.topInset = topInset
        self.bottomInset = bottomInset
        super.init(nibName: nil, bundle: nil)
        
        configureController()
        configureContainerView()
        configureMainView()
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentViewController()
    }
    
    //MARK: Subviews SetUp
    private func configureController(){
        view.backgroundColor = .clear
        containerInitialBottomConstant = view.bounds.height
        containerFinalBottomConstant = 0
    }
    
    //MARK: Subviews SetUp
    private func configureContainerView(){
        view.addSubviews(dimView, containerView)
        
        containerBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: containerInitialBottomConstant)
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor),
            containerBottomAnchor,
        ])
    }
    
    func configureMainView(){
        self.view.addSubview(mainView)
        
        viewTopAnchor = mainView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: topInset + 20)
        
        NSLayoutConstraint.activate([
            mainView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            viewTopAnchor,
            mainView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                             constant: -bottomInset - 20),
            mainView.widthAnchor.constraint(equalTo: containerView.widthAnchor,
                                            multiplier: 0.93),
        ])
    }
    func configureSubviews(){
        self.mainView.addSubviews(firstView, secondView, thirdView, accessView)
        
        firstViewLeadingAnchor = firstView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor)
        
        NSLayoutConstraint.activate([
            accessView.heightAnchor.constraint(equalToConstant: 40),
            accessView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            accessView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            accessView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -subviewsInset),
            
            firstView.topAnchor.constraint(equalTo: mainView.topAnchor),
            firstViewLeadingAnchor,
            firstView.widthAnchor.constraint(equalTo: mainView.widthAnchor),
            firstView.bottomAnchor.constraint(equalTo: accessView.topAnchor),
            
            secondView.topAnchor.constraint(equalTo: mainView.topAnchor),
            secondView.leadingAnchor.constraint(equalTo: firstView.trailingAnchor),
            secondView.widthAnchor.constraint(equalTo: mainView.widthAnchor),
            secondView.bottomAnchor.constraint(equalTo: accessView.topAnchor),
            
            thirdView.topAnchor.constraint(equalTo: mainView.topAnchor),
            thirdView.leadingAnchor.constraint(equalTo: secondView.trailingAnchor),
            thirdView.widthAnchor.constraint(equalTo: mainView.widthAnchor),
            thirdView.bottomAnchor.constraint(equalTo: accessView.topAnchor),
            
        ])
    }
    //MARK: Animations
    ///Animate appearence of  container view and dimming the background
    private func presentViewController(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
            self.animateTransition(newValue: self.containerFinalBottomConstant)
            self.animateDimmedView()
        })
    }
    ///Changing opacity for dimming view
    private func animateDimmedView(){
        UIView.animate(withDuration: 0.5) {
            self.dimView.alpha = 0.4
        }
    }
    ///Changing layout of container view by applying passed value as a constant.
    private func animateTransition(newValue: CGFloat){
        UIView.animate(withDuration: 0.5, delay: 0){
            self.containerBottomAnchor.constant = newValue
            self.view.layoutIfNeeded()
        }
    }
    ///Animating container view and changing opacity for dimming view
    private func animateViewDismiss(){
        let viewDismiss = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut){ [weak self] in
            guard let self = self else { return }
            self.dimView.alpha = 0
            self.containerBottomAnchor.constant = self.containerInitialBottomConstant
            self.view.layoutIfNeeded()
        }
        viewDismiss.addCompletion { [weak self] _  in
            self?.dismiss(animated: false)
        }
        viewDismiss.startAnimation()
    }
}

//MARK: AccessViewDelegate.
extension TutorialVC: AccessViewDelegate {
    ///Depending on tutorial state calls delegate animation methods and animate main changes.
    func didTapNextButton(with pointerOn: Int) {
        currentViewIndex += 1
        switch currentViewIndex {
        case 1:
            delegate?.needToShowHint()
            accessView.updateButtonsAppearence()
        case 2: delegate?.stopShowingHint()
        default:
            delegate?.openAddDictionary()
            animateViewDismiss()
        }
        //Changing main view height and revial next text view.
        UIView.animate(withDuration: 0.5, animations: {
            self.viewTopAnchor.constant += 135
            self.firstViewLeadingAnchor.constant -= self.mainView.bounds.width
            self.view.layoutIfNeeded()
        })
    }
    ///Dismiss tutorial view with animation.
    func didTapSkipButton() {
        self.animateViewDismiss()
    }
}
