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
        let y = {
            print("\(vc.view.safeAreaInsets.top)")
            if vc.navigationController != nil {
                return vc.view.safeAreaInsets.top
            } else {
                return 0
            }
        }()
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
        let y = {
            if vc.tabBarController?.tabBar != nil{
                return vc.tabBarController!.tabBar.frame.minY
            } else {
                return 0
            }
        }()
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: vc.view.bounds.maxX, y: y))
            let stroke = CAShapeLayer()
            stroke.path = path.cgPath
        stroke.lineWidth = 1.5
            stroke.strokeColor = UIColor.label.cgColor
            stroke.fillColor = UIColor.clear.cgColor
            stroke.opacity = 0.8
            
            return stroke
    }
}
extension NSAttributedString{
    func fontWithString(string: String, bold: Bool, size: CGFloat) -> NSAttributedString{
        let font : String!
        if bold {
            font = "Georgia-BoldItalic"
        } else {
            font = "Georgia-Italic"
        }
        let attributes = NSAttributedString(string: string,
                                            attributes: [NSAttributedString.Key.font :
                                                            UIFont(name: font ,
                                                                   size: size)!,
                                                         NSAttributedString.Key.foregroundColor:
                                                            UIColor.label])
        return attributes
    }
    func fontWithoutString(bold: Bool, size: CGFloat) -> [NSAttributedString.Key : Any]{
        let font : String!
        if bold {
            font = "Georgia-BoldItalic"
        } else {
            font = "Georgia-Italic"
        }
        let attributes = [NSAttributedString.Key.font:
                            UIFont(name: font,
                                   size: size)!,
                          NSAttributedString.Key.foregroundColor:
                            UIColor.label]
        return attributes as [NSAttributedString.Key : Any]
    }
}
//MARK: -AddSubviews method.
extension UIView{
    func addSubviews(_ views: UIView...){
        for i in views{
            self.addSubview(i)
        }
    }
}
//extension Bundle{
//    static var localizedBundle: Bundle? {
//        let language = {
//            var language = ""
//            switch SettingsData.shared.settings.language.rawValue{
//            case "English": language = "en"
//            case "Русский": language = "ru"
//            case "Українська": language = "uk"
//            default: break
//            }
//            return language
//        }()
//        if let path = Bundle.main.path(forResource: language, ofType: "lproj"){
//            return Bundle(path: path)
//        }
//        return nil
//    }
//}
extension Notification.Name{
    static let appLanguageDidChange = Notification.Name("appLanguageDidChange")
    static let appThemeDidChange = Notification.Name("appThemeDidChange")
    static let appSearchBarPositionDidChange = Notification.Name("appSearchBarPositionDidChange")
    static let appNotificationSettingsDidChange = Notification.Name("appNotificationSettingsDidChange")
}




