//
//  FontChangeManager.swift
//  Learny
//
//  Created by Star Lord on 01/03/2024.
//

import Foundation
import UIKit

class FontChangeManager {
    static let shared = FontChangeManager()
    static let fontKey = "AppFont"
    
    private var font: UIFont {
        let fontName = UserDefaults.standard.string(forKey: FontChangeManager.fontKey) ?? "Georgia-BoldItalic"
        return UIFont(name: fontName, size: 1) ?? UIFont()
    }
    
    private init(){}
    
    func updateFont(fontName: String) {
        UserDefaults.standard.setValue(fontName, forKey: FontChangeManager.fontKey)
        NotificationCenter.default.post(name: .appFontDidChange, object: nil)
    }
    func currentFont() -> UIFont {
        return font
    }
    func VCTitleAttributes() -> [NSAttributedString.Key : Any]{
        let scaledFont = font.withSize(.titleSize)
        return [NSAttributedString.Key.font : scaledFont,
         NSAttributedString.Key.foregroundColor: UIColor.label,
         NSAttributedString.Key.backgroundColor: UIColor.clear
        ]
    }
}
