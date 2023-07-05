//
//  Menu VC.swift
//  Language
//
//  Created by Star Lord on 10/02/2023.
//

import UIKit
import CoreData
import Charts

private enum Cells: String{
    case dict = "dict"
    case stat = "stat"
    case add = "add"
}
class MenuVC: UIViewController {
    var controller : NSFetchedResultsController!
    var dictionaries: [DictionariesEntity] = []
    
    var menuAccessedForCell: IndexPath?
    
    var shouldDispayStatistic: Bool = false
    //For ignoring updates after deleting.
    var isPostDeletionUpdate: Bool = false
    
    var tableView: UITableView = {
        var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .insetGrouped)
        tableView.register(MenuDictionaryCell.self, forCellReuseIdentifier: Cells.dict.rawValue)
        tableView.register(MenuStatisticCell.self, forCellReuseIdentifier: Cells.stat.rawValue)
        tableView.register(MenuAddDictionaryCell.self, forCellReuseIdentifier: Cells.add.rawValue)
        tableView.rowHeight = 104
        tableView.backgroundColor = .clear
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.subviews.forEach{ section in
            section.addShadowWhichOverlays(false)
        }
        return tableView
    }()
    
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    //MARK: - Prepare Func
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDictionaries()
        configureController()
        configureNavBar()
        configureTableView()
        configureTabBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureStrokes()
    }
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.bottomStroke.strokeColor = UIColor.label.cgColor
            self.topStroke.strokeColor = UIColor.label.cgColor
            if traitCollection.userInterfaceStyle == .dark {
                tableView.subviews.forEach { section in
                    section.layer.shadowColor = shadowColorForDarkIdiom
                }
            } else {
                tableView.subviews.forEach { section in
                    section.layer.shadowColor = shadowColorForLightIdiom
                }
            }
        }
    }
    //MARK: - Controleler SetUp
    func configureController(){
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDataDidChange(sender: )), name: .appDataDidChange, object: nil)
    }
    // MARK: - Data fetching
    func fetchDictionaries() {
        dictionaries = CoreDataHelper.shared.fetchDictionaries()
    }
    
    //MARK: - Stroke SetUp
    func configureStrokes(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
    
    
    //MARK: - TableView SetUP
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    //MARK: - NavigationBar SetUp
    func configureNavBar(){
        navigationItem.title = "menuVCTitle".localized
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        //Statisctic BarButton
        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "chart.bar"),
            style: .plain,
            target: self,
            action: #selector(statButtonDidTap(sender:)))
        self.navigationItem.setRightBarButton(rightButton, animated: true)
        
        navigationItem.backButtonDisplayMode = .minimal
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }
    //MARK: - TabBar SetUp
    func configureTabBar(){
        tabBarController?.tabBar.backgroundColor = .systemBackground
        tabBarController?.tabBar.isTranslucent = false
        tabBarController?.tabBar.shadowImage = UIImage()
        tabBarController?.tabBar.backgroundImage = UIImage()
    }
    func configureDataForDiagram(with data: [Date: Double]) -> ChartData {
        var entries = [BarChartDataEntry]()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        data.forEach { (key: Date, value: Double) in
            entries.append(BarChartDataEntry(x: Double(formatter.string(from: key))!, y: value))
        }
        let barDataSet = BarChartDataSet(entries: entries)
        let chart = ChartData(dataSet: barDataSet)
        return  chart
    }
    //MARK: - Actions
    @objc func statButtonDidTap(sender: Any){
        shouldDispayStatistic.toggle()
        tableView.indexPathsForVisibleRows?.forEach({ index in
            tableView.reloadRows(at: [index], with: .fade)
        })
        tableView.reloadData()
        
    }
    
    @objc func languageDidChange(sender: Any){
        navigationItem.title = "menuVCTitle".localized
        if let barItems = tabBarController?.tabBar.items{
            for index in 0..<(barItems.count){
                barItems[index].title = {
                    switch index{
                    case 0: return  "tabBarDictionaries".localized
                    case 1: return  "tabBarSearch".localized
                    case 2: return  "tabBarSettings".localized
                    default: return " "
                    }
                }()
            }
        }
    }
    
    @objc func appDataDidChange(sender: Notification){
        if let type = sender.userInfo?["changeType"] as? NSManagedObject.ChangeType {
            switch type {
            case .delete:
                isPostDeletionUpdate = true
            case .update:
                print("Updated in menuVc" )
                if !isPostDeletionUpdate {
                    fetchDictionaries()
                    tableView.reloadData()
                } else {
                    isPostDeletionUpdate = false
                }
            case .insert:
                print("inserted in menuVC")
                fetchDictionaries()
                tableView.reloadData()

            }
            
        }
    }
}

//MARK: - UITableViewDelegate
extension MenuVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dictionaries.count + 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == tableView.numberOfSections - 1{
            self.navigationController?.pushViewController(AddDictionaryVC(), animated: true)
        } else {
            let vc = DetailsVC()
            vc.dictionary = dictionaries[indexPath.section]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
//MARK: - Delegate for cells action.
extension MenuVC: CustomCellDataDelegate{
    func panningBegan(for cell: UITableViewCell){
        let index = tableView.indexPath(for: cell)
        guard index == menuAccessedForCell || menuAccessedForCell == nil else {
            if let cell = tableView.cellForRow(at: menuAccessedForCell!) as? MenuDictionaryCell{
                cell.activate(false)
                menuAccessedForCell = index
            }
            return
        }
        menuAccessedForCell = index
    }
    func panningEnded(active: Bool) {
        guard active else {
            menuAccessedForCell = nil
            return
        }
    }
    
    func deleteButtonDidTap(for cell: UITableViewCell){
        guard let index = tableView.indexPath(for: cell) else { return }
        let section = index.section
        
        isPostDeletionUpdate = true
        
        let removedDict = dictionaries.remove(at: section)
        CoreDataHelper.shared.delete(dictionary: removedDict)

        tableView.beginUpdates()
        tableView.deleteSections([section], with: .left)
        tableView.endUpdates()

        menuAccessedForCell = nil
    }
    
    func editButtonDidTap(for cell: UITableViewCell){
        guard let section = menuAccessedForCell?.section else { return }
        let dictionary = dictionaries[section]
        let pairs = CoreDataHelper.shared.fetchWords(dictionary: dictionary)
        
        var textToEdit = ""
        var textByLines = [String]()
        for pair in pairs {
            let line = "\(pair.word) \(UserSettings.shared.settings.separators.selectedValue) \(pair.meaning ?? "")"
            textByLines.append(line)
            textToEdit += line + "\n\n"
        }
        
        let vc = EditVC()
        vc.currentDictionary = dictionary
        vc.currentDictionaryPairs = Array(pairs)
        vc.oldText = textByLines
        vc.textField.text = dictionary.language
        vc.textView.text = textToEdit
            
        self.navigationController?.pushViewController(vc, animated: true)
        menuAccessedForCell = nil
    }
}
//MARK: - UITableViewDataSource
extension MenuVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section != tableView.numberOfSections - 1 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.add.rawValue,
                                                     for: indexPath) as! MenuAddDictionaryCell
            return cell
        }
        
        let dictionary = dictionaries[indexPath.section]
        if shouldDispayStatistic {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.stat.rawValue,
                                                     for: indexPath) as? MenuStatisticCell
            let logs = CoreDataHelper.shared.fetchAccessLogsFor(dictionary: dictionary)
            var convertedLogs = [Date: Double]()
            logs.map { log in
                convertedLogs[log.accessDate ?? Date()] = Double(log.accessCount)
            }
            cell?.diagramView.data = configureDataForDiagram(with: convertedLogs)
            cell?.nameResultLabel.text = dictionary.language
            cell?.creationResultLabel.text = convertedLogs.keys.min()?.formatted(date: .abbreviated, time: .omitted)
            cell?.statisticResultLabel.text = String(Int(convertedLogs.values.reduce(0, +)))
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.dict.rawValue,
                                                     for: indexPath) as! MenuDictionaryCell
            cell.configureCellWith(dictionary, delegate: self)
            return cell
        }
    }
}

protocol CustomCellDataDelegate: AnyObject{
    func panningBegan(for cell: UITableViewCell)

    func panningEnded(active: Bool)

    func deleteButtonDidTap(for cell: UITableViewCell)
    
    func editButtonDidTap(for cell: UITableViewCell)

}
