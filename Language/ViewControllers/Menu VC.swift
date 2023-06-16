//
//  Menu VC.swift
//  Language
//
//  Created by Star Lord on 10/02/2023.
//

import UIKit
import CoreData

class MenuVC: UIViewController {
    
    var dictionaries: [DictionariesEntity] = []
    
    var menuAccessedForCell: IndexPath?
    
    var tableView: UITableView = {
        var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .insetGrouped)
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell().identifier)
        tableView.register(TableViewAddCell.self, forCellReuseIdentifier: TableViewAddCell().identifier)
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
        controllerCustomization()
        navBarCustomization()
        tableViewCustomization()
        tabBarCustomization()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        fetchDictionaries()
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        strokeCustomization()
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
    func controllerCustomization(){
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDataDidChange(sender: )), name: .appDataDidChange, object: nil)
    }
    // MARK: - Data fetching
    func fetchDictionaries() {
        dictionaries = CoreDataHelper.shared.fetchDictionaries()
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        
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
        navigationItem.title = "menuVCTitle".localized
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
        tabBarController?.tabBar.backgroundColor = .systemBackground
        tabBarController?.tabBar.isTranslucent = false
        tabBarController?.tabBar.shadowImage = UIImage()
        tabBarController?.tabBar.backgroundImage = UIImage()
    }
    //MARK: - Actions
    @objc func statiscticButTap(sender: Any){
        let vc = StatisticVC()
        navigationController?.present(vc, animated: true)
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
        tableView.reloadData()
    }
//    @objc func cellDidSwipe(sender: UIPanGestureRecognizer){
//        guard let table = sender.view as? UITableView else {
//            return
//        }
//    }
    @objc func appDataDidChange(sender: Notification){
        print("was called")
        if let type = sender.userInfo?["changeType"] as? NSManagedObject.ChangeType {
            switch type{
            case .delete:
                fetchDictionaries()
                tableView.reloadData()

                dictionaries.forEach { dict in
                    print(dict.language)
                }
                CoreDataHelper.shared.fetchDictionaries().forEach { dict in
                    print("In coreData: \(dict.language)")
                }

            case .insert, .update: fetchDictionaries()
                tableView.reloadData()
            }
        }
    }
}
extension MenuVC: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true 
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
extension MenuVC: CustomCellDataDelegate{
    func panningBegan(for index: IndexPath){
        guard index == menuAccessedForCell || menuAccessedForCell == nil else {
            if let cell = tableView.cellForRow(at: menuAccessedForCell!) as? TableViewCell{
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
    
    func deleteButtonTapped(for index: IndexPath){
        let section = index.section
        let dictionaryToDelete = dictionaries.remove(at: section)
        CoreDataHelper.shared.deleteDictionary(dictionary: dictionaryToDelete)
//        dictionaries.forEach { dict in
//            print(dict.language)
//        }
//        CoreDataHelper.shared.fetchDictionaries().forEach { dict in
//            print("In coreData: \(dict.language)")
//        }

//        dictionaries.remove(at: section)
//        tableView.deleteSections([section], with: .left)
        menuAccessedForCell = nil
    }
//    func deleteButtonTapped(for index: IndexPath){
//
//        let dictionaryToDelete = CoreDataHelper.shared.fetchDictionaries()[index.section]
//
//        CoreDataHelper.shared.deleteDictionary(dictionary: dictionaryToDelete)
//
//        dictionaries.forEach { dict in
//            print(dict.language)
//        }
//        CoreDataHelper.shared.fetchDictionaries().forEach { dict in
//            print("In coreData: \(dict.language)")
//        }
//        tableView.deleteSections([index.section], with: .left)
//        tableView.reloadData()
//        menuAccessedForCell = nil
//
//    }

    
    func editButtonTapped(for index: IndexPath){
        guard let section = menuAccessedForCell?.section else { return }
        let dictionaryToEdit = dictionaries[section]
        let pairs = dictionaryToEdit.words as! Set<WordsEntity>
        
        var wordsToEdit = ""
        for pair in pairs {
            wordsToEdit += "\(pair.word ?? "") \(UserSettings.shared.settings.separators.selectedValue) \(pair.meaning ?? "")" + "\n" + "\n"
        }
            
        let vc = EditVC()
        vc.textField.text = dictionaryToEdit.language
        vc.textView.text = wordsToEdit
            
        self.navigationController?.pushViewController(vc, animated: true)
        menuAccessedForCell = nil
    }
    
    
}
//MARK: - UITableViewDataSource
extension MenuVC: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell().identifier, for: indexPath) as? TableViewCell
        let addCell = tableView.dequeueReusableCell(withIdentifier: TableViewAddCell().identifier, for: indexPath) as? TableViewAddCell
        
        if indexPath.section == tableView.numberOfSections - 1 {
            return addCell!
        } else {
            cell?.languageResultLabel.text = dictionaries[indexPath.section].language
            cell?.cardsResultLabel.text = dictionaries[indexPath.section].numberOfCards
            cell?.indexPath = indexPath
            cell?.delegate = self
            return cell!
        }
    }
}

protocol CustomCellDataDelegate: AnyObject{
    func panningBegan(for index: IndexPath)
        
    func panningEnded(active: Bool)
    
    func deleteButtonTapped(for index: IndexPath)
    
    func editButtonTapped(for index: IndexPath)
        
}
