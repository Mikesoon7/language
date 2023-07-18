//
//  StatiscticCellView.swift
//  Language
//
//  Created by Star Lord on 12/07/2023.
//

//import UIKit
import SwiftUI
import Charts

struct ChartData: Identifiable{
    let id = UUID()
    let week: String
    let weekByDays: [DayLog]
}
struct ChartData1: Identifiable {
    var day: String
    var value: Int
    var id: String { "\(day)" }
    
}


struct BarChart: View{
    
    @State private var data : [WeekLog]
    private var viewWidth: CGFloat
    private var viewHeight: CGFloat
    private var sectionWidth: CGFloat {
        viewWidth / 7
    }
    
    init(data: [FakeLogs], width: CGFloat, height: CGFloat) {
        self.data = DataConverter(logs: data).getDataDividedByWeeks()
        self.viewWidth = width
        self.viewHeight = height
    }
    
    
    var body: some View {
        ScrollView(.horizontal){
            HStack(alignment: .center, spacing: 0){
                ForEach(data) { week in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(week.week)
                        Chart{
                            ForEach(week.weekByDays) { day in
                                BarMark(x: .value("Day", day.date),
                                        y: .value("Count", day.count),
                                        width: MarkDimension(floatLiteral: Double(viewWidth) / 10),
                                        stacking: .standard)
                                .foregroundStyle(.gray)
                                .alignsMarkStylesWithPlotArea(true)
                            }
                            
                        }
                        .frame(width: CGFloat(week.weekByDays.count) * sectionWidth)
                        .onAppear(perform: {
                            
                        })
                        .chartPlotStyle { content in
                            content
                                .background(.clear)
                        }
                        .chartYAxis(.hidden)
                        .chartYScale(domain: 0...50)
                        
                        //            .gridCellColumns(7)
                        .gridCellUnsizedAxes(.horizontal)
                    }
                    .onAppear {
                        animateChartWeek(animate: true, days: week.weekByDays)
                    }
                }
            }
            
        }
    }
    func animateChartWeek(animate: Bool = false, days: [DayLog]) {
        for (index, _ )  in days.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(index) * 0.1)){
                withAnimation (.easeInOut (duration: 0.8)){
                    days[index].animate = animate
                }
            }
        }
    }
}

    //struct StatiscticCellView: View {
    //
    //    var viewWidth: CGFloat!
    //    lazy var dataPointWidth = viewWidth / 8
    //    lazy var barWidth = viewWidth / 9
    //
    //    init(width: CGFloat){
    //        self.viewWidth = width
    //    }
    //    var body: some View {
    //        let date: [ChartData] =  DataConverter().convertData()
    //        let allDates: [DayLog] = {
    //            var allDays: [DayLog] = []
    //            for week in date {
    //                allDays.append(contentsOf: week.weekByDays)
    //            }
    //            return allDays
    //        }()
    //
    //        let currentDate = date.last
    //
    //
    //        VStack {
    //            Text(currentDate?.week ?? "?")
    //                .alignmentGuide(.leading) { _ in
    //                    0
    //                }
    //            ScrollView(.horizontal){
    //                Chart {
    //                    ForEach(allDates) { day in
    //                        BarMark(
    //                            x: .value("Day", day.date),
    //                            y: .value("Count", day.count),
    //                            width: 30
    //                        )
    //                        .foregroundStyle(.gray)
    //                        .annotation(position: .overlay) {
    //                            Text("\(day.count)").font(Font.system(size: 9))
    //                        }
    //                    }
    //                }
    //                .gridCellUnsizedAxes(.vertical)
    //                .chartYAxis(.hidden)
    //                .frame(width: CGFloat(45 * allDates.count))
    //            }
    //        }
    //    }
    //}
 
class FakeLogs {
    static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yy"
        return df
    }()

    var date: Date
    var accessCount: Int
    
    init(date: String, accessCount: Int){
        self.date = Self.formatter.date(from: date) ?? Date()
        self.accessCount = accessCount
    }
    
}

class DayLog: Identifiable{
    var id: String { String(order) + date }
    let order: Int
    let date: String
    let count: Int
    var animate: Bool = false
    
    init(order: Int, date: String, count: Int){
        self.order = order
        self.date = date
        self.count = count
    }
}
struct WeekLog: Identifiable{
    var id = UUID()
    let week: String
    var weekByDays: [DayLog]
    var animate: Bool = false
//    {
//        didSet {
//
//        }
//    }

    
//    func animate(_ aniamte: Bool, sequence: [AnySequence<Any>]){
//        guard let week = sequence as? [DayLog] else { return }
//        week.forEach { day in
//            day.animate = animate
//        }
//    }
}

class DataConverter {
    private struct DayLogRaw{
        let date: Date
        let count: Int
        let order: Int
    }
    
    private var initialLogData: [FakeLogs] = [FakeLogs]()
    private var filledLogData: [DayLogRaw] = [DayLogRaw]()
    private var filledDaySequence = [Date]()
    
    private let dayLitFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
     
    init(logs: [FakeLogs]){
        initialLogData = logs.sorted(by: { $0.date < $1.date})
        completedRange()
        completeFinalLogs()
    }
    
    private func completedRange(){
        let first = initialLogData.first?.date
        let last = initialLogData.last?.date
        
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
        var pointer = 0 {
            didSet {
                if pointer == initialLogData.count{
                    pointer -= 1
                }
            }
        }
        
        for (index, date) in filledDaySequence.enumerated() {
            let day = initialLogData[pointer]
            if date == day.date {
                result.append(DayLogRaw(date: date,
                                        count: day.accessCount,
                                        order: index))
                pointer += 1
            } else {
                result.append(DayLogRaw(date: date,
                                        count: 0,
                                        order: index))
            }
        }
        print(result.count)
        filledLogData = result
        
    }
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
            print(day.date)
            
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
        print(result.count)
        return result
    }
    //Describes weeks day interval
    private func generateWeekDescription(from dates: [Date]) -> String {
        let firstDate = dates.first!
        let lastDate = dates.last!
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // your locale here
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

