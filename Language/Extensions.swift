//
//  Extensions.swift
//  Language
//
//  Created by Star Lord on 28/02/2023.
//

import Foundation
import UIKit

extension UIView {
    func setUpBorderedView(_ light: Bool){
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 9
        self.clipsToBounds = true

        if light {
            self.backgroundColor = .systemGray5
        } else {
            self.backgroundColor = .systemGray4
        
        }
    }
}
extension UIButton {
    func setUpCommotBut(_ light: Bool){
        self.configuration = .gray()
        self.configuration?.baseForegroundColor = .label
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 9
        self.tintColor = .label
        self.clipsToBounds = true
        if light{
            self.configuration?.baseBackgroundColor = .systemGray5
        } else {
            self.configuration?.baseBackgroundColor = .systemGray4

        }
    }
    
}

extension UINavigationController{
    func pushViewControllerFromRight (controller: UIViewController) {
        let transition = CATransition ()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction =
        CAMediaTimingFunction (name :CAMediaTimingFunctionName.easeInEaseOut)
        view.window!.layer.add(transition, forKey: kCATransition)
        pushViewController(controller, animated: false)
         
    }
}

extension UIButton{
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
        })
    }
    @objc func animationEnded( sender: UIButton){
        UIView.animate(withDuration: 0.10, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            sender.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }

}
extension UIView{
    func addTopStroke(vc: UIViewController) -> CAShapeLayer{
        let topStroke = CAShapeLayer()
        let path = UIBezierPath()
        let y = vc.navigationController!.navigationBar.bounds.maxY + vc.navigationController!.navigationBar.bounds.height + 7
        path.move(to: CGPoint(x: 0, y: y ))
        path.addLine(to: CGPoint(x: vc.view.bounds.maxX, y: y))
            topStroke.path = path.cgPath
            topStroke.lineWidth = 1.5
            topStroke.strokeColor = UIColor.label.cgColor
            topStroke.fillColor = UIColor.clear.cgColor
            topStroke.opacity = 0.8
            
            return topStroke
        }
    func addBottomStroke(vc: UIViewController) -> CAShapeLayer{
            let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: vc.view.bounds.maxY - 110))
        path.addLine(to: CGPoint(x: vc.view.bounds.maxX, y: vc.view.bounds.maxY - 110))
            let stroke = CAShapeLayer()
            stroke.path = path.cgPath
        stroke.lineWidth = 1.5
            stroke.strokeColor = UIColor.label.cgColor
            stroke.fillColor = UIColor.clear.cgColor
            stroke.opacity = 0.8
            
            return stroke
    }
}

