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
        var notificattionTime: AppNotificationTime
        
        var searchBar: AppSearchBarOnTop
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
    
    func save(){
        if let encodedData = try? JSONEncoder().encode(UserSettings.shared.settings){
            UserDefaults.standard.set(encodedData, forKey: UserSettings.settingsKey)
        }
    }
    func load() -> Settings{
        let standartSettings = Settings(theme: .system, language: .english, notification: .notAllowed, notificationFrequency: .everyDay, notificattionTime: .initialTime, searchBar: .onTop)
        
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
        } else if let newTheme = newValue as? AppTheme{
            settings.theme = newTheme
            NotificationCenter.default.post(name: .appThemeDidChange, object: nil)
            
            var userInterfaceStyle = UIUserInterfaceStyle.unspecified
            switch newTheme{
            case .dark:
                return userInterfaceStyle = .dark
            case .light:
                return userInterfaceStyle = .light
            case .system:
                return userInterfaceStyle = .unspecified
            }
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.overrideUserInterfaceStyle = userInterfaceStyle
        } else if let notificationAvailability = newValue as? AppNotification{
            settings.notification = notificationAvailability
        } else if let notificationFrequency = newValue as? AppNotificationFrequency{
            settings.notificationFrequency = notificationFrequency
        } else if let notificationTime = newValue as? Date{
            settings.notificattionTime = AppNotificationTime.setTime(notificationTime)
        } else if let searchBarPosition = newValue as? AppSearchBarOnTop{
            settings.searchBar = searchBarPosition
        }
        save()
    }
}
