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
        self.layer.cornerRadius = 9
        self.tintColor = .label
        self.addRightSideShadow()
        self.backgroundColor = .secondarySystemBackground
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    func addTargetTouchBegin(){
        super.addTarget(self, action: #selector(animationBegin(sender:)), for: .touchDown)
        
    }
    func addTargetOutsideTouchStop(){
        super.addTarget(self, action: #selector(animationEnded(sender:)), for: .touchUpOutside)
    }
    func addTargetInsideTouchStop(){
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
}

