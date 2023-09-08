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
    
    var output = PassthroughSubject<StatisticCellOutput, Never>()

    init(model: Dictionary_Words_LogsManager ,dictionary: DictionariesEntity){
        self.dataModel = model
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
        let data = DataConverter(logs: data).getDataDividedByWeeks()
        output.send(.data(data))
    }
    
}
