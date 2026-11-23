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
    
    //MARK: Coordinators_Animators
    private var animator: GameAnimator!
    private lazy var gameCoordinator: GameInteractionCoordinator = {
        let coordinator = GameInteractionCoordinator(
            isOneSideMode: isOneSidesMode
        )
        return coordinator
    }()

    
    //MARK: MVVM
    private var viewModel: GameViewModel?
    private var viewModelFactory: ViewModelFactory
    
    private lazy var collectionAdapter: GameDataAdapter = {
        let adapter = GameDataAdapter(isOneSideMode: isOneSidesMode, interactioncoordinator: gameCoordinator)

        return adapter
    }()

    private var cancellable = Set<AnyCancellable>()
    
    
    //MARK: Properties
    //Pre
    private var isFirstLaunch: Bool = false

    private var selectedTime: Int?
    private var isOneSidesMode: Bool
    
    private var currentDictionaryHash: UUID
    

    //Post
    private var didPresentResults = false
    private var isJumpingToResults = false

    
    private var presentedCard: HashableWordsEntity?

    private var centerPoint: CGPoint {
        CGPoint(x: collectionView.contentOffset.x + collectionView.bounds.width / 2,
                y: collectionView.bounds.height / 2)
    }
    
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
        configureLabels()
        configureCollectionView()
        
        configureTimerView()
        checkForTheTutorial()

        viewModel?.viewIsReadyForTheDataDisplay()
    }
    
    
    //Updates log data with spent time.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timerView.kill()
        viewModel?.updateLogWith(time: timerView.timeSpent(), cardsChecked: collectionAdapter.checkedCardsCount)
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
                vc.modalPresentationStyle = .pageSheet
                
                self.present(vc, animated: true)
            }
        }
    }
    
    
    //MARK: - Controller SetUp
    func bind(){
        viewModel?.output
            .sink(receiveValue: { [weak self] output in
                guard let self = self else { return }
                switch output{
                case .error(let error):
                    self.presentError(error, sourceView: self.view)
                case .updateLables:
                    self.configureLabels()
                case .shouldUpdateFont:
                    self.reloadFont()
                case .shouldPop:
                    self.navigationController?.popToRootViewController(animated: true)
                case .shouldUpdateTimer(let state):
                    switch state {
                    case .shouldResume:
                        self.timerView.resumeCountdown()
                    case .shouldStop:
                        self.timerView.stopCountdown()
                    }
                }
            })
            .store(in: &cancellable)
        
        viewModel?.collectionOutput
            .sink(receiveValue: { [weak self] output in
                guard let self = self else { return }
                switch output {
                    
                case .shouldUpdateResult(let results):
                    var entries: [CellDataWrapper] = []
                    var lastCell: [CellDataWrapper] = []
                    results.forEach { result in
                        switch result {
                        case .mainCellData(let data):
                            entries.append(.mainCellData(data))
                        case .lastCellData(let data):
                            lastCell.append(.lastCellData(data))

                        }
                    }
                    collectionAdapter.apply(entries: entries, lastCellData: lastCell)
                }
            })
            .store(in: &cancellable)
        gameCoordinator.events
            .sink(receiveValue: { [weak self] output in
                guard let self = self else { return }
                switch output {
                case .showDetails(let indexPath, let cell):
                    guard let card = collectionAdapter.word(at: indexPath) else { return }
                    presentedCard = card
                    let controller = configureDetailedVCFor(cell: card)
                    animator.transition(from: cell, to: controller, in: self)
                case .cancelInteraction:
                    break
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
        collectionAdapter.configureDataSource(for: collectionView)
        animator = GameAnimator(collectionView: collectionView, delegate: self)
        
        gameCoordinator.collectionView = collectionView
        gameCoordinator.animator = animator
        collectionView.addGestureRecognizer(gameCoordinator.configureGesture())

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

    
    
    
    //MARK: Details Related
    ///Configures DetailedView depending on the devise.
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
    
    //MARK: Result Related
    ///Gathers the nessesary for display data and passes is to LastCell with flip-revieal
    private func presentLearningSessionData(for cell: CollectionViewLastCell){
        guard !didPresentResults else { return }
        isJumpingToResults = false
        didPresentResults = true

        gameCoordinator.stopTrackingGestures()
        collectionView.isUserInteractionEnabled = true
        collectionView.isScrollEnabled = false
        timerView.stopCountdown()
        timerView.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
        
        let timeSpentInSec = timerView.timeSpent()
        let totalCardsScrolled = max(collectionAdapter.checkedCardsCount, 1)

        let timePerCard: Double = Double(timeSpentInSec) / Double(totalCardsScrolled)
        var twoSessionDifference: Double? = nil
        if let previousSessionTimePerCard = UserDefaults.standard.value(forKey: currentDictionaryHash.uuidString ) as? Double {
            twoSessionDifference = (previousSessionTimePerCard - timePerCard) / previousSessionTimePerCard * 100
        }
        UserDefaults.standard.setValue(timePerCard, forKey: currentDictionaryHash.uuidString )

        cell.flipTheCell(numberOfCards: totalCardsScrolled,
                         timeSpent: String.timeString(from: timeSpentInSec),
                         amount: twoSessionDifference)
    }
    
    /// Finish in the timer popup: jump to the results cell and show the results.
    private func scrollToResults() {
        guard let lastIndexPath = collectionAdapter.lastCellIndexPath else {
            navigationController?.popToRootViewController(animated: true)
            return
        }

        isJumpingToResults = true
        collectionView.isUserInteractionEnabled = false
        collectionView.scrollToItem(at: lastIndexPath, at: .centeredHorizontally, animated: true)

        // If the view was already in place no animation runs, so no end-of-scroll callback comes.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.presentResultsIfLastCellIsCentered()
        }
    }

    /// Shows the results when the results cell is in the middle of the screen.
    private func presentResultsIfLastCellIsCentered() {
        let center = CGPoint(x: collectionView.contentOffset.x + collectionView.bounds.width / 2,
                             y: collectionView.bounds.height / 2)
        if let indexPath = collectionView.indexPathForItem(at: center),
           let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewLastCell {
            presentLearningSessionData(for: cell)      // protected by didPresentResults: runs once
        }
    }
    
    
    //MARK: Appereance related.
    ///Reload labels in case of the language change.
    private func configureLabels(){
        navigationItem.title = "game.title".localized
    }
    
    ///Reload all the view's which display labels.
    private func reloadFont() {
        collectionView.visibleCells
            .compactMap { $0 as? CollectionViewCell }
            .filter { $0.isFlipped }
            .forEach { animator.flip(cell: $0, frontToBack: false) }
        collectionView.reloadData()
    }
}


//MARK: Actions
extension MainGameVC {
    ///Initializing the popUp view to display information about current session.
    @objc private func showPopover() {
        guard popUpTimeView == nil else {
            self.dismisPopUp()
            return
        }
        
        let popOverView = PopUpTimerView(frame: view.frame,
                                         safeAreaInsets: view.safeAreaInsets,
                                         number: collectionAdapter.checkedCardsCount,
                                         delegate: self)
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
        collectionAdapter.flipGlobaly()
        
        let visibleIndexPaths = collectionView.loadedCellsIndeces().sorted()
        
        for indexPath in visibleIndexPaths {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else { continue }
            
            
            animator.flip(cell: cell, frontToBack: cell.isFlipped, swapTextOnly: true)
            
        }
    }
    
    @objc private func dismisPopUp(){
        self.popUpTimeView?.dismiss {
            self.popUpTimeView?.removeFromSuperview()
            self.popUpTimeView = nil
        }
    }
}

//MARK: - MainGameDelegate
extension MainGameVC: MainGameVCDelegate {
    /// Details closed with no changes.
    func restoreCardCell() {
        presentedCard = nil
        gameCoordinator.restoreCell()
    }

    /// The user confirmed deletion in details.
    func deleteCardCell() {
        guard let card = presentedCard else { gameCoordinator.restoreCell(); return }
        presentedCard = nil

        gameCoordinator.restoreCell { [weak self] in
            guard let self else { return }
            let word = card.wordEntity
            // Core Data first: if it fails the error is shown and the card stays.
            guard self.viewModel?.deleteWord(word: word) == true else { return }
            let cardsLeft = self.collectionAdapter.removeCards(of: word)

            if cardsLeft == 0 {      
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }

    /// The text or the image was edited in details.
    func updateCardCell() {
        guard let card = presentedCard else { gameCoordinator.restoreCell(); return }
        presentedCard = nil

        // If the card was showing its back, flip it to the front first.
        if let index = collectionAdapter.indexPath(of: card),
           let cell = collectionView.cellForItem(at: index) as? CollectionViewCell, cell.isFlipped {
            animator.flip(cell: cell, frontToBack: false)
        }
        gameCoordinator.restoreCell { [weak self] in
            self?.collectionAdapter.reloadCards(of: card.wordEntity)
        }
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
////MARK: - CollectionView Delegate
extension MainGameVC: UIScrollViewDelegate{
    ///Triggers collection view cell scale up if the cell is the last.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        presentResultsIfLastCellIsCentered()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard isJumpingToResults else { return }
        presentResultsIfLastCellIsCentered()
        if !didPresentResults {
            isJumpingToResults = false
            collectionView.isUserInteractionEnabled = true
        }
    }
    
    ///Ensures, that before reuse all cells will have default, non altered appearence.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gameCoordinator.viewDidSceroll()
        
        guard !isJumpingToResults else { return }
        guard let indexPath = collectionView.indexPathForItem(at: centerPoint) else { return }
        collectionAdapter.markCardAsSeen(at: indexPath)

        // Timed mode: top the deck up when the user is 5 cards from the end.
        guard selectedTime != nil, let viewModel else { return }
        if collectionAdapter.numberOfCards - 5 <= indexPath.item {
            collectionAdapter.appendCards(viewModel.dataForDiffableDataSource())
        }
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
        popUpTimeView?.removeFromSuperview()
        popUpTimeView = nil
        scrollToResults()
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
