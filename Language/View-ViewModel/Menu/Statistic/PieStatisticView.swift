//
//  PieStatisticView.swift
//  Language
//
//  Created by Star Lord on 28/08/2023.
//

import UIKit
import DGCharts

struct PieChartDataTotal{
    var dataForPie: PieChartData
    var totalNumber: Int
}
class PieStatisticView: UIView {
    private var chartView = PieChartView()
    private weak var delegate: ChartViewDelegate?
    
    required init(delegate: ChartViewDelegate){
        self.delegate = delegate
        super.init(frame: .zero)
        setup(pieChartView: chartView)
        configurePieChart()
        chartView.delegate = delegate
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder: NSCoder) wasn't imported")
    }
    
    func configurePieChart(){
        self.addSubviews(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: topAnchor),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chartView.bottomAnchor.constraint(equalTo: bottomAnchor),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    func setUpChartData(chartData: PieChartDataTotal){
        let totalNumber  = String(chartData.totalNumber)
        
        var attributedText = NSMutableAttributedString.attributedMutableString(
            string: "Total \n \(totalNumber)",
            with: .helveticaNeueBold,
            ofSize: 24)
//        NSAttributedString.attributedString(
//            string: "Total \n \(totalNumber)",
//            with: .helveticaNeueBold,
//            ofSize: 24)
        
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.multiplier = 1
        formatter.allowsFloats = false
        
        chartData.dataForPie.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        self.chartView.highlightValue(nil)
        self.chartView.centerAttributedText = attributedText
        self.chartView.data = chartData.dataForPie
        self.chartView.chartAnimator.animate(yAxisDuration: 1.2, easingOption: .easeInOutSine)


    }
    
    func setup(pieChartView chartView: PieChartView) {
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.transparentCircleRadiusPercent = 0
        chartView.chartDescription.enabled = false
        
        chartView.drawHoleEnabled = true
        chartView.highlightPerTapEnabled = true
        chartView.legend.enabled = false
    }
}
