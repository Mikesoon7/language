//
//  GameDetailsVC.swift
//  Language
//
//  Created by Star Lord on 14/05/2023.
//

import UIKit
import Combine

class GameDetailsVC: UIViewController {
    
    //MARK: - Parent related properties.
    weak var delegate: MainGameVCDelegate?
    var viewModel: GameDetailsViewModel?
    
    var cancellable = Set<AnyCancellable>()
    var navBarTopInset: CGFloat = 100
    
    private let animationView = LoadingAnimation()
    
    //MARK: Views
    let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 13
        view.clipsToBounds = true
        view.backgroundColor = .systemBackground_Secondary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let textView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        
        view.isEditable = false
        view.isSelectable = false
        view.backgroundColor = .clear
        view.font = .helveticaNeueMedium.withSize(18)
        view.tintColor = .label
        return view
    }()
        
    let informationButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(
            UIImage(systemName: "info.circle",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold, scale: .medium)),
            for: .normal
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var editButton:    UIButton = configureButtonWith(title: "system.edit".localized)
    private lazy var deleteButton:  UIButton = configureButtonWith(title: "system.delete".localized)
    private lazy var doneButton:    UIButton = configureButtonWith(title: "system.done".localized)
    
    //MARK: Gestures
    private var wordTapGesture: UITapGestureRecognizer! // For selecting word
    private var viewDismissTapGesture: UITapGestureRecognizer! // Dismiss the view if user taps on dimmedView
    private var viewPanGesture: UIPanGestureRecognizer!
    
    //MARK: Constrait related properties
    private let insetFromBottom: CGFloat = 30
    private var initialAnchorConstant:  CGFloat!
    private var secondAnchorConstant:   CGFloat!
    private var thirdAnchorConstant:    CGFloat!
    private var finalAnchorConstant:    CGFloat!
    private var currentAnchorConstant:  CGFloat!
    
    //Constraits
    private var doneButtonTrailingAnchor:   NSLayoutConstraint!
    private var contentViewBottomAnchor:    NSLayoutConstraint!
    
    private var textViewBottomToContainer:  NSLayoutConstraint!
    private var textViewBottomToKeyboardConstraint: NSLayoutConstraint!
    
    private var deleteBottomToContainer:    NSLayoutConstraint!
    private var editBottomToContainer:      NSLayoutConstraint!
    
    
    //MARK: - Inherited methods
    required init(viewModel: GameDetailsViewModel?){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        controllerCustomization()
        configureContainerView()
        configureActionButtons()
        configureTextView()
        configureGestures()
    }
    override func viewDidAppear(_ animated: Bool) {
        presentViewController()
    }

    private func bind() {
        guard let output = viewModel?.output else { return }
        output
            .sink(receiveValue: { [weak self] output in
                switch output {
                case .error(let error):
                    self?.presentError(error)
                case .shouldPresentAlert(let alert):
                    self?.present(alert, animated: true)
                case .shouldProcceedEditing:
                    self?.textView.text = self?.configureTextFor(editing: true)
                case .shouldEndEditing:
                    self?.textView.text = self?.configureTextFor(editing: false)
                    self?.transitionToEditing(activate: false)
                case .shouldDismissView:
                    self?.animateViewDismiss()

                }
            })
            .store(in: &cancellable)
        
    }
    //MARK: View SetUp
    private func controllerCustomization(){
        view.backgroundColor = .clear
        initialAnchorConstant = view.bounds.height
        secondAnchorConstant = initialAnchorConstant * 0.6
        thirdAnchorConstant = initialAnchorConstant * 0.4
        finalAnchorConstant = navBarTopInset + 5
    }
    
    //MARK: Subviews SetUp
    private func configureContainerView(){
        view.addSubviews(dimView, containerView)
        containerView.addSubview(animationView)
        
        contentViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: initialAnchorConstant)
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor),
            contentViewBottomAnchor,
            
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -animationView.frame.width / 2),
            animationView.heightAnchor.constraint(equalToConstant: animationView.frame.height)
            
        ])
    }

    private func configureTextView(){
        containerView.addSubviews(textView)
        textView.delegate = self
        textView.text = configureTextFor(editing: false)
        
        textViewBottomToContainer = textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -(secondAnchorConstant + insetFromBottom * 2.5))
        textViewBottomToKeyboardConstraint = textView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 15),
            textView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.91),
            textView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            textViewBottomToContainer
        ])
    }
    
    private func configureActionButtons(){
        containerView.addSubviews(deleteButton, editButton, doneButton, informationButton)
        
        doneButtonTrailingAnchor = doneButton.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)
        
        deleteBottomToContainer = deleteButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -(secondAnchorConstant + 40) )
        
        editBottomToContainer = editButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -(secondAnchorConstant + 40))
        
        NSLayoutConstraint.activate([
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            deleteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            deleteBottomToContainer,
            
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            editButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            editBottomToContainer,
            
            doneButton.centerYAnchor.constraint(equalTo: animationView.centerYAnchor),
            doneButtonTrailingAnchor,
            
            informationButton.centerYAnchor.constraint(equalTo: animationView.centerYAnchor),
            informationButton.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -10)
        ])
        editButton.addTarget(self, action: #selector(editButtonDidTap(sender:)), for: .touchUpInside)
        deleteButton.addTarget(self , action: #selector(deleteButtonDidTap(sender:)), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonDidTap(sender: )), for: .touchUpInside)
        informationButton.addTarget(self, action: #selector(informationButtonDidTap(sender: )), for: .touchUpInside)
    }

    
    //MARK: Others
    ///Configure text for textView depending on passed style.
    private func configureTextFor(editing: Bool) -> String{
        viewModel?.configureTexForTextView(isEditing: editing) ?? ""
    }
    ///Configure button by assigning title and font.
    private func configureButtonWith(title: String) -> UIButton{
        let button = UIButton()
        button.configuration = .plain()
        button.setAttributedTitle(.attributedString(string: title, with: .systemBold, ofSize: 15), for: .normal)
        button.configuration?.baseForegroundColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    ///Change buttons layout, making it visible depending on passed boolean.
    private func changeDoneButtonState(activate: Bool){
        UIView.animate(withDuration: 0.2, delay: 0) { [weak self] in
            self?.doneButtonTrailingAnchor.constant = activate ? -(self?.doneButton.frame.width ?? 65) : 0
            self?.informationButton.alpha = activate ? 0 : 1
            self?.view.layoutIfNeeded()
        }
    }

    //MARK: Appearence Animation
    ///Animating container appearence and dimming the background.
    private func presentViewController(){
        animateTransition(newValue: secondAnchorConstant)
        animateDimmedView()
    }
    
    private func animateDimmedView(){
        UIView.animate(withDuration: 0.4) {
            self.dimView.alpha = 0.4
        }
    }
    
    ///Shortcut for switching between Editing and Exploration modes.
    private func transitionToEditing(activate: Bool){
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.textViewBottomToKeyboardConstraint.isActive = activate
            self?.textViewBottomToContainer.isActive = !activate
            self?.view.layoutIfNeeded()
        }
        animateTransition(newValue: activate ? finalAnchorConstant : thirdAnchorConstant )
        viewPanGesture.isEnabled = !activate
        wordTapGesture.isEnabled = !activate
        viewDismissTapGesture.isEnabled = !activate
        textView.isEditable = activate
        changeDoneButtonState(activate: activate)
        if activate{
            textView.becomeFirstResponder()
        } else {
            textView.resignFirstResponder()
        }
    }
    ///Changes bottom anchor of container, updaing layout of subviews if required
    private func animateTransition(newValue: CGFloat){
        UIView.animate(withDuration: 0.5, delay: 0){
            self.contentViewBottomAnchor.constant = newValue
            self.currentAnchorConstant = newValue
            
            self.editBottomToContainer.constant = -(self.currentAnchorConstant + self.insetFromBottom)
            self.deleteBottomToContainer.constant = -(self.currentAnchorConstant + self.insetFromBottom)
            
            if newValue != self.finalAnchorConstant{
                self.textViewBottomToContainer.constant = -(self.currentAnchorConstant + self.insetFromBottom * 2.5)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: Dissapearence Animation
    private func animateViewDismiss(){
        let viewDismiss = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut){
            self.dimView.alpha = 0
            self.contentViewBottomAnchor.constant = self.initialAnchorConstant
            self.view.layoutIfNeeded()
        }
        viewDismiss.addCompletion { _ in
            self.viewModel?.viewWillDissapear()
            self.dismiss(animated: false)
        }
        viewDismiss.startAnimation()
    }
    
    //MARK: Gestures
    ///Settings up and assigning methods to their views.
    private func configureGestures(){
        wordTapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewDidTap(sender:)))
        textView.addGestureRecognizer(wordTapGesture)
        
        viewDismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(sender: )))
        dimView.addGestureRecognizer(viewDismissTapGesture)
        
        viewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(viewDidPan(sender: )))
        view.addGestureRecognizer(viewPanGesture)
    }
}

//MARK: - Actions
extension GameDetailsVC {
    //MARK: Touch events.
    //Recognises the word user tapped
    @objc func textViewDidTap(sender: UITapGestureRecognizer){
        DispatchQueue.main.async(execute: {
            self.animationView.startAnimating()
        })

        let point = sender.location(in: textView)
        var wordRange: UITextRange?
        let errorAnimation: CAKeyframeAnimation = .shakingAnimation()
        
        if let textPosition = textView.closestPosition(to: point){
            if let rightRange = textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection(rawValue: 1)){
                wordRange = rightRange
            } else if let leftRange = textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection(rawValue: 0)){
                wordRange = leftRange
            }
        }
        guard let wordRange = wordRange, let word = textView.text(in: wordRange) else {
            textView.layer.add(errorAnimation, forKey: "animation")
            return
        }
        
        let startPos = textView.offset(from: textView.beginningOfDocument, to: wordRange.start)
        let endPos = textView.offset(from: textView.beginningOfDocument, to: wordRange.end)
        let nsRange = NSMakeRange(startPos, endPos-startPos)
        let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        
        mutableAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        
        let refVC = UIReferenceLibraryViewController(term: word)
        textView.attributedText = mutableAttributedString
        present(refVC, animated: true, completion: { [weak self] in
            self?.animationView.stopAnimating()
        })
    }
    ///Responsible for handling all panning and animations in response.
    @objc func viewDidPan(sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: view).y
        let velocity = sender.velocity(in: view).y
        let newConstant = currentAnchorConstant + translation
        
        switch sender.state{
        case .began, .changed:
            if translation > -50 {
                if translation < 0{
                    deleteBottomToContainer.constant = -(newConstant + insetFromBottom)
                    editBottomToContainer.constant = -(newConstant + insetFromBottom)
                }
                contentViewBottomAnchor.constant = newConstant
                view.layoutIfNeeded()
            }
        case .ended:
            if velocity > 500 {
                animateViewDismiss()
            }  else if ( newConstant > secondAnchorConstant + 50 ||
                         (newConstant > thirdAnchorConstant + 50 && currentAnchorConstant == thirdAnchorConstant ))
                        && translation > 0  {
                animateViewDismiss()
            } else if (newConstant < secondAnchorConstant && newConstant > thirdAnchorConstant)
                        || newConstant < thirdAnchorConstant {
                animateTransition(newValue: thirdAnchorConstant)
            } else if newConstant > secondAnchorConstant {
                animateTransition(newValue: secondAnchorConstant)
            }
        default:
            break
        }
    }
    ///Checks location ot touch. If its outside of container, dismisses the view.
    @objc func handleTapGesture(sender: UITapGestureRecognizer){
        let location = sender.location(in: view)
        if !containerView.frame.contains(location){
            animateViewDismiss()
        }
    }

    //MARK: Buttons actions
    @objc func editButtonDidTap(sender: UIButton){
        textView.text = configureTextFor(editing: true)
        transitionToEditing(activate: true)
    }
    
    @objc func deleteButtonDidTap(sender: UIButton){
        viewModel?.deleteWord()
    }
    
    @objc func doneButtonDidTap(sender: UIButton){
        viewModel?.editWord(with: textView.text)
    }
    
    @objc func informationButtonDidTap(sender: UIButton){
        let vc = InformationView()
        present(vc, animated: true)
    }
}
//MARK: - Delegates
extension GameDetailsVC: UITextViewDelegate{
    ///If user scroll TextView, trigger animation, which will expand view to revieal more content.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if currentAnchorConstant == secondAnchorConstant {
            animateTransition(newValue: thirdAnchorConstant)
        }
    }
}

