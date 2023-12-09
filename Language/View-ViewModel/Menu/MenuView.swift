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

protocol MenuCellDelegate: AnyObject{
    func panningBegan(for cell: UITableViewCell)

    func panningEnded(active: Bool)

    func deleteButtonDidTap(for cell: UITableViewCell)
    
    func editButtonDidTap(for cell: UITableViewCell)
}

class MenuView: UIViewController {
    private var viewModelFactory: ViewModelFactory
    private var viewModel: MenuViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    private var menuAccessedForCell: IndexPath?
    private var isUpdateNeeded: Bool = false
    
//    var firstLaunch = true
    
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
        super.viewWillAppear(animated)
        if isUpdateNeeded {
            self.tableView.reloadData()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //TODO: Dont forget to change on release method.
        viewModel.validateLaunchStatus()
//        if firstLaunch {
//            pushTutorialVC()
//            firstLaunch = false
//        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
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
                case .shouldPresentTutorialView:
                    self?.pushTutorialVC()
                case .shouldUpdateLabels:
                    self?.configureLabels()
                case .error(let error):
                    self?.presentError(error)
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: Dictionary restore
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if viewModel.canUndo() {
                undoActionWasDetected()
            }
        }
    }
    
    private func undoActionWasDetected(){
        let alertController = UIAlertController
            .alertWithAction(alertTitle: "menu.undo.title".localized,
                             action1Title: "system.cancel".localized,
                             action1Style: .cancel
            )
        let restoreAction = UIAlertAction(title: "system.restore".localized,
                                          style: .default) { _ in
            self.undoLastDeletion()
        }
        restoreAction.setValue(UIColor.label, forKey: "titleTextColor")
        alertController.addAction(restoreAction)
        self.present(alertController, animated: true)
    }


    private func undoLastDeletion() {
        viewModel.undoLastDeletion()
    }

    
    //MARK: Subviews setUp & Layout
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
        navigationItem.title = "menu.title".localized
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
    func pushTutorialVC(){
        let vc = TutorialVC(
            delegate: self,
            topInset: view.safeAreaInsets.top,
            bottomInset: navigationController?.tabBarController?.tabBar.bounds.height ?? 0)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    
    //MARK: - Actions
    @objc func statButtonDidTap(sender: Any){
        let vm = viewModelFactory.configureStatisticViewModel()
        let vc = StatisticView(viewModel: vm)
        self.present(vc, animated: true)
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
//MARK: - Delegate for tutorial.
extension MenuView: TutorialCellHintProtocol{
    func stopShowingHint() {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? MenuDictionaryCell{
            cell.activate(false)
        } else {
            print("failed")
        }
    }
    
    func needToShowHint() {
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? MenuDictionaryCell{
            UIView.animate(withDuration: 0.1, delay: 0.8) {
                cell.activate(true)
            }
        }
    }
    func openAddDictionary() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            let vc = AddDictionaryView(factory: self.viewModelFactory)
            vc.isFirstLaunch = true
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
}
//MARK: - Delegate for cells action.
extension MenuView: MenuCellDelegate{
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
        let completion = { [weak self] cell in
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
}
