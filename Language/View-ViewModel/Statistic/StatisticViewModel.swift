//
//  StatisticViewModel.swift
//  Language
//
//  Created by Star Lord on 04/09/2023.
//
//  REFACTORING STATE: CHECKED

import Foundation
import DGCharts
import Combine
import UIKit


class StatisticViewModel{
    //MARK: Objects
    internal struct DictionaryByAccessCount{
        var dictionary: DictionariesEntity
        var accessTime: Int
        var cardsChecked: Int
    }
    internal struct DictionaryFullLogs {
        var dictionary: DictionariesEntity
        var accessTime: Int
        var accessCount: Int
        var cardsChecked: Int
        var creationDate: Date?
        var numberOfCards: Int
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
        case shouldUpdateSelectedTableCell
        case shouldUpdateSelectedInterval(DateInterval)
        case shouldUpdateCustomInterval
        case shouldPresent(Error)
    }
    
    enum Input{
        case viewDidLoad
        case selectedIntervalUpdated(DateInterval)
        case selectedChartEntryUpdated(PieChartDataEntry?)
    }
    
    //MARK: Properties
    private var dataModel: Dictionary_Words_LogsManager
    private var settingModel: UserSettingsStorageProtocol

    private var dataConverter = StatisticLogConverter()
    
    private var fullData: [DictionaryFullLogs] = []
    private var tableViewData: [StatisticCellData] = []
    private var tableViewFilteredData: [StatisticCellData] = []
    private var tableViewSelectedEntry: StatisticCellData?
    
    private var pieChartData: PieChartData = .init()
    private var pieChartColours: [UIColor] = []
    private var pieChartSelectedEntry: PieChartDataEntry?
    
    private var selectedCustomOption: CustomOptions = .currentMonth
    
    var output = PassthroughSubject<Output, Never>()
    private var cancellable = Set<AnyCancellable>()

    
    init(dataModel: Dictionary_Words_LogsManager, settingsModel: UserSettingsStorageProtocol){
        self.settingModel = settingsModel
        self.dataModel = dataModel
        self.fetchDictionaries()
    }
    
    ///Binding viewModel to passed input and returning viewModels output
    func transform(input: AnyPublisher<Input, Never>?) -> AnyPublisher<Output, Never> {
        input?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                switch type{
                case .viewDidLoad:
                    self?.configureDataFor(range: .currentMonth)
                    self?.output.send(.shouldUpdateCustomInterval)
                case .selectedIntervalUpdated(let interval):
                    self?.configureDataForCustomRange(interval)
                case .selectedChartEntryUpdated(let entry):
                    self?.updateSelectedDictionary(entry: entry)
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
        var dictionariesByTimeSpent: [DictionaryFullLogs] = []
        
        var pieChartDataEntries: [PieChartDataEntry] = []
        var tableViewData: [StatisticCellData] = []
        
        pieChartColours = UIColor.getColoursArray(data.count)
        
        for dict in data{
            let accessTime = dict.affiliatedLogs.reduce(0) { partialResult, log in
                return partialResult + Int(log.accessTime)
            }
            let accessCards = dict.affiliatedLogs.reduce(0) { partialResult, log in
                return partialResult + Int(log.accessAmount)
            }
            let accessCount = dict.affiliatedLogs.reduce(0) { partialResult, log in
                return partialResult + Int(log.accessCount)
            }
            let creationDate = dict.dictionary.creationDate
        
//            dictionariesByTimeSpent.append(
//                DictionaryByAccessCount(
//                    dictionary: dict.dictionary,
//                    accessTime: accessTime,
//                    cardsChecked: accessCards
//                )
//            )
            dictionariesByTimeSpent.append(
                DictionaryFullLogs(
                    dictionary: dict.dictionary,
                    accessTime: accessTime,
                    accessCount: accessCount,
                    cardsChecked: accessCards,
                    creationDate: creationDate,
                    numberOfCards: Int(dict.dictionary.numberOfCards)
                )
            )
            fullData = dictionariesByTimeSpent.sorted(by: { $0.accessTime > $1.accessTime})
        }
        
        let totalAccessTime = dictionariesByTimeSpent.reduce(0) { partialResult, dictionary in
            return partialResult + dictionary.accessTime
        }
        let totalCardsAccesed = dictionariesByTimeSpent.reduce(0) { partialResult, dictionary in
            return partialResult + dictionary.cardsChecked
        }
        
        for (index, dict) in fullData.sorted(by: {$0.accessTime > $1.accessTime}).enumerated() {
            
            let percents = Double(dict.accessTime) / Double(totalAccessTime) * 100
            let percentsString = String(format: "%.1f", percents.isNaN ? 0 : percents) + "%"
            
            pieChartDataEntries.append(
                PieChartDataEntry(
                    value: Double(dict.accessTime),
                    label: percentsString,
                    data: dict.dictionary.language
                )
            )
            tableViewData.append(
                StatisticCellData(
                    entityColour: pieChartColours[index],
                    entityName: dict.dictionary.language,
                    entityAccessTime: localizedFormatTimeInterval(dict.accessTime, locale: self.currentLocale()),
                    entityAccessTimeRatio: String(dict.cardsChecked) + " " + (dict.cardsChecked > 1 ? "statistic.cardsNumber.cards".localized : "statistic.cardsNumber.card".localized),
                    entityCreationDate: convertDateToString(dict.creationDate),
                    entityCardsNumber: dict.numberOfCards,
                    entityAccessNumber: dict.accessCount,
                    isSelected: false
                )
            )
        }
        self.tableViewData = tableViewData
        self.tableViewFilteredData = tableViewData
        
        
        let dataForPieChartInSet = PieChartDataSet(entries: pieChartDataEntries)
        dataForPieChartInSet.colors = pieChartColours
        dataForPieChartInSet.label = localizedFormatTimeInterval(totalAccessTime, locale: self.currentLocale())
        
        let pieChartData = PieChartData(dataSet: dataForPieChartInSet)
        pieChartData.setValueFont(.helveticaNeueMedium.withSize(15))
        pieChartData.setValueTextColor(.white)
        
        pieChartData.dataSet?.drawValuesEnabled = false

        self.pieChartData = pieChartData
        self.pieChartSelectedEntry = nil
        
        output.send(.shouldUpdateSelectedTableCell)
        output.send(.shouldUpdatePieChartWith(pieChartData))
    }
    
    ///Creating new DataSet for passed entry and sending set back to view.
    private func updateSelectedDictionary(entry: PieChartDataEntry? = nil, item: Int? = nil){
        let mainDataSet = pieChartData.dataSet
        var selectedEntry: PieChartDataEntry
        var selectedItem: Int
        
        if entry != nil {
            guard pieChartSelectedEntry != entry, let entryIndex = mainDataSet?.entryIndex(entry: entry!) else {
                pieChartSelectedEntry = nil
                tableViewFilteredData = tableViewData
                output.send(.shouldUpdatePieChartWith(pieChartData))
                output.send(.shouldUpdateSelectedTableCell)
                return
            }
            selectedEntry = entry!
            selectedItem = entryIndex
        } else if item != nil {
            guard let entry = mainDataSet?.entryForIndex(item!) as? PieChartDataEntry, tableViewFilteredData[item!].isSelected != true  else {
                pieChartSelectedEntry = nil
                tableViewFilteredData = tableViewData
                output.send(.shouldUpdatePieChartWith(pieChartData))
                output.send(.shouldUpdateSelectedTableCell)
                return
            }
            selectedEntry = entry
            selectedItem = item!
        } else {
            pieChartSelectedEntry = nil
            tableViewFilteredData = tableViewData
            output.send(.shouldUpdatePieChartWith(pieChartData))
            output.send(.shouldUpdateSelectedTableCell)
            return
        }
        

        let selectedEntryFullLog = fullData[selectedItem]
        var selectedTableEntry = tableViewData[selectedItem]
        selectedTableEntry.isSelected = true
        
        tableViewFilteredData = [selectedTableEntry]
                
        let entryToPresent = PieChartDataEntry(value: Double(selectedEntryFullLog.cardsChecked),
                                               label: "statistic.cardsLearned".localized)
        pieChartSelectedEntry = entryToPresent
        
        let filteredDataSet = PieChartDataSet(entries: [entryToPresent])
        
        filteredDataSet.label = localizedFormatTimeInterval(selectedEntryFullLog.accessTime, locale: self.currentLocale())
        filteredDataSet.colors = [pieChartColours[selectedItem]]

        let pieChartData = PieChartData(dataSet: filteredDataSet)
        pieChartData.setValueFont(.helveticaNeueMedium.withSize(15))
        
        print(tableViewFilteredData)
        
        output.send(.shouldUpdateSelectedTableCell)
        output.send(.shouldUpdatePieChartWith(pieChartData))
    }
    
    func currentLocale() -> Locale {
        let lnCode = settingModel.appLanguage.languageCode
        return Locale(identifier: lnCode)
    }
    private func convertDateToString(_ date: Date?) -> String{
        guard let date = date else { return "__ __ ___"}
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = self.currentLocale()
        
        return formatter.string(from: date)
    }
    func localizedFormatTimeInterval(_ seconds: Int, locale: Locale = .current) -> String {
        let interval = TimeInterval(Double(seconds))
        let formatter = DateComponentsFormatter()
        if seconds < 60 {
            // Format for seconds (e.g., "45 sec")
            formatter.allowedUnits = [.second]
        } else if seconds < 3600 {
            // Format for minutes (e.g., "9.5 min")
            formatter.allowedUnits = [.minute, .second]
        } else {
            formatter.allowedUnits = [.hour, .minute]
        }
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .pad // Ensures two-digit formatting (e.g., "00:59")
        formatter.calendar = Calendar.current
        formatter.calendar?.locale = locale

        return formatter.string(from: interval) ?? ""
    }

//    func formatTime(seconds: Int, oneLine: Bool = true) -> String {
////        let interval = TimeInterval(Double(seconds))
//        if seconds < 60 {
//            // Format for seconds (e.g., "45 sec")
//            return "\(seconds) sec"
//        } else if seconds < 3600 {
//            // Format for minutes (e.g., "9.5 min")
//            let minutes = seconds / 60
//            let remainingSeconds = seconds % 60
//            return "\(minutes).\(String(format: "%02d", remainingSeconds)) min"
//        } else {
//            // Format for hours (e.g., "2.5.45 hours")
//            let hours = seconds / 3600
//            let minutes = (seconds % 3600) / 60
//            let remainingSeconds = seconds % 60
//            
//            if oneLine {
//                return "\(hours) hours, \(minutes).\(String(format: "%02d", remainingSeconds)) min"
//            } else {
//                return "\(hours) hours \n \(minutes).\(String(format: "%02d", remainingSeconds)) min"
//            }
//        }
//            }
//

    //MARK: TableView Related
    func numberOfRowsInSection(section: Int) -> Int {
        let isSelected = pieChartSelectedEntry != nil
        
        switch section {
        case 0: return isSelected ? 0 : tableViewFilteredData.count
        default: return isSelected ? 1 : 0
        }
//        if pieChartSelectedEntry != nil && section == 0 {
//            return 0
//        } else if pieChartSelectedEntry != nil && section == 1 {
//            return tableViewFilteredData.count
//        }
//        self.tableViewFilteredData.count
    }
    func dataForTableViewCell(at indexPath: IndexPath) -> StatisticCellData{
        self.tableViewFilteredData[indexPath.row]
    }
    
    func didSelectRow(at indexPath: IndexPath){
        updateSelectedDictionary(item: indexPath.item)
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


