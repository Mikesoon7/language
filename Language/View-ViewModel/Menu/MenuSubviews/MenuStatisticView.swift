//
//  StatiscticCellView.swift
//  Language
//
//  Created by Star Lord on 12/07/2023.
//

import SwiftUI
import Charts

struct MenuStatisticView: View {
    
    private var viewWidth: CGFloat
    private var viewHeight: CGFloat
    
    private var data: [WeekLog]
    @State private var selectedWeek: WeekLog
    
    init(data: [WeekLog], width: CGFloat, height: CGFloat) {

        self.data = data
        self.viewWidth = width
        self.viewHeight = height
        self._selectedWeek = State(initialValue: data.last!)

    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(selectedWeek.week)")
                .font(.footnote)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 0, trailing: 0))
            
            TabView(selection: $selectedWeek) {
                ForEach(data) { week in
                    ChartView(selectedWeek: $selectedWeek, shouldDisplayFinalData: week == selectedWeek, week: week)
                        .tag(week)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
    }
    struct ChartView: View {
        
        @Binding var selectedWeek: WeekLog
        @State var shouldDisplayFinalData: Bool = false
        
        var week: WeekLog

        var body: some View{
            let appeared = (selectedWeek.id == week.id)
            Chart(week.weekByDays) { day in
                BarMark(
                    x: .value("Day", day.date),
                    y: .value("Count", shouldDisplayFinalData ? day.count : 0)
                )

                .annotation(position: .overlay, alignment: .bottom, content: {
                    Text("\(day.count)")
                })
                .foregroundStyle(.gray)
            }
            .onChange(of: appeared, perform: { newValue in
                withAnimation(.easeIn(duration: 0.5)){
                    shouldDisplayFinalData = newValue
                }

            })
            .chartYAxis(.hidden)
            .chartPlotStyle { content in
                content
                    .background(.clear)
                    .gridCellUnsizedAxes(.horizontal)
                    .gridCellUnsizedAxes(.vertical)
            }
            .padding(EdgeInsets(top: 10, leading: 5, bottom: 0, trailing: 5))
            .chartYScale(domain: 0...20)
        }
    }
}
