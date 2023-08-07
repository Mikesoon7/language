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
        
        var notifications: PushNotifications
        
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
        let standartSettings = Settings(theme: .system,
                                        language: .english,
                                        notifications: PushNotifications(
//                                            permissionGranted: .denied,
                                                                         notificationState: .off,
                                                                         notificationFrequency: .everyDay,
                                                                         time: .initialTime),
                                        searchBar: .onTop,
                                        separators: .selected("-"),
                                        availabelSeparators: ["-", "–", "~", "="],
                                        duplicates: .keep)
        
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
        } else if let notification = newValue as? PushNotifications{
            settings.notifications = notification
        } else if let searchBarPosition = newValue as? AppSearchBarOnTop{
            settings.searchBar = searchBarPosition
            NotificationCenter.default.post(name: .appSearchBarPositionDidChange, object: nil)
        } else if let separators = newValue as? AppDictionarySeparators{
            settings.separators = separators
            NotificationCenter.default.post(name: .appSeparatorDidChange, object: nil)
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
    
    case notificationsNew(PushNotifications)

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
        case .notificationsNew:
            return "notificationItem".localized
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
        case .notificationsNew:
            return ""
        case .searchBar(let value):
            return value.value
        case .separators(_):
            return " "
        case .duplicates(let value):
            return value.value
        }
    }
}

struct PushNotifications: Codable{
    
    var notificationState: NotificationState
    var notificationFrequency: NotificationFrequency
    var time: NotificationTime
        
    enum NotificationState: Codable{
        case on
        case off
        
        var title: String {
            return "notification.allowNotification".localized
        }
        var value: Bool {
            return (self == .on)
        }
    }
    enum NotificationFrequency: Codable{
            
        var allCases: [NotificationFrequency] {
            [  .everyDay,
               .onTheWeekday,
               .onTheWeekend,
               .custom([]) ]
        }
        
        case everyDay
        case onTheWeekday
        case onTheWeekend
        case custom([Int])
        
        var title: String{
            return "frequency".localized
        }
        
        var selectedDays: [Int] {
            switch self{
            case .everyDay: return [1, 2, 3, 4, 5, 6, 7]
            case .onTheWeekday: return [1, 2, 3, 4, 5]
            case .onTheWeekend: return [6, 7]
            case .custom(let days): return days
            }
        }
    
        var value: String {
            switch self{
            case .everyDay:     return "everyDay".localized
            case .onTheWeekday: return "onWeekdays".localized
            case .onTheWeekend: return "onTheWeekend".localized
            case .custom:       return "custom".localized
            }
        }
        var index: IndexPath {
            switch self{
            case .everyDay:     return IndexPath(item: 0, section: 0)
            case .onTheWeekday: return IndexPath(item: 1, section: 0)
            case .onTheWeekend: return IndexPath(item: 2, section: 0)
            case .custom:       return IndexPath(item: 3, section: 0)
            }
        }
    }
    enum NotificationTime: Codable{
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
}
