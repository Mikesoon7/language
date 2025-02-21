//
//  SearchVC.swift
//  Language
//
//  Created by Star Lord on 02/04/2023.
//
//  REFACTORING STATE: CHECKED

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
    
    var popoverView: SearchCellExpandedView?
    
    var selectedIndexPath: IndexPath? = nil
    
    //MARK: - Views
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.contentInset = .init(top: .longInnerSpacer, left: .innerSpacer, bottom: .longInnerSpacer, right: .innerSpacer)
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        
        view.register(SearchCell.self, forCellWithReuseIdentifier: SearchCell.identifier)
        view.register(DictionaryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DictionaryHeaderView.headerIdentifier)
        
        return view
    }()
    
    private let layout = UICollectionViewFlowLayout()
    
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
    private var collectionViewBottomAnchor: NSLayoutConstraint =    .init()
    private var searchBarWidthAnchor: NSLayoutConstraint =          .init()
    private var cancelButtonLeadingAnchor: NSLayoutConstraint =     .init()
    
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
        configureCollectionView()
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
        adjustLayoutForSizeClass()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        adjustLayoutForSizeClass()
        dismissPopover()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            bottomStroke.strokeColor = UIColor.label.cgColor
            topStroke.strokeColor = UIColor.label.cgColor
            bottomSearchView.topStroke.strokeColor = UIColor.label.cgColor
            
            if traitCollection.userInterfaceStyle == .dark {
                collectionView.subviews.forEach { section in
                    section.layer.shadowColor = shadowColorForDarkIdiom
                }
            } else {
                collectionView.subviews.forEach { section in
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
                    self.collectionView.reloadData()
                case .error(let error):
                    self.navigationController?.presentError(error, sourceView: self.view)
                case .shouldReloadView:
                    self.refreshSearchBars()
                case .shouldUpdateLabels:
                    self.configureLabels()
                    self.bottomSearchView.configureLabels()
                case .shouldUpdateFonts:
                    self.configureFont()
                case .shouldReplaceSearchBarOnTop(_):
                    self.prepeareForNewPosition()
                case .shouldReloadCell(let cellIndex):
                    self.collectionView.reloadItems(at: [cellIndex])
                }
            }
            .store(in: &cancellable)
    }
    
    //MARK: - Controller SetUp
    private func configureController(){
        view.backgroundColor = .systemBackground
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK:  NavBar SetUp
    private func configureNavBar(){
        navigationController?.navigationBar.titleTextAttributes = FontChangeManager.shared.VCTitleAttributes()
        
    }
    
    //MARK: CollectionView + Layout setUp
    private func configureCollectionView() {
        view.addSubview(collectionView)
        
        collectionViewBottomAnchor = collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: searchBarOnTop ? 0 : -searchControllerHeight)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionViewBottomAnchor
        ])
    }
    
    private func adjustLayoutForSizeClass() {
        let collectionWidth = collectionView.bounds.width
        let itemWidth: CGFloat = (traitCollection.isRegularWidth
                                  ? (collectionWidth - (.innerSpacer * 2 + .longInnerSpacer * 2)) / 3
                                  : (collectionWidth - (.innerSpacer * 2 + .longInnerSpacer)) / 2
        )
        
        layout.itemSize = CGSize(width: itemWidth, height: .genericButtonHeight)
        layout.minimumLineSpacing = .longInnerSpacer
        layout.sectionInset = UIEdgeInsets(top: .zero, left: .zero, bottom: .longOuterSpacer, right: .zero)
        layout.headerReferenceSize = CGSize(width: collectionView.bounds.width, height: .genericButtonHeight) // Header height
        
        layout.invalidateLayout()
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
                self.tabBarController?.tabBar.layer.addSublayer(bottomStroke)
            } else {
                self.navigationController?.navigationBar.layer.addSublayer(topStroke)
            }
        }
    }
    
    //MARK: Configure SearchBars
    private func configureSearchBar() {
        if searchBarOnTop {
            navigationItem.searchController = topSearchController
            collectionViewBottomAnchor.constant = 0
        } else {
            if !view.subviews.contains(bottomSearchView){
                configureBottomSearchView()
            } else {
                bottomSearchView.isHidden = false
            }
            
            collectionViewBottomAnchor.constant = -searchControllerHeight
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
            self.tabBarController?.tabBar.layer.addSublayer(bottomStroke)
            topStroke.removeFromSuperlayer()
            refreshBottomSearchBar()
            bottomSearchView.isHidden = true
        } else {
            bottomStroke.removeFromSuperlayer()
            refreshTopSearchBar()
            navigationItem.searchController = nil
            self.navigationController?.navigationBar.layer.addSublayer(topStroke)
        }
        searchBarDidChanged = true
    }
    
    //MARK: Text values setUp or Update.
    private func configureLabels(){
        title = "searchVCTitle".localized
        topSearchController.searchBar.placeholder = "yourWord".localized
    }
    
    private func configureFont(){
        configureNavBar()
        collectionView.reloadData()
    }
    
    //MARK: - Actions
    //These methods will trigger only if the view uses custom bottm searcHBar. We need in to animate appearence of cancel button and shrinking the searchBar field.
    @objc func keyboardWillShow(notification: Notification) {
        guard !searchBarOnTop else { return }
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }
        
        bottomSearchView.animateTransitionTo(isActivated: true, time: animationDuration)
        
        let keyboardHeight = keyboardFrame.height
        collectionView.contentInset = UIEdgeInsets(top: .longInnerSpacer, left: .innerSpacer,
                                                   bottom: keyboardHeight, right: .innerSpacer)
        collectionView.scrollIndicatorInsets = collectionView.contentInset
        
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard !searchBarOnTop else { return }
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        
        collectionView.contentInset = UIEdgeInsets(top: .longInnerSpacer, left: .innerSpacer,
                                                   bottom: -.longInnerSpacer, right: .innerSpacer)
        
        collectionView.scrollIndicatorInsets =   collectionView.contentInset
        //Here we checking if searchBar contain text. If contains, that means search button was tapped.
        if bottomSearchView.searchBar.text == nil {
            bottomSearchView.animateTransitionTo(isActivated: false, time: animationDuration)
        }
    }
    @objc func dismissPopover() {
        popoverView?.dismissPopOver(closure: self.popOverDidDismiss )
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

//MARK: - CollectionView Delegate
extension SearchView: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCellsIn(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DictionaryHeaderView.headerIdentifier,
            for: indexPath
        ) as! DictionaryHeaderView
        let name = viewModel.titleForHeaderView(at: indexPath.section)
        header.configureCellWithData(name)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = viewModel.dataForCellFor(indexPath: indexPath)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCell.identifier, for: indexPath) as? SearchCell else { return UICollectionViewCell()}
        cell.configureCellWith(data: data)
        cell.addCenterShadows()
        return cell
    }
    
    
    //MARK: Access Responce
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            })
        }
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SearchCell else { return }
        
        if selectedIndexPath != nil { self.dismissPopover() }
        
        let numberOfColumns = traitCollection.isRegularWidth ? 3 : 2
        
        let viewToAttach = view.window ?? view ?? collectionView
        
        let cellFrameInWindow = collectionView.convert(cell.frame, to: view)
        
        let data = viewModel.dataForCellFor(indexPath: indexPath)
        
        let cellPosition: Position = {
            let part = collectionView.bounds.width / CGFloat(numberOfColumns)
            
            if cellFrameInWindow.midX < part {
                return .leading
            } else {
                if (numberOfColumns == 3 && cellFrameInWindow.midX > part * 2) || numberOfColumns == 2 {
                    return .trailing
                } else {
                    return .center
                }
            }
        }()
        
        let popover = SearchCellExpandedView(windowView: viewToAttach, shadowPosition: cellPosition, sourceViewFrame: cellFrameInWindow, word: data.word, description: data.description, delegate: self, selectedIndex: indexPath, selectedSeparator: viewModel.textSeparator(), placeholder: viewModel.currentPlaceholder())
        
        
        self.selectedIndexPath = indexPath
        self.popoverView = popover
        popover.modalPresentationStyle = .overFullScreen
        self.present(popover, animated: false)
        popover.presentPopOver()
    }
}

extension SearchView: SearchViewDeleteDelegate{
    func shouldDeleteCell(at index: IndexPath) {
        viewModel.deleteWordAt(indexPath: index)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.popOverDidDismiss()
        })

    }
    func shouldSaveCell(at index: IndexPath, text: String) {
        viewModel.editWord(with: text, index: index)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.popOverDidDismiss()
        })

    }
    func popOverDidDismiss() {
//        self.popoverView?.dismiss(animated: false)
        self.popoverView = nil
        self.selectedIndexPath = nil
    }
}



