//
//  MenuViewModel.swift
//  Language
//
//  Created by Star Lord on 07/07/2023.
//

import Foundation
import CoreData
import Combine

final class MenuViewModel{
    enum ChangeType{
        case needReload
        case needDelete(Int)
        case needUpdate(Int)
    }

    private let model: CoreDataHelper
    private var cancellables = Set<AnyCancellable>()
    var dictionaries: [DictionariesEntity] = []
    
    private var displayStatistic = false
    
    @Published var objectDidChange = PassthroughSubject<ChangeType, Never>()
    @Published var error: CoreDataHelper.CoreDataError?
    
    init(model: CoreDataHelper = CoreDataHelper.shared) {
        self.model = model
        model.dictionaryDidChange
            .sink { [weak self] type in
                switch type {
                case .wasDeleted(let section):
                    self?.fetch()
                    self?.objectDidChange.send(.needDelete(section))
                case .wasAdded:
                    self?.fetch()
                    self?.objectDidChange.send(.needReload)
                case .wasUpdated(let section):
                    self?.fetch()
                    self?.objectDidChange.send(.needUpdate(section))
                }
            }
            .store(in: &cancellables)
        fetch()
    }
    func configureStatistic(){
        
    }
    func fetch(){
        do {
            dictionaries = try model.fetchDictionaries()
        } catch {
            self.error = error as? CoreDataHelper.CoreDataError
        }
    }
        
    
    func deleteDictionary(at index: IndexPath) {
        let dictionary = dictionaries[index.section]
        do {
            try model.delete(dictionary: dictionary)
        } catch {
            print("dictionary not found")
        }
    }
    func editDictionary(at index: IndexPath) -> EditView{
        let dictionary = dictionaries[index.section]
        let vc = EditView(dictionary: dictionary)
        return vc
    }
    
    //MARK: - Methods for tableView
    func dataForCell(at index: IndexPath) -> DictionariesEntity{
        return dictionaries[index.section]
    }
    func numberOfCells() -> Int{
        return dictionaries.count + 1
    }

}

//func configureDataForDiagram(with data: [Date: Double]) -> ChartData {
//    var entries = [BarChartDataEntry]()
//    let formatter = DateFormatter()
//    formatter.dateFormat = "dd"
//    data.forEach { (key: Date, value: Double) in
//        entries.append(BarChartDataEntry(x: Double(formatter.string(from: key))!, y: value))
//    }
//    let barDataSet = BarChartDataSet(entries: entries)
//    let chart = ChartData(dataSet: barDataSet)
//    return  chart
//}

