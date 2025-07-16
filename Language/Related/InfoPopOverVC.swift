//
//  InfoPopOverVC.swift
//  Learny
//
//  Created by Star Lord on 24/04/2025.
//

import UIKit

protocol InfoViewDelegate: AnyObject {
    func viewDidDismiss()
}
    class InfoPopoverViewController: UIView {
        
        weak var delegate: InfoViewDelegate?
        
        //        var learnedNumber: Int
        var sourceViewRect: CGRect
        var sourceSafeArea: UIEdgeInsets
        
        let popover: UIView = {
            let view = UIView()
            view.backgroundColor = .systemSecondary_WhiteColour
            view.layer.cornerRadius = .cornerRadius + 5
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.2
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 4
            view.layer.masksToBounds = true
            view.alpha = 0
            return view
        }()
        
        //MARK: Lablels
        let informationLabel: UILabel = {
            let label = UILabel()
            label.font = .selectedFont.withSize(.bodyTextSize)
            label.textColor = .label
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.contentMode = .top
            label.textAlignment = .center
            label.lineBreakMode = .byWordWrapping
            return label
        }()
        
        
        init(frame: CGRect, infoText: String, safeAreaInsets: UIEdgeInsets, delegate: InfoViewDelegate) {
            self.sourceViewRect = frame
            self.sourceSafeArea = safeAreaInsets
            self.delegate = delegate
            super.init(frame: .zero)
            self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.alpha = 0
            self.translatesAutoresizingMaskIntoConstraints = false
            
            configureGestures()
            configureSubviews()
            
            self.informationLabel.text = infoText
        }
        
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // Add tap gesture recognizer to dismiss popover when tapping outside
        func configureGestures(){
            let dismissTap = UITapGestureRecognizer(target: self, action: #selector(viewDidDismiss))
            self.addGestureRecognizer(dismissTap)
            let dismissSwipe = UISwipeGestureRecognizer(target: self, action: #selector(viewDidDismiss))
            self.addGestureRecognizer(dismissSwipe)
        }
        
        func configureSubviews(){
            if traitCollection.isRegularWidth  {
                popover.frame = CGRect(x: sourceViewRect.width / 2 + .innerSpacer ,
                                       y: sourceSafeArea.top + .longInnerSpacer,
                                       width:   (sourceViewRect.width / 2) - (.innerSpacer * 2),
                                       height:  ((sourceViewRect.width / 2) - (.innerSpacer * 2)) * 0.66 )
            } else {
                popover.frame = CGRect(x: .innerSpacer,
                                       y: sourceSafeArea.top + .longInnerSpacer,
                                       width:  (sourceViewRect.width - (.innerSpacer * 2)),
                                       height: (sourceViewRect.width - (.innerSpacer * 2)) * 0.66 )
            }
            popover.center = CGPoint(x: sourceViewRect.width - .innerSpacer,
                                     y: sourceSafeArea.top + .longInnerSpacer)
            popover.anchorPoint = CGPoint(x: 1, y: 0)
            popover.transform = .init(scaleX: 0.2, y: 0.2).concatenating(.init(translationX: -30, y: -10))
            
            
            self.addSubview(popover)
            
            popover.addSubviews(informationLabel)
            
            
            NSLayoutConstraint.activate([
                informationLabel.topAnchor.constraint(
                    equalTo: popover.topAnchor, constant: .longInnerSpacer),
                informationLabel.leadingAnchor.constraint(
                    equalTo: popover.leadingAnchor, constant: .longInnerSpacer),
                informationLabel.trailingAnchor.constraint(equalTo: popover.trailingAnchor, constant: -.longInnerSpacer),
                informationLabel.bottomAnchor.constraint(equalTo: popover.bottomAnchor, constant: -.outerSpacer)
                
            ])
        }
        func present(){
            UIView.animate(withDuration: 0.3) {
                self.popover.transform = .identity
                self.popover.alpha = 1
                self.alpha = 1
            }
        }
        
        func dismiss(completion: @escaping () -> () ){
            UIView.animate(withDuration: 0.3, animations: {
                self.popover.transform = .init(scaleX: 0.2, y: 0.2).concatenating(.init(translationX: -50, y: -20))
                self.popover.alpha = 0
                self.alpha = 0
            }) { _ in completion() }
        }

}
extension InfoPopoverViewController{
    @objc func viewDidDismiss(){
        self.dismiss { [weak self] in
            self?.delegate?.viewDidDismiss()
        }
    }
}
