//
//  MenuCellViewModel.swift
//  Language
//
//  Created by Star Lord on 24/07/2023.
//

import Foundation
import Combine
import UIKit
import DGCharts


class StatisticCellViewModel {
    
    enum StatisticCellOutput{
        case data([WeekLog])
        case error(Error)
    }
    
    var dictionary: DictionariesEntity
    private var dataModel: Dictionary_Words_LogsManager
    private var settingsModel: UserSettingsStorageProtocol
    
    var output = PassthroughSubject<StatisticCellOutput, Never>()

    init(dataModel: Dictionary_Words_LogsManager, settingModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity){
        self.dataModel = dataModel
        self.settingsModel = settingModel
        self.dictionary = dictionary
    }

    func fetchDataForStatisticCell(){
        do {
            let logs = try dataModel.fetchAllLogs(for: dictionary)
            convertData(data: logs)
        } catch {
            output.send(.error(error))
        }
    }
    
    private func convertData(data: [DictionariesAccessLog]){
        let locale = Locale(identifier: settingsModel.appLanguage.languageCode)
        let data = DataConverter(logs: data, locale: locale).getDataDividedByWeeks()
        output.send(.data(data))
    }
    
}
