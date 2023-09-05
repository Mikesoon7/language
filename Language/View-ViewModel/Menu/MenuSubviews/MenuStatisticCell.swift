//
//  MenuStatisticCell.swift
//  Language
//
//  Created by Star Lord on 27/06/2023.
//

//import UIKit
//import Charts
//
//class MenuStatisticCell: UITableViewCell {
//    
//    static let identifier = "statisCell"
//    
//    var isDisplayingStatistic: Bool = false
//            
//    let view: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGray6
//        
//        view.layer.cornerRadius = 9
//        view.clipsToBounds = true
//        
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
////    var diagramView: StatisticChart!
//    let nameLabel: UILabel = {
//        let label = UILabel()
//        label.attributedText = NSAttributedString().fontWithString(
//            string: LanguageChangeManager.shared.localizedString(forKey: "tableCellName"),
//            bold: true,
//            size: 20)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    let statisticLabel: UILabel = {
//        var label = UILabel()
//        label.attributedText = NSAttributedString().fontWithString(
//            string: LanguageChangeManager.shared.localizedString(forKey: "statisticCellNumberOfUse"),
//            bold: true,
//            size: 20)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    let creationLabel: UILabel = {
//        var label = UILabel()
//        label.attributedText = NSAttributedString().fontWithString(
//            string: LanguageChangeManager.shared.localizedString(forKey: "statisticCellCreationDate"),
//            bold: true,
//            size: 20)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    let nameResultLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont(name: .SelectedFonts.georigaItalic.rawValue, size: 15)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textColor = .label
//        return label
//    }()
//    let statisticResultLabel : UILabel = {
//        var label = UILabel()
//        label.font = UIFont(name: .SelectedFonts.georigaItalic.rawValue, size: 15)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textColor = .label
//        return label
//    }()
//    let creationResultLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont(name: .SelectedFonts.georigaItalic.rawValue, size: 15)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textColor = .label
//        return label
//    }()
//    
//    
////MARK: - Prepare Func
//    init(style: UITableViewCell.CellStyle, reuseIdetifier: String?, dataForChart: [Date: Double]){
//        super.init(style: style, reuseIdentifier: reuseIdetifier)
//    }
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
////        var data: [Date: Double] = [
////            Date(timeInterval: 3600, since: Date.now): 18.0,
////            Date(timeInterval: 1600, since: Date.now): 9.0,
////            Date(timeInterval: 2600, since: Date.now): 4.0,
////            Date(timeInterval: 4400, since: Date.now): 19.0,
////            Date(timeInterval: 1100, since: Date.now): 11.0,
////
////        ]
////        let dateFormatter = DateFormatter()
////        dateFormatter.dateFormat = "dd"
////        var entries = [BarChartDataEntry]()
////        for i in data{
////            entries.append(BarChartDataEntry(x: Double(dateFormatter.string(from: i.key))!, y: i.value))
////        }
////        let set = BarChartDataSet(entries: entries )
////        set.colors = [UIColor.red]
////        let dataBar = BarChartData(dataSet: set)
////        diagramView = StatisticChart(frame: CGRect(), data: dataBar)
////        diagramView.notifyDataSetChanged()
////
////        diagramView.delegate = self
////
////        diagramView.translatesAutoresizingMaskIntoConstraints = false
////
//        configureView()
//        contentView.backgroundColor = .clear
//        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
//
//    }
//    required init?(coder: NSCoder) {
//        fatalError("coder wasn't imported")
//    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//    }
//    override func prepareForReuse() {
//        
//    }
//    func configureView(){
//        contentView.addSubview(view)
//        view.addSubviews(nameLabel ,statisticLabel, statisticResultLabel, creationLabel,
//                         nameResultLabel, creationResultLabel)
//        
//        NSLayoutConstraint.activate([
//            view.topAnchor.constraint(equalTo: contentView.topAnchor),
//            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            
////            diagramView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
////            diagramView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
////            diagramView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
////            diagramView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
//            
//            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
//            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
//            nameLabel.heightAnchor.constraint(equalToConstant: 25),
//            
//            statisticLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            statisticLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
//            statisticLabel.heightAnchor.constraint(equalToConstant: 25),
//            
//            creationLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
//            creationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
//            creationLabel.heightAnchor.constraint(equalToConstant: 25),
//
//            nameResultLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
////            nameResultLabel.trailingAnchor.constraint(equalTo: diagramView.leadingAnchor, constant: -10),
//            nameResultLabel.heightAnchor.constraint(equalToConstant: 25),
//
//            statisticResultLabel.centerYAnchor.constraint(equalTo: statisticLabel.centerYAnchor),
////            statisticResultLabel.trailingAnchor.constraint(equalTo: diagramView.leadingAnchor, constant: -10),
//            statisticResultLabel.heightAnchor.constraint(equalToConstant: 25),
//            
//            creationResultLabel.centerYAnchor.constraint(equalTo: creationLabel.centerYAnchor),
////            creationResultLabel.trailingAnchor.constraint(equalTo: diagramView.leadingAnchor, constant: -10),
//            creationResultLabel.heightAnchor.constraint(equalToConstant: 25)
//
//        ])
//    }
//            
//    @objc func languageDidChange(sender: Any){
//        nameLabel.text = LanguageChangeManager.shared.localizedString(forKey: "tableCellName")
//        statisticLabel.text = LanguageChangeManager.shared.localizedString(forKey: "statisticCellNumberOfUse")
//        creationLabel.text = LanguageChangeManager.shared.localizedString(forKey: "statisticCellCreationDate")
//    }
//}
////extension MenuStatisticCell: ChartViewDelegate {
////
////}
////class StatisticChart: BarChartView {
////
////    init(frame: CGRect, data: ChartData) {
////        super.init(frame: frame)
////        self.data = data
////    }
////    required init?(coder aDecoder: NSCoder) {
////        fatalError("Could not load NSCoder")
////    }
////}
