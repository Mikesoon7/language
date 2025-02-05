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
    static var outerSpacer = 15.0
    static var innerSpacer = 12.0
    static var nestedSpacer = 10.0
    static var cornerRadius = 9.0
    static var longOuterSpacer = outerSpacer * 2
    static var genericButtonHeight = 60.0
    static var systemButtonSize = 20.0
    static var keyboardInputAccessoryViewInset = (UIDevice.current.userInterfaceIdiom == .pad ? -44.0 : 0)
    
    static var fontTitleSize = 23.0
    static var fontContentSize = 18
}
extension UIBlurEffect {
    static func addBlurBackground(to view: UIView, style: UIBlurEffect.Style = .light) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.layer.cornerRadius = .cornerRadius
        blurEffectView.clipsToBounds = true
        blurEffectView.alpha = 0.5
        view.insertSubview(blurEffectView, at: 0)
        
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
    
    static func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
                                sourceRect: CGRect? = nil) -> UIAlertController{
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: alertStyle)
        if action1Title != ""{
            let action = UIAlertAction(title: action1Title, style: action1Style, handler: action1Handler)
            if action1Style != .destructive {
                action.setValue(UIColor.label, forKey: "titleTextColor")
            }
            alert.addAction(action)
        }
        if action2Title != ""{
            let action = UIAlertAction(title: action2Title, style: action2Style, handler: action2Handler)
            if action2Style != .destructive {
                action.setValue(UIColor.label, forKey: "titleTextColor")
            }
            alert.addAction(action)
        }
        //Blank fir the future iPad support.
        if UIDevice.current.userInterfaceIdiom == .pad,
           let popoverController = alert.popoverPresentationController {
                if let sourceView = sourceView, let sourceRect = sourceRect {
                    popoverController.sourceView = sourceView
                    popoverController.sourceRect = sourceRect
                                        
                } else if let sourceView = sourceView {
                    popoverController.sourceView = sourceView
                    popoverController.sourceRect = CGRect(x: sourceView.bounds.midX,
                                                          y: sourceView.bounds.midY,
                                                          width: 0,
                                                          height: 0)
                } else {
//                    let view = UIApplication.shared.connectedScenes
//                                                        .compactMap { $0 as? UIWindowScene }
//                                                        .flatMap { $0.windows }
//                                                        .first { $0.isKeyWindow }?.rootViewController?.view
                    let view = UIView.screenSizeView()
//                    popoverController.popoverLayoutMargins = .init(top: view.frame.midY - 100,
//                                                                   left: view.frame.midX - 100,
//                                                                   bottom: view.frame.midY - 100,
//                                                                   right: view.frame.midX - 100)
                    sourceView
                    popoverController.sourceView = view
                    popoverController.sourceRect = CGRect(x: view.bounds.midX,
                                                          y: view.bounds.midY,
                                                          width: 0,
                                                          height: 0)
                }
            popoverController.permittedArrowDirections = (sourceRect != nil
                                                          ? (popoverController.sourceView!.frame.midX > popoverController.sourceRect.midX ? .left : .right)
                                                          : [])
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
extension UIDevice {
    static var isIPadDevice: Bool = UIDevice.current.userInterfaceIdiom == .pad
}

extension UITraitCollection {
    var isRegularWidth: Bool {
        self.horizontalSizeClass == .regular
    }
}

extension UIResponder {
    func nearestViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }
}
