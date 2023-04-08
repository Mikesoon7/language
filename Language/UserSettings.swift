//
//  UserSettings.swift
//  Language
//
//  Created by Star Lord on 05/04/2023.
//

import Foundation
import UIKit

class SettingsData {
    
    static let shared = SettingsData()
    
    struct Settings: Codable{
        var theme: AppTheme
        var language: AppLanguage
        var notification: AppNotification
        
        var searchBar: AppSearchBarPosition
    }
    
    public var settings: Settings!
    public var settingsKey = "settings"

    private init() {
        settings = load()
    }
    
    enum AppTheme: String, Codable {
        case name = "Theme"
        case light = "Light"
        case dark = "Dark"
        case deviceSettings = "System"
        
    }
    enum AppLanguage: String, Codable {
        case english = "English"
        case russian = "Русский"
        case ukrainian = "Українська"
    }
    enum AppNotification: String, Codable {
        case allowed = "Allowed"
        case notAllowed = "Not allowed"
    }
    
    enum AppSearchBarPosition: String, Codable{
        case top = "Top"
        case bottom = "Bottom"
    }
    
    //MARK: - Saving Settings
    func save(){
        if let encodeSettings = try? JSONEncoder().encode(settings){
            UserDefaults.standard.set(encodeSettings, forKey: settingsKey)
        }
    }
    //MARK: - Loading Settings
    func load() -> Settings{
        if let savedSettings = UserDefaults.standard.data(forKey: settingsKey),
           let decodedSettings = try? JSONDecoder().decode(Settings.self, from: savedSettings){
            return decodedSettings
        } else {
            return Settings(theme: .deviceSettings, language: .english, notification: .notAllowed, searchBar: .top)
        }
    }
    //MARK: - Updating Settings with unspesified type of data
    func update(newValue: Any){
        if let language = newValue as? AppLanguage{
            settings.language = language
        } else if let theme = newValue as? AppTheme{
            settings.theme = theme
            NotificationCenter.default.post(name: .appThemeDidChange, object: nil)
            
            var userInterfaceStyle = UIUserInterfaceStyle.unspecified
            switch theme{
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
        } else if let notification = newValue as? AppNotification{
            settings.notification = notification
            NotificationCenter.default.post(name: .appNotificationSettingsDidChange, object: nil)
            
            
        } else if let searchPlace = newValue as? AppSearchBarPosition{
            settings.searchBar = searchPlace
            NotificationCenter.default.post(name: .appSearchBarPositionDidChange, object: nil)
        }
        save()
    }
    func setAppLanguage(_ languageCode: String, vc: UIViewController) {
        let alertMessage = UIAlertController(
            title: NSLocalizedString("changeLanguageTitle", comment: ""),
            message: NSLocalizedString("changeLanguageDescription", comment: ""),
            preferredStyle: .alert)
        let alertActionYes = UIAlertAction(
            title: NSLocalizedString("changeOptionYes", comment: ""),
            style: .default) { _ in
                NotificationCenter.default.post(name: .appLanguageDidChange, object: nil)
                UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
                print(SettingsData.shared.settings.language)
            }
        let alertActionNo = UIAlertAction(
            title: NSLocalizedString("changeOptionLater", comment: ""),
            style: .cancel) { _ in
                return
            }
        alertMessage.addAction(alertActionNo)
        alertMessage.addAction(alertActionYes)
        vc.show(alertMessage, sender: nil)
    }
    func applySavedSettings() {
        guard let savedSettings = SettingsData.shared.settings else {
            return
        }

        var userInterfaceStyle = UIUserInterfaceStyle.unspecified
        switch savedSettings.theme {
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

        let languageCode: String
        switch savedSettings.language {
        case .english:
            languageCode = "en"
        case .russian:
            languageCode = "ru"
        case .ukrainian:
            languageCode = "uk"
        }
        LanguageChangeManager.shared.changeLanguage(to: languageCode)
    }
}


enum SettingsItems{
    // First Section
    case theme(SettingsData.AppTheme)
    case language(SettingsData.AppLanguage)
    case notification(SettingsData.AppNotification)
    // Second Section
    case searchBarPosition(SettingsData.AppSearchBarPosition)
    
    var title: String {
        switch self {
        case .theme:
            return LanguageChangeManager.shared.localizedString(forKey: "themeItem")
        case .language:
            return LanguageChangeManager.shared.localizedString(forKey: "languageItem")

        case .notification:
            return LanguageChangeManager.shared.localizedString(forKey: "notificationItem")

        case .searchBarPosition:
            return LanguageChangeManager.shared.localizedString(forKey: "searchSection")

        }
        
    }
    var value: String {
        switch self {
        case .theme(let theme):
            return theme.rawValue
        case .language(let language):
            return language.rawValue
        case .notification:
            return ""
        case .searchBarPosition(let position):
            return position.rawValue
        }
    }
//    LanguageChangeManager.shared.localizedString(forKey: "lightTheme")
//    case dark = LanguageChangeManager.shared.localizedString(forKey: "darkTheme")
//    case deviceSettings = LanguageChangeManager.shared.localizedString(forKey: "systemTheme")

    
    func updateValue(with newValue: String) {
        switch self {
        case .theme:
            if let newTheme = SettingsData.AppTheme(rawValue: newValue) {
                SettingsData.shared.update(newValue: newTheme)
            }
        case .language:
            if let newLanguage = SettingsData.AppLanguage(rawValue: newValue) {
                SettingsData.shared.update(newValue: newLanguage)
            }
        case .notification:
            if let notification = SettingsData.AppNotification(rawValue: newValue){
                print("Notifiction should be recieved")
            }
        case .searchBarPosition:
            if let newPosition = SettingsData.AppSearchBarPosition(rawValue: newValue){
                SettingsData.shared.update(newValue: newPosition)
            }
        }
    }
}
