//
//  Language
//
//  Created by Star Lord on 15/03/2023.
//
//TODO: Polish

import UIKit
import Combine

protocol MainGameVCDelegate: AnyObject {
    func restoreCardCell()
    func deleteCardCell()
    func updateCardCell()
}

struct DataForGameView {
    var initialNumber: Int
    var selectedNumber: Int
    var words: [WordsEntity]
}
struct DataForDetailsView {
    var dictionary: DictionariesEntity
    var word: WordsEntity
}

enum CellDataWrapper: Hashable {
    case mainCellData(HashableWordsEntity)
    case lastCellData(DataForLastCell)
    
    var data: any Hashable  {
        switch self{
        case .mainCellData(let data):
            return data
        case .lastCellData(let data):
            return data
        }
    }
}
///Quick overview: Each contentView's cell has a long press gesture recognizer that supports two types of taps:
/// 1. A short tap to flip the cell, revealing information on its back.
/// 2. A long tap to present a new controller with more detailed information and functionality.
/// Since the tap animation for executing the respective methods needs to begin within the first 0.1 seconds of the tap,
/// I opted to use a single recognizer for both interactions. This is more efficient from a UI perspective, but introduces some complexity.
///
/// Short tap: Adjusts the cell's content visibility using the isHidden property,
/// and applies a 3D transform to the view to create the flip effect.
/// Long tap: Modifies the content visibility by adjusting the alpha property,
/// and uses the cell's transform property to both flip the cell and change its position.
class MainGameVC: UIViewController{
    // MARK: - TypeAliases
    typealias MainCell = UICollectionView.CellRegistration<CollectionViewCell, HashableWordsEntity>
    typealias LastCell = UICollectionView.CellRegistration<CollectionViewLastCell, DataForLastCell>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, CellDataWrapper>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CellDataWrapper>
    
    //MARK: Coordinators
    private var animator: GameAnimator!
//    private var gestureHandler: GameGestureHandler!
    //MARK: Properties.
    private var viewModel: GameViewModel?
    private var viewModelFactory: ViewModelFactory
    
    private var cancellable = Set<AnyCancellable>()
    
    private var mainCell : MainCell!
    private var lastCell : LastCell!
    private var dataSource : DataSource!
    
    private var selectedCell: IndexPath?
    private var tappedToScrollCell: IndexPath?
    
    private var selectedTime: Int?
    private var isOneSidesMode: Bool
    
    private var scrolledCards: Set<AnyHashable> = []
    private var currentDictionaryHash: UUID
    
    private var isFlippedGlobally: Bool = false
    private var isFirstLaunch: Bool = false

    //MARK: Gesture related
    private var longGestureCannHappen = false
    private var longPressCompleted = false

    //MARK: Timer Related
    private lazy var timerView: CountdownTimerLabel = CountdownTimerLabel(initialTimerTime: ( selectedTime ?? 0 ), delegate: self)
    private var popUpTimeView: PopUpTimerView?
    
    //MARK: Views
    private var collectionView: UICollectionView!
    
    //MARK: Inherited and required
    required init(viewModelFactory: ViewModelFactory, dictionary: DictionariesEntity, selectedOrder: DictionariesSettings.CardOrder, isOneSideModeOn: Bool, selectedNumber: Int, selectedTime: Int? = nil, isFirstLaunch: Bool) {
        self.viewModelFactory = viewModelFactory
        self.viewModel = viewModelFactory.configureGameViewmModel(
            dictionary: dictionary,
            selectedOrder: selectedOrder,
            isOneSideMode: isOneSideModeOn,
            selectedNumber: selectedNumber,
            selectedTime: selectedTime)
        self.selectedTime = selectedTime
        self.isOneSidesMode = isOneSideModeOn
        self.currentDictionaryHash = dictionary.id
        self.isFirstLaunch = isFirstLaunch
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        prepareCells()
        configureLabels()
        configureCollectionView()
        
        configureTimerView()
//        setupGestures()
        
        checkForTheTutorial()
        
//        gestureHandler = GameGestureHandler(collectionView: collectionView, animator: animator)
//        gestureHandler.delegate = self

    }
    //Updates log data with spent time.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timerView.kill()
        viewModel?.updateLogWith(time: timerView.timeSpent(), cardsChecked: scrolledCards.count)
    
    }
    
    //Redraws popover and passes current centre cell to layourAgent on devices rotation.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //Insure proper sizing and positioning of pop up view
        if popUpTimeView != nil{
            coordinator.animate { _ in
                self.dismisPopUp()
            } completion: { _ in
                self.showPopover()           
            }
        }
        
        let superview = collectionView.superview?.bounds
        let centerX = collectionView.contentOffset.x + (superview ?? collectionView.bounds).width / 2
        let centerY = (superview ?? collectionView.bounds).height / 2
        
        if let cell = collectionView.indexPathForItem(at: CGPoint(x: centerX, y: centerY)),
        let layout = collectionView.collectionViewLayout as? CustomFlowLayout {
            layout.centeredCellIndexPath = cell
        }
    }
    
    
    private func checkForTheTutorial(){
        if isFirstLaunch{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let vc = GameTutorialVC()
                self.modalPresentationStyle = .pageSheet

                self.present(vc, animated: true)

            }
        }
    }
    
    
    //MARK: - Controller SetUp
    func bind(){
        viewModel?.output
            .sink(receiveValue: { [weak self] output in
                switch output{
                case .error(let error):
                    self?.presentError(error, sourceView: self?.view)
                case .updateLables:
                    self?.configureLabels()
                case .shouldUpdateFont:
                    self?.reloadFont()
                case .shouldPop:
                    self?.navigationController?.popToRootViewController(animated: true)
                case .shouldUpdateTimer(let state):
                    switch state {
                    case .shouldResume:
                        self?.timerView.resumeCountdown()
                    case .shouldStop:
                        self?.timerView.stopCountdown()
                    }
                }
            })
            .store(in: &cancellable)
    }
    

    
    
    //MARK: Subviews SetUp
    private func configureCollectionView(){
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: CustomFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.bounces = false
        collectionView.delegate = self

        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        collectionView.dataSource = dataSourceCustomization()
        animator = GameAnimator(collectionView: collectionView, delegate: self)
    }
    
    private func configureTimerView(){
        let button = UIBarButtonItem(customView: timerView)

        let flipButton = UIBarButtonItem(image: UIImage(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90") ?? UIImage(systemName: "arrow.2.circlepath"), style: .done, target: self, action: #selector(flipCard(sender: )))
        
        navigationItem.setRightBarButtonItems([button, flipButton], animated: true)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showPopover))
        timerView.addGestureRecognizer(tapGesture)

        selectedTime != nil ? timerView.startCountdown() : timerView.startCountingUp()
        
        self.collectionView.showsHorizontalScrollIndicator = false
    }

    
    
    //MARK: - Cell SetUp
    private func prepareCells(){
        self.mainCell = UICollectionView.CellRegistration<CollectionViewCell, HashableWordsEntity> { cell, indexPath, data in
            cell.configure(with: self.transformer(wordEntity: data), oneSideMode: self.isOneSidesMode)
        }
        self.lastCell = UICollectionView.CellRegistration<CollectionViewLastCell, DataForLastCell> { cell, indexPath, data in
            cell.configure(with: data)
        }
    }
    
    func transformer(wordEntity: HashableWordsEntity) -> HashableWordsEntity {
        var transformedEntity = wordEntity
        transformedEntity.globalyFliped = isFlippedGlobally
        return transformedEntity
        
    }
    
    //MARK: - DataSource SetUp
    private func dataSourceCustomization() -> DataSource{
        self.dataSource = DataSource(collectionView: collectionView) { [ weak self ] (collectionView,indexPath,item) -> UICollectionViewCell? in

            guard let self = self else { return UICollectionViewCell() }
            
            
            switch item {
            case .mainCellData(let data):
                let cell = collectionView.dequeueConfiguredReusableCell(using: self.mainCell,
                                                                        for: indexPath,
                                                                        item: data)
                cell.addGestureRecognizer(self.longGestureCustomization())
                return cell
            case .lastCellData(let data):
                let cell = collectionView.dequeueConfiguredReusableCell(using: self.lastCell, for: indexPath, item: data)
                cell.addGestureRecognizer(self.longGestureCustomization())
                return cell
            }
//            if let item = item as? HashableWordsEntity{
//                let cell = collectionView.dequeueConfiguredReusableCell(using: self.mainCell,
//                                                                        for: indexPath,
//                                                                        item: item)
//                cell.addGestureRecognizer(self.longGestureCustomization())
//                return cell
//            } else if let item = item as? DataForLastCell{
//                let cell = collectionView.dequeueConfiguredReusableCell(using: self.lastCell,
//                                                                        for: indexPath,
//                                                                        item: item)
//                cell.addGestureRecognizer(self.longGestureCustomization())
//                return cell
//            }
//            return nil
        }
        
        guard let viewModel = viewModel else { return dataSource }
        
        var snapshot = Snapshot()
        snapshot.appendSections([.cards])
        snapshot.appendItems(viewModel.dataForDiffableDataSource(), toSection: .cards)
        if self.selectedTime != nil {
            snapshot.appendItems(viewModel.dataForDiffableDataSource(), toSection: .cards)
        } else {
            snapshot.appendItems(
                viewModel.dataForTheLastCell(),
                toSection: .cards)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
        let _ = scrolledCards.insert(snapshot.itemIdentifiers.first)
        return dataSource
    }
    

    




    
    //MARK: Others
    private func configureDetailedVCFor(cell: HashableWordsEntity) -> UIViewController{
        guard let data = viewModel?.didSelectCellAt(cell: cell ) else { return UIViewController() }
        let vm = viewModelFactory.configureGameDetailsViewModel(dictionary: data.dictionary, word: data.word, delegate: self)

        var viewController = UIViewController()
        
        if UIDevice.isIPadDevice {
            let vc = GameDetailsIPadVC(viewModel: vm )
            vc.modalPresentationStyle = .pageSheet
            viewController = vc
        } else {
            let vc = GameDetailsVC(viewModel: vm )
            vc.modalPresentationStyle = .overFullScreen
            vc.navBarTopInset = view.safeAreaInsets.top
            viewController = vc
        }
        return viewController
    }
    
    private func longGestureCustomization() -> UILongPressGestureRecognizer {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureDidPress(sender: )))
        gesture.minimumPressDuration = 0.01
        gesture.delegate = self
        return gesture
    }
    
    
    private func centerCellManually(at indexPath: IndexPath) {

        collectionView.isUserInteractionEnabled = false
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.collectionView.isUserInteractionEnabled = true
            self.tappedToScrollCell = nil
            
        })
    }

    private func centerLastCell(at indexPath: IndexPath, cell: CollectionViewLastCell){
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
            self?.presentLearningSessionData(for: cell)
        })
    }
    
    private func presentLearningSessionData(for cell: CollectionViewLastCell){
        collectionView.isUserInteractionEnabled = true
        collectionView.isScrollEnabled = false
        collectionView.visibleCells.forEach { cell in
            if let longGesture = cell.gestureRecognizers?.first(where: { $0 is UILongPressGestureRecognizer }){
                cell.removeGestureRecognizer(longGesture)
            }
        }
        timerView.stopCountdown()
        timerView.isUserInteractionEnabled = false
        let timeSpentInSec = timerView.timeSpent()

        let timePerCard: Double = Double(timeSpentInSec) / Double(scrolledCards.count)
        var twoSessionDifference: Double? = nil
        if let previousSessionTimePerCard = UserDefaults.standard.value(forKey: currentDictionaryHash.uuidString ) as? Double {
            twoSessionDifference = (previousSessionTimePerCard - timePerCard) / previousSessionTimePerCard * 100
        }
        UserDefaults.standard.setValue(timePerCard, forKey: currentDictionaryHash.uuidString )

        cell.flipTheCell(numberOfCards: self.scrolledCards.count,
                         timeSpent: String.timeString(from: timeSpentInSec),
                         amount: twoSessionDifference)
    }
    
    
    //MARK: Appereance related.
    ///Reload labels in case of the language change.
    private func configureLabels(){
        navigationItem.title = "game.title".localized
    }
    
    ///Reload all the view's which display labels.
    private func reloadFont(){
        guard let index = selectedCell, let cell = collectionView.cellForItem(at: index) as? CollectionViewCell else{
            collectionView.reloadData()
            return
        }
        if cell.isFlipped == true {
            animator.flip(cell: cell, frontToBack: false)
        }
        collectionView.reloadData()
    }
    
}


//MARK: - Gesture Related Actions
extension MainGameVC {
    ///Handles two types of gesture. Tap animation begins at the very beginning, while leading to either long or short gesture execution.
    @objc func longGestureDidPress(sender: UILongPressGestureRecognizer) {
        guard let cell = resolveCell(from: sender) as? CollectionViewCell,
              let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let centerIndexPath = collectionView.indexPathForItem(at: centerPoint)
        
        switch sender.state {
        case .began:
            handleGestureBegan(cell: cell, indexPath: indexPath, centerIndexPath: centerIndexPath, sender: sender)
        case .changed:
            break
        case .ended:
            handleGestureEnded(cell: cell, indexPath: indexPath, centerIndexPath: centerIndexPath, sender: sender)
        case .cancelled:
            resetGestureState()
        default:
            restoreCellTransformIfNeeded(cell)
        }
    }
    
    private func resolveCell(from sender: UILongPressGestureRecognizer) -> UICollectionViewCell? {
        if let cell = sender.view as? CollectionViewCell {
            return cell
        }
        if let cell = sender.view as? CollectionViewLastCell,
           let indexPath = collectionView.indexPath(for: cell) {
            tappedToScrollCell = indexPath
            animator.centerLastCell(at: indexPath, cell: cell)
        }
        return nil
    }
    
    private var centerPoint: CGPoint {
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let centerY = collectionView.bounds.height / 2
        return CGPoint(x: centerX, y: centerY)
    }
    
    private func handleGestureBegan(cell: CollectionViewCell, indexPath: IndexPath, centerIndexPath: IndexPath?, sender: UILongPressGestureRecognizer) {
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.prepare()
        longPressCompleted = false
        longGestureCannHappen = isOneSidesMode
        
        if indexPath == centerIndexPath {
            selectedCell = indexPath
            animator.shrinkIn(cell: cell) {
                if sender.state == .began {
                    impactGenerator.impactOccurred()
                    self.longGestureCannHappen = true
                    self.longPressCompleted = true
                }
            }
        } else {
            tappedToScrollCell = indexPath
        }
    }
    
    private func handleGestureEnded(cell: CollectionViewCell, indexPath: IndexPath, centerIndexPath: IndexPath?, sender: UILongPressGestureRecognizer) {
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        let point = sender.location(in: cell)
        
        guard indexPath == centerIndexPath else {
            centerCellManually(at: indexPath)
            return
        }
        
        if cell.bounds.contains(point) {
            if longGestureCannHappen || longPressCompleted {
                impactGenerator.impactOccurred()
                
                if let item = dataSource.itemIdentifier(for: indexPath), let data = item.data as? HashableWordsEntity {
                        let controller = configureDetailedVCFor(cell: data)
                        animator.transition(from: cell, to: controller, in: self)
//                    let controller = configureDetailedVCFor(cell: item)
//                    animator.transition(from: cell, to: controller, in: self)
                }
            } else {
                animator.flip(cell: cell, frontToBack: !cell.isFlipped)
                animator.shrinkOut(cell: cell)
            }
        } else {
            animator.shrinkOut(cell: cell)
            selectedCell = nil
        }
    }
    
    private func resetGestureState() {
        selectedCell = nil
        tappedToScrollCell = nil
    }
    
    private func restoreCellTransformIfNeeded(_ cell: UICollectionViewCell) {
        guard cell.transform != .identity else { return }
        UIView.animate(withDuration: 0.2) {
            cell.transform = .identity
            self.resetGestureState()
        }
    }
    
}
//MARK: Actions
extension MainGameVC {
    //Initializing the popUp view to display information about current session.
    @objc private func showPopover() {
        guard popUpTimeView == nil else {
            self.dismisPopUp()
            return
        }
        
        let popOverView = PopUpTimerView(frame: view.frame, safeAreaInsets: view.safeAreaInsets, number: scrolledCards.count, delegate: self)
        if let window = view.window {
            window.addSubview(popOverView)
            NSLayoutConstraint.activate([
                popOverView.topAnchor.constraint(equalTo: window.topAnchor),
                popOverView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                popOverView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                popOverView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])
        }

        timerView.stopCountdown()
        
        self.popUpTimeView = popOverView
        popUpTimeView?.present()
    }
    
    @objc func flipCard(sender: Any) {
        isFlippedGlobally.toggle()
        
        let visibleIndexPaths = collectionView.loadedCellsIndeces().sorted()
        
        for indexPath in visibleIndexPaths {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else { continue }
            
            
            animator.flip(cell: cell, frontToBack: cell.isFlipped, swapTextOnly: true)
//            if cell.isFlipped {
//                animator.flip(cell: cell, frontToBack: true, swapTextOnly: true)
//            } else {
//                animator.flip(cell: cell, frontToBack: false, swapTextOnly: true)
//
//            }
            
        }
    }
    
    @objc private func dismisPopUp(){
        self.popUpTimeView?.dismiss {
            self.popUpTimeView?.removeFromSuperview()
            self.popUpTimeView = nil
        }
    }
}

//MARK: - DELEGATES
//MARK: MainGameVCDelegate
extension MainGameVC: MainGameVCDelegate {
    func restoreAnimation() -> UIViewPropertyAnimator{
        guard let index = selectedCell,
              let cell = collectionView.cellForItem(at: index) as? CollectionViewCell
        else {
            return UIViewPropertyAnimator()
        }
        
        let dimming = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut){
            cell.transform = .identity
            cell.cardView.subviews.forEach { view in
                view.alpha = 1
            }
            cell.translationBacksideLabel.alpha = cell.isFlipped ? 1 : 0
            cell.cardShadowView.layer.shadowOpacity = cell.shadowOpacity
        }
        dimming.addCompletion { _ in
            cell.layer.removeAllAnimations()
            self.collectionView.isUserInteractionEnabled = true
        }
        return dimming
    }

    func restoreCardCell() {
        let animation = restoreAnimation()
        animation.addCompletion { _ in
            self.selectedCell = nil
        }
        animation.startAnimation()
    }
    
    func deleteCardCell() {
        let animation = restoreAnimation()
        animation.addCompletion { [ weak self ] _ in

            guard let self = self, let index = selectedCell, let item = dataSource.itemIdentifier(for: index) else { return }
            var snapshot = self.dataSource.snapshot()
            guard let hashableInstance = item.data as? HashableWordsEntity else { return }
            
            self.viewModel?.deleteWord(word: hashableInstance.wordEntity)
            snapshot.deleteItems([item])
            
            self.dataSource.apply(snapshot, animatingDifferences: true)
            self.selectedCell = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
                if snapshot.numberOfItems == 1 {
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            })
        }
        animation.startAnimation()

    }
    func updateCardCell(){
        let animation = restoreAnimation()
        
        guard let index = selectedCell, let item = self.dataSource.itemIdentifier(for: index), let data = item.data as? HashableWordsEntity else {
            let alert = UIAlertController
                .alertWithAction(
                    alertTitle: "unknownGameError.title".localized,
                    alertMessage: "unknownGameError.message".localized,
                    alertStyle: .alert,
                    action1Title: "system.agreeFormal".localized
                )
            animation.startAnimation()
            self.present(alert, animated: true)
            return
        }
        let wordEntity = data.wordEntity
        
        ///Ensures, that if cell was edited, it will flip to it's initial appearence.
        if let cell = collectionView.cellForItem(at: index) as? CollectionViewCell, cell.isFlipped {
            animator.flip(cell: cell, frontToBack: false)
        }

        animation.addCompletion { [weak self] _ in
            guard let self = self else { return }
                                    
            var snapshot = self.dataSource.snapshot()
            wordEntity.word = wordEntity.word
            wordEntity.meaning = wordEntity.meaning
            
            snapshot.reloadItems([CellDataWrapper.mainCellData(data)])
            
            self.dataSource.apply(snapshot, animatingDifferences: true)
            self.selectedCell = nil
        }
        
        animation.startAnimation()
    }
}
//MARK: - CustomCellDelegate
extension MainGameVC: UICollectionViewDelegateFlowLayout, CustomCellDelegate{
    func finishButtonTap() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? CollectionViewCell {
            cell.loadImageLazily()
        }
    }

}
//MARK: - CollectionView Delegate
extension MainGameVC: UIScrollViewDelegate{
    ///Triggers collection view cell scale up if the cell is the last.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let centerY = collectionView.bounds.height / 2
        let center = CGPoint(x: centerX, y: centerY)
        
        if let indexPath = collectionView.indexPathForItem(at: center),
           let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewLastCell {
            self.presentLearningSessionData(for: cell)
        }
    }
    
    
    ///Ensures, that before reuse all cells will have default, non altered appearence.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard tappedToScrollCell == nil else {
            let cell = collectionView.cellForItem(at: tappedToScrollCell!)
            let longGesture = cell?.gestureRecognizers?.first(where: { $0 is UILongPressGestureRecognizer })
            longGesture?.state = .cancelled
            
            
            if let selectedCell = selectedCell, let cardCell = collectionView.cellForItem(at: selectedCell) as? CollectionViewCell  {
                guard !cardCell.isFlipped else {
                    animator.flip(cell: cardCell, frontToBack: !cardCell.isFlipped)
                    return
                }
            }
            tappedToScrollCell = nil
            return
        }
        
        guard selectedCell == nil else {
            if let cardCell = collectionView.cellForItem(at: selectedCell!) as? CollectionViewCell  {
                
                let longGesture = cardCell.gestureRecognizers?.first(where: { $0 is UILongPressGestureRecognizer })
                longGesture?.state = .cancelled
                
                animator.shrinkOut(cell: cardCell)
                
                guard !cardCell.isFlipped else {
                    animator.flip(cell: cardCell, frontToBack: !cardCell.isFlipped)
                    return
                }
            }
            selectedCell = nil
            return
        }
        

        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let centerY = collectionView.bounds.height / 2
        let center = CGPoint(x: centerX, y: centerY)
        
        if let index = collectionView.indexPathForItem(at: center){
            guard let item = dataSource.itemIdentifier(for: index), let _ = item.data as? HashableWordsEntity else { return }
            let _ = self.scrolledCards.insert(dataSource.itemIdentifier(for: index))
        }
            
        
        guard selectedTime == nil else {
            guard let indexPath = collectionView.indexPathForItem(at: center),
                  let viewModel = viewModel else { return }
            var snapshot = dataSource.snapshot()
            let items = snapshot.itemIdentifiers(inSection: .cards)
        
            if items.count - 5 <= indexPath.item {
                    snapshot.appendItems(viewModel.dataForDiffableDataSource(), toSection: .cards)
                    dataSource.apply(snapshot, animatingDifferences: false)
            }
            return
        }
    }
    
}


//MARK: - Gestures delegate
extension MainGameVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == self.collectionView.panGestureRecognizer,
           self.collectionView.isDragging || self.collectionView.isDecelerating {
            return false
        }
        return true
    }
    
}


//MARK: CountdownTimerDelegate
extension MainGameVC: CountdownTimerDelegate {
    func timerDidFire() {
        self.showPopover()
    }
}
//MARK: PopUpTimerViewDelegate
extension MainGameVC: PopUpTimerViewDelegate {
    func continueButtonDidTap() {
        if !timerView.isCountingDown {
            self.timerView.startCountingUp()
        }
        self.timerView.resumeCountdown()
        self.dismisPopUp()
    }
    
    func finishButtonDidTap() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {  [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        })
    }
    
    func viewDidDismiss() {
        popUpTimeView?.removeFromSuperview()
        popUpTimeView = nil
        self.timerView.resumeCountdown()
    }
}
extension MainGameVC: GameAnimatorDelegate {
    func requiresDetailsSession(for cell: CollectionViewLastCell) {
        self.presentLearningSessionData(for: cell)
    }
}

//extension MainGameVC: GameGestureHandlerDelegate {
//    func gestureHandler(_ handler: GameGestureHandler, didShortTap cell: UICollectionViewCell) {
//        animator.flip(cell: cell, toBack: true)
//    }
//
//    func gestureHandler(_ handler: GameGestureHandler, didLongPress cell: UICollectionViewCell) {
//        guard let indexPath = collectionView.indexPath(for: cell) else { return }
//        let item = viewModel.item(at: indexPath)
//        
//        coordinator.presentDetails(for: item)
//    }
//}

