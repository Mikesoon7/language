//
//  CustomUserDefaults.swift
//  Language
//
//  Created by Star Lord on 13/08/2023.
//

import Foundation
import UIKit

//MARK: - Protocols
protocol UserSettingsManagerProtocol{
    func update <T: Codable>(_ value: T, forKey key: String)
    func load   <T: Codable>(_ type: T.Type, forKey key: String) -> T?
    func use(theme: AppTheme, language: AppLanguage)
}
extension UserSettingsManagerProtocol{
    func update <T: Codable>(_ value: T, forKey key: String){
        if let data = try? JSONEncoder().encode(value){
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    func load   <T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        if let savedData = UserDefaults.standard.data(forKey: key) {
            return try? JSONDecoder().decode(T.self, from: savedData)
        }
        return nil
    }
    func use(theme: AppTheme, language: AppLanguage){
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.overrideUserInterfaceStyle = theme.userInterfaceStyle
        LanguageChangeManager.shared.changeLanguage(to: language.languageCode)
    }
}
protocol UserSettingsStorageProtocol{
    var manager: UserSettingsManagerProtocol        { get }
    var helper: UserSettingsUpdateHelper            { get }
    var appLaunchStatus: AppLaunchStatus            { get set }
    var appTheme: AppTheme                          { get set }
    var appLanguage : AppLanguage                   { get set }
    var appNotifications: AppPushNotifications      { get set }
    var appSearchBarPosition: AppSearchBarPosition  { get set }
    var appSeparators: AppPairSeparators            { get set }
    var appExceptions: AppExceptions                { get set }
//    var appDuplicates: AppDuplicates                { get set }
    
    init(manager: UserSettingsManagerProtocol, helper: UserSettingsUpdateHelper)
    
    func reload(newValue: SettingsOptions)
}

protocol UserSettingsUpdateHelper{
    func apply(newValue: SettingsOptions)
}

//MARK: - Classes
class UserSettingsManager: UserSettingsManagerProtocol{ }

class UserSettings: UserSettingsStorageProtocol{
    
//    static var shared = UserSettings()
    
    var manager: UserSettingsManagerProtocol
    var helper: UserSettingsUpdateHelper
    
    var appLaunchStatus: AppLaunchStatus{
        get {
            manager.load(AppLaunchStatus.self, forKey: AppLaunchStatus.key) ?? .isFirst
        }
        set {
            manager.update(newValue, forKey: AppLaunchStatus.key)
        }
    }
    var appTheme: AppTheme{
        get{
            manager.load(AppTheme.self, forKey: AppTheme.key) ?? .system
        }
        set{
            manager.update(newValue, forKey: AppTheme.key)
            apply(newValue: .theme(newValue))
        }
    }
    
    var appLanguage: AppLanguage{
        get{
            manager.load(AppLanguage.self, forKey: AppLanguage.key) ?? .english
        }
        set{
            manager.update(newValue, forKey: AppLanguage.key)
            //Maybe this isn't the right play to perform it. But every language change should invalidate the notification settigns and update language.
            manager.update(self.appNotifications, forKey: AppPushNotifications.key)
            apply(newValue: .language(newValue))
        }
    }
    
    var appNotifications: AppPushNotifications{
        get{
            manager.load(AppPushNotifications.self, forKey: AppPushNotifications.key) ?? .init(notificationState: .off, notificationFrequency: .everyDay, time: .initialTime)
        }
        set{
            manager.update(newValue, forKey: AppPushNotifications.key)
            apply(newValue: .notifications(newValue))
        }
    }
    
    var appSearchBarPosition: AppSearchBarPosition{
        get{
            manager.load(AppSearchBarPosition.self, forKey: AppSearchBarPosition.key) ?? .atTheBottom
        }
        set{
            manager.update(newValue, forKey: AppSearchBarPosition.key)
            apply(newValue: .searchBarPosition(newValue))
        }
    }
    
    var appSeparators: AppPairSeparators{
        get{
            manager.load(AppPairSeparators.self, forKey: AppPairSeparators.key) ?? .init(availableSeparators: ["-", "–", "~", "="], value: "-")
        }
        set{
            manager.update(newValue, forKey: AppPairSeparators.key)
            apply(newValue: .separators(newValue))
        }
    }
    var appExceptions: AppExceptions{
        get{
            manager.load(AppExceptions.self, forKey: AppExceptions.key) ?? .init(availableExceptionsBySections: [AppExceptions.Selection(content: ["1", "2", "-"], isSelected: true)])
        }
        set{
            manager.update(newValue, forKey: AppExceptions.key)
            apply(newValue: .exceptions(newValue))
        }
    }

    required init(manager: UserSettingsManagerProtocol = UserSettingsManager(), helper: UserSettingsUpdateHelper = SettingsUpdateHelper()){
        self.manager = manager
        self.helper = helper
    }
    
    func reload(newValue: SettingsOptions) {
        switch newValue{
        case .language(let language):
            self.appLanguage = language
        case .theme(let theme):
            self.appTheme = theme
        case .notifications(let notifications):
            self.appNotifications = notifications
        case .searchBarPosition(let position):
            self.appSearchBarPosition = position
        case .separators(let separator):
            self.appSeparators = separator
        case .exceptions(let exeptions):
            self.appExceptions = exeptions
        case .lauchStatus(let status):
            self.appLaunchStatus = status
        case .sectionHeader(_):
            break
        }

    }
    private func apply(newValue: SettingsOptions){
        helper.apply(newValue: newValue)
    }
}
class SettingsUpdateHelper: UserSettingsUpdateHelper{
    func apply(newValue: SettingsOptions){
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
        case .sectionHeader(_), .lauchStatus(_), .exceptions(_):
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


//MARK: - UserSettings CustomObjects.
enum SettingsOptions: Codable{
    case sectionHeader(String)
    case lauchStatus(AppLaunchStatus)
    case theme(AppTheme)
    case language(AppLanguage)
    case notifications(AppPushNotifications)
    case searchBarPosition(AppSearchBarPosition)
    case separators(AppPairSeparators)
    case exceptions(AppExceptions)
}

enum AppLaunchStatus: Codable{
    static let key = "isFirstLaunch"
    case isFirst, isNotFirst
    
    var isFirstLaunch: Bool {
        switch self{
        case .isFirst: return true
        case .isNotFirst: return false
        }
    }
}

enum AppTheme: String, Codable, CaseIterable {
    static let key = "AppTheme"
    case dark, light, system
    
    var title: String{
        return "settings.general.theme".localized
    }
    var value: String{
        switch self {
        case .light:    return "settings.general.theme.light".localized
        case .dark:     return "settings.general.theme.dark".localized
        case .system:   return "settings.general.theme.system".localized
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
    static let key = "AppLanguage"
    case english, russian, ukrainian
    
    var title: String{
        return "settings.general.language".localized
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
    static let key = "AppSeparators"

    var availableSeparators: [String]
    
    var title: String{
        return "settings.dictionaries.separator".localized
    }
    var value: String
    var maxCapacity: Int = 5
}

struct AppExceptions: Codable{
    static let key = "AppExeptions"
    
    struct Selection: Codable {
        var content: [String]
        var isSelected: Bool
    }

    var availableExceptionsBySections: [Selection]
    
        
    var title: String {
        return "settings.dictionaries.exception".localized
    }
    
    var selectedExceptions: [Selection] {
        return availableExceptionsBySections.filter { $0.isSelected }
    }
    
    var availableExceptionsInString: String {
        return selectedExceptions.map({$0.content}).joined().joined(separator: " ")
    }

}

enum AppSearchBarPosition: String, Codable{
    static let key = "AppSearchBarPosition"
    case onTop, atTheBottom
    
    var title: String{
        return "settings.search.barPosition".localized
    }
    var value: String{
        return ""
    }
}
enum AppDuplicates: String, Codable, CaseIterable{
    static let key = "AppDuplicates"
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
    static let key = "AppNotifications"
    var title: String{
        return "settings.general.notification".localized
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


