//
//  MenuView.swift
//  Language
//
//  Created by Star Lord on 07/07/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit
import CoreData
import Combine

protocol MenuCellDelegate: AnyObject{
    func panningBegan(for cell: UICollectionViewCell)

    func panningEnded(active: Bool)

    func deleteButtonDidTap(for cell: UICollectionViewCell)
    
    func editButtonDidTap(for cell: UICollectionViewCell)
    
    func shareButtonDidTap(for cell: UICollectionViewCell)
}


class MenuView: UIViewController {
    private var viewModelFactory: ViewModelFactory
    private var viewModel: MenuViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    private var menuAccessedForCell: IndexPath?
    private var isUpdateNeeded: Bool = false
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.contentInset = .init(top: .longOuterSpacer, left: .outerSpacer, bottom: .outerSpacer, right: .outerSpacer)
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        
        view.register(MenuDictionaryCVCell.self, forCellWithReuseIdentifier: MenuDictionaryCVCell.identifier)
        view.register(MenuAddDictionaryCVCell.self, forCellWithReuseIdentifier: MenuAddDictionaryCVCell.identifier)
        return view
    }()
    
    lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = .innerSpacer
        return layout
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
        setupCollectionView()
        configureLabels()
        print(max(UIScreen.main.bounds.width, UIScreen.main.bounds.height))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isUpdateNeeded {
            self.collectionView.reloadData()
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            collectionView.subviews.forEach { section in
                section.layer.shadowColor = (traitCollection.userInterfaceStyle == .dark
                                             ? shadowColorForDarkIdiom
                                             : shadowColorForLightIdiom)
            }
        }
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            adjustLayoutForSizeClass()
        }
    }
    
    //MARK: - Binding View and ViewModel
    private func bind(){
        viewModel.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output{
                case .needReload:
                    self?.collectionView.reloadData()
                case .needDelete(let item):
                    self?.collectionView.deleteItems(at: [IndexPath(item: item, section: 0)])
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
                case .shouldUpdateFont:
                    self?.configurefont()
                    self?.collectionView.reloadData()
                case .error(let error):
                    self?.presentError(error, sourceView: self?.view)
                }
            }
            .store(in: &cancellables)
    }
    
    //Dictionary restores
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if viewModel.canUndo() {
                undoActionWasDetected()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustLayoutForSizeClass()
    }

    //Ensures that accessed menu will deactivate on transitions.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        guard self.menuAccessedForCell == nil else {
            if let activeCell = collectionView.cellForItem(at: menuAccessedForCell!) as? MenuDictionaryCVCell {
                coordinator.animate(alongsideTransition: { context in
                    activeCell.activate(false)
                    
                }, completion: { [weak self] _ in
                    self?.menuAccessedForCell = nil
                })
            }
            return
        }
    }
    
    
    //MARK: CollectionView setUp
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    
    private func adjustLayoutForSizeClass() {
        let isCompact = traitCollection.horizontalSizeClass == .compact
        let numberOfColumns: CGFloat = isCompact ? 1 : 2
        
        let itemWidth = ((self.view.bounds.width - (.outerSpacer * 2)) / numberOfColumns) - (isCompact ? 0 : 10)
        
        layout.itemSize = CGSize(width: itemWidth, height: .largeButtonHeight)
        layout.minimumLineSpacing = .outerSpacer
        layout.invalidateLayout()
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
    private func configurefont(){
        let rightButton = UIBarButtonItem(
            
            image: UIImage(systemName: "chart.bar")?.withConfiguration(UIImage.SymbolConfiguration(weight: UIFont.selectedFont.fontWeight.symbolWeight())),
            style: .plain,
            target: self,
            action: #selector(statButtonDidTap(sender:)))
        self.navigationItem.setRightBarButton(rightButton, animated: true)
        
    }
    private func undoLastDeletion() {
        viewModel.undoLastDeletion()
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
        let vc = TutorialVCTest()
        
        self.navigationController?.present(vc, animated: true)
    }
        
    //MARK: - System
    //If available, will suggest user to restore deleted entity.
    private func undoActionWasDetected(){
        let alertController = UIAlertController
            .alertWithAction(alertTitle: "menu.undo.title".localized,
                             action1Title: "system.cancel".localized,
                             action1Style: .cancel,
                             sourceView: self.view
            )
        let restoreAction = UIAlertAction(title: "system.restore".localized,
                                          style: .default) { _ in
            self.undoLastDeletion()
        }
        restoreAction.setValue(UIColor.label, forKey: "titleTextColor")
        alertController.addAction(restoreAction)
        self.present(alertController, animated: true)
    }
    
    //MARK: - Actions
    @objc func statButtonDidTap(sender: Any){
        let vm = viewModelFactory.configureStatisticViewModel()
        let vc = StatisticView(viewModel: vm)
        vc.modalPresentationStyle = .formSheet
        guard let navigationController = navigationController as? CustomNavigationController else {
            self.present(vc, animated: true)
            return
        }
        navigationController.present(vc, animated: true)
    }
}
//MARK: - CollectionView Delegate & DataSource
extension MenuView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectTableRowAt(item: indexPath.item)
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfSectionsInTableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let data = viewModel.dataForTableCellAt(item: indexPath.item) else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MenuAddDictionaryCVCell.identifier,
                for: indexPath) as? MenuAddDictionaryCVCell
            cell?.addCenterShadows()
            return cell ?? UICollectionViewCell()
        }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MenuDictionaryCVCell.identifier,
            for: indexPath) as? MenuDictionaryCVCell else {
            return UICollectionViewCell()
        }
        
        cell.configureCellWith(data: data, delegate: self)
        cell.addCenterShadows()
        return cell
    }
}

//MARK: - Delegate for cells action.
extension MenuView: MenuCellDelegate {
    func panningBegan(for cell: UICollectionViewCell){
        let index = collectionView.indexPath(for: cell)
        //Dismiss another swiped cell.
        guard index == menuAccessedForCell || menuAccessedForCell == nil else {
            if let cell = collectionView.cellForItem(at: menuAccessedForCell!) as? MenuDictionaryCVCell{
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
    func deleteButtonDidTap(for cell: UICollectionViewCell) {
        let completion = { [weak self] cell in
            self?.menuAccessedForCell = nil
            guard let index = self?.collectionView.indexPath(for: cell) else { return }
            self?.viewModel.deleteDictionary(at: index)
        }
        
        guard let sourceView = self.view,
              let cellFrame = cell.superview?.convert(cell.frame, to: self.view) else {
            return
        }
        
        let alertController = UIAlertController
            .alertWithAction(
                alertTitle: "menu.deleteDictionary".localized,
                action1Title: "system.cancel".localized,
                action1Style: .cancel,
                sourceView: sourceView,
                sourceRect: cellFrame
            )
        let delete = UIAlertAction(title: "system.delete".localized, style: .destructive) { _ in
            completion(cell)
        }
        alertController.addAction(delete)
        self.present(alertController, animated: true)
    }
    
    func editButtonDidTap(for cell: UICollectionViewCell){
        menuAccessedForCell = nil
        guard let index = collectionView.indexPath(for: cell) else { return }
        viewModel.editDictionary(at: index)
    }
    
    func shareButtonDidTap(for cell: UICollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else { return }
        let text = viewModel.shareCellsInformation(at: index)
        let inviteLink = AppLinks.websiteLink
        let activityVC = UIActivityViewController(activityItems: [inviteLink, text], applicationActivities: nil)
        activityVC.allowsProminentActivity = true
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(activityVC, animated: true, completion: nil)
    }
}
