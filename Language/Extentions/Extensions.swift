//
//  Extensions.swift
//  Language
//
//  Created by Star Lord on 28/02/2023.
//

import Foundation
import UIKit
import CoreData


//MARK: - UISwitch
extension UISwitch {
    func setUpCustomSwitch(isOn: Bool){
        self.onTintColor = .systemGray2
        self.tintColor = .systemBackground
        self.setOn(isOn, animated: true)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
//MARK: - CGFloat
extension CGFloat{
    enum Multipliers {
        case forViews
        case forPickers
    
        var multiplier: CGFloat{
            switch self{
            case .forPickers: return 0.95
            case .forViews  : return 0.91
            }
        }
    }
    static func widthMultiplerFor(type: Multipliers) -> CGFloat{
        return type.multiplier
    }
    
}
//MARK: - UINavigationViewController
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

//MARK: - NSAttributedString
extension NSAttributedString{
    static func attributedString(string: String, with font: UIFont, ofSize: CGFloat, foregroundColour: UIColor = .label, backgroundColour: UIColor = .clear) -> NSAttributedString{
        let attributes = NSAttributedString(
            string: string,
            attributes: 
                [NSAttributedString.Key.font : font.withSize(ofSize),
                 NSAttributedString.Key.foregroundColor: foregroundColour,
                 NSAttributedString.Key.backgroundColor: backgroundColour])
        return attributes
    }
    
    static func textAttributesForNavTitle() -> [NSAttributedString.Key : Any] {
        [NSAttributedString.Key.font:            UIFont.georgianBoldItalic.withSize(23),
         NSAttributedString.Key.foregroundColor: UIColor.label,
         NSAttributedString.Key.backgroundColor: UIColor.clear]
    }
    
}
extension NSMutableAttributedString{
    static func attributedMutableString(string: String, with font: UIFont, ofSize: CGFloat, foregroundColour: UIColor = .label, backgroundColour: UIColor = .clear, alignment: NSTextAlignment = .center) -> NSMutableAttributedString{
        let attributes = NSMutableAttributedString(
            string: string,
            attributes: 
                [NSMutableAttributedString.Key.font : font.withSize(ofSize),
                 NSMutableAttributedString.Key.foregroundColor: foregroundColour,
                 NSMutableAttributedString.Key.backgroundColor: backgroundColour,
                ])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        attributes.addAttribute(.paragraphStyle, value: paragraphStyle , range: NSRange(location: 0, length: attributes.length))
        return attributes
    }

}
//MARK: - Animation
extension CABasicAnimation{
    static func rotationAnimation() -> CABasicAnimation {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = -Double.pi
        rotationAnimation.duration = 0.5 //0.6
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = .forwards
        return rotationAnimation
    }
}
extension CAKeyframeAnimation {
    static func shakingAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [5, 0, -5, 0, 5, 0]
        animation.duration = 0.5
        animation.keyTimes = [0, 0.1, 0.2, 0.3, 0.4, 0.5]
        animation.isAdditive = true
        return animation
    }
}

extension NSManagedObject{
    enum ChangeType{
        case insert
        case delete
        case update
    }
}
//MARK: - Notifications
extension Notification.Name{
    static let appLanguageDidChange = Notification.Name("appLanguageDidChange")
    static let appThemeDidChange = Notification.Name("appThemeDidChange")
    static let appFontDidChange = Notification.Name("appFontDidChange")
    static let appSearchBarPositionDidChange = Notification.Name("appSearchBarPositionDidChange")
    static let appNotificationSettingsDidChange = Notification.Name("appNotificationSettingsDidChange")
    static let appDataDidChange = Notification.Name("appDataDidChange")
    static let appSeparatorDidChange = Notification.Name("separatorDidChange")
}

extension String{
    var localized: String{
        return LanguageChangeManager.shared.localizedString(forKey: self)
    }
}
//MARK: - UIAlertController
extension UIAlertController {
    static func alertWithAction(alertTitle: String, 
                                alertMessage: String? = nil,
                                alertStyle: UIAlertController.Style = .actionSheet,
                                action1Title: String = "", 
                                action1Handler: ((UIAlertAction) -> (Void))? = (.none),
                                action1Style: UIAlertAction.Style = .default,
                                action2Title: String = "",
                                action2Handler: ((UIAlertAction) -> (Void))? = (.none),
                                action2Style: UIAlertAction.Style = .default,
                                sourceView: UIView? = nil,
                                locationOfTap: CGPoint? = nil) -> UIAlertController{
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: alertStyle)
        if action1Title != ""{
            let action = UIAlertAction(title: action1Title, style: action1Style, handler: action1Handler)
            action.setValue(UIColor.label, forKey: "titleTextColor")
            alert.addAction(action)
        }
        if action2Title != ""{
            let action = UIAlertAction(title: action2Title, style: action2Style, handler: action2Handler)
            action.setValue(UIColor.label, forKey: "titleTextColor")
            alert.addAction(action)
        }
        
        //Blank fir the future iPad support.
        if UIDevice.current.userInterfaceIdiom == .pad, let popoverController = alert.popoverPresentationController {
                if let sourceView = sourceView, let tapLocation = locationOfTap {
                    popoverController.sourceView = sourceView
                    popoverController.sourceRect = CGRect(x: tapLocation.x, y: tapLocation.y, width: 1, height: 1)
                                        
                } else if let sourceView = sourceView {
                    popoverController.sourceView = sourceView
                    popoverController.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 1, height: 1)

                } else {
                    fatalError("sourceView is required for presenting actionSheet on iPad")
                }
            popoverController.permittedArrowDirections = locationOfTap != nil ? .left : []
        }

        
        return alert
    }
}
//MARK: - Date
extension Date {
    var timeStripped: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components) ?? self
    }
}
//MARK: - UITextView
extension UITextView {
    override open func paste(_ sender: Any?) {
        if let pasteboardText = UIPasteboard.general.string {
            let attributes = self.typingAttributes
            let attributedString = NSAttributedString(string: pasteboardText, attributes: attributes)

            textStorage.insert(attributedString, at: selectedRange.location)

            selectedRange = NSRange(location: selectedRange.location + pasteboardText.count, length: 0)
            if delegate != nil {
                delegate?.textViewDidChange?(self)
            }
        }
    }
}
