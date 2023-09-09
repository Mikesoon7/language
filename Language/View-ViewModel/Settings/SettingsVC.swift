//
//  SettingsVC.swift
//  Language
//
//  Created by Star Lord on 05/03/2023.
//

import UIKit
import Combine

class SettingsVC: UIViewController {
    
    private let viewModelFactory: ViewModelFactory
    private let viewModel:  SettingsViewModel
    private var cancellable = Set<AnyCancellable>()
    
    //MARK: Views.
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(SettingsHeaderCell.self, forCellReuseIdentifier: SettingsHeaderCell.identifier)
        view.register(SettingsTextCell.self, forCellReuseIdentifier: SettingsTextCell.identifier)
        view.register(SettingsImageCell.self, forCellReuseIdentifier: SettingsImageCell.identifier)
        
        view.backgroundColor = .clear
        view.separatorStyle = .none
    
        view.translatesAutoresizingMaskIntoConstraints = false
        view.subviews.forEach { sections in
            sections.addRightSideShadow()
        }
        return view
    }()
    
    
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    required init(factory: ViewModelFactory){
        self.viewModelFactory = factory
        self.viewModel = factory.configureSettingsViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported")
    }
    //MARK: Inherited methods and initializers.
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureViewController()
        configureNavBar()
        configureTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureStrokes()
    }
        
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            bottomStroke.strokeColor = UIColor.label.cgColor
            topStroke.strokeColor = UIColor.label.cgColor
            tableView.subviews.forEach { view in
                view.layer.shadowColor = (traitCollection.userInterfaceStyle == .dark
                                          ? shadowColorForDarkIdiom
                                          : shadowColorForLightIdiom )
            }
        }
    }
    //MARK: Binding View and ViewModel
    func bind(){
        viewModel.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output{
                case .needPresentAlertWith(let actions):
                    self?.presentAlertWith(action: actions)
                case .needUpdateRowAt(let index):
                    self?.tableView.reloadRows(at: [index], with: .fade)
                case .needUpdateLanguage:
                    self?.updateLanguage()
                case .needPresentNotificationView:
                    self?.presentNotificationVC()
                case .needPresentSeparatorsView:
                    self?.presentSeparatorVC()
                }
            }
            .store(in: &cancellable)
    }
    //MARK: Configuring view
    func configureViewController(){
        view.backgroundColor = .systemBackground
        
    }

    //MARK: - Stroke SetUp
    func configureStrokes(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
    
    //MARK: - NavigationBar SetUp
    func configureNavBar(){
        self.navigationItem.title = "settingsVCTitle".localized
        self.navigationController?.navigationBar.titleTextAttributes = NSAttributedString.textAttributesForNavTitle()
//        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }
    //MARK: - TableView SetUp
    func configureTableView(){
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    //MARK: - ViewModelResponse
    func presentNotificationVC(){
        let vc = NotificationView()
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    func presentSeparatorVC(){
        let vc = SeparatorsView()
        self.present(vc, animated: true)
    }
    //Attaching cancel action to passed action.
    func presentAlertWith(action: [UIAlertAction]){
        let alertMessage = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "system.cancel".localized, style: .cancel)
        action.forEach({alertMessage.addAction($0)})
        alertMessage.addAction(cancelAction)
        self.present(alertMessage, animated: true)
    }
    //Reloading table to update localized text values.
    func updateLanguage(){
        tableView.reloadData()
        navigationItem.title = "settingsVCTitle".localized
        
    }
}

//MARK: - UITableView Delegate & DataSource
extension SettingsVC: UITableViewDelegate,  UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberofRowsInSection(section: section)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRowAt(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = UITableViewCell()
        let data = viewModel.dataForCellAt(indexPath: indexPath)
        if let data = data as? DataForSettingsHeaderCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsHeaderCell.identifier, for: indexPath) as? SettingsHeaderCell else { return defaultCell }
            cell.configureCellWithData(data)
            return cell
        } else
        if let data = data as? DataForSettingsTextCell{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTextCell.identifier, for: indexPath) as? SettingsTextCell else { return defaultCell }
            cell.configureCellWithData(data)
            return cell
        } else
        if let data = data as? DataForSettingsImageCell{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsImageCell.identifier, for: indexPath) as? SettingsImageCell  else { return defaultCell }
            cell.configureCellWithData(data)
            return cell
        }
        return defaultCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.heightForRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 80
        }
        return UITableView.automaticDimension
    }
}
