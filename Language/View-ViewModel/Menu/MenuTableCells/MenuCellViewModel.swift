//
//  MenuCellViewModel.swift
//  Language
//
//  Created by Star Lord on 24/07/2023.
//

import Foundation
import Combine

class MenuCellViewModel {
    
    enum Output{
        case data([WeekLog])
        case error(Error)
    }
    
    var dictionary: DictionariesEntity
    var model: LogsManaging
    var output = PassthroughSubject<Output, Never>()
    
    init(model: LogsManaging = CoreDataHelper.shared ,dictionary: DictionariesEntity){
        self.model = model
        self.dictionary = dictionary
        
    }
    
    func fetchDataForStatistic(){
        do {
            let logs = try model.fetchAllLogs(for: dictionary)
            convertData(data: logs)
        } catch {
            output.send(.error(error))
        }
    }
    func convertData(data: [DictionariesAccessLog]){
        let data = DataConverter(logs: data).getDataDividedByWeeks()
        output.send(.data(data))
    }
}
