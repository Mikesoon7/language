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
    enum Output {
        case error(Error)
        case configureStat([DictionariesAccessLog])
    }
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
    var output = PassthroughSubject<Output, Never>()
//    @Published var error: CoreDataHelper.CoreDataError?
    
    init(model: CoreDataHelper = CoreDataHelper.shared) {
        self.model = model
        model.dictionaryDidChange
            .sink { [weak self] type in
                switch type {
                case .wasDeleted(let section):
                    self?.fetch()
                    print("deleted \(section)")
                    self?.objectDidChange.send(.needDelete(section))
                case .wasAdded:
                    self?.fetch()
                    self?.objectDidChange.send(.needReload)
                case .wasUpdated(let section):
                    self?.fetch()
                    print("updated \(section)")
                    self?.objectDidChange.send(.needUpdate(section))
                }
            }
            .store(in: &cancellables)
        fetch()
    }
    func fetchStatiscticDataFor(cellIndex: IndexPath) throws {
        let dictionary = dictionaries[cellIndex.section]
        do {
            let logs = try model.fetchAllLogs(for: dictionary)
            output.send(.configureStat(logs))
//            return DataConverter(logs: logs).getDataDividedByWeeks()
        } catch {
            output.send(.error(error))
        }
    }
    func fetch(){
        do {
            dictionaries = try model.fetchDictionaries()
        } catch {
            output.send(.error(error))
            
        }
    }
    func importButtonWasTapped(){
        
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
    func dataForCell(at index: IndexPath) -> MenuCellViewModel{
        let viewModel = MenuCellViewModel(dictionary: dictionaries[index.section])
        return viewModel
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

