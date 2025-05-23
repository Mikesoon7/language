//
//  SettingsViewModel.swift
//  Language
//
//  Created by Star Lord on 13/08/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit
import Combine

class SettingsViewModel{
    enum Output{
        case needPresentAlertWith([UIAlertAction], IndexPath)
        case needPresentSeparatorsView
        case needUpdateLanguage
        case needUpdateFont
        case needPresentFontView
        case needUpdateRowAt(IndexPath)
        case needPresentNotificationView
        case needPresentExceptionsView
        case needPresentTutorialView
    }
    
    struct SettingsSection{
        var sectionIndex: Int
        var items: [SettingsOptions]
    }

    private var settingsModel: UserSettingsStorageProtocol
    private var settingsStructure: [SettingsSection] = []
        
    var output = PassthroughSubject<Output, Never>()

    init(settingsModel: UserSettingsStorageProtocol){
        self.settingsModel = settingsModel
        configureSettingsStructure()

        NotificationCenter.default.addObserver(self, selector: #selector(appLanguageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appFontDidChange(sender: )), name: .appFontDidChange, object: nil)

    }
    
    deinit { NotificationCenter.default.removeObserver(self) }

    //MARK: Configure or update structure of settings tableView.
    func configureSettingsStructure(){
        settingsStructure = [
            SettingsSection(sectionIndex: 0,
                            items: [
                                SettingsOptions.sectionHeader("settings.sections.general"),
                                SettingsOptions.theme(settingsModel.appTheme),
                                SettingsOptions.language(settingsModel.appLanguage),
                                SettingsOptions.font(settingsModel.appFont),
                                SettingsOptions.notifications(settingsModel.appNotifications)
                            ]),
            SettingsSection(sectionIndex: 1,
                            items: [
                                SettingsOptions.sectionHeader("settings.sections.search"),
                                SettingsOptions.searchBarPosition(settingsModel.appSearchBarPosition)
                            ]),
            SettingsSection(sectionIndex: 2,
                            items: [
                                SettingsOptions.sectionHeader("settings.sections.dictionaries"),
                                SettingsOptions.separators(settingsModel.appSeparators),
                                SettingsOptions.exceptions(settingsModel.appExceptions),
                                SettingsOptions.lauchStatus(settingsModel.appLaunchStatus)
                            ])
        ]
    }
    
        
    //MARK: Retrieve indexPath for passedValue.
    func getTablePositionFor(option: SettingsOptions) -> IndexPath{
        switch option{
        case .theme(_): return IndexPath(row: 1 , section: 0)
        case .language(_): return IndexPath(row: 2 , section: 0)
        case .font(_): return IndexPath(row: 3, section: 0)
        case .notifications(_): return IndexPath(row: 4 , section: 0)
        case .searchBarPosition(_): return IndexPath(row: 1 , section: 1)
        case .separators(_): return IndexPath(row: 1 , section: 2)
        case .exceptions(_): return IndexPath(row: 2, section: 2)
        case .lauchStatus(_): return IndexPath(row: 3, section: 2)
//        case .duplicates(_): return IndexPath(row: 2 , section: 2)
        default: return IndexPath()
        }
    }
    //MARK:  Methods to set up tableView.
    func numberOfSections() -> Int{
        return settingsStructure.count
    }
    func numberofRowsInSection(section: Int) -> Int{
        return settingsStructure[section].items.count
    }
    
    //Return increased heigth for cell with images.
    func heightForRowAt(indexPath: IndexPath) -> CGFloat{
        if indexPath == self.getTablePositionFor(option: .searchBarPosition(.onTop)) {
            return .textViewGenericSize
        } else {
            return .accessoryViewHeight
        }
    }

    func dataForCellAt(indexPath: IndexPath) -> Any{
        let reference = settingsStructure[indexPath.section].items[indexPath.row]
        switch reference{
        case .sectionHeader(let header):
            return DataForSettingsHeaderCell(title: header.localized)
        case .theme(let theme):
            return DataForSettingsTextCell(title: theme.title, value: theme.value)
        case .language(let language):
            return DataForSettingsTextCell(title: language.title, value: language.value)
        case .font(let font):
            return DataForSettingsTextCell(title: font.title, value: font.value)
        case .notifications(let notifications):
            return DataForSettingsTextCell(title: notifications.title, value: nil)
        case .searchBarPosition(let position):
            return DataForSettingsImageCell(
                title: position.title, isBarOnTop: position == .onTop ? true : false) { [weak self] option in
                    self?.updateSearchBarPosition(position: option)
                }
        case .separators(let separators):
            return DataForSettingsTextCell(title: separators.title, value: nil)
        case .exceptions(let exception):
            return DataForSettingsTextCell(title: exception.title, value: nil)
        case .lauchStatus(_):
            return DataForSettingsTextCell(title: "tutorial".localized, value: nil)
        }
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
            output.send(.needPresentAlertWith(alertOptions, indexPath))
        case .language(_):
            for option in AppLanguage.allCases{
                alertOptions.append(UIAlertAction(title: option.value, style: .default, handler: { [weak self]_ in
                    self?.handleValueUpdateFor(newValue: .language(option))
                }))
            }
            output.send(.needPresentAlertWith(alertOptions, indexPath))
        case .font(_):
            output.send(.needPresentFontView)
        case .exceptions(_):
            output.send(.needPresentExceptionsView)
        case .notifications(_):
            output.send(.needPresentNotificationView)
        case .separators(_):
            output.send(.needPresentSeparatorsView)
        case .lauchStatus(_):
            output.send(.needPresentTutorialView)
        default:
            break
        }
    }
    //MARK: Updating model and local settings reference.
    //Since we use cell, which automaticaly responce on user touches, we dont need to update searchBarPosition row.
    func updateSelectedFont(font: UIFontDescriptor) {
        //        settingModel.reload(newValue: .font())
        let font = UIFont(descriptor: font, size: .bodyTextSize)
        settingsModel.reload(newValue: .font(.init(selectedFontName: font.fontName)))
        configureSettingsStructure()
        output.send(.needUpdateRowAt(self.getTablePositionFor(option: .font(.init(selectedFontName: font.fontName)))))
    }
    
        
    func updateSearchBarPosition(position: AppSearchBarPosition){
        settingsModel.reload(newValue: .searchBarPosition(position))
        configureSettingsStructure()
    }
    //Used for updatin passed value in Model and local variable.
    func handleValueUpdateFor(newValue: SettingsOptions){
        settingsModel.reload(newValue: newValue)
        configureSettingsStructure()
        output.send(.needUpdateRowAt(self.getTablePositionFor(option: newValue)))
    }
        
    @objc func appLanguageDidChange(sender: Any){
        output.send(.needUpdateLanguage)
    }
    @objc func appFontDidChange(sender: Any){
        output.send(.needUpdateFont)
    }
    
    
}


