//
//  PieStatisticView.swift
//  Language
//
//  Created by Star Lord on 28/08/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit

struct ChartEntityData: Equatable{
    var value: Double
    var label: String
    var colour: UIColor
    var assosiatedData: String
}

struct ChartEntityDataSet{
    var chartTitle: String
    var chartData: [ChartEntityData]
}

class PieStatisticView: UIView {
    //MARK: Properties
    var chartView: PieChartView? = PieChartView()
    
    weak var delegate: PieChartViewDelegate? {
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

        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: topAnchor),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chartView.bottomAnchor.constraint(equalTo: bottomAnchor),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    ///Assigning passed data to the pie chart
    func setUpChartData(_ chartData: ChartEntityDataSet){
        let totalNumber = chartData.chartTitle
        
        let attributedText = NSMutableAttributedString.attributedMutableString(
            string: "statistic.timeSpent".localized + "\n\(totalNumber)",
            with: .helveticaNeueBold,
            ofSize: .subtitleSize,
            alignment: .center
        )
        
        self.chartView?.centreLabel.attributedText = attributedText
        self.chartView?.applyNewData(dataSet: chartData)
    }
}

                        
class PieChartView: UIView {
    
    // MARK: View's
    private var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    let centreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.tintColor = .label
        label.numberOfLines = 3
        return label
    }()
    
    //MARK: Properties
    private var data: ChartEntityDataSet? = nil

    var delegate: PieChartViewDelegate?
    var entities: [ChartEntityData] {
        get {
            return data?.chartData.reversed() ?? []
        }
    }
    
    private var displayedLayers: [ChartEntityLayer] = []
    private var dispalyedLabels: [ChartEntityLabel] = []
    
    
    //MARK: Constants
    private var currentPercent =    CGFloat(0.000001)
    private var totalPercent =      CGFloat(0)

    private var totalValue: CGFloat {
        return entities.reduce(0) { partialResult, entity in
            return partialResult + entity.value
        }
    }
    
    private var radius =        CGFloat(0)
    private var chartWidth =    CGFloat(0)
    private var strokeWidth =   CGFloat(0)
    
    let displayDuration: CGFloat = 0.8
    let deleteDuration: CGFloat = 0.5
    
    //MARK: Inherited
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        radius = containerView.bounds.width * 3 / 8
        chartWidth = containerView.bounds.width
        strokeWidth = chartWidth / 4
    }
    
    
    //MARK: Subviews SetUp
    func configureView() {
        self.addSubviews(containerView, centreLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            centreLabel.centerXAnchor.constraint(
                equalTo: centerXAnchor),
            centreLabel.centerYAnchor.constraint(
                equalTo: centerYAnchor),
            centreLabel.widthAnchor.constraint(
                equalTo: containerView.widthAnchor, multiplier: 0.5),
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(sliceWasTapped(sender: )))
        self.containerView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: Change response
    func applyNewData(dataSet: ChartEntityDataSet){
        let sortedData = dataSet.chartData.sorted(by: {$0.value > $1.value})
        self.data = ChartEntityDataSet(chartTitle: dataSet.chartTitle, chartData: sortedData)
        redrawTheContent()
    }
    
    func sizeHasChanged() {
        animation()
    }

    //MARK: System
    func percentToRadian(_ percent: CGFloat) -> CGFloat {
        var angle = 270 + percent * 360
        if angle >= 360 {
            angle -= 360
        }
        return angle * CGFloat.pi / 180.0
    }
    
    
    //Creating the chart entity layer, where smallest entity takes the most space, while bigger entities overlay in incremental order
    private func addNewLayer(for entity: ChartEntityData){
        guard entity.value != 0 else { return }
        let valuePercent = (entity.value / totalValue * 100) / 100
        
        let path = UIBezierPath(arcCenter: containerView.center,
                                radius: radius,
                                startAngle: percentToRadian(0.0),
                                endAngle: percentToRadian(1.0 - currentPercent),
                                clockwise: true)
        
        
        let sliceLayer = CAShapeLayer()
        sliceLayer.path = path.cgPath
        sliceLayer.fillColor = nil
        sliceLayer.strokeColor = entity.colour.cgColor
        sliceLayer.lineWidth = strokeWidth
        sliceLayer.strokeEnd = 1
        
        let animation = layerDisplayAnimation()
        sliceLayer.add(animation, forKey: animation.keyPath)
        
        containerView.layer.addSublayer(sliceLayer)
        
        displayedLayers.append(ChartEntityLayer(
            reference: entity,
            layer: sliceLayer,
            colour: entity.colour,
            angleRange: AngleRange(
                startPoint: percentToRadian(0.0),
                endPoint: percentToRadian(1.0 - currentPercent))
            ))

        currentPercent += valuePercent
    }
    
    private func addNewLabel(for entity: ChartEntityData, isSelected: Bool){
        let valuePercent = (entity.value / totalValue * 100) / 100

        let startAngle = (isSelected
                          ? percentToRadian(0.0)
                          : percentToRadian(0.0 - ( currentPercent - valuePercent)))
        let endAngle = percentToRadian(1.0 - currentPercent)
        let midAngle = {
            if isSelected {
                    return (startAngle + self.percentToRadian(0.75))
            
            } else {
                var middle = (startAngle + endAngle) / 2
                if endAngle > startAngle {
                    middle = (startAngle + (endAngle + 2 * .pi)) / 2
                    if middle > 2 * .pi {
                        middle -= 2 * .pi
                    }
                }
                return middle
            }
        }()
                
        let centerX = containerView.center.x + radius * cos(midAngle)
        let centerY = containerView.center.y + radius * sin(midAngle)

        let labelPath = UIBezierPath(arcCenter: containerView.center,
                                  radius: radius,
                                  startAngle: percentToRadian(0.0),
                                  endAngle: midAngle,
                                  clockwise: true)

        let sliceLabel = UILabel()
        sliceLabel.text = entity.label + "\n" + entity.assosiatedData
        sliceLabel.textColor = .white
        sliceLabel.font = UIFont.systemFont(ofSize: .assosiatedTextSize, weight: .bold)
        sliceLabel.sizeToFit()
        sliceLabel.numberOfLines = 3
        sliceLabel.textAlignment = .center
        sliceLabel.frame = CGRect(origin: .zero,
                                  size: CGSize(width: self.strokeWidth * 2, height: strokeWidth))
        sliceLabel.center = CGPoint(x: centerX, y: centerY)
        sliceLabel.alpha = 0

        let animation = labelDisplayAnimation(path: labelPath.cgPath)

        if valuePercent > 0.05 {
            containerView.addSubview(sliceLabel)
            sliceLabel.layer.add(animation, forKey: animation.keyPath)
            dispalyedLabels.append(ChartEntityLabel(
                reference: entity,
                label: sliceLabel,
                angleRange: AngleRange(startPoint: percentToRadian(0.0), endPoint: midAngle)))
        }
        UIView.animate(withDuration: 1.0) {
            sliceLabel.alpha = 1
        }
    }
    
    private func removeLayer(layer: ChartEntityLayer){
        let animation = layerDeletionAnimation()
        layer.layer.add(animation, forKey: animation.keyPath)
    }
    
    private func removeLabel(label: ChartEntityLabel ){
        
        let path = UIBezierPath(arcCenter: containerView.center, radius: radius, startAngle: label.angleRange.endPoint, endAngle: label.angleRange.startPoint, clockwise: false)
        
        let animation = labelDeleteAnimation(path: path.cgPath)
        
        label.label.layer.add(animation, forKey: animation.keyPath)
        
        UIView.animate(withDuration: 0.5) {
            label.label.alpha = 0
            
        }
    }

    

    private func animation() {
        clearDisplayedSubviews(animated: false)
        
        currentPercent = 0.000001
    
        if !entities.isEmpty {
            for entity in entities {
                addNewLayer(for: entity)
                addNewLabel(for: entity,
                            isSelected: entity.value == totalValue)
            }
        }

    }
    
    private func clearDisplayedSubviews(animated: Bool){
        displayedLayers.forEach { layer in
            if animated {
                self.removeLayer(layer: layer)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + deleteDuration, execute: {
                    layer.layer.removeFromSuperlayer()
                })
                
            } else {
                layer.layer.removeFromSuperlayer()
            }
            
            
        }
        displayedLayers = []

        dispalyedLabels.forEach({ label in
            if animated {
                self.removeLabel(label: label)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + deleteDuration, execute: {
                    label.label.removeFromSuperview()
                })

            } else {
                label.label.removeFromSuperview()
            }
        })
        dispalyedLabels = []

    }

    private func redrawTheContent(){
        if (displayedLayers.isEmpty && displayedLayers.isEmpty) != true {
            self.clearDisplayedSubviews(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + deleteDuration, execute: {
                self.animation()
            })
        } else {
            animation()
        }

    }
    
    //MARK: Animations
    private func layerDisplayAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = displayDuration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.delegate = self
        return animation
    }
    
    private func layerDeletionAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = deleteDuration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.delegate = self
        return animation
    }
    
    private func labelDisplayAnimation(path: CGPath) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path
        animation.duration = displayDuration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        return animation
    }
    
    private func labelDeleteAnimation(path: CGPath) -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path
        animation.duration = deleteDuration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        return animation
    }

    
    //MARK: Actions
    @objc func sliceWasTapped(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self)
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let dx = tapLocation.x - centerPoint.x
        let dy = tapLocation.y - centerPoint.y
        let distance = sqrt(dx * dx + dy * dy)
        
        let radius = bounds.width / 2
        
        if distance < radius - strokeWidth { //Inside
            delegate?.chartValueSelected(entry: nil)
            return
        } else if distance > radius { //Outside
            print("ouside")
            return
        }
        
        var tapAngle = atan2(dy, dx) * 180 / .pi // Convert to degrees
        if tapAngle < 0 { tapAngle += 360 } // Normalize to 0-360 degrees
        
        //Going from the biggest entity to the smallest.
        for segment in displayedLayers.reversed() {
            var startAngle = segment.angleRange.startPoint * 180 / .pi
            // Convert to degrees
            var endAngle = segment.angleRange.endPoint * 180 / .pi
            
            // Normalize angles to [0, 360] range
            if startAngle < 0 { startAngle += 360 }
            if endAngle < 0 { endAngle += 360 }
            
            if startAngle > endAngle {
                if tapAngle >= startAngle || tapAngle <= endAngle {
                    delegate?.chartValueSelected(entry: segment.reference )
                    return
                }
            } else {
                if tapAngle >= startAngle && tapAngle <= endAngle {
                    delegate?.chartValueSelected(entry: segment.reference)

                    return
                }
            }
        }
    }
}

//MARK: Animation Delegate
extension PieChartView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    
    }
}
//MARK: Struct
extension PieChartView {
    
    private struct AngleRange{
        var startPoint: CGFloat
        var endPoint: CGFloat
    }
    
    private struct ChartEntityLayer{
        var reference: ChartEntityData
        
        var layer: CAShapeLayer
        var colour: UIColor
        var angleRange: AngleRange
    }

    private struct ChartEntityLabel{
        var reference: ChartEntityData
        
        var label: UILabel
        var angleRange: AngleRange
    }

    
}
protocol PieChartViewDelegate: AnyObject {
    func chartValueSelected(entry: ChartEntityData?)
    
}


