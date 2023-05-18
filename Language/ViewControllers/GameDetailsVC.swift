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
    
    lazy var textView: UITextView = {
        let view = UITextView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textContainerInset = .init(top: 5, left: 5, bottom: 5, right: 5)
        
        view.isEditable = false
        view.backgroundColor = .blue
        view.font = UIFont(name: "Helvetica Neue Medium", size: 20)
        view.tintColor = .label
        return view
    }()
    lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 9
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
    
    var initialAnchorConstant: CGFloat!
    var finalAnchorConstant: CGFloat!
    var currentAnchorConstant: CGFloat!
    
    var contentViewBottomAnchor: NSLayoutConstraint!
    
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
                contentView.backgroundColor = .secondarySystemBackground
            } else {
                contentView.backgroundColor = .systemBackground
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.restoreCardCell()
    }
    
    func controllerCustomization(){
        view.backgroundColor = .clear
        initialAnchorConstant = 400
        finalAnchorConstant = 50
        containerViewCustomization()
        panGestureCustomization()
        tapGestureRecognizer()
    }
    
    func containerViewCustomization(){
        view.addSubviews(dimView, contentView)
        
        contentViewBottomAnchor = contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: initialAnchorConstant)
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            contentViewBottomAnchor,
        ])
    }
    func textViewCustomization(){
        contentView.addSubviews(textView)
        textView.text = textToPresent

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            textView.heightAnchor.constraint(equalToConstant: 200),
            textView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.91),
            textView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleTextTapGesture(sender:)))
        textView.addGestureRecognizer(gesture)

    }
    func presentViewController(){
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
        let textPosition = textView.closestPosition(to: sender.location(in: textView))!
        let wordRange = textView.tokenizer.rangeEnclosingPosition(textPosition, with: .word, inDirection: UITextDirection(rawValue: 1))!
        textView.selectedTextRange = wordRange
        let word = textView.text(in: wordRange)!
        if UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: word) {
            let refVC = UIReferenceLibraryViewController(term: word)
            present(refVC, animated: true, completion: nil)
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
        if !contentView.frame.contains(location){
            animateViewDismiss()
        }

    }

}

extension GameDetailsVC: UITextViewDelegate{
    }
//class CustomTextView: UITextView, UIContextMenuInteractionDelegate {
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//
//
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let point = touch.location(in: self)
//        if let position = closestPosition(to: point),
//           let range = tokenizer.rangeEnclosingPosition(position, with: .word, inDirection: UITextDirection(rawValue: UITextLayoutDirection.right.rawValue)) {
//            selectedTextRange = range
//        }
//        let text = self.selectedTextRange
//
//
//    }
//}
