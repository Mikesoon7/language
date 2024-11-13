//
//  UIFont.swift
//  Language
//
//  Created by Star Lord on 10/08/2023.
//

import Foundation
import UIKit

extension UIFont{
    
    static var selectedFont: UIFont{
        return FontChangeManager.shared.currentFont()
    }
    
    static var georgianBoldItalic: UIFont{
        UIFont(name: "Georgia-BoldItalic", size: 1) ?? UIFont()
    }
    static var georgianItalic: UIFont{
        UIFont(name: "Georgia-Italic", size: 1)     ?? UIFont()
    }
    static var timesNewRoman: UIFont{
        UIFont(name: "Times New Roman", size: 1)    ?? UIFont()
    }
    static var timesNewRomanPSMT: UIFont {
        UIFont(name: "TimesNewRomanPSMT", size: 1)  ?? UIFont()
    }
    static var helveticaNeue: UIFont {
        UIFont(name: "Helvetica Neue", size: 1 )    ?? UIFont()
    }
    static var helveticaNeueBold: UIFont {
        UIFont(name: "Helvetica Neue Bold", size: 1 )  ?? UIFont()
    }
    static var helveticaNeueMedium: UIFont {
        UIFont(name: "Helvetica Neue Medium", size: 1) ?? UIFont()
    }
    static var systemBold: UIFont {
        UIFont.systemFont(ofSize: 1, weight: .bold)
    }
    
    /// Gets the font style (face) name
    var fontStyle: String {
        return fontFace
    }
    
    /// Gets the font face name
    var fontFace: String {
        return (fontDescriptor.object(forKey: .face) as? String) ?? "error"
    }
    var fontFaceAttribute: UIFont.Weight {
        return fontDescriptor.object(forKey: .face) as? UIFont.Weight ?? .regular
    }
        
    var fontWeight: UIFont.Weight {
        let weightMapping: [String: UIFont.Weight] = [
            "UltraLight": .ultraLight,
            "Thin": .thin,
            "Light": .light,
            "Regular": .regular,
            "Medium": .medium,
            "Semibold": .semibold,
            "Bold": .bold,
            "Heavy": .heavy,
            "Black": .black
        ]
        
        for (key, value) in weightMapping {
            if self.fontName.contains(key) {
                return value
            }
        }

        
        if let weight = weightMapping[self.fontFace] {
            return weight
        } else {
            for (key, value) in weightMapping {
                if self.fontFace.contains(key) {
                    return value
                }
            }
            return .regular

        }
    }
}
