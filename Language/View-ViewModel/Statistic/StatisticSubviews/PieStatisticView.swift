//
//  PieStatisticView.swift
//  Language
//
//  Created by Star Lord on 28/08/2023.
//

import UIKit
import DGCharts

class PieStatisticView: UIView {
    //MARK: Properties
    private var chartView: PieChartView? = PieChartView()
    weak var delegate: ChartViewDelegate? {
        didSet {
            chartView?.delegate = delegate
        }
    }
    //MARK: Inherited
    required init(){
        super.init(frame: .zero)
        configurePieChart()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder: NSCoder) wasn't imported")
    }
    deinit {
        self.chartView?.delegate = nil
    }
    
    //MARK: Subviews setUp
    func configurePieChart(){
        guard let chartView = chartView else { return }
        self.addSubviews(chartView)
        
        chartView.drawSlicesUnderHoleEnabled = true
        chartView.transparentCircleRadiusPercent = 0.2
        chartView.chartDescription.enabled = false
        
        chartView.drawHoleEnabled = true
        chartView.legend.enabled = false
        chartView.rotationEnabled = false
        
        chartView.holeColor = .systemBackground.withAlphaComponent(0.9)

        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: topAnchor),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chartView.bottomAnchor.constraint(equalTo: bottomAnchor),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    ///Assigning passed data to the pie chart
    func setUpChartData(_ chartData: PieChartData){
        if let totalNumber = chartData.dataSet?.label {
            var attributedText = NSMutableAttributedString.attributedMutableString(
                string: "Total \n \(totalNumber)",
                with: .helveticaNeueBold,
                ofSize: 24,
                alignment: .center
            )
            self.chartView?.centerAttributedText = attributedText
        }
        
        let valueFormatter = DefaultValueFormatter()
        valueFormatter.decimals = 0
        
        self.chartView?.chartAnimator.animate(yAxisDuration: 1.2, easingOption: .easeInOutSine)
        self.chartView?.highlightValue(nil)
        self.chartView?.data = chartData

        self.chartView?.data?.setValueFormatter(valueFormatter)
    }
}
