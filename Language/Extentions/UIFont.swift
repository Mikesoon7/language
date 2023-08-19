//
//  UIFont.swift
//  Language
//
//  Created by Star Lord on 10/08/2023.
//

import Foundation
import UIKit

extension UIFont{
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
        UIFont(name: "Helvetica Neue Bold", size: 1 )   ?? UIFont()
    }
    static var helveticaNeueMedium: UIFont {
        UIFont(name: "Helvetica Neue Medium", size: 1) ?? UIFont()
    }

}
