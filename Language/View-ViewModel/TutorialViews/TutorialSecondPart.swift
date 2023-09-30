//
//  TutorialSecondPart.swift
//  Language
//
//  Created by Star Lord on 22/09/2023.
//

import UIKit


protocol TutorialSecondPartDelegate: AnyObject{
    func activateKeyboard()
}

class TutorialSecondPart: UIViewController {
    
    //MARK: Properties
    private var numberOfViews = 6
    private var currentViewIndex: Int = 3
    
    private weak var delegate: TutorialSecondPartDelegate?

    //MARK: Views
    //View for background dimming i
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    //View, which holds replace main view of the controller for custom appearence animation.
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 13
        view.clipsToBounds = true
        view.backgroundColor = .systemBackground_Secondary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //Views with information labels.
    private var firstView = TutorialInformationView(
        titleText: nil,
        mainText: "tutorial.fourthViewLabel"
    )
    private var secondView = TutorialInformationView(
        titleText: nil,
        mainText: "tutorial.fifthViewLabel"
    )
    private var thirdView = TutorialInformationView(
        titleText: nil,
        mainText: "tutorial.sixthViewLabel"
    )
    
    //View with buttons and pageController.
    private lazy var accessView = TutorialAccessView(
        pagesNumber: numberOfViews,
        currentPage: currentViewIndex,
        delegate: self
    )
    
    //MARK: Dimensions
    //Properties for container layout.
    private var containerInitialBottomConstant:     CGFloat!
    private var containerFinalBottomConstant:       CGFloat!
    private var containerBottomAnchor:              NSLayoutConstraint!

    //Properties for subviews animation.
    private var firstViewLeadingAnchor: NSLayoutConstraint!
    private var nextButBottomToContainer:      NSLayoutConstraint!
    

    private let subviewsInset = CGFloat(25)
    
    //Value for container view final constant
    private var textViewBottomAnchor: CGFloat = 0
    
    
    //MARK: Inherited
    init(delegate: TutorialSecondPartDelegate?, textViewBottom: CGFloat) {
        self.textViewBottomAnchor = textViewBottom
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        configureController()
        configureContainerView()
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        presentViewController()
    }


    //MARK: Subviews SetUP
    private func configureController(){
        view.backgroundColor = .clear
        containerInitialBottomConstant = view.bounds.height
        containerFinalBottomConstant = containerInitialBottomConstant - (containerInitialBottomConstant - textViewBottomAnchor - 10)
    }
    
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

    func configureSubviews(){
        self.containerView.addSubviews(accessView, firstView, secondView, thirdView)
        
        firstViewLeadingAnchor = firstView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
        
        nextButBottomToContainer = accessView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -(containerFinalBottomConstant + 40) )

        
        NSLayoutConstraint.activate([
            accessView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            accessView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nextButBottomToContainer,
            accessView.heightAnchor.constraint(equalToConstant: 40),

            firstView.topAnchor.constraint(equalTo: containerView.topAnchor),
            firstViewLeadingAnchor,
            firstView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            firstView.bottomAnchor.constraint(equalTo: accessView.topAnchor),
            
            secondView.topAnchor.constraint(equalTo: containerView.topAnchor),
            secondView.leadingAnchor.constraint(equalTo: firstView.trailingAnchor),
            secondView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            secondView.bottomAnchor.constraint(equalTo: accessView.topAnchor),
            
            thirdView.topAnchor.constraint(equalTo: containerView.topAnchor),
            thirdView.leadingAnchor.constraint(equalTo: secondView.trailingAnchor),
            thirdView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            thirdView.bottomAnchor.constraint(equalTo: accessView.topAnchor),
            
        ])
    }
    
    //MARK: Animations
    ///Animate appearence of  container view and dimming the background
    private func presentViewController(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.animateTransition(newValue: self.containerFinalBottomConstant)
            self.animateDimmedView()
        })
    }

    ///Changing opacity for dimming view
    private func animateDimmedView(){
        UIView.animate(withDuration: 0.4) {
            self.dimView.alpha = 0.4
        }
    }

    ///Changing layout of container view by applying passed value as a constant.
    private func animateTransition(newValue: CGFloat) {
        UIView.animate(withDuration: 0.5, delay: 0){
            self.containerBottomAnchor.constant = newValue
            
            self.nextButBottomToContainer.constant = -(newValue + self.subviewsInset)
            self.view.layoutIfNeeded()
        }
    }

    ///Animating container view and changing opacity for dimming view
    private func animateViewDismiss() {
        var viewDismiss = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut){ [weak self] in
            guard let self = self else { return }
        
            self.dimView.alpha = 0
            self.containerBottomAnchor.constant = self.containerInitialBottomConstant
            self.delegate?.activateKeyboard()
            self.view.layoutIfNeeded()
        }
        viewDismiss.addCompletion { _ in
            self.dismiss(animated: false)
        }
        viewDismiss.startAnimation()
    }
}

//MARK: AccessViewDelegate
extension TutorialSecondPart: AccessViewDelegate {
    func didTapNextButton(with pointerOn: Int) {
        currentViewIndex += 1
        if currentViewIndex == numberOfViews {
            self.animateViewDismiss()
            return
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.firstViewLeadingAnchor.constant -= self.containerView.bounds.width
                self.view.layoutIfNeeded()
            })
            
        }
    }
    func didTapSkipButton() {
        self.animateViewDismiss()
    }
}
    


