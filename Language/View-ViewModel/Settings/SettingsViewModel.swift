//
//  SettingsViewModel.swift
//  Language
//
//  Created by Star Lord on 13/08/2023.
//

import UIKit
import Combine

class SettingsViewModel{
//    enum SettingsReference: Int{
//        case firstSectionTitle = 0 , theme, language, notifications,
//             secondSectionTitle, searchBarPosition,
//             thirdSectionTitle, separators, duplicates
//
//        var indexPath: IndexPath {
//            switch self{
//            case .firstSectionTitle:    return IndexPath(item: self.rawValue, section: 0)
//            case .theme:                return IndexPath(item: self.rawValue, section: 0)
//            case .language:             return IndexPath(item: self.rawValue, section: 0)
//            case .notifications:        return IndexPath(item: self.rawValue, section: 0)
//
//            case .secondSectionTitle:   return IndexPath(item: self.rawValue, section: 1)
//            case .searchBarPosition:    return IndexPath(item: self.rawValue, section: 1)
//
//            case .thirdSectionTitle:    return IndexPath(item: self.rawValue, section: 2)
//            case .separators:           return IndexPath(item: self.rawValue, section: 2)
//            case .duplicates:           return IndexPath(item: self.rawValue, section: 2)
//            }
//        }
//    }
        
    
//    }
    enum Output{
        case needPresentAlertWith([UIAlertAction])
        case needPresentView(UIViewController)
        case needUpdateLanguage
        case needUpdateRowAt(IndexPath)
        case needPresentNotificationView
    }
    struct SettingsSection{
        var sectionIndex: Int
        var items: [SettingsOptions]
    }

    private var settingsManager: UserSettingsManager
    private var settingsStorage: UserSettingsStorage!
    private var settingsStructure: [SettingsSection]
    
//    private var settingsReference: [SettingsReference] = [
//        .firstSectionTitle, .theme, .language, .notifications,
//        .secondSectionTitle, .searchBarPosition,
//        .thirdSectionTitle, .separators, .duplicates
//    ]
    
    var output = PassthroughSubject<Output, Never>()

    init(){
        settingsManager = UserSettings.shared
        settingsStorage = settingsManager.settings
        settingsStructure = [
            SettingsSection(sectionIndex: 0,
                            items: [
                                SettingsOptions.sectionHeader("generalSection"),
                                SettingsOptions.theme(settingsStorage.appTheme),
                                SettingsOptions.language(settingsStorage.appLanguage),
                                SettingsOptions.notifications(settingsStorage.appNotifications)
                            ]),
            SettingsSection(sectionIndex: 1,
                            items: [
                                SettingsOptions.sectionHeader("searchSection"),
                                SettingsOptions.searchBarPosition(settingsStorage.appSearchBarPosition)
                            ]),
            SettingsSection(sectionIndex: 2,
                            items: [
                                SettingsOptions.sectionHeader("dictionaries"),
                                SettingsOptions.separators(settingsStorage.appSeparators),
                                SettingsOptions.duplicates(settingsStorage.appDuplicates)
                            ])
        ]
        NotificationCenter.default.addObserver(self, selector: #selector(appLanguageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
    }
    func getTablePositionFor(option: SettingsOptions) -> IndexPath{
    
//        let section = settingsStructure.map { section in
//            section.items.contains { option in
//                <#code#>
//            }
//        }
//
//        settingsStructure.map { section in
//            section.items.contains(where: {$0 == option})
//        }
                switch option{
        case .theme(_): return IndexPath(row: 1 , section: 0)
        case .language(_): return IndexPath(row: 2 , section: 0)
        case .notifications(_): return IndexPath(row: 3 , section: 0)
        case .searchBarPosition(_): return IndexPath(row: 1 , section: 1)
        case .separators(_): return IndexPath(row: 1 , section: 2)
        case .duplicates(_): return IndexPath(row: 2 , section: 2)
        default: return IndexPath()
        }
    }
    
    //MARK: - Settings table view Configuration
    func numberOfSections() -> Int{
        return settingsStructure.count
    }
    func numberofRowsInSection(section: Int) -> Int{
        return settingsStructure[section].items.count
    }
    func dataForCellAt(indexPath: IndexPath) -> Any{
        let reference = settingsStructure[indexPath.section].items[indexPath.row]
        var title = ""
        var value = ""
        switch reference{
        case .sectionHeader(let header):
            return DataForSettingsHeaderCell(title: header.localized)
        case .theme(let theme):
            title = theme.title
            value = theme.value
        case .language(let language):
            title = language.title
            value = language.value
        case .notifications(let notifications):
            title = notifications.title
            value = ""
        case .searchBarPosition(let position):
            return DataForSettingsImageCell(
                title: position.title, isBarOnTop: position == .onTop ? true : false)
        case .separators(let separators):
            title = separators.title
            value = ""
        case .duplicates(let duplicates):
            title = duplicates.title
            value = duplicates.value
        }
        return DataForSettingsTextCell(title: title, value: value)
    }
    func didSelectRowAt(indexPath: IndexPath){
        let subject = settingsStructure[indexPath.section].items[indexPath.row]
        var alertOptions = [UIAlertAction]()
        switch subject{
        case .theme(_):
            for option in AppTheme.allCases{
                alertOptions.append(UIAlertAction(title: option.value, style: .default, handler: { [weak self]_ in
                    self?.handleValueUpdateFor(newValue: .theme(option))
                }))
            }
            output.send(.needPresentAlertWith(alertOptions))
        case .language(_):
            for option in AppLanguage.allCases{
                alertOptions.append(UIAlertAction(title: option.value, style: .default, handler: { [weak self]_ in
                    self?.handleValueUpdateFor(newValue: .language(option))
                }))
            }
            output.send(.needPresentAlertWith(alertOptions))
        case .duplicates(_):
            for option in AppDuplicates.allCases{
                alertOptions.append(UIAlertAction(title: option.value, style: .default, handler: { [weak self]_ in
                    self?.handleValueUpdateFor(newValue: .duplicates(option))
                }))
            }
            output.send(.needPresentAlertWith(alertOptions))
        case .notifications(_):
            output.send(.needPresentNotificationView)
        case .separators(_):
            output.send(.needPresentView(SeparatorsVC()))
        default:
            break
        }
    }
    func handleValueUpdateFor(newValue: SettingsOptions){
        settingsStorage.reload(newValue: newValue)
        switch newValue{
        case .language(_):
            print(settingsStorage.appLanguage)
        case .theme(_):
            print(settingsStorage.appTheme)
        default: print("update method worked")
        }
        output.send(.needUpdateRowAt(self.getTablePositionFor(option: newValue)))
    }
    func heightForRowAt(indexPath: IndexPath) -> CGFloat{
        if indexPath == self.getTablePositionFor(option: .searchBarPosition(.onTop)) {
            return 150
        } else {
            return 44
        }
    }
    
    @objc func appLanguageDidChange(sender: Any){
        output.send(.needUpdateLanguage)
    }
    
}


