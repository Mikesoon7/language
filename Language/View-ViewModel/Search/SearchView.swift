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

fileprivate enum CustomStrokePosition {
    case top, bottom, undefined
}


class SearchView: UIViewController {
    
    //Combine
    private let viewModelFactory: ViewModelFactory
    private let viewModel: SearchViewModel
    private var cancellable = Set<AnyCancellable>()
    private let input =  PassthroughSubject<SearchViewModel.Input, Never>()
    
    
    private var keyboardListener: KeyboardListener?
    private var alertCoordinator = SearchViewAlertController()

    private var popoverController: SearchCellExpandedView?
    private var selectedIndexPath: IndexPath? = nil
    
    private var currentLayoutContext: CustomLayoutContext?
    
    private var currentStrokePosition: CustomStrokePosition?
    private var isStrokePositionPending: Bool = false
    
    
    //MARK: - Views
    private let layout = UICollectionViewFlowLayout()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.contentInset = collectionContentInset
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        
        view.register(SearchCell.self, forCellWithReuseIdentifier: SearchCell.identifier)
        view.register(DictionaryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DictionaryHeaderView.headerIdentifier)
        
        return view
    }()
    
    
    //MARK: SearchRelated
    private lazy var topSearchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.delegate = self
        controller.searchBar.tag = 1
        controller.obscuresBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false

        return controller
    }()
    
    private let bottomSearchView: CustomSearchBarView = CustomSearchBarView()
    
    
    //MARK: Strokes
    private var topStroke = CAShapeLayer()
    private var bottomStroke = CAShapeLayer()

    
    //MARK: Constrait related properties
    private let collectionContentInset: UIEdgeInsets = .init(
        top: .longInnerSpacer, left: .innerSpacer,
        bottom: .longOuterSpacer, right: .innerSpacer)

    private var searchBarBottomAnchorActive: NSLayoutConstraint =   .init()
    private var searchBarBottomAnchorInactive: NSLayoutConstraint = .init()
    
    private let searchControllerHeight: CGFloat = 44
    
    
    //MARK: Init
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
        bindViewHelpers()
        
        configureController()
        configureCollectionView()
        configureNavBar()
        configureBottomSearchView()
        configureLabels()
        
        applySearchBarPosition(viewModel.searchBarPosition)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        input.send(.viewWillAppear)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Sometimes UIKit updates
        guard !isStrokePositionPending else {
            updateStrokesIfNeeded(positionIsPending: true)
            isStrokePositionPending = false
            return
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateLayoutIfNeeded()
        updateStrokesIfNeeded()
        bottomSearchView.configureStrokes()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateLayoutIfNeeded(width: size.width)
        dismissPopover()
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            bottomStroke.strokeColor = UIColor.label.cgColor
            topStroke.strokeColor = UIColor.label.cgColor
            bottomSearchView.updateForThemeChange()
            
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
    deinit { NotificationCenter.default.removeObserver(self) }

    //MARK: - Binding View and VM
    func bind(){
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { changeType in
                switch changeType{
                case .shouldUpdateResults:
                    self.collectionView.reloadData()
                case .shouldPresentError(let error):
                    self.navigationController?.presentError(error, sourceView: self.view)
                case .shouldUpdateLabels:
                    self.configureLabels()
                    self.bottomSearchView.updateForLanguageChange()
                case .shouldUpdateFonts:
                    self.configureFont()
                case .reflectSearchPositionChange(let position):
                    self.applySearchBarPosition(position)
                case .shouldReloadCell(let cellIndex):
                    self.collectionView.reloadItems(at: [cellIndex])
                case .shouldPresentAlert(let alertType):
                    self.presentAlert(for: alertType)
                }
            }
            .store(in: &cancellable)
    }
    
    func bindViewHelpers() {
        self.keyboardListener = KeyboardListener(view: self.view)
        
        keyboardListener?.events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else {return}
                handleKeyboard(event)
            }
            .store(in: &cancellable)
    }
    
    //MARK: - SetUp Subviews
    private func configureController(){
        view.backgroundColor = .systemBackground
    }
    
    private func configureNavBar(){
        navigationController?.navigationBar.titleTextAttributes = FontChangeManager.shared.VCTitleAttributes()
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
                
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
        
    private func configureBottomSearchView() {
        view.addSubview(bottomSearchView)
        
        bottomSearchView.delegate = self
        bottomSearchView.isHidden = true
        
        self.searchBarBottomAnchorActive = bottomSearchView.bottomAnchor.constraint(
            equalTo: view.keyboardLayoutGuide.topAnchor)
        self.searchBarBottomAnchorInactive = bottomSearchView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            searchBarBottomAnchorInactive,
            bottomSearchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSearchView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSearchView.heightAnchor.constraint(equalToConstant: searchControllerHeight),
        ])
    }
    
    //MARK: Refreshing SearchBars.
    private func clearAndResignPreviousSearch() {
        switch viewModel.searchBarPosition {
        case .onTop:
            bottomSearchView.refreshSearchBar()
        case .atTheBottom:
            topSearchController.searchBar.text = nil
            topSearchController.searchBar.resignFirstResponder()
        }
    }

//    MARK: State Change
    private func applySearchBarPosition(_ position: AppSearchBarPosition ) {
        switch position {
        case .onTop:
            clearAndResignPreviousSearch()
            self.navigationItem.searchController = self.topSearchController
            self.bottomSearchView.isHidden = true
            
        case .atTheBottom:
            clearAndResignPreviousSearch()
            if self.navigationItem.searchController != nil {
                self.navigationItem.searchController = nil
            }
            self.bottomSearchView.isHidden = false
        }
        isStrokePositionPending = true
    }
    

    //MARK: Layout
    private func updateLayoutIfNeeded(width: CGFloat? = nil) {
        if width != nil {
            let newContext = view.layoutContext(width: width)

            currentLayoutContext = newContext
            adjustLayoutFor(context: newContext, width: width)
        } else {
            let newContext = view.layoutContext()
            guard newContext != currentLayoutContext else { return }
            
            currentLayoutContext = newContext
            adjustLayoutFor(context: newContext)
        }
    }

    private func updateStrokesIfNeeded(positionIsPending: Bool = false){
        switch viewModel.searchBarPosition {
        case .onTop:
            guard currentStrokePosition == .bottom && !positionIsPending else {
                topStroke.removeFromSuperlayer()
                bottomStroke.removeFromSuperlayer()

                bottomStroke = UIView().addBottomStroke(vc: self)
                self.tabBarController?.tabBar.layer.addSublayer(bottomStroke)

                currentStrokePosition = .bottom
                return
            }
        case .atTheBottom:
            guard currentStrokePosition == .top && !positionIsPending else {
                topStroke.removeFromSuperlayer()
                bottomStroke.removeFromSuperlayer()
                
                topStroke = UIView().addTopStroke(vc: self)
                self.navigationController?.navigationBar.layer.addSublayer(topStroke)

                currentStrokePosition = .top
                return
            }
        }
    }
    

    //MARK: CollectionLayout
    private func adjustLayoutFor(context: CustomLayoutContext, width: CGFloat? = nil) {
        let isCompact = context == .compact
        let numberOfColumns: CGFloat = isCompact ? 2 : 3
        let width = width ?? self.view.bounds.width
        
        let itemWidth = ((width - (.longInnerSpacer * (numberOfColumns + 1))) / numberOfColumns)
        
        layout.itemSize = CGSize(width: itemWidth, height: .genericButtonHeight)
        
        layout.minimumLineSpacing = .longInnerSpacer
        
        layout.sectionInset = UIEdgeInsets(
            top: .zero, left: .zero,
            bottom: .longOuterSpacer, right: .zero)
        layout.headerReferenceSize = CGSize(
            width: collectionView.bounds.width,
            height: .genericButtonHeight)
        layout.invalidateLayout()
    }
    
    //MARK: Keyboard response
    private func handleKeyboard(_ event: KeyboardListener.Event) {
        UIView.animate(
            withDuration: event.duration,
            delay: 0,
            options: event.curve
        ) {
            switch event.presence {
            case .hidden, .accessoryOnly:
                self.updateCollectionViewForKeyboardState(isVisible: false, intersectingHeight: event.intersection.height)
                self.updateSearchViewForKeyboardState(isVisible: false)
            case .full:
                self.updateCollectionViewForKeyboardState(isVisible: true, intersectingHeight: event.intersection.height)
                self.updateSearchViewForKeyboardState(isVisible: true)
            }
            self.view.layoutIfNeeded()
        }
    }
    private func updateSearchViewForKeyboardState(isVisible: Bool){
        let isMainResponder = {
            switch self.viewModel.searchBarPosition {
            case .onTop: return self.topSearchController.searchBar.isFirstResponder
            case .atTheBottom: return self.bottomSearchView.searchBar.isFirstResponder
            }
        }()
        let followsKeyboard: Bool = isVisible && isMainResponder
        
        
        NSLayoutConstraint.deactivate([followsKeyboard ? searchBarBottomAnchorInactive : searchBarBottomAnchorActive])
        NSLayoutConstraint.activate([followsKeyboard ? searchBarBottomAnchorActive : searchBarBottomAnchorInactive])
    }

    private func updateCollectionViewForKeyboardState(isVisible: Bool,
                                                      intersectingHeight: CGFloat)
    {
        if isVisible {
            collectionView.contentInset = UIEdgeInsets(
                top: .longInnerSpacer, left: .innerSpacer,
                bottom: intersectingHeight + collectionContentInset.bottom, right: .innerSpacer)
        } else {
            collectionView.contentInset = collectionContentInset
        }
        collectionView.scrollIndicatorInsets = collectionView.contentInset
    }
    
    //MARK: Cell calctulations
    private func prepareForExpandedView() {
        if selectedIndexPath != nil { self.dismissPopover() }
        
        if topSearchController.searchBar.isFirstResponder {
            topSearchController.searchBar.resignFirstResponder()
        } else  {
            _ = bottomSearchView.resignFirstResponder()
        }
    }
    private func positionForCell(_ frame: CGRect) -> Position {
        let columns = currentLayoutContext == .compact ? 2 : 3
        let columnWidth = collectionView.bounds.width / CGFloat(columns)

        switch frame.midX {
        case ..<columnWidth:
            return .leading
        case columnWidth..<(columnWidth * 2):
            return columns == 2 ? .trailing : .center
        default:
            return .trailing
        }
    }

    
    private func presentAlert(for alert: SingleEntryEditAlertType) {
        let alert = self.alertCoordinator.makeAlert(alertType: alert)
        self.present(alert, animated: true)
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
    @objc func dismissPopover() {
        popoverController?.dismissPopOver()
    }
}

//MARK: - SearchBar delegate.
//Since i havent found a way to implement custom bottomSearchBar with controller, i should trigger custom search results updater ecery time the customSearchBar calls its delegate.
extension SearchView: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) { }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchBar.text ?? ""
        input.send(.reciveText(text))
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let text = searchBar.text ?? ""
        input.send(.reciveText(text))

    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text ?? ""
        input.send(.reciveText(text))
    }
}

extension SearchView: CustomSearchBarDelegate {
    func customSearchBarDidBeginEditing(_ searchBar: UISearchBar) { }
    
    func customSearchBarDidEndEditing(_ searchBar: UISearchBar) {
        let text = searchBar.text ?? ""
        input.send(.reciveText(text))
    }
    
    func customSearchBar(_ searchBar: UISearchBar, didChangeText text: String) {
        let text = searchBar.text ?? ""
        input.send(.reciveText(text))
    }
    
    func customSearchBarSearchButtonTapped(_ searchBar: UISearchBar) {
        let text = searchBar.text ?? ""
        input.send(.reciveText(text))
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
        
        self.prepareForExpandedView()
        
        let viewToAttach = view.window ?? view ?? collectionView
        let cellFrameInWindow = collectionView.convert(cell.frame, to: viewToAttach)
        let data = viewModel.dataForCellFor(indexPath: indexPath)

        let cellContext = ExpandedCellContext(
            cellPosition: positionForCell(cellFrameInWindow),
            sourceViewFrame: cellFrameInWindow,
            word: data.word,
            description: data.description,
            selectedSeparator: viewModel.textSeparator(),
            placeholder: viewModel.currentPlaceholder())
        
        let popover = SearchCellExpandedView(cellContext: cellContext, delegate: self)
        
        self.selectedIndexPath = indexPath
        self.popoverController = popover
        
        popover.modalPresentationStyle = .overFullScreen
        self.present(popover, animated: false)
        popover.presentPopOver()
    }
}

extension SearchView: SearchCellInteractionDelegate{
    func didRequestDelete(/*cellID: UUID*/) {
        guard let index = selectedIndexPath else { return }
        viewModel.deleteWordAt(indexPath: index)
    }
    
    func didCommitEdit(/*cellID: UUID,*/ updatedText: String) {
        guard let index = selectedIndexPath else { return }
        viewModel.editWord(with: updatedText, index: index)
    }
    
    func didDismissSelection() {
        selectedIndexPath = nil
        popoverController = nil
    }
}




