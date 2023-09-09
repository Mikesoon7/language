//
//  StatisticLogsConverter.swift
//  Language
//
//  Created by Star Lord on 07/09/2023.
//

import Foundation

struct DictionaryByLogs{
    var dictionary: DictionariesEntity
    var affiliatedLogs: [DictionariesAccessLog]
}

class StatisticLogConverter {
    private let currentCalendar = Calendar.current
    private let currentDate = Date()
    
    var initialLogsData: [DictionaryByLogs] = []
    var initialLogsDataRange = DateInterval()
    
    var sortedLogsData: [DictionaryByLogs] = []
    var sortedLogsDataRange = DateInterval()
    
    init( ) {   }
    
    ///Assigning passed logs for further filtering.
    func configureConverter(with data: [DictionaryByLogs]){
        self.initialLogsData = data
        self.sortedLogsData = data
        self.configureDataRange()
    }
    
    ///Calculating date interval for logs
    private func configureDataRange(){
        var upperBound = Date()
        let lowerBound = Date()
        for dictionary in initialLogsData{
            let firstDay = dictionary.affiliatedLogs.first?.accessDate ?? Date()
            if upperBound > firstDay {
                upperBound = firstDay
            }
        }
        self.initialLogsDataRange = DateInterval(start: upperBound, end: lowerBound)
        self.sortedLogsDataRange = initialLogsDataRange
    }
    
    //MARK: Method for defining required range logs
    ///Returns filltered by conformence to interval array.
    func getCustomLogsFor(_ interval: DateInterval) -> [DictionaryByLogs]{
        return filterLogsByInterval(interval)
    }
    
    ///Returns unfiltered logs.
    func getAllTimeLogs() -> [DictionaryByLogs]{
        self.sortedLogsData = initialLogsData
        self.sortedLogsDataRange = initialLogsDataRange
        return sortedLogsData
    }
    
    ///Defines interval for current week and return filtered array
    func getCurrentWeekLogs() -> [DictionaryByLogs]{
        var weekComponents = currentCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)
        weekComponents.hour = 0
        weekComponents.minute = 0
        
        guard let firstDayOfTheWeek = currentCalendar.date(from: weekComponents), let lastDayOfTheWeek = currentCalendar.date(byAdding: .day, value: 6, to: firstDayOfTheWeek) else {
            return sortedLogsData
        }
        let interval = DateInterval(start: firstDayOfTheWeek, end: lastDayOfTheWeek)
        
        return filterLogsByInterval(interval)
    }
    
    ///Defines interval for current month and return filtered array
    func getCurrentMonthLogs() -> [DictionaryByLogs]{
        let currentMonthStartComponents = currentCalendar
            .dateComponents([.year, .month], from: currentDate)
        
        guard let currentMonthRange = currentCalendar.range(
                of: .day, in: .month, for: currentDate),
              let currentMonthFirstDate = currentCalendar.date(
                from: currentMonthStartComponents),
              let currentMonthLastDate = currentCalendar.date(
                byAdding: .day, value: currentMonthRange.count,
                to: currentMonthFirstDate)
        else {
            return sortedLogsData
        }
        
        let interval = DateInterval(
            start: currentMonthFirstDate, end: currentMonthLastDate)
        
        return filterLogsByInterval(interval)
    }
    
    ///Defines interval for previous month and return filtered array
    func getPreviousMonthLogs() -> [DictionaryByLogs]{
        
        let currentMonthStartComponents = currentCalendar
            .dateComponents([.year, .month], from: currentDate)
            
        guard let currentMonthFirstDate = currentCalendar.date(
            from: currentMonthStartComponents),
              let previousMonthFirstDate = currentCalendar.date(
                byAdding: .month, value: -1,
                to: currentMonthFirstDate),
              let previousMonthRange = currentCalendar.range(
                of: .day, in: .month,
                for: previousMonthFirstDate),
              let previousMonthLastDate = currentCalendar.date(
                byAdding: .day, value: previousMonthRange.count,
                to: previousMonthFirstDate)
        else {
            return sortedLogsData
        }

        let interval = DateInterval(
            start: previousMonthFirstDate, end: previousMonthLastDate)
        
        return filterLogsByInterval(interval)
    }
    
    //MARK: Filtering method
    ///Filtering initial logs array by conformence to interval. Returns filtered Array
    private func filterLogsByInterval(_ interval: DateInterval) -> [DictionaryByLogs]{
        var filteredLogs: [DictionaryByLogs] = []
        
        for dictionary in initialLogsData{
            let logs = dictionary.affiliatedLogs.filter { log in
                interval.contains(log.accessDate ?? Date())
            }
            filteredLogs.append(DictionaryByLogs(dictionary: dictionary.dictionary, affiliatedLogs: logs))
        }
        sortedLogsData = filteredLogs
        sortedLogsDataRange = interval
        
        return filteredLogs
    }
}
