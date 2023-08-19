//
//  MenuView.swift
//  Language
//
//  Created by Star Lord on 07/07/2023.
//

import UIKit
import Charts
import CoreData
import Combine

protocol CustomCellDataDelegate: AnyObject{
    func panningBegan(for cell: UITableViewCell)

    func panningEnded(active: Bool)

    func deleteButtonDidTap(for cell: UITableViewCell)
    
    func editButtonDidTap(for cell: UITableViewCell)
    
    func statisticButtonDidTap(for cell: UITableViewCell)
    
    func importButtonDidTap()
}

class MenuView: UIViewController {
    

    private lazy var viewModel: MenuViewModel = {
        return MenuViewModel()
    }()
    private var cancellables = Set<AnyCancellable>()
    
    
    private var menuAccessedForCell: IndexPath?
        
    var tableView: UITableView = {
        var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .insetGrouped)
        tableView.register(MenuDictionaryCell.self, forCellReuseIdentifier: MenuDictionaryCell.identifier)
//        tableView.register(MenuStatisticCell.self, forCellReuseIdentifier: MenuStatisticCell.identifier)
        tableView.register(MenuAddDictionaryCell.self, forCellReuseIdentifier: MenuAddDictionaryCell.identifier)
        tableView.rowHeight = 104
        tableView.backgroundColor = .clear
    
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.subviews.forEach{ section in
            section.addRightSideShadow()
        }
        return tableView
    }()
    
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    //MARK: - Inherited Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
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
    
    //MARK: - Binding View and ViewModel
    func bind(){
        viewModel.objectDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] changeType in
                switch changeType{
                case .needReload:
                    self?.tableView.reloadData()
                case .needDelete(let section):
                    self?.tableView.deleteSections([section], with: .left)
                case .needUpdate(let section):
                    print("Reloading \(section)")
                    self?.tableView.reloadSections([section], with: .automatic)
                }
            }
            .store(in: &cancellables)
    }
    //MARK: - Controleler SetUp
    func configureController(){
        view.backgroundColor = .systemBackground
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
    //MARK: - Actions
    @objc func statButtonDidTap(sender: Any){
        //TODO: Call new vc with the model.
    }
}
//MARK: - UITableView Delegate & DataSource
extension MenuView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfCells()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        if section == numberOfSections(in: tableView) - 1 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MenuAddDictionaryCell.identifier, for: indexPath) as! MenuAddDictionaryCell
            cell.configureCellWith(delegate: self)
            return cell
        }
        let data = viewModel.dataForCell(at: indexPath)
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MenuDictionaryCell.identifier, for: indexPath) as! MenuDictionaryCell
        cell.configureCellWith(viewModel: data, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        if section == tableView.numberOfSections - 1{
            self.navigationController?.pushViewController(AddDictionaryVC(), animated: true)
        } else {
            let vc = DetailsView(dictionary: viewModel.dictionaries[section])
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }


    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, selectionFollowsFocusForRowAt indexPath: IndexPath) -> Bool {
        false
    }
}

//MARK: - Delegate for cells action.
extension MenuView: CustomCellDataDelegate{
    func panningBegan(for cell: UITableViewCell){
        let index = tableView.indexPath(for: cell)
        //Dismiss another swiped cell.
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
    
    func deleteButtonDidTap(for cell: UITableViewCell) {
        menuAccessedForCell = nil
        guard let index = tableView.indexPath(for: cell) else { return }
        viewModel.deleteDictionary(at: index)
    }
    
    func editButtonDidTap(for cell: UITableViewCell){
        menuAccessedForCell = nil
        guard let index = tableView.indexPath(for: cell) else { return }
        let vc = viewModel.editDictionary(at: index)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func statisticButtonDidTap(for cell: UITableViewCell){
        
    }
    func importButtonDidTap() {
        viewModel.importButtonWasTapped()
    }

}
