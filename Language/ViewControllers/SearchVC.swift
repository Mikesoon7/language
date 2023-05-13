//
//  SearchVC.swift
//  Language
//
//  Created by Star Lord on 02/04/2023.
//

import UIKit
import CoreData
class SearchVC: UIViewController {

    var searchBarOnTop: Bool!
    var searchBarDidChanged = false
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.backgroundColor = .clear
        table.register(SearchViewCell.self, forCellReuseIdentifier: SearchViewCell().identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.delegate = self
        table.dataSource = self
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
    
    private var allData: [WordsEntity] = []
    private var filteredData: [WordsEntity] = []
    
    private var topStroke = CAShapeLayer()
    private var bottomStroke = CAShapeLayer()
    private var upperBottomStroke = CAShapeLayer()
    
    private var tableViewBottomAnchor: NSLayoutConstraint!
    private var searchBarWidthAnchor: NSLayoutConstraint!
    private var cancelButtonLeadingAnchor: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        controllerCustomization()
        tableViewCustomization()
        navBarCustomization()
        searchBarCustomisation(onTop: searchBarOnTop)
        loadData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        }
    }
    //MARK: - Controller SetUp
    func controllerCustomization(){
        searchBarOnTop = UserSettings.shared.settings.searchBar.value
        view.backgroundColor = .systemBackground
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(positionDidChange(sender: )), name: .appSearchBarPositionDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDataDidChange(sender: )), name: .appDataDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    private func loadData() {
        let dictionaries = CoreDataHelper.shared.fetchDictionaries()
        allData = dictionaries.flatMap { dictionary in
            guard let words = dictionary.words as? Set<WordsEntity> else { return Set<WordsEntity>() }
            return words
        }
        filteredData = allData
        tableView.reloadData()
    }
    
    func navBarCustomization(){
        title = "searchVCTitle".localized
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)

        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }
    func tableViewCustomization(){
        view.addSubview(tableView)
        
        tableViewBottomAnchor = tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: searchBarOnTop ? 0 : 44)

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
            searchContainer.heightAnchor.constraint(equalToConstant: 44),
            
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
        upperBottomStroke.lineWidth = 0.4
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
            tableViewBottomAnchor?.constant = -44
        }
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
        } else {
            view.layer.addSublayer(topStroke)
            bottomStroke.removeFromSuperlayer()
        }
        searchBarDidChanged = true
    }
    @objc func appDataDidChange(sender: Notification){
        loadData()
        if searchBarOnTop && !searchControllerForTop.searchBar.text!.isEmpty{
            searchControllerForTop.searchBar.text = nil
        } else if !searchBarOnTop && customSearchBar.text!.isEmpty{
            customSearchBar.text = nil
        }
    }
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
    }
    @objc func cancelButtonTapped(sender: UIButton){
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.searchBarWidthAnchor.constant = 0
            self?.view.layoutIfNeeded()
        }
        customSearchBar.resignFirstResponder()
        customSearchBar.text = nil
    }
}

extension SearchVC: UISearchResultsUpdating{
    
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
        if !text.isEmpty {
            filteredData = allData.filter { words in
                words.word!.lowercased().contains(text.lowercased()) ||
                words.meaning!.lowercased().contains(text.lowercased())
            }
        } else {
            filteredData = allData
        }
        tableView.reloadData()
    }
}
extension SearchVC: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateSearchResults(for: nil)
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.tag == 2 {
            updateSearchResults(for: nil)
        }
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
extension SearchVC: UIScrollViewDelegate {
    
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

extension SearchVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchViewCell().identifier, for: indexPath) as? SearchViewCell else { return UITableViewCell()}
        
        let data = filteredData[indexPath.row]
        cell.wordLabel.text = data.word
        cell.descriptionLabel.text = data.meaning
        return cell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        1
    }
}

