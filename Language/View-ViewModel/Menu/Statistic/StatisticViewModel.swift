//
//  StatisticViewModel.swift
//  Language
//
//  Created by Star Lord on 04/09/2023.
//

import Foundation
import DGCharts
import Combine
import UIKit

struct SelectedRange{
    var beginDate: Date
    var endDate: Date
}
private struct DictionaryByAccessCount{
    var dictionary: DictionariesEntity
    var accessCount: Int
}

class StatisticViewModel{
    enum StatisticViewOutput{
        case data([DictionaryLogData])
        case pieData(PieChartDataTotal)
        case selectedRangeWasUpdated(SelectedRange)
        case shouldUpdateCustomInterval
        case shouldDefineAllowedRange(DateInterval)
        case error(Error)
    }

    private var dataModel: Dictionary_Words_LogsManager

    private var data: PieChartData = .init()
    private var filteredData: PieChartData = .init()

    private var logsForConverting: [LogsForDictionary] = []
    private var converter: DateLogExtractor!
    
    private var colours = [UIColor]()
    private var selectedEntry: PieChartDataEntry? = nil

    private var beginDate: Date = Date()
    private var endDate: Date = Date()
    
    private var totalAccessNumber: Int = 0
    private var dataForLegendTable = [StatisticCellData]()

    let viewOutput = PassthroughSubject<StatisticViewOutput, Never>()

    init(dataModel: Dictionary_Words_LogsManager){
        self.dataModel = dataModel

    }

    func initialStatisticDate() -> Date{
        return Date()
    }
    func endStatisticDate() -> Date{
        return Date()
    }

    ///Fetch the existing dictionaries. If succeed, passes fetched data to converter.
    func fetchDataForStatisticPieView(){
        var dictionaries = [DictionariesEntity]()
        do {
            let dictionaries = try dataModel.fetchDictionaries()
            print("dictioanries were fetched")
            convertDataForLegendTable(data: dictionaries)
            
        } catch {
            viewOutput.send(.error(error))
        }
    }

    func didSelectEntry(_ entry: PieChartDataEntry?){
        guard let entry = entry, selectedEntry != entry else {
            selectedEntry = nil
            viewOutput.send(.pieData(
                PieChartDataTotal(dataForPie: data, totalNumber: totalAccessNumber)))
            return
        }
        let mainDataSet = data.dataSet
        let entryToPresent = PieChartDataEntry(value: entry.value, label: entry.data as? String ?? "")
        selectedEntry = entryToPresent
        
        let filteredDataSet = PieChartDataSet(entries: [entryToPresent])
        let entryIndex = mainDataSet?.entryIndex(entry: entry)
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        formatter.multiplier = 1
        formatter.maximumFractionDigits = 1

        filteredDataSet.colors = [colours[entryIndex ?? 0]]
        filteredDataSet.valueFormatter = DefaultValueFormatter(formatter: formatter)
        print(filteredDataSet.valueFormatter)
        let pieChartData = PieChartData(dataSet: filteredDataSet)
        pieChartData.setValueFont(.helveticaNeueMedium.withSize(15))
        
        viewOutput.send(.pieData(PieChartDataTotal(dataForPie: pieChartData, totalNumber: Int(entryToPresent.value))))
    }

    private func convertDataForLegendTable(data: [DictionariesEntity]){
        print("Started converting passed dictionaries")
        var dictionaries = [DictionaryByAccessCount]()
        var dictionariesForConverter: [LogsForDictionary] = []
        
        var dataForPieChartByEntries = [PieChartDataEntry]()
        
        var dataForLegendCell = [StatisticCellData]()
        
        colours = UIColor.getColoursArray(data.count)
        
        for dict in data{
            do {
                let assosiatedLogs = try dataModel.fetchAllLogs(for: dict)
                for log in assosiatedLogs{
                    print(log.accessDate)
                }
                let accessCount: Int = assosiatedLogs.reduce( 0, { partialResult, log in
                    return partialResult + Int(log.accessCount)
                })
                dictionariesForConverter.append(LogsForDictionary(dictionary: dict, affiliatedLogs: assosiatedLogs))

                dictionaries.append(DictionaryByAccessCount(
                    dictionary: dict,
                    accessCount: accessCount))
            } catch {
                viewOutput.send(.error(error))
            }
        }
        logsForConverting = dictionariesForConverter
        converter = DateLogExtractor(logs: logsForConverting)
        self.beginDate = converter.sortedLogsDataRange.start
        self.endDate = converter.sortedLogsDataRange.end
        self.viewOutput.send(.shouldDefineAllowedRange(DateInterval(start: beginDate, end: endDate)))
        self.viewOutput.send(.selectedRangeWasUpdated(SelectedRange(beginDate: beginDate, endDate: endDate)))
        
//        let converter = DateLogExtractor(logs: dictionariesForConverter)
//        let testConverter = TestDateLogExtractor()
//
//        testConverter.getCurrentWeekLogs()
//        converter.getCurrentWeekLogs()
//        converter.getCurrentMonthLogs()
//        converter.getPreviousMonthLogs()
        dictionaries = dictionaries.sorted(by: {$0.accessCount > $1.accessCount})
        
        self.totalAccessNumber = dictionaries.map({$0.accessCount}).reduce(0, +)
        
        for (index, dict) in dictionaries.enumerated(){
            
            let percents = String(format: "%.1f", Double(dict.accessCount) / Double(totalAccessNumber) * 100.0) + "%"
            
            dataForPieChartByEntries.append(PieChartDataEntry(value: Double(dict.accessCount), label: percents, data: dict.dictionary.language))
            
            dataForLegendCell.append(StatisticCellData(
                colour: colours[index],
                title: dict.dictionary.language,
                value: dict.accessCount,
                percents: percents))
        }
        self.dataForLegendTable = dataForLegendCell
        
        let dataForPieChartInSet = PieChartDataSet(entries: dataForPieChartByEntries)
        dataForPieChartInSet.colors = colours
        let pieChartData = PieChartData(dataSet: dataForPieChartInSet)
        pieChartData.setValueFont(.helveticaNeueMedium.withSize(15))
        pieChartData.setValueTextColor(.white)
        
        pieChartData.dataSet?.drawValuesEnabled = false

        self.data = pieChartData
        viewOutput.send(.pieData(PieChartDataTotal(dataForPie: pieChartData, totalNumber: totalAccessNumber)))
        
    }
    func updateDisplayedRangeWith(_ data: [LogsForDictionary]){
        var filteredData = [PieChartData]()
        var dictionaries = [DictionaryByAccessCount]()
        
        var dataForPieChartByEntries = [PieChartDataEntry]()
        var dataForLegendCell = [StatisticCellData]()

        for dict in data{
            let totalCount = dict.affiliatedLogs.reduce(0) { partialResult, log in
                return partialResult + Int(log.accessCount)
            }
            dictionaries.append(DictionaryByAccessCount(dictionary: dict.dictionary, accessCount: totalCount))
        }
        dictionaries = dictionaries.sorted(by: {$0.accessCount > $1.accessCount})
        
        self.totalAccessNumber = dictionaries.map({$0.accessCount}).reduce(0, +)

        for (index, dict) in dictionaries.enumerated(){
            
            let percents = String(format: "%.1f", Double(dict.accessCount) / Double(totalAccessNumber) * 100.0) + "%"
            
            dataForPieChartByEntries.append(PieChartDataEntry(value: Double(dict.accessCount), label: percents, data: dict.dictionary.language))
            
            dataForLegendCell.append(StatisticCellData(
                colour: colours[index],
                title: dict.dictionary.language,
                value: dict.accessCount,
                percents: percents))
        }
        self.dataForLegendTable = dataForLegendCell
        
        let dataForPieChartInSet = PieChartDataSet(entries: dataForPieChartByEntries)
        dataForPieChartInSet.colors = colours
        let pieChartData = PieChartData(dataSet: dataForPieChartInSet)
        pieChartData.setValueFont(.helveticaNeueMedium.withSize(15))
        pieChartData.setValueTextColor(.white)
        
        pieChartData.dataSet?.drawValuesEnabled = false

        self.data = pieChartData
        viewOutput.send(.pieData(PieChartDataTotal(dataForPie: pieChartData, totalNumber: totalAccessNumber)))

    }
    
    func beginDateDidChangeOn(_ date: Date){
        self.beginDate = date
        self.endDate = endDate > date ? endDate : date
        viewOutput.send(.selectedRangeWasUpdated(
            SelectedRange(beginDate: date, endDate: self.endDate)))
        self.viewOutput.send(.shouldUpdateCustomInterval)
        self.converter.getCustomLogs(beginDate: beginDate, endDate: endDate)
        self.updateDisplayedRangeWith(converter.sortedLogsData)
    }
    func endDateDidChangedOn(_ date: Date){
        self.beginDate = beginDate < date ? beginDate : date
        self.endDate = date
        
        viewOutput.send(.selectedRangeWasUpdated(
            SelectedRange(beginDate: self.beginDate, endDate: date)))
        self.viewOutput.send(.shouldUpdateCustomInterval)
        self.converter.getCustomLogs(beginDate: beginDate, endDate: endDate)
        self.updateDisplayedRangeWith(converter.sortedLogsData)
    }

    //MARK: TableView Related
    func numberOfRowsInTableView() -> Int {
        self.dataForLegendTable.count
    }
    func dataForTableViewCell(at indexPath: IndexPath) -> StatisticCellData{
        self.dataForLegendTable[indexPath.row]
    }
    
    //MARK: PickerView Related
    func numberOfRowsInPicker() -> Int{
        CustomOptions.allCases.count
    }
    func titleForPickerRowAt(_ row: Int) -> String {
        CustomOptions.allCases[row].rawValue
    }
    func selectedRowForPicker() -> Int {
        CustomOptions.allCases.firstIndex(where: { option in
            option == .custom
        }) ?? 0
    }
    func didSelectPickerRowAt(_ row: Int){
        switch CustomOptions.allCases[row]{
        case .currentWeek:
            converter.getCurrentWeekLogs()
            self.updateDisplayedRangeWith(converter.sortedLogsData)
            self.beginDate = converter.sortedLogsDataRange.start
            self.endDate = converter.sortedLogsDataRange.end
            self.viewOutput.send(.selectedRangeWasUpdated(SelectedRange(beginDate: beginDate, endDate: endDate)))
        case .currentMonth:
            converter.getCurrentMonthLogs()
            self.updateDisplayedRangeWith(converter.sortedLogsData)
            self.beginDate = converter.sortedLogsDataRange.start
            self.endDate = converter.sortedLogsDataRange.end
            self.viewOutput.send(.selectedRangeWasUpdated(SelectedRange(beginDate: beginDate, endDate: endDate)))
        case .previousMonth:
            converter.getPreviousMonthLogs()
            self.updateDisplayedRangeWith(converter.sortedLogsData)
            self.beginDate = converter.sortedLogsDataRange.start
            self.endDate = converter.sortedLogsDataRange.end
            self.viewOutput.send(.selectedRangeWasUpdated(SelectedRange(beginDate: beginDate, endDate: endDate)))
        case .custom: return
        }
    }
    
    private func convertDataForStatView(data: [DictionariesEntity]){
        var array = [DictionaryLogData]()
        for i in data {
            var dictionary = DictionaryLogData(dictionaryName: i.language, accessCount: 0)
            do {
                let logs = try dataModel.fetchAllLogs(for: i)
                for log in logs{
                    dictionary.accessCount += Int(log.accessCount)
                }
                array.append(dictionary)
                
            } catch {
                self.viewOutput.send(.error(error))
            }
        }
        viewOutput.send(.data(array))
    }

}

enum CustomOptions: String, CaseIterable {
    case currentWeek = "statistic.currentWeek"
    case currentMonth = "statistic.currentMonth"
    case previousMonth = "statistic.previousMonth"
    case custom = "statistic.custom"
}
