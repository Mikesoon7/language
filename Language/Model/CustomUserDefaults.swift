//
//  CustomUserDefaults.swift
//  Language
//
//  Created by Star Lord on 13/08/2023.
//

import Foundation
import UIKit

class UserSettings{
    static var shared: UserSettingsManager!
}

//MARK: - Protocols
//Protcol for class, which will contain all values for apps settings
protocol UserSettingsStorage: Codable{
    var appTheme: AppTheme                          { get set }
    var appLanguage : AppLanguage                   { get set }
    var appNotifications: AppPushNotifications      { get set }
    var appSearchBarPosition: AppSearchBarPosition  { get set }
    var appSeparators: AppPairSeparators            { get set }
    var appDuplicates: AppDuplicates                { get set }
    
    func reload(newValue: SettingsOptions)
}

//Protocol for class, which will contain method to load and save settings
protocol UserSettingsManager{
    var settings: UserSettingsStorage       { get set }

    func save() -> Bool
    func use()
    func reload(newValue: SettingsOptions)
}

//MARK: - SettingsManager class
class DefaultUserSettingsManager<T: UserSettingsStorage>: UserSettingsManager {
    var settings: UserSettingsStorage
    
    private let userSettingsKey = "UserSettings"
    
    init(defaultSettings: T) {
        self.settings = Self.load(userSettingsKey: userSettingsKey) ?? defaultSettings
    }
    
    private static func load(userSettingsKey: String) -> UserSettingsStorage? {
        if let data = UserDefaults.standard.data(forKey: userSettingsKey),
           let userSettings = try? JSONDecoder().decode(T.self, from: data) {
            return userSettings
        } else {
            return nil
        }
    }
    func reload(newValue: SettingsOptions){
        settings.reload(newValue: newValue)

    }
    func save() -> Bool {
        do {
            let encodedData = try JSONEncoder().encode(settings)
            UserDefaults.standard.set(encodedData, forKey: userSettingsKey)
            return true
        } catch {
            print("Failed to save user settings: \(error)")
            return false
        }
    }

    func use(){
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.overrideUserInterfaceStyle = settings.appTheme.userInterfaceStyle
        LanguageChangeManager.shared.changeLanguage(to: settings.appLanguage.languageCode)
    }
}

enum SettingsOptions{
    case sectionHeader(String)
    case theme(AppTheme)
    case language(AppLanguage)
    case notifications(AppPushNotifications)
    case searchBarPosition(AppSearchBarPosition)
    case separators(AppPairSeparators)
    case duplicates(AppDuplicates)
}
enum AppTheme: String, Codable, CaseIterable {
    case dark, light, system
    
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
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return .unspecified
        }
    }
}
enum AppLanguage: String, Codable, CaseIterable{
    case english, russian, ukrainian
    
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
    var languageCode: String{
        switch self{
        case .english:      return "en"
        case .russian:      return "ru"
        case .ukrainian:    return "uk"
        }
    }
}

struct AppPairSeparators: Codable{
    var availableSeparators: [String]
    
    var title: String{
        return "separatorItem".localized
    }
    var value: String
}

enum AppSearchBarPosition: String, Codable{
    case onTop, atTheBottom
    
    var title: String{
        return "searchBarPositionItem".localized
    }
    var value: String{
        return ""
    }
}
enum AppDuplicates: String, Codable, CaseIterable{
    case remove, keep
    
    var title: String{
        return "duplicatesItem".localized
    }
    var value: String{
        switch self{
        case .keep:     return "keep".localized
        case .remove:   return "remove".localized
        }
    }
}

struct AppPushNotifications: Codable{
    var title: String{
        return "notificationItem".localized
    }
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

class CustomUserSettings: UserSettingsStorage, Codable {
    var appTheme: AppTheme
    
    var appLanguage: AppLanguage
    
    var appNotifications: AppPushNotifications
    
    var appSearchBarPosition: AppSearchBarPosition
    
    var appSeparators: AppPairSeparators
    
    var appDuplicates: AppDuplicates
    
    init(){
        appTheme = AppTheme.system
        appLanguage = AppLanguage.english
        appNotifications = AppPushNotifications(notificationState: .off, notificationFrequency: .everyDay, time: .initialTime)
        
        appSearchBarPosition = AppSearchBarPosition.onTop
        
        appSeparators = AppPairSeparators(availableSeparators: ["-", "–", "~", "="], value: "-")
        appDuplicates = AppDuplicates.keep
    }
    
    func reload(newValue: SettingsOptions){
        switch newValue{
        case .theme(let theme):
            self.appTheme = theme
        case .language(let language):
            self.appLanguage = language
        case .notifications(let notifications):
            self.appNotifications = notifications
        case .searchBarPosition(let position):
            self.appSearchBarPosition = position
        case .separators(let separators):
            self.appSeparators = separators
        case .duplicates(let duplicates):
            self.appDuplicates = duplicates
        case.sectionHeader(_):
            break
        }
        SettingsApplingHelper.reload(newValue: newValue)
    }
//    func provideDefaultvalues() -> UserSettingsStorage {
//        return CustomUserSettings()
//    }
}

class SettingsApplingHelper{
    static func reload(newValue: SettingsOptions){
        switch newValue{
        case .language(let language):
            let languageCode = language.languageCode
            LanguageChangeManager.shared.changeLanguage(to: languageCode)
        case .theme(let theme):
            let userInterfaceStyle = theme.userInterfaceStyle
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.overrideUserInterfaceStyle = userInterfaceStyle
        case .notifications(let notifications):
            NotificationUpdateHelper.invalidateExistingNotification()
            NotificationUpdateHelper.scheduleNotifications(for: notifications.notificationFrequency.selectedDays, at: notifications.time.value)
        case .searchBarPosition(_):
            NotificationCenter.default.post(name: .appSearchBarPositionDidChange, object: nil)
        case .separators(_):
            NotificationCenter.default.post(name: .appSeparatorDidChange, object: nil)
        case .duplicates(_):
            print("Duplicates functionality wasn't imported")
        case .sectionHeader(_):
            break
        }
    }
}

class NotificationUpdateHelper{
    //Scheduling new notification.
    static func scheduleNotifications(for days: [Int], at time: Date){
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        
        for day in days {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.weekday = day
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let content = UNMutableNotificationContent()
            content.title = "notification.notificationTitle".localized
            content.body = "notification.notificationMessage".localized
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: "notification\(day)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("Failed to schedule notification: \(error)")
                }
            }
        }
    }
    //Invalidating old notifications
    static func invalidateExistingNotification(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}


