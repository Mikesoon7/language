//
//  GameDetailsVC.swift
//  Language
//
//  Created by Star Lord on 14/05/2023.
//
//  REFACTORING STATE: CHECKED

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
        view.layer.cornerRadius = .outerCornerRadius
        view.clipsToBounds = true
        view.backgroundColor = .systemBackground_Secondary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var textInputView: TextInputView = {
        let view = TextInputView(delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textView.layer.borderColor = UIColor.clear.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowColor = UIColor.clear.cgColor
        view.layer.shadowOpacity = 0
        view.backgroundColor = .clear
        view.textView.font = .helveticaNeueMedium.withSize(.subBodyTextSize)

        view.textView.isEditable = false
        view.textView.isSelectable = false
        return view
    }()
        
    let informationButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(
            UIImage(systemName: "info.circle",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: .titleSize, weight: .semibold, scale: .medium)),
            for: .normal
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var editButton:    UIButton = configureButtonWith(title: "system.edit".localized)
    private lazy var deleteButton:  UIButton = configureButtonWith(title: "system.delete".localized)
    private lazy var doneButton:    UIButton = configureButtonWith(title: "system.done".localized)
    
    //MARK: Gestures
    private var wordTapGesture: UITapGestureRecognizer = .init() // For selecting word
    private var viewDismissTapGesture: UITapGestureRecognizer = .init()
    // Dismiss the view if user taps on dimmedView
    private var viewPanGesture: UIPanGestureRecognizer = .init()
    
    //MARK: Constrait related properties
    private let insetFromBottom: CGFloat = 30
    private var initialAnchorConstant:  CGFloat = 0
    private var secondAnchorConstant:   CGFloat = 0
    private var thirdAnchorConstant:    CGFloat = 0
    private var finalAnchorConstant:    CGFloat = 0
    private var currentAnchorConstant:  CGFloat = 0
    
    //Constraits
    private var doneButtonTrailingAnchor:           NSLayoutConstraint = .init()
    private var doneButtonActiveTrailingAnchor:     NSLayoutConstraint = .init()
    
    private var containerViewBottomAnchor:          NSLayoutConstraint = .init()
    
    private var textViewBottomToContainer:          NSLayoutConstraint = .init()
    private var textViewBottomToKeyboardConstraint: NSLayoutConstraint = .init()
    
    private var deleteBottomToContainer:            NSLayoutConstraint = .init()
    private var editBottomToContainer:              NSLayoutConstraint = .init()
    
    
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
        animationView.stopAnimating()
    }

    private func bind() {
        guard let output = viewModel?.output else { return }
        output
            .sink(receiveValue: { [weak self] output in
                switch output {
                case .error(let error):
                    self?.presentError(error, sourceView: self?.view)
                case .shouldPresentAlert(let alert):
                    self?.present(alert, animated: true)
                case .shouldProcceedEditing:
                    self?.textInputView.textView.text = self?.configureTextFor(editing: true)
                    self?.textInputView.updatePlaceholderVisability()
                case .shouldEndEditing:
                    self?.textInputView.textView.text = self?.configureTextFor(editing: false)
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
        
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: initialAnchorConstant)
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor),
            
            containerViewBottomAnchor,
            
            
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor,
                                               constant: .longInnerSpacer),
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor,
                                                   constant: -animationView.frame.width / 2),
            animationView.heightAnchor.constraint(equalToConstant: animationView.frame.height)
            
        ])
    }

    private func configureTextView(){
        containerView.addSubviews(textInputView)
        textInputView.textView.text = configureTextFor(editing: false)
        
        textInputView.updatePlaceholderVisability()

        textViewBottomToContainer = textInputView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -(secondAnchorConstant + insetFromBottom * 2.5))
        textViewBottomToKeyboardConstraint = textInputView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        
        NSLayoutConstraint.activate([
            textInputView.topAnchor.constraint(equalTo: animationView.bottomAnchor,
                                               constant: .longInnerSpacer),
            textInputView.widthAnchor.constraint(equalTo: containerView.widthAnchor,
                                                 multiplier: 0.91),
            textInputView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            textViewBottomToContainer
        ])
    }
        

///Changes done button layout to make it visible all hidden.

    
    private func configureActionButtons(){
        containerView.addSubviews(deleteButton, editButton, doneButton, informationButton)
        
        
        doneButtonTrailingAnchor = doneButton.leadingAnchor.constraint(equalTo: view.trailingAnchor,
                                                                       constant: .longInnerSpacer)
        doneButtonActiveTrailingAnchor = doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                                              constant: -.innerSpacer)
        
        deleteBottomToContainer = deleteButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -(secondAnchorConstant + .longOuterSpacer) )
        editBottomToContainer = editButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -(secondAnchorConstant + .longOuterSpacer))
        
        NSLayoutConstraint.activate([
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                  constant: .longInnerSpacer),
            deleteButton.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                multiplier: 0.3),
            deleteBottomToContainer,
            
            
            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, 
                                                 constant: -.longInnerSpacer),
            editButton.widthAnchor.constraint(equalTo: view.widthAnchor,
                                              multiplier: 0.3),
            editBottomToContainer,
            
            
            doneButton.centerYAnchor.constraint(equalTo: animationView.centerYAnchor),
            
            doneButtonTrailingAnchor,
            
            
            informationButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                        constant: -.longInnerSpacer),
            informationButton.centerYAnchor.constraint(equalTo: animationView.centerYAnchor)
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
        button.setAttributedTitle(.attributedString(string: title, with: .systemBold, ofSize: .assosiatedTextSize), for: .normal)
        button.configuration?.baseForegroundColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    ///Change buttons layout, making it visible depending on passed boolean.
    private func changeDoneButtonState(activate: Bool){
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            NSLayoutConstraint.deactivate([activate
                                           ? doneButtonTrailingAnchor
                                           : doneButtonActiveTrailingAnchor ] )
            NSLayoutConstraint.activate([!activate
                                           ? doneButtonTrailingAnchor
                                           : doneButtonActiveTrailingAnchor ] )
            informationButton.alpha = activate ? 0 : 1
            view.layoutIfNeeded()
        })
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
        textInputView.textView.isEditable = activate
        changeDoneButtonState(activate: activate)
        if activate{
            textInputView.textView.becomeFirstResponder()
        } else {
            textInputView.textView.resignFirstResponder()
        }
    }
    ///Changes bottom anchor of container, updaing layout of subviews if required
    private func animateTransition(newValue: CGFloat){
        UIView.animate(withDuration: 0.5, delay: 0){
            self.containerViewBottomAnchor.constant = newValue
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
            self.containerViewBottomAnchor.constant = self.initialAnchorConstant
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
        textInputView.textView.addGestureRecognizer(wordTapGesture)
        
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

        let point = sender.location(in: textInputView.textView)
        var wordRange: UITextRange?
        let errorAnimation: CAKeyframeAnimation = .shakingAnimation()
        
        if let textPosition = textInputView.textView.closestPosition(to: point){
            if let rightRange = textInputView.textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection(rawValue: 1)){
                wordRange = rightRange
            } else if let leftRange = textInputView.textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection(rawValue: 0)){
                wordRange = leftRange
            }
        }
        
        guard let wordRange = wordRange, let word = textInputView.textView.text(in: wordRange) else {
            textInputView.textView.layer.add(errorAnimation, forKey: "animation")
            animationView.stopAnimating()
            return
        }
        
        let startPos = textInputView.textView.offset(from: textInputView.textView.beginningOfDocument, to: wordRange.start)
        let endPos = textInputView.textView.offset(from: textInputView.textView.beginningOfDocument, to: wordRange.end)
        let nsRange = NSMakeRange(startPos, endPos-startPos)
        let mutableAttributedString = NSMutableAttributedString(attributedString: textInputView.textView.attributedText)
        
        mutableAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        textInputView.textView.attributedText = mutableAttributedString

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let refVC = UIReferenceLibraryViewController(term: word)
            self.present(refVC, animated: true, completion: { [weak self] in
                self?.animationView.stopAnimating()
            })
        }
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
                containerViewBottomAnchor.constant = newConstant
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
        textInputView.textView.text = configureTextFor(editing: true)
        transitionToEditing(activate: true)
    }
    
    @objc func deleteButtonDidTap(sender: UIButton){
        //Passing view for an iPad version.
        viewModel?.deleteWord(view: self.view)
    }
    
    @objc func doneButtonDidTap(sender: UIButton){
        viewModel?.editWord(with: textInputView.textView.text, view: self.view)
    }
    
    @objc func informationButtonDidTap(sender: UIButton){
        let vc = InformationView()
        present(vc, animated: true)
    }
}
//MARK: - Delegates
extension GameDetailsVC: PlaceholderTextViewDelegate{
    func textViewDidBeginEditing(sender: UITextView)  { }
    
    func textViewDidEndEditing(sender: UITextView)    { }
    
    func textViewDidChange(sender: UITextView)        { }
    
    func presentErrorAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    func currentSeparatorSymbol() -> String? {
        viewModel?.textSeparator()
    }
    func configurePlaceholderText(sender: UITextView) -> String? {
        viewModel?.configureTextPlaceholder()
    }
    ///If user scroll TextView, trigger animation, which will expand view to revieal more content.
    func textViewDidScroll() {
        if currentAnchorConstant == secondAnchorConstant {
            animateTransition(newValue: thirdAnchorConstant)
        }
    }
}

class GameDetailsIPadVC: UIViewController {
    
    //MARK: - Parent related properties.
    weak var delegate: MainGameVCDelegate?
    var viewModel: GameDetailsViewModel?
    
    var cancellable = Set<AnyCancellable>()
    var navBarTopInset: CGFloat = 100
    
    private let animationView = LoadingAnimation()
    
    //MARK: Views
    private lazy var textInputView: TextInputView = {
        let view = TextInputView(delegate: self)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textView.layer.borderColor = UIColor.clear.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowColor = UIColor.clear.cgColor
        view.layer.shadowOpacity = 0
        view.backgroundColor = .clear
        
        view.textView.isEditable = false
        view.textView.isSelectable = false
        
        return view
    }()
        
    let informationButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(
            UIImage(systemName: "info.circle",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: .titleSize, weight: .semibold, scale: .large)),
            for: .normal
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var editButton:    UIButton = configureButtonWith(title: "system.edit".localized)
    private lazy var deleteButton:  UIButton = configureButtonWith(title: "system.delete".localized)
    private lazy var doneButton:    UIButton = configureButtonWith(title: "system.done".localized)
    
    //MARK: Gestures
    private var wordTapGesture: UITapGestureRecognizer = .init() // For selecting word

    //MARK: Constrait related properties
    //Constraits
    private var doneButtonTrailingAnchor:       NSLayoutConstraint = .init()
    private var doneButtonActiveTrailingAnchor: NSLayoutConstraint = .init()
    
    private var textViewBottomToContainer:          NSLayoutConstraint = .init()
    private var textViewBottomToKeyboardConstraint: NSLayoutConstraint = .init()
    
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

    private func bind() {
        guard let output = viewModel?.output else { return }
        output
            .sink(receiveValue: { [weak self] output in
                switch output {
                case .error(let error):
                    self?.presentError(error, sourceView: self?.view)
                case .shouldPresentAlert(let alert):
                    self?.present(alert, animated: true)
                case .shouldProcceedEditing:
                    self?.textInputView.updatePlaceholderVisability()
                    self?.textInputView.textView.text = self?.configureTextFor(editing: true)
                case .shouldEndEditing:
                    self?.textInputView.textView.text = self?.configureTextFor(editing: false)
                    self?.transitionToEditing(activate: false)
                case .shouldDismissView:
                    self?.dismiss(animated: true)
                }
            })
            .store(in: &cancellable)
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.viewModel?.viewWillDissapear()
    }
    
    //MARK: View SetUp
    private func controllerCustomization(){
        view.backgroundColor = .systemBackground_Secondary
    }
    
    //MARK: Subviews SetUp
    private func configureContainerView(){

        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor, constant: .longInnerSpacer),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -animationView.frame.width / 2),
            animationView.heightAnchor.constraint(equalToConstant: animationView.frame.height)
            
        ])
    }

    private func configureTextView(){
        view.addSubviews(textInputView)

        textInputView.textView.text = configureTextFor(editing: false)
        
        textInputView.updatePlaceholderVisability()

        textViewBottomToContainer = textInputView.bottomAnchor.constraint(equalTo: editButton.topAnchor, constant: -.longInnerSpacer)
        textViewBottomToKeyboardConstraint = textInputView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        
        NSLayoutConstraint.activate([
            textInputView.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: .longInnerSpacer),
            textInputView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            textInputView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textViewBottomToContainer
        ])
    }

    
        
    private func configureActionButtons(){
        view.addSubviews(deleteButton, editButton, doneButton, informationButton)
        
        doneButtonTrailingAnchor = doneButton.leadingAnchor.constraint(equalTo: view.trailingAnchor,
                                                                       constant: .longInnerSpacer)

        doneButtonActiveTrailingAnchor = doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                                              constant: -.innerSpacer)

        NSLayoutConstraint.activate([
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .longInnerSpacer),
            
            deleteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: -.longInnerSpacer ),

            editButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.longInnerSpacer),
            
            editButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            
            editButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                               constant: -.longInnerSpacer),
            
            doneButton.centerYAnchor.constraint(equalTo: animationView.centerYAnchor),
            
            doneButtonTrailingAnchor,
            
            
            informationButton.centerYAnchor.constraint(equalTo: animationView.centerYAnchor),
            
            informationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.longInnerSpacer)
        ])
        editButton.addTarget(self, action: #selector(editButtonDidTap(sender:)), for: .touchUpInside)
        deleteButton.addTarget(self , action: #selector(deleteButtonDidTap(sender:)), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonDidTap(sender: )), for: .touchUpInside)
        informationButton.addTarget(self, action: #selector(informationButtonDidTap(sender: )), for: .touchUpInside)
    }

    
    //MARK: Others
    ///Configure text for textView depending on passed style.
    private func configureTextFor(editing: Bool) -> String {
        viewModel?.configureTexForTextView(isEditing: editing) ?? ""
    }
    ///Configure button by assigning title and font.
    private func configureButtonWith(title: String) -> UIButton{
        let button = UIButton()
        button.configuration = .plain()
        button.setAttributedTitle(.attributedString(string: title, with: .systemBold, ofSize: .assosiatedTextSize), for: .normal)
        button.configuration?.baseForegroundColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    ///Change buttons layout, making it visible depending on passed boolean.
    private func changeDoneButtonState(activate: Bool){
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            NSLayoutConstraint.deactivate([activate
                                           ? doneButtonTrailingAnchor
                                           : doneButtonActiveTrailingAnchor ] )
            NSLayoutConstraint.activate([!activate
                                           ? doneButtonTrailingAnchor
                                           : doneButtonActiveTrailingAnchor ] )
            informationButton.alpha = activate ? 0 : 1
            view.layoutIfNeeded()
        })
    }

    //MARK: Appearence Animation
    ///Shortcut for switching between Editing and Exploration modes.
    private func transitionToEditing(activate: Bool){
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.textViewBottomToKeyboardConstraint.isActive = activate
            self?.textViewBottomToContainer.isActive = !activate
            self?.view.layoutIfNeeded()
        }
        wordTapGesture.isEnabled = !activate
        textInputView.textView.isEditable = activate
        changeDoneButtonState(activate: activate)
        if activate{
            textInputView.textView.becomeFirstResponder()
        } else {
            textInputView.textView.resignFirstResponder()
        }
    }
    //MARK: Gestures
    ///Settings up and assigning methods to their views.
    private func configureGestures(){
        wordTapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewDidTap(sender:)))
        textInputView.textView.addGestureRecognizer(wordTapGesture)
    }
}

//MARK: - Actions
extension GameDetailsIPadVC {
    //MARK: Touch events.
    //Recognises the word user tapped
    @objc func textViewDidTap(sender: UITapGestureRecognizer){
        DispatchQueue.main.async(execute: {
            self.animationView.startAnimating()
        })

        let point = sender.location(in: textInputView.textView)
        var wordRange: UITextRange?
        let errorAnimation: CAKeyframeAnimation = .shakingAnimation()
        
        if let textPosition = textInputView.textView.closestPosition(to: point){
            if let rightRange = textInputView.textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection(rawValue: 1)){
                wordRange = rightRange
            } else if let leftRange = textInputView.textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection(rawValue: 0)){
                wordRange = leftRange
            }
        }
        
        guard let wordRange = wordRange, let word = textInputView.textView.text(in: wordRange) else {
            textInputView.textView.layer.add(errorAnimation, forKey: "animation")
            animationView.stopAnimating()
            return
        }
        
        let startPos = textInputView.textView.offset(from: textInputView.textView.beginningOfDocument, to: wordRange.start)
        let endPos = textInputView.textView.offset(from: textInputView.textView.beginningOfDocument, to: wordRange.end)
        let nsRange = NSMakeRange(startPos, endPos-startPos)
        let mutableAttributedString = NSMutableAttributedString(attributedString: textInputView.textView.attributedText)
        
        mutableAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        textInputView.textView.attributedText = mutableAttributedString

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let refVC = UIReferenceLibraryViewController(term: word)
            self.present(refVC, animated: true, completion: { [weak self] in
                self?.animationView.stopAnimating()
            })
        }
    }
    
    
    //MARK: Buttons actions
    @objc func editButtonDidTap(sender: UIButton){
        textInputView.textView.text = configureTextFor(editing: true)
        
        transitionToEditing(activate: true)
    }
    
    @objc func deleteButtonDidTap(sender: UIButton){
        //Passing view for an iPad version.
        viewModel?.deleteWord(view: self.view)
    }
    
    @objc func doneButtonDidTap(sender: UIButton){
        guard let text = textInputView.validateText() else { return }
        viewModel?.editWord(with: text, view: self.view)
    }
    
    @objc func informationButtonDidTap(sender: UIButton){
        let vc = InformationView()
        present(vc, animated: true)
    }
}
//MARK: - Delegates
extension GameDetailsIPadVC: PlaceholderTextViewDelegate{
    func textViewDidBeginEditing(sender: UITextView)  { }
    
    func textViewDidEndEditing(sender: UITextView)    { }
    
    func textViewDidChange(sender: UITextView)        { }
    
    func presentErrorAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }

    func currentSeparatorSymbol() -> String? {
        viewModel?.textSeparator()
    }
    
    func configurePlaceholderText(sender: UITextView) -> String? {
        viewModel?.configureTextPlaceholder()
    }
}

