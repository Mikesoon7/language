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


//extension UIView {
//    func setUpCustomView(){
//        self.layer.cornerRadius = 9
//        self.addShadowWhichOverlays(false)
//        self.backgroundColor = .secondarySystemBackground
//        self.translatesAutoresizingMaskIntoConstraints = false
//    }
//}


extension UIButton {
    func setUpCustomButton(){
        self.layer.cornerRadius = 9
        self.tintColor = .label
        self.addRightSideShadow()
        self.backgroundColor = .secondarySystemBackground
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UISwitch {
    func setUpCustomSwitch(isOn: Bool){
        self.onTintColor = .systemGray2
        self.tintColor = .systemBackground
        self.setOn(isOn, animated: true)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
// MARK: CGFloat
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

extension UITableViewCell{
    func cellTouchDownAnimation(){
        UIView.animate(withDuration: 0.20, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            self.contentView.layer.shadowOffset = CGSize(width: 0, height: 0)

        })

    }
    func cellTouchUpAnimation(){
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.contentView.layer.shadowOffset = CGSize(width: 4, height: 5)
        })
    }
}
extension NSAttributedString{    
    static func textAttributes(with font: UIFont, ofSize: CGFloat, foregroundColour: UIColor = .label, backgroundColour: UIColor = .clear) -> [NSAttributedString.Key : Any]{
        let attributes = [NSAttributedString.Key.font:
                            font.withSize(ofSize),
                          NSAttributedString.Key.foregroundColor:
                             foregroundColour,
                          NSAttributedString.Key.backgroundColor:
                             backgroundColour]
        return attributes as [NSAttributedString.Key : Any]
    }
    static func attributedString(string: String, with font: UIFont, ofSize: CGFloat, foregroundColour: UIColor = .label, backgroundColour: UIColor = .clear) -> NSAttributedString{
        let attributes = NSAttributedString(string: string,
                                            attributes: [NSAttributedString.Key.font :
                                                            font.withSize(ofSize),
                                                         NSAttributedString.Key.foregroundColor:
                                                            foregroundColour,
                                                         NSAttributedString.Key.backgroundColor:
                                                            backgroundColour
                                                        ])
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
        let attributes = NSMutableAttributedString(string: string,
                                            attributes: [NSMutableAttributedString.Key.font :
                                                            font.withSize(ofSize),
                                                         NSMutableAttributedString.Key.foregroundColor:
                                                            foregroundColour,
                                                         NSMutableAttributedString.Key.backgroundColor:
                                                            backgroundColour,
                                                        ])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        attributes.addAttribute(.paragraphStyle, value: paragraphStyle , range: NSRange(location: 0, length: attributes.length))
        return attributes
    }

}
//MARK: -AddSubviews method.
extension UIView{
//    func addSubviews(_ views: UIView...){
//        for i in views{
//            self.addSubview(i)
//        }
//    }
//    func addCenterSideShadows(_ over: Bool){
//        self.layer.masksToBounds = false
//        self.layer.shadowOffset = over ? CGSize(width: 0, height: 10) : CGSize(width: 0, height: 5)
//        self.layer.shadowColor = ((traitCollection.userInterfaceStyle == .dark)
//                                  ? shadowColorForDarkIdiom
//                                  : shadowColorForLightIdiom)
//        self.layer.shadowOpacity = over ? 0.4 : 0.8
//    }
//
//    func addShadowWhichOverlays( _ over: Bool){
//        self.layer.masksToBounds = false
//        self.layer.shadowOffset = over ? CGSize(width: 9, height: 10) : CGSize(width: 4, height: 5)
//        self.layer.shadowColor = ((traitCollection.userInterfaceStyle == .dark)
//                                  ? shadowColorForDarkIdiom
//                                  : shadowColorForLightIdiom)
//        self.layer.shadowOpacity = over ? 0.4 : 0.8
//    }
}
extension UIColor{
    static func getColoursArray(_ count: Int) -> [UIColor]{
        var base: [UIColor] = [.systemRed, .systemBlue, .systemPink, .systemCyan, .systemGray,  .systemMint, .systemBrown, .systemGreen, .systemIndigo, .systemOrange, .systemPurple, .systemYellow]
        var appendedColors = [UIColor]()
        
        let exceedCount = count - base.count
        if exceedCount > 0 {
            for i in 0..<count {
                let baseColor = base[i % base.count]
                let alpha = CGFloat(1 - 0.1 * Double(i / base.count))
                let appendedColor = baseColor.withAlphaComponent(alpha)
                appendedColors.append(appendedColor)
            }
        } else {
            appendedColors = Array(base.prefix(count))
        }
        
        return appendedColors
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
//    static let appNotificationTimeDidChange = Notification.Name(
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
    func presentUnknownError(){
        let alertController = UIAlertController(
            title: "unknownError.title".localized,
            message: "unknownError.message".localized,
            preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "system.agreeFormal".localized, style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    func presentError(_ error: Error) {
        var description = String()
        switch error{
        case let error as DictionaryErrorType:
            switch error{
            case .creationFailed:
                description = "coreData.dictionaryCreation".localized
            case .fetchFailed:
                description = "coreData.dictionaryFetch".localized
            case .updateFailed:
                description = "coreData.dictionaryUpdate ".localized
            case .additionFailed:
                description = "coreData.dictionaryAddition".localized
            case .updateOrderFailed:
                description = "coreData.dictionaryOrderUpdate".localized
            case .deleteFailed:
                description = "coreData.dictionaryDeletion".localized
            }
        case let error as LogsErrorType:
            switch error {
            case .creationFailed:
                description = "coreData.logCreation".localized
            case .accessFailed:
                description = "coreData.logAccess".localized
            case .fetchFailed:
                description = "coreData.logFetch".localized
            }
            
        default:
            description = "unknownError.title".localized
        }
        let alertController = UIAlertController(
            title: description,
            message: "unknownError.message".localized,
            preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "system.agreeFormal".localized, style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
}
extension Date {
    var timeStripped: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: components) ?? self
    }
}
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
            print("Extenstion worked")
        }
    }
}
