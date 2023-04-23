//
//  Menu VC.swift
//  Language
//
//  Created by Star Lord on 10/02/2023.
//

import UIKit

class MenuVC: UIViewController {
    
    var dictionaries: [DictionariesEntity] = []
    
    var tableView: UITableView = {
        var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .insetGrouped)
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "dictCell")
        tableView.register(TableViewAddCell.self, forCellReuseIdentifier: "addCell")
        tableView.rowHeight = 104
        tableView.backgroundColor = .systemBackground
        tableView.selectionFollowsFocus = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
//MARK: - Prepare Func
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBarCustomization()
        tableViewCustomization()
        tabBarCustomization()
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchDictionaries()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        strokeCustomization()
    }
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
        
                self.bottomStroke.strokeColor = UIColor.white.cgColor
                self.topStroke.strokeColor = UIColor.white.cgColor
            } else {
                self.bottomStroke.strokeColor = UIColor.black.cgColor
                self.topStroke.strokeColor = UIColor.black.cgColor
            }
        }
    }
    // MARK: - Data fetching
    func fetchDictionaries() {
        dictionaries = CoreDataHelper.shared.fetchDictionaries()
        
    }
    
    //MARK: - Stroke SetUp
    func strokeCustomization(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)

        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
    
    
    //MARK: - TableView SetUP
    func tableViewCustomization(){
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
    func navBarCustomization(){
        navigationItem.title = "navBarTitle".localized
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        //Statisctic BarButton
        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "chart.bar"),
            style: .plain,
            target: self,
            action: #selector(statiscticButTap(sender:)))
        self.navigationItem.setRightBarButton(rightButton, animated: true)
        
        navigationItem.backButtonDisplayMode = .minimal
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }
    //MARK: - TabBar SetUp
    func tabBarCustomization(){

    }
    //MARK: - Actions
    @objc func statiscticButTap(sender: Any){
        let vc = StatisticVC()
        navigationController?.present(vc, animated: true)
        }
    @objc func languageDidChange(sender: Any){
        navigationItem.title = "navBarTitle".localized
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
        tableView.reloadData()
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
//MARK: - UITableViewDataSource
extension MenuVC: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dictCell", for: indexPath) as? TableViewCell
        let addCell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as? TableViewAddCell
        
        if indexPath.section == tableView.numberOfSections - 1 {
            return addCell!
        } else {
            cell?.languageResultLabel.text = dictionaries[indexPath.section].language
            cell?.cardsResultLabel.text = dictionaries[indexPath.section].numberOfCards
            return cell!
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == tableView.numberOfSections - 1{
            return false
        }
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            tableView.deleteRows(at: [indexPath], with: .right)
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            let dictionaryToDelete = CoreDataHelper.shared.fetchDictionaries()[indexPath.row]
            
            CoreDataHelper.shared.deleteDictionary(dictionary: dictionaryToDelete)
            self.dictionaries = CoreDataHelper.shared.fetchDictionaries()
            
            tableView.deleteSections([indexPath.section], with: .left)
            tableView.reloadData()
            handler(true)
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "Share") { (action, view, handler) in
            
            handler(true)
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (action, view, handler) in
            // Perform your edit action here
            handler(true)
        }
        
        editAction.backgroundColor = .blue
        let configuration = UISwipeActionsConfiguration(actions: [editAction, deleteAction, shareAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }

}

