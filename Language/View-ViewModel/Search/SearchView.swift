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

enum CustomStrokePosition {
    case top, bottom, undefined
}

class SearchView: UIViewController {
    
    private let viewModelFactory: ViewModelFactory
    private let viewModel: SearchViewModel
    private var cancellable = Set<AnyCancellable>()
    private let input =  PassthroughSubject<SearchViewModel.Input, Never>()
    
    private var keyboardListener: KeyboardListener?
    
    private var popoverView: SearchCellExpandedView?
    private var selectedIndexPath: IndexPath? = nil
    
    private var currentLayoutContext: CustomLayoutContext?
    private var currentStrokePosition: CustomStrokePosition?
    
    //MARK: - Views
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
    private var cancelButtonLeadingAnchor: NSLayoutConstraint =     .init()
    private let searchControllerHeight: CGFloat = 50
    private let collectionContentInset: UIEdgeInsets = .init(
        top: .longInnerSpacer, left: .innerSpacer,
        bottom: .longOuterSpacer, right: .innerSpacer)
    
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
        bindViewhelpers()
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayoutIfNeeded()
        updateStrokesIfNeeded()
        bottomSearchView.configureStrokes()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateLayoutIfNeeded(width: size.width)
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
                case .error(let error):
                    self.navigationController?.presentError(error, sourceView: self.view)
                case .shouldUpdateLabels:
                    self.configureLabels()
                    self.bottomSearchView.configureLabels()
                case .shouldUpdateFonts:
                    self.configureFont()
                case .reflectSearchPositionChange(let position):
                    self.applySearchBarPosition(position)
                case .shouldReloadCell(let cellIndex):
                    self.collectionView.reloadItems(at: [cellIndex])
                }
            }
            .store(in: &cancellable)
    }
    
    func bindViewhelpers() {
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
        
        NSLayoutConstraint.activate([
            bottomSearchView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            bottomSearchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomSearchView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomSearchView.heightAnchor.constraint(equalToConstant: searchControllerHeight),
        ])
    }
    
    //MARK: Refreshing SearchBars.
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
    
//    MARK: State Change
    private func applySearchBarPosition(_ position: AppSearchBarPosition) {
        UIView.animate(withDuration: 0.3) { [weak self]  in
            guard let self = self else {return}
            switch position {
            case .onTop:
                refreshBottomSearchBar()
                bottomSearchView.isHidden = true
                navigationItem.searchController?.isActive = false
                navigationItem.searchController = topSearchController
            case .atTheBottom:
                refreshTopSearchBar()
                bottomSearchView.isHidden = false
                navigationItem.searchController = nil
            }
            view.setNeedsDisplay()
        }
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

    private func updateStrokesIfNeeded(){
        switch viewModel.searchBarPosition {
        case .onTop:
            guard currentStrokePosition == .bottom else {
                topStroke.removeFromSuperlayer()
                bottomStroke.removeFromSuperlayer()

                bottomStroke = UIView().addBottomStroke(vc: self)
                self.tabBarController?.tabBar.layer.addSublayer(bottomStroke)

                currentStrokePosition = .bottom
                return
            }
        case .atTheBottom:
            let navFrame = navigationController?.navigationBar.layer.bounds

            guard currentStrokePosition == .top  && navFrame == topStroke.bounds else {
                topStroke.removeFromSuperlayer()
                bottomStroke.removeFromSuperlayer()
                
                topStroke = UIView().addTopStroke(vc: self)
                self.navigationController?.navigationBar.layer.addSublayer(topStroke)

                currentStrokePosition = .top
                return
            }

        }
    }
    
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
    
    
    private func handleKeyboard(_ event: KeyboardListener.Event) {
        UIView.animate(
            withDuration: event.duration,
            delay: 0,
            options: event.curve
        ) {
            switch event.presence {
            case .hidden, .accessoryOnly:
                self.updateCollectionViewForState(isVisible: false, duration: event.duration, intersectingHeight: event.intersection.height)
            case .full:
                self.updateCollectionViewForState(isVisible: true, duration: event.duration, intersectingHeight: event.intersection.height)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateCollectionViewForState(isVisible: Bool, duration: TimeInterval, intersectingHeight: CGFloat){
        if isVisible {
            collectionView.contentInset = UIEdgeInsets(
                top: .longInnerSpacer, left: .innerSpacer,
                bottom: intersectingHeight + collectionContentInset.bottom, right: .innerSpacer)
        } else {
            collectionView.contentInset = collectionContentInset
        }
        collectionView.scrollIndicatorInsets = collectionView.contentInset
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
        popoverView?.dismissPopOver(closure: self.popOverDidDismiss )
    }
}

//MARK: - SearchBar delegate.
//Since i havent found a way to implement custom bottomSearchBar with controller, i should trigger custom search results updater ecery time the customSearchBar calls its delegate.
extension SearchView: UISearchBarDelegate{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if viewModel.searchBarPosition == .atTheBottom {
            bottomSearchView.animateTransitionTo(isActivated: true, time: 0.3)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let text = searchBar.text ?? ""
        input.send(.reciveText(text))
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if viewModel.searchBarPosition == .atTheBottom {
            bottomSearchView.animateTransitionTo(isActivated: false, time: 0.3)
        }
        
        let text = searchBar.text ?? ""
        input.send(.reciveText(text))

    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let text = searchBar.text ?? ""
        input.send(.reciveText(text))
        
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
        
        if bottomSearchView.searchBar.isFirstResponder {
            bottomSearchView.searchBar.resignFirstResponder()
        } else if topSearchController.searchBar.isFirstResponder {
            topSearchController.searchBar.resignFirstResponder()
        }
        
        let numberOfColumns = currentLayoutContext == .compact ? 2 : 3
        
        let viewToAttach = view.window ?? view ?? collectionView
        
        let cellFrameInWindow = collectionView.convert(cell.frame, to: viewToAttach)
        
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
        self.popoverView = nil
        self.selectedIndexPath = nil
    }
}



