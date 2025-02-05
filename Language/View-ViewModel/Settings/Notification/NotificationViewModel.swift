//
//  NotificationViewModel.swift
//  Language
//
//  Created by Star Lord on 27/07/2023.
//
//  REFACTORING STATE: NOT CHECKED

// Quick intro.
// Im haven't found the way to make it less hardcoded, so im using SettingsReference and creeation property with the ordered elements for Notifications settings.

import Combine
import UserNotifications
import UIKit

class NotificationViewModel{
    
    //MARK: - Enums
    //Representing notification settings structure.
    enum SettingsReference{
        case state
        case frequency
        case time
        
        var indexPath: IndexPath {
            switch self{
            case .state: return IndexPath(item: 0, section: 0)
            case .frequency: return IndexPath(item: 0, section: 1)
            case .time: return IndexPath(item: 1, section: 1)
            }
        }
    }
        
    enum Output {
        case shouldValidateFirstStage
        case shouldValidateFinalStage

        //Updating row to reflect on changing seleted value
        case shouldUpdateTableRowAt(IndexPath)
        
        //Sending in case of an error or notification denial
        case error(Error)
        case presentNotificationInformAlert
    }
      
    //MARK: - Properties
    private var settingsModel: UserSettingsStorageProtocol
    private lazy var notification = settingsModel.appNotifications
    private var notificationHelper: NotificationHelper = NotificationHelper()
    
    public var output = PassthroughSubject<Output, Never>()
    
    //If we change any settings, we toggle this property.
    private var needUpdate: Bool = false
    
    //Settings sctructure
    private var settingReference: [[SettingsReference]] = [
        [.state ],
        [.frequency,
         .time]
    ]
    //If the saved frequency was custom, we saving array of days indexes.
    private lazy var selectedNotificationDays: [Int] = {
        switch settingsModel.appNotifications.notificationFrequency {
        case .custom(let array):
            return array
        default:
            return []
        }
    }()
    
    init(settingsModel: UserSettingsStorageProtocol){
        self.settingsModel = settingsModel
    }
    //MARK: - Methods
    //If notification are off, view wont show all section, but the first with state switch
    public func notificationAreOn() -> Bool{
        notification.notificationState.value
    }
    public func customFrequencyIsOn() -> Bool{
        switch notification.notificationFrequency{
        case .custom(_): return true
        default:         return false
        }
    }
    
    func getSelectedDays() -> [Int]{
        selectedNotificationDays
    }
    func getCurrentLocale() -> Locale {
        let lnCode = settingsModel.appLanguage.languageCode
        return Locale(identifier: lnCode)
    }
    
    //MARK: - Methods for UITableView
    func numberOfCellsIn(section: Int) -> Int{
        return settingReference[section].count
    }
    func numberOfSections() -> Int{
        return settingReference.count
    }
    //Generic data method for Cells assigned to picker.
    func dataForCellAt(indexPath: IndexPath) -> DataForNotificationTextCell{
        switch settingReference[indexPath.section][indexPath.row] {
        case .frequency:
            let frequency = notification.notificationFrequency
            return DataForNotificationTextCell(label: frequency.title,
                                   value: frequency.value)
        default:
            let time = notification.time
            return DataForNotificationTextCell(label: time.title,
                                   value: time.value.formatted(date: .omitted, time: .shortened))
        }
    }

    //MARK: - Methods for UIPickerView
    func numberOfRowsInComponent() -> Int{
        notification.notificationFrequency.allCases.count
    }
    func titleForRow(for row: Int) -> String{
        notification.notificationFrequency.allCases[row].value
    }
    //Initial value for frequency picker.
    func selectedRowForFrequencyPicker() -> IndexPath {
        let index = notification.notificationFrequency.index
        return index
    }
    //Initial value for datePicker.
    func selectedDateForTimePicker() -> Date{
        return notification.time.value
    }
    
    //MARK: - Methods to respond on changes
    // Calls after checking permission for presenting notifications.
    func toggleNotificationSwitch() {
        let currentState = notification.notificationState
        notification.notificationState = currentState.value ? .off : .on
        needUpdate = true
        output.send(.shouldValidateFirstStage)
    }
    //Calls when user changes value on frequency picker.
    func updateFrequency(row index: Int){
        let newValue = notification.notificationFrequency.allCases[index]
        switch newValue{
        case .custom(_):
            self.notification.notificationFrequency = .custom(selectedNotificationDays)
            output.send(.shouldUpdateTableRowAt(SettingsReference.frequency.indexPath))
        default:
            self.notification.notificationFrequency = newValue
            output.send(.shouldUpdateTableRowAt(SettingsReference.frequency.indexPath))
        }
        output.send(.shouldValidateFinalStage)
        needUpdate = true
    }
    //Calls when user updates value on datePicker.
    func updateNotificationTime(with time: Date){
        notification.time = .setTime(time)
        needUpdate = true
        output.send(.shouldUpdateTableRowAt(SettingsReference.time.indexPath))
    }
    //Calls when user selects new day in DayPicker.
    func updateSelectedDaysSet(with tag: Int){
        switch notification.notificationFrequency {
            case .custom(var days):
                if days.contains(tag) {
                    days.removeAll(where: { $0 == tag })
                } else {
                    days.append(tag)
                }
                notification.notificationFrequency = .custom(days)
            needUpdate = true
            default:
                break
            }
    }

    
    
    //MARK: - Saving
    //If any changed were made, we clear existing and creating new notifications.
    func save(){
        if needUpdate {
            settingsModel.reload(newValue: .notifications(notification))
        }
    }
}
//MARK: NotificationsStateDelegate conforming.
extension NotificationViewModel: NotificationsStateDelegate{
    func switchValueChanged(isOn: Bool) {
        if isOn{
            self.notificationHelper.requestNotificationPermission { (granted, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self.output.send(.error(error))
                        self.output.send(.shouldUpdateTableRowAt(IndexPath(item: 0, section: 0)))
                    } else if !granted {
                        self.output.send(.presentNotificationInformAlert)
                        self.output.send(.shouldUpdateTableRowAt(IndexPath(item: 0, section: 0)))
                    } else {
                        self.toggleNotificationSwitch()
                    }
                }
            }
        } else {
            self.toggleNotificationSwitch()
        }
    }
}
//MARK: - Custom notification helper class
class NotificationHelper{
    //Checking permitiion to push notifications
    func requestNotificationPermission(completion: @escaping (Bool, Error? ) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                completion(true, nil)
            case .denied:
                completion(false, nil)
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        completion(false, error)
                    } else {
                        completion(granted, nil)
                    }
                }
            default:
                completion(false, nil)
            }
        }
    }
}
