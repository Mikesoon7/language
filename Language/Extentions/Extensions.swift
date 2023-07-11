//
//  Extensions.swift
//  Language
//
//  Created by Star Lord on 28/02/2023.
//

import Foundation
import UIKit
import CoreData

public let shadowColorForDarkIdiom = UIColor.clear.cgColor
public let shadowColorForLightIdiom = UIColor.systemGray2.cgColor


extension UIView {
    func setUpBorderedView(_ overlays: Bool){
        self.layer.cornerRadius = 9
        self.addShadowWhichOverlays(overlays)
        self.backgroundColor = .secondarySystemBackground
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
extension UIButton {
    func setUpCommotBut(_ overlays: Bool){
        self.layer.cornerRadius = 9
        self.tintColor = .label
        self.addShadowWhichOverlays(overlays)
        self.backgroundColor = .secondarySystemBackground
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
            if vc.navigationController != nil {
                return vc.view.safeAreaInsets.top
            } else {
                return 0
            }
        }()
        path.move(to: CGPoint(x: 0, y: y ))
        path.addLine(to: CGPoint(x: vc.view.bounds.maxX, y: y))
        topStroke.path = path.cgPath
        topStroke.lineWidth = 0.8
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
        stroke.lineWidth = 0.8
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
    func addCenterSideShadows(_ over: Bool){
        self.layer.masksToBounds = false
        self.layer.shadowOffset = over ? CGSize(width: 0, height: 10) : CGSize(width: 0, height: 5)
        self.layer.shadowColor = ((traitCollection.userInterfaceStyle == .dark)
                                  ? shadowColorForDarkIdiom
                                  : shadowColorForLightIdiom)
        self.layer.shadowOpacity = over ? 0.4 : 0.8
    }

    func addShadowWhichOverlays( _ over: Bool){
        self.layer.masksToBounds = false
        self.layer.shadowOffset = over ? CGSize(width: 9, height: 10) : CGSize(width: 4, height: 5)
        self.layer.shadowColor = ((traitCollection.userInterfaceStyle == .dark)
                                  ? shadowColorForDarkIdiom
                                  : shadowColorForLightIdiom)
        self.layer.shadowOpacity = over ? 0.4 : 0.8
    }
}
extension String{
    enum SelectedFonts: String{
        case georgiaBoldItalic = "Georgia-BoldItalic"
        case georigaItalic = "Georgia-Italic"
        case charter = ""
    }
}
extension NSManagedObject{
    enum ChangeType{
        case insert
        case delete
        case update
    }
}

extension Notification.Name{
    static let appLanguageDidChange = Notification.Name("appLanguageDidChange")
    static let appThemeDidChange = Notification.Name("appThemeDidChange")
    static let appSearchBarPositionDidChange = Notification.Name("appSearchBarPositionDidChange")
    static let appNotificationSettingsDidChange = Notification.Name("appNotificationSettingsDidChange")
    static let appDataDidChange = Notification.Name("appDataDidChange")
    static let appSeparatorDidChange = Notification.Name("separatorDidChange")
}

extension String{
    var localized: String{
        return LanguageChangeManager.shared.localizedString(forKey: self)
    }
    
    func load() -> UIImage {
        do{
            guard let url = URL(string: self) else { return UIImage()}
            let data: Data = try Data(contentsOf: url, options: .uncached)
            return UIImage(data: data) ?? UIImage()
        } catch {
            
        }
        return UIImage()
    }
}
extension UIAlertController {
    func alertWithAction(alertTitle: String, alertMessage: String, alertStyle: UIAlertController.Style = .actionSheet,
                         action1Title: String = "", action1Style: UIAlertAction.Style = .default,
                         action2Title: String = "", action2Style: UIAlertAction.Style = .default) -> UIAlertController{
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: alertStyle)
        if action1Title != ""{
            let action = UIAlertAction(title: action1Title, style: action1Style)
            action.setValue(UIColor.label, forKey: "titleTextColor")
            alert.addAction(action)
        }
        if action2Title != ""{
            let action = UIAlertAction(title: action2Title, style: action2Style)
            action.setValue(UIColor.label, forKey: "titleTextColor")
            alert.addAction(action)
        }
        return alert
    }
}
extension UIViewController{
    func presentError(_ error: Error) {
        let alertController = UIAlertController(
            title: error.localizedDescription,
            message: "Please try again or contact the support team if the issue persists.",
            preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
}