//
//  UIButton Extension.swift
//  Learny
//
//  Created by Star's MacBook Air on 29.11.2023.
//

import Foundation
import UIKit

extension UIButton{
    func setUpCustomButton(){
        self.layer.cornerRadius = .cornerRadius
        self.tintColor = .label
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.minimumScaleFactor = 0.5
        self.titleLabel?.numberOfLines = 1
        self.setTitleColor(.label, for: .normal)
        self.addCenterShadows()
        self.backgroundColor = .secondarySystemBackground
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addTargetTouchBegin()
        self.addTargetInsideTouchStop()
        self.addTargetOutsideTouchStop()
    }
    func setUpAccessoryViewButton(image: UIImage?, title: String? = nil){
        self.sizeToFit()
        self.contentHorizontalAlignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
        self.tintColor = .label

        if let title = title {
            self.setTitle(title, for: .normal)
            self.setTitleColor(.lightGray, for: .highlighted)

            self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            self.titleLabel?.numberOfLines = 2
            self.titleLabel?.adjustsFontSizeToFitWidth = true
            self.configuration = .plain()
            self.configuration?.imagePlacement = .trailing
            self.configuration?.imagePadding = 3.0
            
        }
        if let image = image {
            self.setImage(image, for: .normal)
            self.setImage(image.withTintColor(.lightGray), for: .highlighted)
            self.imageView?.contentMode = .scaleAspectFill
        }
    }

    fileprivate func addTargetTouchBegin(){
        super.addTarget(self, action: #selector(animationBegin(sender:)), for: .touchDown)
        
    }
    fileprivate func addTargetOutsideTouchStop(){
        super.addTarget(self, action: #selector(animationEnded(sender:)), for: .touchUpOutside)
    }
    fileprivate func addTargetInsideTouchStop(){
        super.addTarget(self, action: #selector(animationEnded(sender: )), for: .touchUpInside)
    }
    
    @objc func animationBegin( sender: UIButton){
        UIView.animate(withDuration: 0.20, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            sender.layer.shadowOffset = CGSize(width: 0, height: 0)
        })
    }
    @objc func animationEnded( sender: UIButton){
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            sender.transform = CGAffineTransform(scaleX: 1, y: 1)
            sender.layer.shadowOffset = CGSize(width: 4, height: 5)
        })
    }
    static func configureNavButtonWith(title: String, font: UIFont = .systemBold, size: CGFloat = 15) -> UIButton{
        let button = UIButton()
        button.configuration = .plain()
        button.setAttributedTitle(.attributedString(string: title, with: font, ofSize: size), for: .normal)
        button.configuration?.baseForegroundColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

}

