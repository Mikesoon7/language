//
//  SearchVC.swift
//  Language
//
//  Created by Star Lord on 02/04/2023.
//

import UIKit
import CoreData
import Combine

class SearchView: UIViewController {

    private var searchBarOnTop: Bool {
        viewModel.searchBarPositionIsOnTop()
    }
    private var searchBarDidChanged = false
    
    private let viewModelFactory: ViewModelFactory
    private let viewModel: SearchViewModel
    private var cancellable = Set<AnyCancellable>()
    private let input =  PassthroughSubject<SearchViewModel.Input, Never>()
    
    //MARK: - Views
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = .clear
        table.register(SearchViewCell.self, forCellReuseIdentifier: SearchViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
    
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 60
        
        table.sectionHeaderHeight = 10
        table.sectionFooterHeight = 10
        
        table.subviews.forEach { section in
            section.addCenterShadows()
        }
        return table
    }()
    
    
    private lazy var topSearchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.delegate = self
        controller.searchBar.tag = 1
        controller.obscuresBackgroundDuringPresentation = false
        return controller
    }()
    
    private let bottomSearchView: CustomSearchBar = CustomSearchBar()

    private var topStroke = CAShapeLayer()
    private var bottomStroke = CAShapeLayer()

    //MARK: Constrait related properties
    private var tableViewBottomAnchor: NSLayoutConstraint!
    private var searchBarWidthAnchor: NSLayoutConstraint!
    private var cancelButtonLeadingAnchor: NSLayoutConstraint!

    private let searchControllerHeight: CGFloat = 50
    
    
    required init(factory: ViewModelFactory){
        self.viewModelFactory = factory
        self.viewModel = factory.configureSearchViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported")
    }
    //MARK: - Inherited
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureController()
        configureTableView()
        configureNavBar()
        configureSearchBar()
        configureLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        input.send(.viewWillAppear)
        if searchBarDidChanged{
            configureSearchBar()
            view.layoutSubviews()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureStrokes()
        bottomSearchView.configureStrokes()
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            bottomStroke.strokeColor = UIColor.label.cgColor
            topStroke.strokeColor = UIColor.label.cgColor
            bottomSearchView.topStroke.strokeColor = UIColor.label.cgColor
            
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
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: - Binding View and VM
    func bind(){
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { changeType in
                switch changeType{
                case .shouldUpdateResults:
                    self.tableView.reloadData()
                case .error(let error):
                    self.presentError(error)
                case .shouldReloadView:
                    self.refreshSearchBars()
                case .shouldUpdateLabels:
                    self.configureLabels()
                    self.bottomSearchView.configureLabels()
                case .shouldUpdateFonts:
                    self.configureFont()
                case .shouldReplaceSearchBarOnTop(_):
                    self.prepeareForNewPosition()
                }
            }
            .store(in: &cancellable)
    }
    //MARK: - Controller SetUp
    func configureController(){
        view.backgroundColor = .systemBackground
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    //MARK:  NavBar SetUp
    func configureNavBar(){
        navigationController?.navigationBar.titleTextAttributes = FontChangeManager.shared.VCTitleAttributes()

//        self.navigationController?.navigationBar.tintColor = .label
//        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    private func configureFont(){
        navigationController?.navigationBar.titleTextAttributes =  FontChangeManager.shared.VCTitleAttributes()
        self.tableView.reloadData()
    }
    
    //MARK:  TableView SetUP
    private func configureTableView(){
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableViewBottomAnchor = tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: searchBarOnTop ? 0 : searchControllerHeight)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableViewBottomAnchor!
        ])
    }
    //MARK: ContainerForBottomSearchBar SetUp
    private func configureBottomSearchView() {
        view.addSubview(bottomSearchView)

        bottomSearchView.delegate = self
        
        NSLayoutConstraint.activate([
            bottomSearchView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            bottomSearchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSearchView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSearchView.heightAnchor.constraint(equalToConstant: searchControllerHeight),
        ])
    }
    //MARK: Strokes
    private func configureStrokes(){
        if topStroke.superlayer == nil && bottomStroke.superlayer == nil {
            topStroke = UIView().addTopStroke(vc: self)
            bottomStroke = UIView().addBottomStroke(vc: self)
            
            if searchBarOnTop {
                view.layer.addSublayer(bottomStroke)
            } else {
                view.layer.addSublayer(topStroke)
            }
        }
    }

    //MARK: Configure SearchBars
    private func configureSearchBar() {
        if searchBarOnTop {
            navigationItem.searchController = topSearchController
            tableViewBottomAnchor?.constant = 0
        } else {
            if !view.subviews.contains(bottomSearchView){
                configureBottomSearchView()
            } else {
                bottomSearchView.isHidden = false
            }

            tableViewBottomAnchor?.constant = -searchControllerHeight
        }
    }
    
    //MARK: Refreshing SearchBars.
    private func refreshSearchBars(){
        if searchBarOnTop{
            refreshTopSearchBar()
        } else {
            refreshBottomSearchBar()
        }
    }
    //If searchBar contain text( that mean in search stage) we clearing it, resigning and updating tableView, by manualy calling didEndEditing.
    private func refreshTopSearchBar(){
        if topSearchController.searchBar.text != nil{
            topSearchController.searchBar.text = nil
            topSearchController.isActive = false
            searchBarTextDidEndEditing(topSearchController.searchBar)
            topSearchController.resignFirstResponder()
        }
    }
    private func refreshBottomSearchBar(){
        if bottomSearchView.searchBar.text != nil{
            bottomSearchView.searchBar.text = nil
            bottomSearchView.searchBar.resignFirstResponder()
            bottomSearchView.animateTransitionTo(isActivated: false, time: 0.2)
            searchBarTextDidEndEditing(bottomSearchView.searchBar)
        }
    }
    
    //MARK: Prepairing view by canishing current searchBar
    private func prepeareForNewPosition(){
        if searchBarOnTop {
            view.layer.addSublayer(bottomStroke)
            topStroke.removeFromSuperlayer()
            refreshBottomSearchBar()
            bottomSearchView.isHidden = true
        } else {
            view.layer.addSublayer(topStroke)
            bottomStroke.removeFromSuperlayer()
            refreshTopSearchBar()
            navigationItem.searchController = nil
        }
        searchBarDidChanged = true
    }
    
    //MARK: Text values setUp or Update.
    private func configureLabels(){
        title = "searchVCTitle".localized
        topSearchController.searchBar.placeholder = "yourWord".localized
    }

    
    //MARK: - Actions
    //These methods will trigger only if the view uses custom bottm searcHBar. We need in to animate appearence of cancel button and shrinking the searchBar field.
    @objc func keyboardWillShow(notification: Notification) {
        guard !searchBarOnTop else { return }
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        bottomSearchView.animateTransitionTo(isActivated: true, time: animationDuration)
    }

    @objc func keyboardWillHide(notification: Notification) {
        guard !searchBarOnTop else { return }
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        //Here we checking if searchBar contain text. If contains, that means search button was tapped.
        if bottomSearchView.searchBar.text == nil {
            bottomSearchView.animateTransitionTo(isActivated: false, time: animationDuration)
        }
    }
}

//MARK: - SearchResults updating.
extension SearchView: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController?){
        let text = {
            if searchBarOnTop{
                guard let text = topSearchController.searchBar.text else { return String() }
                return text
            } else {
                guard let text = bottomSearchView.searchBar.text else { return String() }
                return text
            }
        }()
        input.send(.reciveText(text))
    }
}

//MARK: - SearchBar delegate.
//Since i havent found a way to implement custom bottomSearchBar with controller, i should trigger custom search results updater ecery time the customSearchBar calls its delegate.
extension SearchView: UISearchBarDelegate{
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: nil)
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        updateSearchResults(for: nil)
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        updateSearchResults(for: nil)
        if searchBar.tag == 2 {
            bottomSearchView.searchBar.resignFirstResponder()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.isFirstResponder {
            searchBar.becomeFirstResponder()
            searchBar.text = nil
        }
    }
}

//MARK: - TableView Delegate & DataSource
extension SearchView: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfCells()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchViewCell.identifier, for: indexPath) as? SearchViewCell else { return UITableViewCell()}
        
        cell.configureCellWith(data: viewModel.dataForCell(at: indexPath))
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SearchViewCell else { return }
        tableView.beginUpdates()
        cell.isExpanded.toggle()
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

