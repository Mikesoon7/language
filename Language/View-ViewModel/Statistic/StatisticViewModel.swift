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


class StatisticViewModel{
    //MARK: Objects
    internal struct DictionaryByAccessCount{
        var dictionary: DictionariesEntity
        var accessCount: Int
    }
    internal enum CustomOptions: String, CaseIterable {
        case currentWeek = "statistic.currentWeek"
        case currentMonth = "statistic.currentMonth"
        case previousMonth = "statistic.previousMonth"
        case allTime = "statistic.allTime"
        case custom = "statistic.custom"
    }


    enum Output{
        case shouldUpdatePieChartWith(PieChartData)
        
        case shouldUpdateSelectedInterval(DateInterval)
        case shouldUpdateCustomInterval
        case shouldPresent(Error)
    }
    
    enum Input{
        case viewWillAppear
        case selectedIntervalUpdated(DateInterval)
        case selectedChartEntryUpdated(PieChartDataEntry?)
    }
    
    //MARK: Properties
    private var dataModel: Dictionary_Words_LogsManager

    private var dataConverter = StatisticLogConverter()
    
    private var tableViewData: [StatisticCellData] = []
    
    private var pieChartData: PieChartData = .init()
    private var pieChartColours: [UIColor] = []
    private var pieChartSelectedEntry: PieChartDataEntry?
    
    private var selectedCustomOption: CustomOptions = .allTime
    
    var output = PassthroughSubject<Output, Never>()
    private var cancellable = Set<AnyCancellable>()

    
    init(dataModel: Dictionary_Words_LogsManager){
        self.dataModel = dataModel
        self.fetchDictionaries()
    }
    
    ///Binding viewModel to passed input and returning viewModels output
    func transform(input: AnyPublisher<Input, Never>?) -> AnyPublisher<Output, Never> {
        input?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                switch type{
                case .viewWillAppear:
                    self?.configureDataFor(range: .allTime)
                    self?.output.send(.shouldUpdateCustomInterval)
                case .selectedIntervalUpdated(let interval):
                    self?.configureDataForCustomRange(interval)
                case .selectedChartEntryUpdated(let entry):
                    self?.updateSelectedEntry(entry)
                }
            }
            .store(in: &cancellable)
        
        return output.eraseToAnyPublisher()
    }
    //MARK: Initial SetUp
    ///Fetches all stored dictionaries. Passes to configurator if  succeed.
    private func fetchDictionaries(){
        do {
            let dictionaries = try dataModel.fetchDictionaries()
            configureDataForConverter(data: dictionaries)
        } catch {
            output.send(.shouldPresent(error))
        }
    }
    
    ///Fetched affiliated logs and passes them to converter.
    private func configureDataForConverter(data: [DictionariesEntity]){
        var dataForConverter: [DictionaryByLogs] = []
        
        for dict in data {
            do {
                let assosiatedLogs = try dataModel.fetchAllLogs(for: dict)
                dataForConverter.append(DictionaryByLogs(dictionary: dict, affiliatedLogs: assosiatedLogs))
            } catch {
                output.send(.shouldPresent(error))
            }
        }
        dataConverter.configureConverter(with: dataForConverter)
    }
    
    //MARK: Response on user actions
    ///Getting logs conforming to passed range and passes to prepare method.
    ///Used for responding on custom pickers selection.
    private func configureDataFor(range: CustomOptions){
        var logs: [DictionaryByLogs] = []
        switch range{
        case .allTime:
            logs = dataConverter.getAllTimeLogs()
        case .currentWeek:
            logs = dataConverter.getCurrentWeekLogs()
        case .currentMonth:
            logs = dataConverter.getCurrentMonthLogs()
        case .previousMonth:
            logs = dataConverter.getPreviousMonthLogs()
        default:
            break
        }
        self.output.send(.shouldUpdateSelectedInterval(dataConverter.sortedLogsDataRange))
        self.prepareDataForDisplay(logs)
    }
    
    ///Getting logs conforming to passed range and passes to prepare method.
    ///Used for responding on selected date change.
    private func configureDataForCustomRange(_ interval: DateInterval){
        self.selectedCustomOption = .custom
        self.output.send(.shouldUpdateSelectedInterval(interval))
        self.output.send(.shouldUpdateCustomInterval)

        let logs = dataConverter.getCustomLogsFor(interval)
        self.prepareDataForDisplay(logs)
    }

    ///Using passed filtered data to create data objects for ChartView and TableView.
    private func prepareDataForDisplay(_ data: [DictionaryByLogs]){
        var dictionariesByAccessCount: [DictionaryByAccessCount] = []
        
        var pieChartDataEntries: [PieChartDataEntry] = []
        var tableViewData: [StatisticCellData] = []
        
        pieChartColours = UIColor.getColoursArray(data.count)
        
        for dict in data{
            let accessCount = dict.affiliatedLogs.reduce(0) { partialResult, log in
                return partialResult + Int(log.accessCount)
            }
            dictionariesByAccessCount.append(
                DictionaryByAccessCount(
                    dictionary: dict.dictionary,
                    accessCount: accessCount
                )
            )
        }
        
        let totalAccessCount = dictionariesByAccessCount.reduce(0) { partialResult, dictionary in
            return partialResult + dictionary.accessCount
        }
        
        for (index, dict) in dictionariesByAccessCount.enumerated() {
            
            let percents = String(format: "%.1f", Double(dict.accessCount) / Double(totalAccessCount) * 100.0) + "%"
            
            pieChartDataEntries.append(
                PieChartDataEntry(
                    value: Double(dict.accessCount),
                    label: percents,
                    data: dict.dictionary.language
                )
            )
            
            tableViewData.append(
                StatisticCellData(
                    colour: pieChartColours[index],
                    title: dict.dictionary.language,
                    value: dict.accessCount,
                    percents: percents
                )
            )
        }
        self.tableViewData = tableViewData
        
        
        let dataForPieChartInSet = PieChartDataSet(entries: pieChartDataEntries)
        dataForPieChartInSet.colors = pieChartColours
        dataForPieChartInSet.label = String(totalAccessCount)
        
        let pieChartData = PieChartData(dataSet: dataForPieChartInSet)
        pieChartData.setValueFont(.helveticaNeueMedium.withSize(15))
        pieChartData.setValueTextColor(.white)
        
        pieChartData.dataSet?.drawValuesEnabled = false

        self.pieChartData = pieChartData
        
        output.send(.shouldUpdatePieChartWith(pieChartData))
    }
    
    ///Creating new DataSet for passed entry and sending set back to view.
    private func updateSelectedEntry(_ entry: PieChartDataEntry?){
        guard let entry = entry, pieChartSelectedEntry != entry else {
            pieChartSelectedEntry = nil
            output.send(.shouldUpdatePieChartWith(pieChartData))
            return
        }
        let mainDataSet = pieChartData.dataSet
        let entryToPresent = PieChartDataEntry(value: entry.value, label: entry.data as? String ?? "")
        pieChartSelectedEntry = entryToPresent
        
        let filteredDataSet = PieChartDataSet(entries: [entryToPresent])
        let entryIndex = mainDataSet?.entryIndex(entry: entry)
        
        filteredDataSet.label = String(Int(entryToPresent.value))
        filteredDataSet.colors = [pieChartColours[entryIndex ?? 0]]

        let pieChartData = PieChartData(dataSet: filteredDataSet)
        pieChartData.setValueFont(.helveticaNeueMedium.withSize(15))
        
        output.send(.shouldUpdatePieChartWith(pieChartData))

    }
    

    //MARK: TableView Related
    func numberOfRowsInTableView() -> Int {
        self.tableViewData.count
    }
    func dataForTableViewCell(at indexPath: IndexPath) -> StatisticCellData{
        self.tableViewData[indexPath.row]
    }
    
    //MARK: PickerView Related
    //Methods for CustomPicker.
    func numberOfRowsInPicker() -> Int{
        CustomOptions.allCases.count
    }
    func titleForPickerRowAt(_ row: Int) -> String {
        CustomOptions.allCases[row].rawValue
    }
    func selectedRowForPicker() -> Int {
        CustomOptions.allCases.firstIndex(where: { option in
            option == selectedCustomOption
        }) ?? 0
    }
    func didSelectPickerRowAt(_ row: Int){
        guard CustomOptions.allCases[row] != .custom else {
            return
        }
        let selectedRange = CustomOptions.allCases[row]
        self.selectedCustomOption = selectedRange
        self.configureDataFor(range: selectedRange)
    }
}


