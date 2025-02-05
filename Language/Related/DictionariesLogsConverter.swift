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
    var timeInSec: Int
    var numberOfCards: Int
    
    
    init(order: Int, date: String, count: Int, timeInSec: Int, numberOfCards: Int){
        self.order = order
        self.date = date
        self.count = count
        self.timeInSec = timeInSec
        self.numberOfCards = numberOfCards
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

//MARK: - DataConverter for cell statistics.
///Converts access statistics, filling the date gaps and returning array of weeks.
class DatesToWeekConverter {
    private struct DayLogRaw{
        let date: Date
        let count: Int
        let order: Int
        let timeInSec: Int
        let numberOfCards: Int
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
            return
        }
        
        var dates: [Date] = []
        var currentDate = firstDateOfRangesWeek
    
        while currentDate <= lastDateOfRangesWeek {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        self.filledDaySequence = dates.sorted()
    }
    private func completeFinalLogs(){
        var result = [DayLogRaw]()
        
        for (index, date) in filledDaySequence.enumerated() {
            if let day = initialLogData.first(where: { $0.accessDate == date }) {
                result.append(DayLogRaw(date: date,
                                        count: Int(day.accessCount),
                                        order: index,
                                        timeInSec: Int(day.accessTime),
                                        numberOfCards: Int(day.accessAmount)
                                       )
                )
            } else {
                result.append(DayLogRaw(date: date,
                                        count: 0,
                                        order: index,
                                        timeInSec: 0,
                                        numberOfCards: 0))
            }
        }
        filledLogData = result
    }

    func getDataDividedByWeeks() -> [WeekLog] {
        var result = [WeekLog]()
        
        var weekDates = [Date]()
        var week = [DayLog]()
        
        for day in filledLogData {
            let dayLit = dayLitFormatter.string(from: day.date)
            week.append(DayLog(order:   day.order,
                               date:    dayLit ,
                               count:   day.count,
                               timeInSec: day.timeInSec,
                               numberOfCards: day.numberOfCards))
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


