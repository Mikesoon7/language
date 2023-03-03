//
//  Extensions.swift
//  Language
//
//  Created by Star Lord on 28/02/2023.
//

import Foundation
import UIKit

extension UIView {
    func setUpBorderedView(_ bordered: Bool){
        if bordered {
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.black.cgColor
            
            self.layer.cornerRadius = 9
            self.backgroundColor = .systemGray5
            self.clipsToBounds = true
        } else {
            self.layer.cornerRadius = 9
            self.backgroundColor = .systemGray4
            self.clipsToBounds = true
        
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
