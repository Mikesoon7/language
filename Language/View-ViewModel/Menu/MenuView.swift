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
}

class MenuView: UIViewController {
    

    private var viewModelFactory: ViewModelFactory
    private var viewModel: MenuViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    private var menuAccessedForCell: IndexPath?
    private var isUpdateNeeded: Bool = false
    
    //MARK: Views
    var tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(MenuDictionaryCell.self, forCellReuseIdentifier: MenuDictionaryCell.identifier)
        tableView.register(MenuAddDictionaryCell.self, forCellReuseIdentifier: MenuAddDictionaryCell.identifier)
        tableView.rowHeight = 104
        tableView.backgroundColor = .clear
    
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.subviews.forEach{ section in
            section.addRightSideShadow()
        }
        return tableView
    }()
        
    //MARK: Inherited
    required init(factory: ViewModelFactory){
        self.viewModelFactory = factory
        self.viewModel = factory.configureMenuViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn'r imported")
    }
    
    //MARK: - Inherited Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureNavBar()
        configureTableView()
        configureLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isUpdateNeeded {
            self.tableView.reloadData()
        }
    }
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            tableView.subviews.forEach { section in
                section.layer.shadowColor = (traitCollection.userInterfaceStyle == .dark
                                             ? shadowColorForDarkIdiom
                                             : shadowColorForLightIdiom)
            }
        }
    }
    
    //MARK: - Binding View and ViewModel
    private func bind(){
        viewModel.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output{
                case .needReload:
                    self?.tableView.reloadData()
                case .needDelete(let section):
                    self?.tableView.deleteSections([section], with: .left)
                case .needUpdate(_):
                    self?.isUpdateNeeded = true
                case .shouldPresentAddView:
                    self?.pushAddDictionaryVC()
                case .shouldPresentDetailsView(let dict):
                    self?.pushDetailsVCFor(dict)
                case .shouldPresentEditView(let dict):
                    self?.pushEditVCFor(dict)
                case .shouldUpdateLabels:
                    self?.configureLabels()
                case .error(let error):
                    self?.presentError(error)
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: - TableView SetUP
    private func configureTableView(){
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
    private func configureNavBar(){
        //Statisctic BarButton
        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "chart.bar"),
            style: .plain,
            target: self,
            action: #selector(statButtonDidTap(sender:)))
        self.navigationItem.setRightBarButton(rightButton, animated: true)
    }
    
    private func configureLabels(){
        navigationItem.title = "menuVCTitle".localized
    }
    
    //MARK: Configuring and presenting VC's
    func pushAddDictionaryVC(){
        let vc = AddDictionaryView(factory: self.viewModelFactory)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func pushDetailsVCFor(_ dictionary: DictionariesEntity){
        let vc = DetailsView(factory: self.viewModelFactory,
                             dictionary: dictionary)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func pushEditVCFor(_ dictionary: DictionariesEntity){
        let vc = EditView(dictionary: dictionary,
                          factory: self.viewModelFactory)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Actions
    @objc func statButtonDidTap(sender: Any){
        let vm = viewModelFactory.configureStatisticViewModel()
        let vc = StatisticView(viewModel: vm)
        self.present(vc, animated: true)
        //TODO: Call new vc with the model.
    }
}
//MARK: - UITableView Delegate & DataSource
extension MenuView: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSectionsInTableView()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = viewModel.dataForTableCellAt(section: indexPath.section) else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MenuAddDictionaryCell.identifier,
                for: indexPath) as? MenuAddDictionaryCell
            return cell ?? UITableViewCell()
        }
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MenuDictionaryCell.identifier,
            for: indexPath) as? MenuDictionaryCell else {
            return UITableViewCell()
        }
        let viewModel = viewModelFactory.configureStatisticModel(dictionary: data)
        cell.configureCellWith(viewModel: viewModel, delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectTableRowAt(section: indexPath.section)
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
        var completion = { [weak self] cell in
            self?.menuAccessedForCell = nil
            guard let index = self?.tableView.indexPath(for: cell) else { return }
            self?.viewModel.deleteDictionary(at: index)
        }
    
        let alertController = UIAlertController
            .alertWithAction(
                alertTitle: "menu.deleteDictionary".localized,
                action1Title: "system.cancel".localized,
                action1Style: .cancel
            )
        let delete = UIAlertAction(title: "system.delete".localized, style: .destructive) { _ in
            completion(cell)
        }
        alertController.addAction(delete)
        self.present(alertController, animated: true)
    }
    
    func editButtonDidTap(for cell: UITableViewCell){
        menuAccessedForCell = nil
        guard let index = tableView.indexPath(for: cell) else { return }
        viewModel.editDictionary(at: index)
    }
    func statisticButtonDidTap(for cell: UITableViewCell){
        
    }
    
}
