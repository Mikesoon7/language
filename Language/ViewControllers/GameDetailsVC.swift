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
    
    lazy var textView: UITextView = {
        let view = UITextView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textContainerInset = .init(top: 5, left: 5, bottom: 5, right: 5)
        
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        
        view.isEditable = false
        view.isSelectable = false
        view.backgroundColor = .clear
        view.font = UIFont(name: "Helvetica Neue Medium", size: 20)
        view.tintColor = .label
        return view
    }()
    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        view.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                ? .secondarySystemBackground
                                : .systemBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var wikipediaView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        view.backgroundColor = .secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var wikiImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        return view
    }()
    lazy var wikiTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue Medium", size: 18)
        label.textColor = .label
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var wikiTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue Regular", size: 14)
        label.textColor = .label
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var initialAnchorConstant: CGFloat!
    var secondAnchorConstant: CGFloat!
    var finalAnchorConstant: CGFloat!
    var currentAnchorConstant: CGFloat!
    
    var contentViewBottomAnchor: NSLayoutConstraint!
    var textViewBottomAnchor: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controllerCustomization()
        textViewCustomization()
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
        delegate?.restoreCardCell()
    }
    
    func controllerCustomization(){
        view.backgroundColor = .clear
        initialAnchorConstant = view.bounds.height * 0.5
        secondAnchorConstant = initialAnchorConstant * 0.5
        finalAnchorConstant = 50
        containerViewCustomization()
        panGestureCustomization()
        tapGestureRecognizer()
    }

    func containerViewCustomization(){
        view.addSubviews(dimView, containerView)
        
        contentViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: initialAnchorConstant)
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            contentViewBottomAnchor,
        ])
    }
    func textViewCustomization(){
        containerView.addSubviews(textView)
        textView.text = textToPresent

        textViewBottomAnchor = textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            textView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.91),
            textView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            textViewBottomAnchor
        ])

        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleTextTapGesture(sender:)))
        textView.addGestureRecognizer(gesture)
    }
    func wikiViewCustomization(){
        containerView.addSubview(wikipediaView)
        wikipediaView.addSubviews(wikiImageView, wikiTextLabel, wikiTitleLabel)
        
        NSLayoutConstraint.activate([
            wikipediaView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 40),
            wikipediaView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            wikipediaView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.91),
            wikipediaView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15),
            
            wikiTextLabel.topAnchor.constraint(equalTo: wikipediaView.topAnchor, constant: 10),
            wikiTextLabel.leadingAnchor.constraint(equalTo: wikipediaView.leadingAnchor, constant: 10),
            wikiTextLabel.trailingAnchor.constraint(equalTo: wikipediaView.trailingAnchor, constant: -10),
            wikiTextLabel.bottomAnchor.constraint(equalTo: wikipediaView.bottomAnchor, constant: -10),

        ])
        wikiTextLabel.text = selectedText
    }
    
    func presentViewController(){
        animateTransition(newValue: secondAnchorConstant)
    }
    func presentWikiInformation(){
        wikiViewCustomization()
        animateTransition(newValue: finalAnchorConstant)
    }
    func panGestureCustomization(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(sender: )))
        
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        
        view.addGestureRecognizer(panGesture)
    }
    func tapGestureRecognizer(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(sender: )))
        dimView.addGestureRecognizer(tapGesture)
    }
    func animateDimmedView(){
        UIView.animate(withDuration: 0.4) {
            self.dimView.alpha = 0.4
        }
    }
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
    func animateTransition(newValue: CGFloat){
        UIView.animate(withDuration: 0.5, delay: 0){
            self.contentViewBottomAnchor.constant = newValue
            self.currentAnchorConstant = newValue
            self.view.layoutIfNeeded()
        }
    }
    @objc func handleTextTapGesture(sender: UITapGestureRecognizer){
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
        
        let startPos = textView.offset(from: textView.beginningOfDocument, to: wordRange.start)
        let endPos = textView.offset(from: textView.beginningOfDocument, to: wordRange.end)
        let nsRange = NSMakeRange(startPos, endPos-startPos)
        let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
        
        mutableAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
        
        if UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: word) {
            let refVC = UIReferenceLibraryViewController(term: word)
            textView.attributedText = mutableAttributedString
            present(refVC, animated: true, completion: nil)
        } else {
            mutableAttributedString.addAttribute(.underlineColor, value: UIColor.red, range: nsRange)
            textView.attributedText = mutableAttributedString
        }
    }
    @objc func handlePanGesture(sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: view).y
        let newConstant = currentAnchorConstant + translation
        
        switch sender.state{
        case .began, .changed:
            if newConstant > currentAnchorConstant - 50 || newConstant > currentAnchorConstant{
                contentViewBottomAnchor.constant = newConstant
                view.layoutIfNeeded()
            }
        case .ended:
            if newConstant < finalAnchorConstant{
                animateTransition(newValue: finalAnchorConstant)
                view.layoutIfNeeded()
            } else if newConstant > initialAnchorConstant * 0.5{
                animateViewDismiss()
            } else {
                animateTransition(newValue: finalAnchorConstant)
            }
        default:
            break
        }
    }
    @objc func handleTapGesture(sender: UITapGestureRecognizer){
        let location = sender.location(in: view)
        if !containerView.frame.contains(location){
            animateViewDismiss()
        }

    }

}
extension GameDetailsVC: UITextViewDelegate{
    }

