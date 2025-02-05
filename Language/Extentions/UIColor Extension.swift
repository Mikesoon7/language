//
//  UIColor Extension.swift
//  Learny
//
//  Created by Star's MacBook Air on 29.11.2023.
//

import Foundation
import UIKit

public let shadowColorForDarkIdiom = UIColor.clear.cgColor
public let shadowColorForLightIdiom = UIColor.systemGray2.cgColor

extension UIColor {
    static var popoverSubviewsBackgroundColour: UIColor {
        UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return .tertiarySystemBackground
            } else {
                return .secondarySystemBackground
            }
        }
    }
    static var systemBackground_Secondary: UIColor {
        UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return .secondarySystemBackground
            } else {
                return .systemBackground
            }
        }
    }
    static var searchModeBackground:  UIColor {
        UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return .clear
            } else {
                return .systemGray2
            }
        }
    }
    static var searchModeSelection: UIColor {
        UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return .systemGray2
            } else {
                return .white
            }
        }
    }
}

extension UIColor{
    static func getColoursArray(_ count: Int) -> [UIColor]{
        let base: [UIColor] = [.systemRed, .systemBlue, .systemPink, .systemCyan, .systemGray,  .systemMint, .systemBrown, .systemGreen, .systemIndigo, .systemOrange, .systemPurple, .systemYellow]
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

