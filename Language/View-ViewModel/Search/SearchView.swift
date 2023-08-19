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

    private var searchBarOnTop: Bool!
    private var searchBarDidChanged = false
    
    private let viewModel = SearchViewModel()
    private var cancellable = Set<AnyCancellable>()
    private let input =  PassthroughSubject<SearchViewModel.Input, Never>()

    private var expandedCellIndexSet: IndexSet = []
    
    //MARK: - Views
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = .clear
        table.register(SearchViewCell.self, forCellReuseIdentifier: SearchViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
                
        table.delegate = self
        table.dataSource = self
        
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 60
        
        table.sectionHeaderHeight = 10
        table.sectionFooterHeight = 10
        
        table.subviews.forEach { section in
            section.addCenterShadows()
        }
        return table
    }()
    lazy var topSearchBarController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "yourWord".localized
        controller.searchBar.delegate = self
        controller.searchBar.tag = 1
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        return controller
    }()
    lazy var bottomSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "yourWord".localized
        searchBar.delegate = self
        searchBar.tag = 2
        searchBar.backgroundImage = UIImage()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setAttributedTitle(NSAttributedString(string: "Cancel",
                                                     attributes: [NSAttributedString.Key.font :
                                                                    UIFont.systemFont(ofSize: 18)]), for: .normal)
        button.tintColor = .label
        button.backgroundColor = .systemBackground
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped(sender:)), for: .touchUpInside)
        return button
    }()

    let bottomSearchBarContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private var topStroke = CAShapeLayer()
    private var bottomStroke = CAShapeLayer()
    private var upperBottomStroke = CAShapeLayer()

    //MARK: Constrait related properties
    private var tableViewBottomAnchor: NSLayoutConstraint!
    private var searchBarWidthAnchor: NSLayoutConstraint!
    private var cancelButtonLeadingAnchor: NSLayoutConstraint!

    private var searchControllerHeight: CGFloat = 50
    
    
    //MARK: - Inherited
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureController()
        configureTableView()
        configureNavBar()
        configureSearchBar(positionOnTop: searchBarOnTop)
        configureLabels()
//        loadData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        input.send(.viewWillAppear)
        if searchBarDidChanged{
            configureSearchBar(positionOnTop: searchBarOnTop)
            view.layoutSubviews()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureStrokes()
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            upperBottomStroke.strokeColor = UIColor.label.cgColor
            bottomStroke.strokeColor = UIColor.label.cgColor
            topStroke.strokeColor = UIColor.label.cgColor
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
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //MARK: - Binding View and VM
    func bind(){
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { changeType in
                switch changeType{
                case .shouldUpdateResults:
                    print("Worked")
                    self.tableView.reloadData()
                case .error(let error):
                    self.presentError(error)
                case .shouldReloadView:
                    self.reloadSearchBars()
                    self.tableView.reloadData()
                case .shouldUpdateLabels:
                    self.configureLabels()
                case .shouldReplaceSearchBarOnTop(let onTop):
                    self.reloadSearchBar(positionOnTop: onTop)
                    print("Attempt to reload")
                }
            }
            .store(in: &cancellable)
    }
    //MARK: - Controller SetUp
    func configureController(){
        searchBarOnTop = viewModel.searchBarPositionIsOnTop()
        view.backgroundColor = .systemBackground
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    //MARK: - NavBar SetUp
    func configureNavBar(){
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)

        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    //MARK: - TableView SetUP
    func configureTableView(){
        view.addSubview(tableView)
        
        tableViewBottomAnchor = tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: searchBarOnTop ? 0 : searchControllerHeight)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableViewBottomAnchor!
        ])
    }
    //MARK: - ContainerForBottomSearchBar SetUp
    func configureContainerForBottomSearchBar() {
        view.addSubview(bottomSearchBarContainer)
        bottomSearchBarContainer.addSubviews(bottomSearchBar, cancelButton)
        
        searchBarWidthAnchor = bottomSearchBar.widthAnchor.constraint(
            equalTo: view.widthAnchor, multiplier: 0.95)

        cancelButtonLeadingAnchor = cancelButton.leadingAnchor.constraint(equalTo: bottomSearchBar.trailingAnchor, constant: 10)
        
        NSLayoutConstraint.activate([
            bottomSearchBarContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            bottomSearchBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSearchBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 100),
            bottomSearchBarContainer.heightAnchor.constraint(equalToConstant: searchControllerHeight),
            
            bottomSearchBar.topAnchor.constraint(equalTo: bottomSearchBarContainer.topAnchor),
            searchBarWidthAnchor,
            bottomSearchBar.bottomAnchor.constraint(equalTo: bottomSearchBarContainer.bottomAnchor),
            bottomSearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: (view.bounds.width - view.bounds.width * 0.95) / 2),
                                                     
            cancelButton.topAnchor.constraint(equalTo: bottomSearchBarContainer.topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: bottomSearchBarContainer.bottomAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 80),
            cancelButtonLeadingAnchor
        ])
        upperBottomStroke = UIView().addBottomStroke(vc: self)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: view.bounds.maxX, y: 0))
        upperBottomStroke.lineWidth = 0.5
        upperBottomStroke.path = path.cgPath
        bottomSearchBarContainer.layer.addSublayer(upperBottomStroke)

    }
        
    func configureStrokes(){
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
    
    func configureSearchBar(positionOnTop: Bool) {
        if positionOnTop {
            navigationItem.searchController = topSearchBarController
            if view.subviews.contains(bottomSearchBarContainer) {
                bottomSearchBarContainer.removeFromSuperview()
            }
            tableViewBottomAnchor?.constant = 0
        } else {
            navigationItem.searchController = nil
            if !view.subviews.contains(bottomSearchBarContainer){
                configureContainerForBottomSearchBar()
            }
            tableViewBottomAnchor?.constant = -searchControllerHeight
        }
    }
    func reloadSearchBars(){
        if searchBarOnTop && topSearchBarController.searchBar.text != nil{
            topSearchBarController.searchBar.text = nil
            topSearchBarController.resignFirstResponder()
        } else if !searchBarOnTop && bottomSearchBar.text != nil{
            bottomSearchBar.resignFirstResponder()
            bottomSearchBar.text = nil
        }
    }
    func configureLabels(){
        title = "searchVCTitle".localized
        topSearchBarController.searchBar.placeholder = "yourWord".localized
        bottomSearchBar.placeholder = "yourWord".localized
    }
    func reloadSearchBar(positionOnTop: Bool){
        searchBarOnTop = positionOnTop
        if searchBarOnTop {
            view.layer.addSublayer(bottomStroke)
            topStroke.removeFromSuperlayer()
            if bottomSearchBar.text != nil {
                bottomSearchBar.text = nil
                searchBarTextDidEndEditing(bottomSearchBar)
            }
        } else {
            view.layer.addSublayer(topStroke)
            bottomStroke.removeFromSuperlayer()
            
            if topSearchBarController.searchBar.text != nil {
                topSearchBarController.searchBar.resignFirstResponder()
                topSearchBarController.searchBar.text = nil
                topSearchBarController.isActive = false
            }
        }
        searchBarDidChanged = true
    }
    
        //MARK: - Actions
    @objc func keyboardWillShow(notification: Notification) {
        guard !searchBarOnTop else { return }
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        UIView.animate(withDuration: animationDuration) { [weak self] in
            self?.searchBarWidthAnchor.constant = -100
            self?.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        guard !searchBarOnTop else { return }
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        if bottomSearchBar.text == "" {
            UIView.animate(withDuration: animationDuration) { [weak self] in
                self?.searchBarWidthAnchor.constant = 0
                self?.view.layoutIfNeeded()
                print("1")
            }
            
        }
    }
    @objc func cancelButtonTapped(sender: UIButton){
        bottomSearchBar.resignFirstResponder()
        bottomSearchBar.text = nil

        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.searchBarWidthAnchor.constant = 0
            self?.view.layoutIfNeeded()
            print("2")
        }
        searchBarTextDidEndEditing(bottomSearchBar)
    }
}

extension SearchView: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController?){
        let text = {
            if searchBarOnTop{
                guard let text = topSearchBarController.searchBar.text else { return String() }
                return text
            } else {
                guard let text = bottomSearchBar.text else { return String() }
                return text
            }
        }()
        print("Update result worked")
        input.send(.reciveText(text))
    }
}

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
            bottomSearchBar.resignFirstResponder()
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.isFirstResponder {
            searchBar.becomeFirstResponder()
            searchBar.text = nil
        }
    }
}
extension SearchView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchBarOnTop {
            let offsetY = scrollView.contentOffset.y
            let searchBarHeight = topSearchBarController.searchBar.frame.height
            if offsetY >= searchBarHeight {
                topSearchBarController.searchBar.isHidden = true
            } else {
                topSearchBarController.searchBar.isHidden = false
            }
        }
    }
}

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

