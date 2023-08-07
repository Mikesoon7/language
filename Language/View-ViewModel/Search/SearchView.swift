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
    
    private let model = SearchViewModel()
    private var cancellable = Set<AnyCancellable>()
    private let input: PassthroughSubject<SearchViewModel.Input, Never> = .init()

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
            section.addCenterSideShadows(false)
        }
        return table
    }()
    lazy var searchControllerForTop: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "yourWord".localized
        controller.searchBar.delegate = self
        controller.searchBar.tag = 1
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        return controller
    }()
    lazy var customSearchBar: UISearchBar = {
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

    let searchContainer: UIView = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        controllerCustomization()
        tableViewCustomization()
        configureNavBar()
        searchBarCustomisation(onTop: searchBarOnTop)
        configureLabel()
//        loadData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        input.send(.viewWillAppear)
        if searchBarDidChanged{
            searchBarCustomisation(onTop: searchBarOnTop)
            view.layoutSubviews()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        strokeCustomization()
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
    func bind(){
        let output = model.transform(input: input.eraseToAnyPublisher())
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
                    self.configureLabel()
                case .shouldReplaceSearchBarOnTop(let onTop):
                    self.changeSearchBarPosition(onTop: onTop)
                }
            }
            .store(in: &cancellable)
    }
    //MARK: - Controller SetUp
    func controllerCustomization(){
        searchBarOnTop = UserSettings.shared.settings.searchBar.value
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
    
    func tableViewCustomization(){
        view.addSubview(tableView)
        
        tableViewBottomAnchor = tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: searchBarOnTop ? 0 : searchControllerHeight)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableViewBottomAnchor!
        ])
    }
    func searchContainerCustomization() {
        view.addSubview(searchContainer)
        searchContainer.addSubviews(customSearchBar, cancelButton)
        
        searchBarWidthAnchor = customSearchBar.widthAnchor.constraint(
            equalTo: view.widthAnchor, multiplier: 0.95)

        cancelButtonLeadingAnchor = cancelButton.leadingAnchor.constraint(equalTo: customSearchBar.trailingAnchor, constant: 10)
        
        NSLayoutConstraint.activate([
            searchContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 100),
            searchContainer.heightAnchor.constraint(equalToConstant: searchControllerHeight),
            
            customSearchBar.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchBarWidthAnchor,
            customSearchBar.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            customSearchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: (view.bounds.width - view.bounds.width * 0.95) / 2),
                                                     
            cancelButton.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 80),
            cancelButtonLeadingAnchor
        ])
        upperBottomStroke = UIView().addBottomStroke(vc: self)
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: view.bounds.maxX, y: 0))
        upperBottomStroke.lineWidth = 0.5
        upperBottomStroke.path = path.cgPath
        searchContainer.layer.addSublayer(upperBottomStroke)

    }
        
    func strokeCustomization(){
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
    
    func searchBarCustomisation(onTop: Bool) {
        if onTop {
            navigationItem.searchController = searchControllerForTop
            if view.subviews.contains(searchContainer) {
                searchContainer.removeFromSuperview()
            }
            tableViewBottomAnchor?.constant = 0
        } else {
            navigationItem.searchController = nil
            if !view.subviews.contains(searchContainer){
                searchContainerCustomization()
            }
            tableViewBottomAnchor?.constant = -searchControllerHeight
        }
    }
    func reloadSearchBars(){
        if searchBarOnTop && searchControllerForTop.searchBar.text != nil{
            searchControllerForTop.searchBar.text = nil
            searchControllerForTop.resignFirstResponder()
        } else if !searchBarOnTop && customSearchBar.text != nil{
            customSearchBar.resignFirstResponder()
            customSearchBar.text = nil
        }
    }
    func configureLabel(){
        title = "searchVCTitle".localized
        searchControllerForTop.searchBar.placeholder = "yourWord".localized
        customSearchBar.placeholder = "yourWord".localized
    }
    func changeSearchBarPosition(onTop: Bool){
        searchBarOnTop = onTop
        if searchBarOnTop {
            view.layer.addSublayer(bottomStroke)
            topStroke.removeFromSuperlayer()
            if customSearchBar.text != nil {
                customSearchBar.text = nil
                searchBarTextDidEndEditing(customSearchBar)
            }
        } else {
            view.layer.addSublayer(topStroke)
            bottomStroke.removeFromSuperlayer()
            
            if searchControllerForTop.searchBar.text != nil {
                searchControllerForTop.searchBar.resignFirstResponder()
                searchControllerForTop.searchBar.text = nil
                searchControllerForTop.isActive = false
            }
        }
        searchBarDidChanged = true
    }
    
        //MARK: - Actions
    @objc func languageDidChange(sender: AnyObject){
        title = "searchVCTitle".localized
        searchControllerForTop.searchBar.placeholder = "yourWord".localized
        customSearchBar.placeholder = "yourWord".localized
    }
    @objc func positionDidChange(sender: AnyObject){
        searchBarOnTop = UserSettings.shared.settings.searchBar.value
        if searchBarOnTop {
            view.layer.addSublayer(bottomStroke)
            topStroke.removeFromSuperlayer()
            if customSearchBar.text != nil {
                customSearchBar.text = nil
                searchBarTextDidEndEditing(customSearchBar)
            }
        } else {
            view.layer.addSublayer(topStroke)
            bottomStroke.removeFromSuperlayer()
            
            if searchControllerForTop.searchBar.text != nil {
                searchControllerForTop.searchBar.resignFirstResponder()
                searchControllerForTop.searchBar.text = nil
                searchControllerForTop.isActive = false
            }
        }
        searchBarDidChanged = true
    }
//    @objc func appDataDidChange(sender: Notification){
//        let type = sender.userInfo?["changeType"] as? NSManagedObject.ChangeType
//        print("Debug purpose: SearchVC appDataDidChange worked with type: \(type)")
//        if searchBarOnTop && searchControllerForTop.searchBar.text != nil{
//            searchControllerForTop.searchBar.text = nil
//            searchControllerForTop.resignFirstResponder()
//        } else if !searchBarOnTop && customSearchBar.text != nil{
//            customSearchBar.resignFirstResponder()
//            customSearchBar.text = nil
//        }
//    }
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
        if customSearchBar.text == "" {
            UIView.animate(withDuration: animationDuration) { [weak self] in
                self?.searchBarWidthAnchor.constant = 0
                self?.view.layoutIfNeeded()
                print("1")
            }
            
        }
    }
    @objc func cancelButtonTapped(sender: UIButton){
        customSearchBar.resignFirstResponder()
        customSearchBar.text = nil

        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.searchBarWidthAnchor.constant = 0
            self?.view.layoutIfNeeded()
            print("2")
        }
        searchBarTextDidEndEditing(customSearchBar)
    }
}

extension SearchView: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController?){
        let text = {
            if searchBarOnTop{
                guard let text = searchControllerForTop.searchBar.text else { return String() }
                return text
            } else {
                guard let text = customSearchBar.text else { return String() }
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
            customSearchBar.resignFirstResponder()
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
            let searchBarHeight = searchControllerForTop.searchBar.frame.height
            if offsetY >= searchBarHeight {
                searchControllerForTop.searchBar.isHidden = true
            } else {
                searchControllerForTop.searchBar.isHidden = false
            }
        }
    }
}

extension SearchView: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfCells()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchViewCell.identifier, for: indexPath) as? SearchViewCell else { return UITableViewCell()}
        
        cell.configureCellWith(data: model.dataForCell(at: indexPath))
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

