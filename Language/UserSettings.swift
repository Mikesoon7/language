//
//  UserSettings.swift
//  Language
//
//  Created by Star Lord on 05/04/2023.
//

import Foundation
import UIKit

enum SettingsType: String{
    case General = "General"
    case Dictionary = "Dictionary"
    case Search = "Search"
    case Notifications = "Notification"
}

struct SettingsSection{
    let settingsType: SettingsType.RawValue
    let title: String
    var value: String
}

class SettingsData {
    static let shared = SettingsData()

    private init() {
        loadSettings()
    }
    
    enum AppTheme: String, Codable {
        case name = "Theme"
        case light = "Light"
        case dark = "Dark"
        case deviceSettings = "System Settings"
    }
    enum AppLanguage: String, Codable {
        case english = "English"
        case russian = "Русский"
        case ukrainian = "Українська"
    }
    enum AppSearchBarPosition: String, Codable{
        case top = "Top"
        case bottom = "Bottom"
    }
    
        
    var appLanguage: AppLanguage!
    var appTheme: AppTheme!
    
    var appSearchBarPosition: AppSearchBarPosition!
    
    private let appLanguageKey = "appLanguage"
    private let appThemeKey = "appTheme"
    private let appSearchBarPositionKey = "searchBar"
    
    func saveSettings(){
        if let encodeLanguage = try? JSONEncoder().encode(appLanguage) {
            UserDefaults.standard.set(encodeLanguage, forKey: appLanguageKey)
        }
        if let encodedTheme = try? JSONEncoder().encode(appTheme) {
            UserDefaults.standard.set(encodedTheme, forKey: appThemeKey)
        }
        if let encodedPosition = try? JSONEncoder().encode(appSearchBarPosition){
            UserDefaults.standard.set(encodedPosition, forKey: appSearchBarPositionKey)
        }
    }
    
    
    
    func loadSettings() {
        if let languageData = UserDefaults.standard.data(forKey: appLanguageKey), let decodedLanguage = try? JSONDecoder().decode(AppLanguage.self, from: languageData){
            appLanguage = decodedLanguage
        } else {
            appLanguage = .english
        }
        if let themeData = UserDefaults.standard.data(forKey: appThemeKey), let decodedTheme = try? JSONDecoder().decode(AppTheme.self, from: themeData) {
            appTheme = decodedTheme
        } else {
            appTheme = .deviceSettings
        }
        if let barPosition = UserDefaults.standard.data(forKey: appSearchBarPositionKey), let decodedPosition = try? JSONDecoder().decode(AppSearchBarPosition.self, from: barPosition) {
            appSearchBarPosition = decodedPosition
        } else {
            appSearchBarPosition = .top
            
        }

    }

    func updateLanguage(newLanguage: AppLanguage){
        appLanguage = newLanguage
        UserDefaults.standard.set(newLanguage, forKey: appLanguageKey)
        NotificationCenter.default.post(name: .appLanguageDidChange, object: nil)
    }
    func updateTheme(theme: AppTheme){
        appTheme = theme
        if let encodedTheme = try? JSONEncoder().encode(theme) {
            UserDefaults.standard.set(encodedTheme, forKey: appThemeKey)
        }
        NotificationCenter.default.post(name: .appThemeDidChange, object: nil)
    }
    func updatePosition(position: AppSearchBarPosition){
        appSearchBarPosition = position
        if let encodedPosition = try? JSONEncoder().encode(position) {
            UserDefaults.standard.set(encodedPosition, forKey: appSearchBarPositionKey)
        }
        NotificationCenter.default.post(name: .appSearchBarPositionDidChange, object: nil)

    }
    
    
    func registerSettingsNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange(sender:)), name: .appThemeDidChange, object: nil)
    }
    
    @objc func themeDidChange(sender: Any?){
        let appTheme = SettingsData.shared.appTheme
        var userInterfaceStyle = UIUserInterfaceStyle.unspecified
        switch appTheme{
        case .light:
            userInterfaceStyle = .light
        case .dark:
            userInterfaceStyle = .dark
        case .deviceSettings:
            userInterfaceStyle = .unspecified
        default:
            break
        }
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.overrideUserInterfaceStyle = userInterfaceStyle
    }
}

protocol SettingsRepresentation{
    var title: String { get }
    var value: String { get }
    
    func updateValue(with newValue: String)
}

enum SettingsItem: SettingsRepresentation{
    case theme(SettingsData.AppTheme)
    case language(SettingsData.AppLanguage)
    case searchBarPosition(SettingsData.AppSearchBarPosition)
    
    var title: String {
            switch self {
            case .theme:
                return "Theme"
            case .language:
                return "Language"
            case .searchBarPosition:
                return "Search bar"
            }
        }

        var value: String {
            switch self {
            case .theme(let theme):
                return theme.rawValue
            case .language(let language):
                return language.rawValue
            case .searchBarPosition(let position):
                return position.rawValue
            }
        }

        func updateValue(with newValue: String) {
            switch self {
            case .theme:
                if let newTheme = SettingsData.AppTheme(rawValue: newValue) {
                    SettingsData.shared.updateTheme(theme: newTheme)
                }
            case .language:
                if let newLanguage = SettingsData.AppLanguage(rawValue: newValue) {
                    SettingsData.shared.updateLanguage(newLanguage: newLanguage)
                }
            case .searchBarPosition:
                break
            }
        }
    }
