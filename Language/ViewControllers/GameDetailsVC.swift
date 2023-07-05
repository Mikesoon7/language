//
//  GameDetailsVC.swift
//  Language
//
//  Created by Star Lord on 14/05/2023.
//

import UIKit

class GameDetailsVC: UIViewController {

    weak var delegate: MainGameVCDelegate?
    var textToPresent: String!
    var selectedText: String!
    
    var dictionary: DictionariesEntity!
    var words: [WordsEntity]!
    var wordEntity: WordsEntity!
    var pairIndex: Int!
    
    let animationView = LoadingAnimation()

    let informationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = "Tap for details"
        label.textAlignment = .left
        label.font = UIFont(name: .SelectedFonts.georgiaBoldItalic.rawValue , size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var textView: UITextView = {
        let view = UITextView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        
        view.isEditable = false
        view.isSelectable = false
        view.backgroundColor = .clear
        view.font = UIFont(name: "Helvetica Neue Medium", size: 18)
        view.tintColor = .label
        return view
    }()
    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 13
        view.clipsToBounds = true
        view.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                ? .secondarySystemBackground
                                : .systemBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let informationButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: "info.circle",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold, scale: .medium)), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
        
    private lazy var editButton:    UIButton = configureButtonWith(title: "Edit")
    private lazy var deleteButton:  UIButton = configureButtonWith(title: "Delete")
    private lazy var doneButton:    UIButton = configureButtonWith(title: "Done")
    
    private var wordTapGesture: UITapGestureRecognizer! // For selecting word
    private var viewDismissTapGesture: UITapGestureRecognizer! // Dismiss the view if user taps on dimmedView
    private var viewPanGesture: UIPanGestureRecognizer!
    
    let insetFromBottom: CGFloat = 30
    var initialAnchorConstant:  CGFloat!
    var secondAnchorConstant:   CGFloat!
    var thirdAnchorConstant:    CGFloat!
    var finalAnchorConstant:    CGFloat!
    var currentAnchorConstant:  CGFloat!
    
    var contentViewBottomAnchor: NSLayoutConstraint!
    var doneButtonTrailingAnchor: NSLayoutConstraint!
    
    var textViewBottomAnchor: NSLayoutConstraint!
    var textViewBottomToContainer: NSLayoutConstraint!
    
    var deleteBottomConstrait: NSLayoutConstraint!
    var deleteBottomToContainer: NSLayoutConstraint!
    
    var editBottomConstrait: NSLayoutConstraint!
    var editBottomToContainer: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controllerCustomization()
        containerViewCustomization()
        configureActionButtons()
        textViewCustomization()
        configureGestures()
    }
    override func viewDidAppear(_ animated: Bool) {
        presentViewController()
        animateDimmedView()
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            if traitCollection.userInterfaceStyle == .dark{
                containerView.backgroundColor = .secondarySystemBackground
            } else {
                containerView.backgroundColor = .systemBackground
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.restoreCardCell(with: wordEntity)
    }
    
    func controllerCustomization(){
        view.backgroundColor = .clear
        initialAnchorConstant = view.bounds.height
        secondAnchorConstant = initialAnchorConstant * 0.6
        thirdAnchorConstant = initialAnchorConstant * 0.4
    }
    //MARK: - ContainerView SetUp
    func containerViewCustomization(){
        view.addSubviews(dimView, containerView)
        containerView.addSubview(animationView)
        
        contentViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: initialAnchorConstant)
//        informationLabelTopAnchor = informationLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15)
        
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
    //MARK: - TextView SetUp
    func textViewCustomization(){
        containerView.addSubviews(textView)
        textView.text = textToPresent

        textViewBottomAnchor = textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insetFromBottom)
        textViewBottomToContainer = textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -(secondAnchorConstant + insetFromBottom * 2.5))
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 15),
            textView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.91),
            textView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            textViewBottomToContainer
        ])

    }
    //MARK: - Edit and Delete buttons SetUp
    func configureActionButtons(){
        containerView.addSubviews(deleteButton, editButton, doneButton, informationButton)
        
        doneButtonTrailingAnchor = doneButton.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)
        
        deleteBottomConstrait = deleteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insetFromBottom)
        deleteBottomToContainer = deleteButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -(secondAnchorConstant + 40) )
        
        editBottomConstrait = editButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insetFromBottom)
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
    //MARK: -
    func configureButtonWith(title: String) -> UIButton{
        let button = UIButton()
        button.configuration = .plain()
        button.setAttributedTitle( NSAttributedString(
            string: title,
            attributes: [NSAttributedString.Key.font:
                                            UIFont.systemFont(ofSize: 15,
                                                              weight: .bold)]),
                                       for: .normal)
        button.configuration?.baseForegroundColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    //MARK: - Appearence Animation
    func presentViewController(){
        animateTransition(newValue: secondAnchorConstant)
    }
    func animateDimmedView(){
        UIView.animate(withDuration: 0.4) {
            self.dimView.alpha = 0.4
        }
    }
    func animateTransition(newValue: CGFloat){
        UIView.animate(withDuration: 0.5, delay: 0){
            self.contentViewBottomAnchor.constant = newValue
            self.currentAnchorConstant = newValue
            
            self.editBottomToContainer.constant = -(self.currentAnchorConstant + self.insetFromBottom)
            self.deleteBottomToContainer.constant = -(self.currentAnchorConstant + self.insetFromBottom)
            
            if newValue != self.finalAnchorConstant{
                self.textViewBottomToContainer.constant = -(self.currentAnchorConstant + self.insetFromBottom * 2.5)
            } else {
                self.textViewBottomToContainer.constant = -(self.currentAnchorConstant + self.insetFromBottom * 2.5)
            }
            self.view.layoutIfNeeded()
        }
    }
    //MARK: - Dissapearence Animation
    func animateViewDismiss(){
        let viewDismiss = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut){
            self.dimView.alpha = 0
            self.contentViewBottomAnchor.constant = self.initialAnchorConstant
            self.view.layoutIfNeeded()
        }
        viewDismiss.addCompletion { _ in
            self.dismiss(animated: false)
        }
        viewDismiss.startAnimation()
    }
    //MARK: Gestures
    func configureGestures(){
        wordTapGesture = UITapGestureRecognizer(target: self, action: #selector(textViewDidTap(sender:)))
        textView.addGestureRecognizer(wordTapGesture)
        
        viewDismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(sender: )))
        dimView.addGestureRecognizer(viewDismissTapGesture)

        viewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(viewDidPan(sender: )))
        
//        viewPanGesture.delaysTouchesBegan = false
//        viewPanGesture.delaysTouchesEnded = false
        
        view.addGestureRecognizer(viewPanGesture)
    }
    func transitionToEditing(activate: Bool){
        animateTransition(newValue: activate ? finalAnchorConstant : thirdAnchorConstant )
        wordTapGesture.isEnabled = activate ? false : true
        textView.isEditable = activate ? true : false
        doneButton(activate: activate)
        if activate{
            textView.becomeFirstResponder()
        } else {
            textView.resignFirstResponder()
        }
    }
    func doneButton(activate: Bool){
        UIView.animate(withDuration: 0.2, delay: 0) { [weak self] in
            self?.doneButtonTrailingAnchor.constant = activate ? -65 : 0
            self?.informationButton.alpha = activate ? 0 : 1
            self?.view.layoutIfNeeded()
        }
    }
    //MARK: - Actions
    //Recognises the word user tapped
    @objc func textViewDidTap(sender: UITapGestureRecognizer){
        let point = sender.location(in: textView)
        var wordRange: UITextRange?
        let errorAnimation: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation()
            animation.keyPath = "position.x"
            animation.values = [5, 0, -5, 0, 5, 0]
            animation.duration = 0.5
            animation.keyTimes = [0, 0.1, 0.2, 0.3, 0.4, 0.5]
            animation.isAdditive = true
            return animation
        }()
        if let textPosition = textView.closestPosition(to: point){
            if let rightRange = textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection(rawValue: 1)){
                wordRange = rightRange
                print(textView.text(in: rightRange)! + "right")
            } else if let leftRange = textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection(rawValue: 0)){
                wordRange = leftRange
                
                print(textView.text(in: leftRange)! + "left")
            }
        }
        guard let wordRange = wordRange, let word = textView.text(in: wordRange) else {
            textView.layer.add(errorAnimation, forKey: "animation")
            return
        }
        
        self.animationView.startAnimating()
        let startPos = textView.offset(from: textView.beginningOfDocument, to: wordRange.start)
        let endPos = textView.offset(from: textView.beginningOfDocument, to: wordRange.end)
        let nsRange = NSMakeRange(startPos, endPos-startPos)
        let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        
        mutableAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        if UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: word) {
            let refVC = UIReferenceLibraryViewController(term: word)
            textView.attributedText = mutableAttributedString
            present(refVC, animated: true, completion: { [weak self] in
                self?.animationView.stopAnimating()
            })
        } else {
            mutableAttributedString.addAttribute(.underlineColor, value: UIColor.red, range: nsRange)
            animationView.stopAnimating()
            textView.attributedText = mutableAttributedString
        }
    }
    //Container view was panned
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
    
    @objc func editButtonDidTap(sender: UIButton){
        textView.text = "\(wordEntity.word) \(UserSettings.shared.settings.separators.selectedValue) \(wordEntity.meaning)"
        transitionToEditing(activate: true)
    }
    
    @objc func deleteButtonDidTap(sender: UIButton){
        let alert = UIAlertController(title: "Delete current pair", message: "Are you sure to delte delete this pair.", preferredStyle: .alert)
        if words.count == 1 {
            alert.message?.append("\n This is the last card, so you dictionary will be deleted as well.")
        }
        let confirm = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            CoreDataHelper.shared.delete(words: self.wordEntity!)
            print(self.words.count)
            self.wordEntity = nil
            print(self.words.count)
            self.animateViewDismiss()
            
        }
        let deny = UIAlertAction(title: "No", style: .cancel) { _ in
            print("canceled")
        }
        alert.addAction(deny)
        alert.addAction(confirm)
        present(alert, animated: true)
    }
    @objc func doneButtonDidTap(sender: UIButton){
        let id = wordEntity.identifier
        let order = wordEntity.order
        self.wordEntity = CoreDataHelper.shared.pairDividerFor(dictionary: dictionary,
                                                               text: self.textView.text,
                                                               index: Int(order),
                                                               id: id ?? UUID())
        words[pairIndex] = wordEntity
        textView.text = wordEntity.word + "\n" + "\n" + wordEntity.meaning
        CoreDataHelper.shared.update(dictionary: dictionary, words: words, name: nil)
        delegate?.updateCardCell(with: wordEntity)
        transitionToEditing(activate: false)
    }
    @objc func informationButtonDidTap(sender: UIButton){
        let vc = InformationSheetController()
        present(vc, animated: true)
        
    }
    //Tap gesture to cancel view.
    @objc func handleTapGesture(sender: UITapGestureRecognizer){
        let location = sender.location(in: view)
        if !containerView.frame.contains(location){
            animateViewDismiss()
        }

    }

}
extension GameDetailsVC: UITextViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if currentAnchorConstant == secondAnchorConstant {
            animateTransition(newValue: thirdAnchorConstant)
        }
    }
}
class InformationSheetController: UIViewController{
    
    let informationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = LanguageChangeManager.shared.localizedString(forKey: "gameDetails.information")
        label.font = UIFont(name: .SelectedFonts.georigaItalic.rawValue , size: 18)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
        configureInformationLabel()
    }
    override func viewDidLayoutSubviews() {
        sheetPresentationController?.detents = [.custom(resolver: { context in
            return self.informationLabel.bounds.height * 1.5
        })]

    }
    func configureController(){
        view.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                ? .secondarySystemBackground
                                : .systemBackground)
        self.modalPresentationStyle = .pageSheet
    }
    func configureInformationLabel(){
        view.addSubview(informationLabel)
        
        NSLayoutConstraint.activate([
            informationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.05),
            informationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            informationLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91)
        
        ])
    }
    
}


