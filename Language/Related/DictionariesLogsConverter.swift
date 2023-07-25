//
//  DictionariesLogsConverter.swift
//  Language
//
//  Created by Star Lord on 22/07/2023.
//

import Foundation
import UIKit

class DayLog: Identifiable, Hashable{
    var id: String { String(order + count) + date }
    let order: Int
    let date: String
    var count: Int
    var animate: Bool = false
    
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

class DataConverter {
    private struct DayLogRaw{
        let date: Date
        let count: Int
        let order: Int
    }
    private var initialLogData: [DictionariesAccessLog] = [DictionariesAccessLog]()
    private var filledLogData: [DayLogRaw] = [DayLogRaw]()
    private var filledDaySequence = [Date]()
    
    private let dayLitFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
     
    init(logs: [DictionariesAccessLog]){
        initialLogData = logs.sorted(by: { $0.accessDate! < $1.accessDate!})
        completedRange()
        completeFinalLogs()
    }
    
    private func completedRange(){
        let first = initialLogData.first?.accessDate
        let last = initialLogData.last?.accessDate
        
        guard let firstDate = first, let lastDate = last else {
            print("Failed to get first and last days from provided log sequence")
            return
        }
        
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

//    private func completeFinalLogs(){
//        var result = [DayLogRaw]()
//        var pointer = 0 {
//            didSet {
//                if pointer == initialLogData.count{
//                    pointer -= 1
//                }
//            }
//        }
//
//        for (index, date) in filledDaySequence.enumerated() {
//            let day = initialLogData[pointer]
//            if date == day.accessDate {
//                print("\(day.accessCount)")
//                result.append(DayLogRaw(date: date,
//                                        count: Int(day.accessCount),
//                                        order: index))
//                pointer += 1
//            } else {
//                result.append(DayLogRaw(date: date,
//                                        count: 0,
//                                        order: index))
//            }
//        }
//        filledLogData = result
//
//    }
    func getDataDevidedByDays() -> [DayLog] {
        var result = [DayLog]()
        for day in filledLogData{
            result.append(DayLog(order: day.order,
                                         date: dayLitFormatter.string(from: day.date ),
                                         count: day.count))
        }
        print(result.count)
        return result
    }
    func getDataDividedByWeeks() -> [WeekLog] {
        var result = [WeekLog]()
        
        var weekDates = [Date]()
        var week = [DayLog]()
        
        let dayDigFormatter = DateFormatter()
        dayDigFormatter.dateFormat = "dd"
        
        for day in filledLogData {
            let dayLit = dayLitFormatter.string(from: day.date)
            print("On \(day.date) you accesses \(day.count) times ")
            
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


