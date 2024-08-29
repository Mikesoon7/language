//
//  DictionariesLogsConverter.swift
//  Language
//
//  Created by Star Lord on 22/07/2023.
//
///Wednesday, Sep 12, 2018               --> EEEE, MMM d, yyyy
///09/12/2018                                       --> MM/dd/yyyy
///09-12-2018 14:11                             --> MM-dd-yyyy HH:mm
///Sep 12, 2:11 PM                              --> MMM d, h:mm a
///September 2018                              --> MMMM yyyy
///Sep 12, 2018                                   --> MMM d, yyyy
///Wed, 12 Sep 2018 14:11:54 +0000      --> E, d MMM yyyy HH:mm:ss Z
///2018-09-12T14:11:54+0000             --> yyyy-MM-dd'T'HH:mm:ssZ
///12.09.18                                            --> dd.MM.yy
///10:41:02.112                                     --> HH:mm:ss.SSS

import Foundation
import UIKit

class DayLog: Identifiable, Hashable{
    var id: String { String(order + count) + date }
    let order: Int
    let date: String
    var count: Int
    
    init(order: Int, date: String, count: Int){
        self.order = order
        self.date = date
        self.count = count
    }
    static func == (lhs: DayLog, rhs: DayLog) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}



struct WeekLog: Identifiable, Hashable{
    var id = UUID()
    let week: String
    var weekByDays: [DayLog]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
struct DataForLogs{
    var dictionary: String
    var logs: [Date]
}

//class TestDateLogExtractor {
//    var formatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MM/dd/yyy"
//        formatter.timeZone = .autoupdatingCurrent
//        return formatter
//    }()
//    private lazy var initialLogsData: [DataForLogs] = [
//        DataForLogs(dictionary: "Swift", logs: [
//            formatter.date(from: "08.04.2023")!,
//            formatter.date(from: "09.03.2023")!,
//            formatter.date(from: "09.04.2023")!,
//            formatter.date(from: "09.05.2023")!,
//            formatter.date(from: "09.06.2023")!,
//            formatter.date(from: "09.04.2023")!,
//
//        ]),
//        DataForLogs(dictionary: "Language", logs: [
//            formatter.date(from: "08.04.2023")!,
//            formatter.date(from: "09.03.2023")!,
//            formatter.date(from: "09.04.2023")!,
//            formatter.date(from: "09.05.2023")!,
//            formatter.date(from: "09.06.2023")!,
//            formatter.date(from: "09.04.2023")!,
//
//        ]),
//        DataForLogs(dictionary: "actors", logs: [
//            formatter.date(from: "09.03.2023")!,
//            formatter.date(from: "09.01.2023")!,
//            formatter.date(from: "09.02.2023")!,
//            formatter.date(from: "09.05.2023")!,
//            formatter.date(from: "09.06.2023")!,
//            formatter.date(from: "09.04.2023")!,
//        ])
//    ]
//    var sortedLogsData: [DataForLogs] = []
//    
//    init(){
//        
//    }
//    func getCurrentWeekLogs(){
//        var sortedLogs: [DataForLogs] = []
//        let currentDay = Date()
//        var calendar = Calendar.autoupdatingCurrent
//        calendar.timeZone = .autoupdatingCurrent
//        calendar.locale = .autoupdatingCurrent
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        formatter.timeZone = TimeZone.current
//        
////        print(formatter.string(from: currentDay))
////        print(currentDay)
////        print(calendar.locale)
////        print(calendar.timeZone)
//        
////        let dateFormatter = DateFormatter()
//        var weekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDay)
//        weekComponents.hour = 0
//        weekComponents.minute = 0
//        
//        guard let firstDayOfTheWeek = calendar.date(from: weekComponents), let lastDayOfTheWeek = calendar.date(byAdding: .day, value: 6, to: firstDayOfTheWeek) else {
//            return
//        }
//        let interval = DateInterval(start: firstDayOfTheWeek, end: lastDayOfTheWeek)
//        
//        print("\(formatter.string(from: interval.start)) - \(formatter.string(from: interval.end))")
//        print("\(interval.start) - \(interval.end)")
//        print(interval)
//        for dictionary in initialLogsData{
//            let filteredLogs = dictionary.logs.filter { log in
//                interval.contains(log)
//            }
//            sortedLogs.append(DataForLogs(dictionary: dictionary.dictionary, logs: filteredLogs))
//        }
//        sortedLogsData = sortedLogs
//        sortedLogsData.forEach { pair in
//            print("\(pair.dictionary) current week (starts: \(firstDayOfTheWeek), ends: \(lastDayOfTheWeek) represented by:")
//            pair.logs.forEach { log in
//                print(log)
//            }
//        }
//    }
//}
//
//MARK: - DataConverter for cell statistics.
///Converts access statistics, filling the date gaps and returning array of weeks.
class DatesToWeekConverter {
    private struct DayLogRaw{
        let date: Date
        let count: Int
        let order: Int
    }
    private var initialLogData: [DictionariesAccessLog] = [DictionariesAccessLog]()
    private var filledLogData: [DayLogRaw] = [DayLogRaw]()
    private var filledDaySequence = [Date]()
    
    private var locale: Locale
    
    private lazy var dayLitFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = self.locale
        return formatter
    }()
     
    init(logs: [DictionariesAccessLog], locale: Locale){
        self.locale = locale
        initialLogData = logs.sorted(by: { $0.accessDate! < $1.accessDate!})
        completedRange()
        completeFinalLogs()
    }
    
    private func completedRange(){
        let firstDate = initialLogData.first?.accessDate ?? Date().timeStripped
        let lastDate = Date().timeStripped
                
        let calendar = Calendar.current
        let componentForFirstDate = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear],
                                                            from: firstDate)
        let componentsForLastDate = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear],
                                                            from: lastDate)
        
        guard let firstDateOfRangesWeek = calendar.date(from: componentForFirstDate),
              let lastDateOfRangesWeek = calendar.date(byAdding: .day, value: 6, to: calendar.date(from: componentsForLastDate)!) else {
            print("Failed to define first and last days for provided weeks")
            return
        }
        
        var dates: [Date] = []
        var currentDate = firstDateOfRangesWeek
    
        while currentDate <= lastDateOfRangesWeek {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        print(dates.count)
        self.filledDaySequence = dates.sorted()
    }
    private func completeFinalLogs(){
        var result = [DayLogRaw]()
        
        for (index, date) in filledDaySequence.enumerated() {
            if let day = initialLogData.first(where: { $0.accessDate == date }) {
                result.append(DayLogRaw(date: date,
                                        count: Int(day.accessCount),
                                        order: index))
            } else {
                result.append(DayLogRaw(date: date,
                                        count: 0,
                                        order: index))
            }
        }
        filledLogData = result
    }

//    func getDataDevidedByDays() -> [DayLog] {
//        var result = [DayLog]()
//        for day in filledLogData{
//            result.append(DayLog(order: day.order,
//                                         date: dayLitFormatter.string(from: day.date ),
//                                         count: day.count))
//        }
//        print(result.count)
//        return result
//    }
    func getDataDividedByWeeks() -> [WeekLog] {
        var result = [WeekLog]()
        
        var weekDates = [Date]()
        var week = [DayLog]()
        
        for day in filledLogData {
            let dayLit = dayLitFormatter.string(from: day.date)
            week.append(DayLog(order:   day.order,
                               date:    dayLit ,
                               count:   day.count))
            weekDates.append(day.date)
            
            if week.count == 7 {
                result.append(WeekLog(week: generateWeekDescription(from: weekDates),
                                      weekByDays: week))
                week = []
                weekDates = []
            }
        }
        return result
    }
    //Describes weeks day interval
    private func generateWeekDescription(from dates: [Date]) -> String {
        let firstDate = dates.first!
        let lastDate = dates.last!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        
        let firstMonth = Calendar.current.component(.month, from: firstDate)
        let lastMonth = Calendar.current.component(.month, from: lastDate)
        
        if firstMonth == lastMonth {
            formatter.dateFormat = "dd"
            let firstDayString = formatter.string(from: firstDate)
            formatter.dateFormat = "dd MMM"
            let lastDayString = formatter.string(from: lastDate)
            return "\(firstDayString) - \(lastDayString)"
        } else {
            let firstDayString = formatter.string(from: firstDate)
            let lastDayString = formatter.string(from: lastDate)
            return "\(firstDayString) - \(lastDayString)"
        }
    }
}


