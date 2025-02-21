//
//  CGFloat Extension.swift
//  Learny
//
//  Created by Star Lord on 13/02/2025.
//

import Foundation
import UIKit

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
    
    static var deviceWidth = UIScreen.main.bounds.width
    
    static var longInnerSpacer = (UIDevice.isDeviceLarge ? 18 : (
        UIDevice.isDeviceCompact ? 12 : 15.0))
    static var innerSpacer = (UIDevice.isDeviceLarge ? 14 : (
        UIDevice.isDeviceCompact ? 10.0 : 12.0))
    static var nestedSpacer = (UIDevice.isDeviceLarge ? 12 : (
        UIDevice.isDeviceCompact ? 8.0 : 10.0))
    static var outerSpacer = (UIDevice.isDeviceLarge ? 22 : (
        UIDevice.isDeviceCompact ? 15 : 20.0))
    static var longOuterSpacer = (UIDevice.isDeviceLarge ? 35 : (
        UIDevice.isDeviceCompact ? 20 : 30.0))
    static var keyboardInputAccessoryViewInset = (UIDevice.current.userInterfaceIdiom == .pad ? -44.0 : 0)
    
    //Buttons
    static var textViewGenericSize = (UIDevice.isDeviceLarge ? 160 : (
        UIDevice.isDeviceCompact ? 130.0 : 150.0))
    static var largeButtonHeight = (UIDevice.isDeviceLarge ? 110 : (
        UIDevice.isDeviceCompact ? 90.0 : 104.0))
    static var genericButtonHeight = (UIDevice.isDeviceLarge ? 70 : (
        UIDevice.isDeviceCompact ? 55.0 : 60.0))
    
    static var systemButtonSize =  25.0
    static var accessoryViewHeight = 44.0
    
    //Fonts
    static var titleSize = (UIDevice.isDeviceLarge ? 25 : (
        UIDevice.isDeviceCompact ? 21 : 23.0))
    static var subtitleSize = (UIDevice.isDeviceLarge ? 23 : (
        UIDevice.isDeviceCompact ? 18 : 20.0))
    static var bodyTextSize = (UIDevice.isDeviceLarge ? 20 : (
        UIDevice.isDeviceCompact ? 16 : 18.0))
    static var subBodyTextSize = (UIDevice.isDeviceLarge ? 18 : (
        UIDevice.isDeviceCompact ? 14 : 16.0))
    static var assosiatedTextSize = (UIDevice.isDeviceLarge ? 16 : (
        UIDevice.isDeviceCompact ? 12 : 14.0))
    static var captionTextSize = (UIDevice.isDeviceLarge ? 14 : (
        UIDevice.isDeviceCompact ? 10 : 12.0))
    static var subCaptionSize = (UIDevice.isDeviceLarge ? 12 : (
        UIDevice.isDeviceCompact ? 8 : 10.0))
    
    //Corners
    static var cornerRadius =  9.0
    static var outerCornerRadius = 13.0
}
