//
//  Language
//
//  Created by Star Lord on 15/03/2023.
//
//  REFACTORING STATE: CHECKED

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
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
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
    
    //MARK: Gesture related
    private var longGestureCannHappen = false
    private var longPressCompleted = false

    //MARK: Timer Related
    private lazy var timerView: CountdownTimerLabel = CountdownTimerLabel(initialTimerTime: ( selectedTime ?? 0 ), delegate: self)
    private var popUpTimeView: PopUpTimerView?
    
    //MARK: Views
    private var collectionView: UICollectionView!
    
    //MARK: Inherited and required
    required init(viewModelFactory: ViewModelFactory, dictionary: DictionariesEntity, selectedOrder: DictionariesSettings.CardOrder, hideTransaltion: Bool, selectedNumber: Int, selectedTime: Int? = nil) {
        self.viewModelFactory = viewModelFactory
        self.viewModel = viewModelFactory.configureGameViewmModel(
            dictionary: dictionary,
            selectedOrder: selectedOrder,
            isTwoSidesModeOn: hideTransaltion,
            selectedNumber: selectedNumber,
            selectedTime: selectedTime)
        self.selectedTime = selectedTime
        self.isOneSidesMode = hideTransaltion
        self.currentDictionaryHash = dictionary.id
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
    }
    
    private func configureTimerView(){
        let button = UIBarButtonItem(customView: timerView)
        navigationItem.setRightBarButton(button, animated: true)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showPopover))
        timerView.addGestureRecognizer(tapGesture)

        selectedTime != nil ? timerView.startCountdown() : timerView.startCountingUp()
        
        self.collectionView.showsHorizontalScrollIndicator = false
    }

    
    
    //MARK: - Cell SetUp
    private func prepareCells(){
        self.mainCell = UICollectionView.CellRegistration<CollectionViewCell, HashableWordsEntity> { cell, indexPath, data in
            cell.configure(with: data, oneSideMode: self.isOneSidesMode)
        }
        self.lastCell = UICollectionView.CellRegistration<CollectionViewLastCell, DataForLastCell> { cell, indexPath, data in
            cell.configure(with: data)
        }
    }
    
    //MARK: - DataSource SetUp
    private func dataSourceCustomization() -> DataSource{
        self.dataSource = DataSource(collectionView: collectionView) { [ weak self ] (collectionView,indexPath,item) -> UICollectionViewCell? in

            guard let self = self else { return UICollectionViewCell() }
            
            if let item = item as? HashableWordsEntity{
                let cell = collectionView.dequeueConfiguredReusableCell(using: self.mainCell,
                                                                        for: indexPath,
                                                                        item: item)
                cell.addGestureRecognizer(self.longGestureCustomization())
                return cell
            } else if let item = item as? DataForLastCell{
                let cell = collectionView.dequeueConfiguredReusableCell(using: self.lastCell,
                                                                        for: indexPath,
                                                                        item: item)
                cell.addGestureRecognizer(self.longGestureCustomization())
                return cell
            }
            return nil
        }
        
        guard let viewModel = viewModel else { return dataSource }
        
        var snapshot = Snapshot()
        snapshot.appendSections([.cards])
        snapshot.appendItems(viewModel.dataForDiffableDataSource(), toSection: .cards)
        if self.selectedTime != nil {
            snapshot.appendItems(viewModel.dataForDiffableDataSource(), toSection: .cards)
        } else {
            snapshot.appendItems([
                DataForLastCell(score: viewModel.configureCompletionPercent(), delegate: self)
            ], toSection: .cards)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
        let _ = scrolledCards.insert(snapshot.itemIdentifiers.first)
        return dataSource
    }
    
    //MARK: Animations
    ///Animationg cell on-tap shrink.
    private func shrinkCellIn(cell: CollectionViewCell, completion: @escaping () -> (Void)){
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            cell.transform = cell.transform.scaledBy(x: 0.95, y: 0.95)
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: completion)
        }
    }
    ///Applying deselect animation for a cell.
    private func shrinkCellOut(cell: CollectionViewCell){
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            cell.transform = .identity
        }
    }
    
    //Flipping cell for 180 degree to reveal the infromation on the back side. Returning 'error' animation in ceses, when there is nothing to reveal.
    ///1. Adjusting Transform3D property of cell's contnent view layer.
    ///2. Changing text label visibility.
    func animateCellFlip(cell: CollectionViewCell, frontToBack: Bool) {
        guard cell.isAccessable else {
            UIView.animate(withDuration: 1) {
                let shakingAnimation = CAKeyframeAnimation.shakingAnimation()
                cell.layer.add(shakingAnimation, forKey: "animation")
            }
            return

        }
        
        self.collectionView.isUserInteractionEnabled = false

        let duration = 0.3
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 5000.0
        
        let liftTransform = CATransform3DTranslate(perspective, 0, -50, 0)
        let initialTransfrom = CATransform3DTranslate(perspective, 0, 0, 0)
        
        let halfwayClockwiseTransform  = CATransform3DRotate(perspective, .pi / 2, 0, 1, 0)
        let finalClockwiseTransform    = CATransform3DRotate(perspective, .pi, 0, 1, 0)
        
        let opositeHalfwayTransform = CATransform3DRotate(perspective, .pi / 2, 0, 1, 0)
        let opositeFinalTransform   = CATransform3DRotate(perspective, 0, 0, 1, 0)

                
        let animation = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            if frontToBack {
                UIView.animate(withDuration: duration / 2, animations: {
                    cell.cardView.layer.transform = CATransform3DConcat(halfwayClockwiseTransform, liftTransform)
                    
                }) { _ in
                    UIView.animate(withDuration: duration / 2) {
                        cell.cardView.layer.transform = CATransform3DConcat(finalClockwiseTransform, initialTransfrom)
                    }
                }
            } else {
                UIView.animate(withDuration: duration / 2, animations: {
                    cell.cardView.layer.transform = CATransform3DConcat(opositeHalfwayTransform, liftTransform)

                    
                }) { _ in
                    UIView.animate(withDuration: duration / 2) {
                        cell.cardView.layer.transform = CATransform3DConcat(opositeFinalTransform, initialTransfrom)
                        
                    }
                }
            }
            cell.isFlipped.toggle()
        }
        animation.addCompletion { _ in
            cell.word.isHidden = frontToBack
            cell.translationBacksideLabel.alpha = frontToBack ? 1 : 0
            self.collectionView.isUserInteractionEnabled = true
        }
        animation.startAnimation()
    }

    ///Create a transition from passed cell to a ViewController by animating cells repositioning and presenting new VC.
    private func animateCellTransition(from cell: CollectionViewCell, to controller: UIViewController){
        //Ensure, that user can't trigger cell flip while aniamtion persist
        collectionView.isUserInteractionEnabled = false
        
        //Applying flip(rotate) animation
        let rotationAnimation = CABasicAnimation.rotationAnimation()
        cell.layer.add(rotationAnimation, forKey: "rotation")
        
        //Raise the cell end hide cell's content
        let slide = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut){
            cell.transform = cell.transform.translatedBy(x: 0, y: -50)
            cell.cardShadowView.layer.shadowOpacity = 0
            cell.cardView.subviews.forEach { view in
                view.alpha = 0
            }
        }
        //Scale cell to the view's bounds and sliding it down.
        slide.addCompletion { _ in
            let neededScale: CGFloat
            let neededLength = self.view.bounds.height

            //Preparation for the future support.
            if UIDevice.current.userInterfaceIdiom == .pad {
                if self.traitCollection.isRegularWidth {
                    neededScale = self.view.bounds.width / cell.bounds.width / 2
                } else {
                    neededScale = self.view.bounds.width / cell.bounds.width
                }
            } else {
                neededScale = self.view.bounds.width / cell.bounds.width
            }
            
            let scaleAndSlide = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) { //0.6
                let scaleTransform = CGAffineTransform(scaleX: neededScale, y: neededScale)
                let slideTransform = CGAffineTransform.identity.translatedBy(x: 0, y: neededLength )
                cell.transform = scaleTransform.concatenating(slideTransform)
            }


            //Adding a background flip.
            scaleAndSlide.addCompletion { _ in
                cell.layer.removeAllAnimations()
                rotationAnimation.fromValue = Double.pi
                rotationAnimation.toValue = 0
                cell.layer.add(rotationAnimation, forKey: "animation")
                
            }
            scaleAndSlide.startAnimation()
            
            self.present(controller, animated: UIDevice.isIPadDevice ? true : false)
        }
        
        slide.startAnimation()
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
            animateCellFlip(cell: cell, frontToBack: false)
        }
        collectionView.reloadData()
    }
    
}


//MARK: - Actions
extension MainGameVC {
    ///Handles two types of gesture. Tap animation begins at the very beginning, while leading to either long or short gesture execution.
    @objc func longGestureDidPress(sender: UILongPressGestureRecognizer) {
        guard let cell = sender.view as? CollectionViewCell,
              let selectedIndex = collectionView.indexPath(for: cell) else {
            if let cell = sender.view as? CollectionViewLastCell, let selectedIndex = collectionView.indexPath(for: cell) {
                tappedToScrollCell = selectedIndex
                centerLastCell(at: selectedIndex, cell: cell)
            }
            return
        }
        
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let centerY = collectionView.bounds.height / 2
        let center = CGPoint(x: centerX, y: centerY)

        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        let point = sender.location(in: cell)
        
        switch sender.state {
        case .began:
            impactGenerator.prepare()
            longPressCompleted = false
            longGestureCannHappen = isOneSidesMode
            
            if collectionView.indexPathForItem(at: center) == selectedIndex {
                selectedCell = selectedIndex
                                
                shrinkCellIn(cell: cell) {
                    if sender.state == .began {
                        impactGenerator.impactOccurred()
                        self.longGestureCannHappen = true
                        self.longPressCompleted = true
                    } else {
                        self.longGestureCannHappen = self.isOneSidesMode
                    }
                }
            } else {
                tappedToScrollCell = selectedIndex
            }
            
        case .changed:
            return
            
        case .ended:
            if collectionView.indexPathForItem(at: center) != selectedIndex {
                centerCellManually(at: selectedIndex)
                return
            }

            if cell.bounds.contains(point) {
                if longGestureCannHappen || longPressCompleted {
                    impactGenerator.impactOccurred()
                    let controllerToPresent: UIViewController = configureDetailedVCFor(cell: dataSource.itemIdentifier(for: selectedIndex) as! HashableWordsEntity)
                    animateCellTransition(from: cell, to: controllerToPresent)
                } else {
                    animateCellFlip(cell: cell, frontToBack: !cell.isFlipped)
                    shrinkCellOut(cell: cell)
                }
            } else {
                shrinkCellOut(cell: cell)
                selectedCell = nil
            }
            
        case .cancelled:
            self.selectedCell = nil
            self.tappedToScrollCell = nil
        default:
            guard cell.transform == .identity else {
                UIView.animate(withDuration: 0.2) {
                    cell.transform = .identity
                    self.selectedCell = nil
                    self.tappedToScrollCell = nil
                }
                break
            }
        }
    }
    
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
            guard let hashableInstance = item as? HashableWordsEntity else { return }
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
        
        guard let index = selectedCell, let hashableInstance = self.dataSource.itemIdentifier(for: index) as? HashableWordsEntity else {
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
        let wordEntity = hashableInstance.wordEntity
        
        ///Ensures, that if cell was edited, it will flip to it's initial appearence.
        if let cell = collectionView.cellForItem(at: index) as? CollectionViewCell, cell.isFlipped {
            animateCellFlip(cell: cell, frontToBack: false)
        }

        animation.addCompletion { [weak self] _ in
            guard let self = self else { return }
                                    
            var snapshot = self.dataSource.snapshot()
            wordEntity.word = wordEntity.word
            wordEntity.meaning = wordEntity.meaning
            
            snapshot.reloadItems([hashableInstance])
            
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
                    animateCellFlip(cell: cardCell, frontToBack: !cardCell.isFlipped)
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
                
                shrinkCellOut(cell: cardCell)
                
                guard !cardCell.isFlipped else {
                    animateCellFlip(cell: cardCell, frontToBack: !cardCell.isFlipped)
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
            guard dataSource.itemIdentifier(for: index) as? HashableWordsEntity != nil else { return }
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
