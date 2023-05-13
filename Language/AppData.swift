//
//  AppData.swift
//  Language
//
//  Created by Star Lord on 14/04/2023.
//

import Foundation
import UIKit

class UserSettings{
    
    static let shared = UserSettings()
    static let settingsKey = "settingsKey"
    
    var settings: Settings!
    
    private init() {
        settings = load()
    }
    
    struct Settings: Codable{
        var theme: AppTheme
        var language: AppLanguage
        var notification: AppNotification
        
        var notificationFrequency: AppNotificationFrequency
        var notificationTime: AppNotificationTime
        
        var searchBar: AppSearchBarOnTop
        
        var separators: AppDictionarySeparators
        var availabelSeparators: [String]
    
        var duplicates: AppDuplicates
        
        
    }
    
    enum AppTheme: Codable{
        case light
        case dark
        case system
        
        var title: String{
            return "themeItem".localized
        }
        var value: String{
            switch self {
            case .light:    return "lightTheme".localized
            case .dark:     return "darkTheme".localized
            case .system:   return "systemTheme".localized
            }
        }
    }
    enum AppLanguage: Codable{
        case english
        case russian
        case ukrainian
        
        var title: String{
            return "languageItem".localized
        }
        var value: String{
            switch self {
            case .english:      return "English"
            case .russian:      return "Русский"
            case .ukrainian:    return "Українська"
            }
        }
    }
    enum AppNotification: Codable{
        case allowed
        case notAllowed
        
        var title: String{
            return "allowNotification".localized
        }
        var value: Bool{
            switch self{
            case .allowed:      return true
            case .notAllowed:   return false
            }
        }
    }
    enum AppNotificationFrequency: Codable{
        case everyDay
        case onceAWeek
        case onTheWeekday
        case onTheWeekend
        
        var title: String{
            return "frequency".localized
        }
        
        var value: (value: String, index: IndexPath){
            switch self{
            case .everyDay:     return ("everyDay".localized, IndexPath(row: 0, section: 0))
            case .onceAWeek:    return ("onceAWeek".localized, IndexPath(row: 1, section: 0))
            case .onTheWeekday: return ("onWeekdays".localized, IndexPath(row: 2, section: 0))
            case .onTheWeekend: return ("onTheWeekend".localized, IndexPath(row: 3, section: 0))
            }
        }
    }
    enum AppNotificationTime: Codable{
        case initialTime
        case setTime(Date)
        
        var title: String{
            return "chooseTime".localized
        }
        var value: Date{
            switch self{
            case .initialTime: return Date()
            case .setTime(let time): return time
            }
        }
    }
    enum AppSearchBarOnTop: Codable{
        case onTop
        case onBottom
        
        var title: String{
            return "searchBarPosition".localized
        }
        var value: Bool{
            switch self{
            case .onBottom: return false
            case .onTop:    return true
            }
        }
    }
    enum AppDictionarySeparators: Codable{
        case selected(String)
        
        var title: String{
            return "dividor".localized
        }
        var selectedValue: String{
            switch self{
            case .selected(let selected):
                return selected
            }
        }
    }
    enum AppDuplicates: Codable{
        case remove
        case keep
        
        var title: String{
            return "duplicates".localized
        }
        var value: String{
            switch self{
            case .keep: return "keep".localized
            case .remove: return "remove".localized
            }
        }
    }
    
    func save(){
        if let encodedData = try? JSONEncoder().encode(UserSettings.shared.settings){
            UserDefaults.standard.set(encodedData, forKey: UserSettings.settingsKey)
        }
    }
    func load() -> Settings{
        let standartSettings = Settings(theme: .system, language: .english, notification: .notAllowed, notificationFrequency: .everyDay, notificationTime: .initialTime, searchBar: .onTop, separators: .selected("-"), availabelSeparators: ["-", "–", "~", "="], duplicates: .keep)
        
        if let userData = UserDefaults.standard.data(forKey: UserSettings.settingsKey){
            let decodedData = try? JSONDecoder().decode(Settings.self, from: userData)
            return decodedData ?? standartSettings
        } else {
            return standartSettings
        }
    }
    func reload(newValue: Any){
        if let newLanguage = newValue as? AppLanguage{
            settings.language = newLanguage
            let languageCode: String
            switch newLanguage {
            case .english:
                languageCode = "en"
            case .russian:
                languageCode = "ru"
            case .ukrainian:
                languageCode = "uk"
            }
            LanguageChangeManager.shared.changeLanguage(to: languageCode)
        } else if let newTheme = newValue as? AppTheme{
            settings.theme = newTheme
            NotificationCenter.default.post(name: .appThemeDidChange, object: nil)
            
            let userInterfaceStyle = {
                switch newTheme{
                case .dark:
                    return UIUserInterfaceStyle.dark
                case .light:
                    return UIUserInterfaceStyle.light
                case .system:
                    return UIUserInterfaceStyle.unspecified
                }
            }()
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.overrideUserInterfaceStyle = userInterfaceStyle
        } else if let notificationAvailability = newValue as? AppNotification{
            settings.notification = notificationAvailability
        } else if let notificationFrequency = newValue as? AppNotificationFrequency{
            settings.notificationFrequency = notificationFrequency
        } else if let notificationTime = newValue as? Date{
            settings.notificationTime = AppNotificationTime.setTime(notificationTime)
        } else if let searchBarPosition = newValue as? AppSearchBarOnTop{
            settings.searchBar = searchBarPosition
            NotificationCenter.default.post(name: .appSearchBarPositionDidChange, object: nil)
        } else if let separators = newValue as? AppDictionarySeparators{
            settings.separators = separators
        } else if let duplicates = newValue as? AppDuplicates{
            settings.duplicates = duplicates
        }
        save()
    }
    func use(){
        let data = load()
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.overrideUserInterfaceStyle = {
            switch data.theme{
            case .dark:
                return UIUserInterfaceStyle.dark
            case .light:
                return UIUserInterfaceStyle.light
            case .system:
                return UIUserInterfaceStyle.unspecified
            }
        }()
        let languageCode: String
        switch data.language {
        case .english:
            languageCode = "en"
        case .russian:
            languageCode = "ru"
        case .ukrainian:
            languageCode = "uk"
        }
        LanguageChangeManager.shared.changeLanguage(to: languageCode)
    }
    func updateCustomSeparators(newSeparator: String, indexPath: IndexPath?) {
        if indexPath != nil{
            settings.availabelSeparators.remove(at: indexPath!.row)
            save()
        } else {
            settings.availabelSeparators.append(newSeparator)
            save()

        }
    }
}

enum UserSettingsPresented{
    case header(String)
    
    case theme(UserSettings.AppTheme)
    case language(UserSettings.AppLanguage)
    case notifications(UserSettings.AppNotification)
    
    case searchBar(UserSettings.AppSearchBarOnTop)
    
    case separators(UserSettings.AppDictionarySeparators)
    case duplicates(UserSettings.AppDuplicates)
    
    var title: String{
        switch self{
        case .header(let title):
            return title
        case .theme(let title):
            return title.title
        case .language(let title):
            return title.title
        case .notifications(let title):
            return title.title
        case .searchBar(let title):
            return title.title
        case .separators(let title):
            return title.title
        case .duplicates(let title):
            return title.title
        }
    }
    var value: Any{
        switch self{
        case .header(_):
            return ""
        case .theme(let value):
            return value.value
        case .language(let value):
            return value.value
        case .notifications(let value):
            return value.value
        case .searchBar(let value):
            return value.value
        case .separators(_):
            return " "
        case .duplicates(let value):
            return value.value
        }
    }
}
