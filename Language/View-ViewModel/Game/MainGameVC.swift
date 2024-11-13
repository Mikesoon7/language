//
//  TestGameVC.swift
//  Language
//
//  Created by Star Lord on 15/03/2023.
//

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
    typealias MainCell = UICollectionView.CellRegistration<CollectionViewCell, WordsEntity>
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
    private var isOneSidesMode: Bool
    
    //MARK: Gesture related
    private var longGestureOcured = false
    private var longPressCompleted = false

    //MARK: Views
    private var collectionView: UICollectionView!
    
    //MARK: Inherited and required
    required init(viewModelFactory: ViewModelFactory, dictionary: DictionariesEntity, isRandom: Bool, hideTransaltion: Bool, selectedNumber: Int) {
        self.viewModelFactory = viewModelFactory
        self.viewModel = viewModelFactory.configureGameViewmModel(
            dictionary: dictionary,
            isRandom: isRandom,
            isTwoSidesModeOn: hideTransaltion,
            selectedNumber: selectedNumber)
        self.isOneSidesMode = hideTransaltion
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout = CustomFlowLayout()
    }
    
    //MARK: - Controller SetUp
    func bind(){
        viewModel?.output
            .sink(receiveValue: { [weak self] output in
                switch output{
                case .error(let error):
                    self?.presentError(error)
                case .updateLables:
                    self?.configureLabels()
                case .shouldUpdateFont:
                    self?.reloadFont()
                }
            })
            .store(in: &cancellable)
    }
    
    ///Flipping cell for 180 degree to reveal the infromation on the back side. Returning 'error' animation in ceses, when there is nothing to reveal.
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
            cell.translationTestLabel.alpha = frontToBack ? 1 : 0
            self.collectionView.isUserInteractionEnabled = true
        }
        animation.startAnimation()
    }

    
    //MARK: Subviews SetUp
    private func configureCollectionView(){
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
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
    
    
    //MARK: - Cell SetUp
    private func prepareCells(){
        self.mainCell = UICollectionView.CellRegistration<CollectionViewCell, WordsEntity> { cell, indexPath, data in
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
            
            if let item = item as? WordsEntity{
                let cell = collectionView.dequeueConfiguredReusableCell(using: self.mainCell,
                                                                        for: indexPath,
                                                                        item: item)
                cell.addGestureRecognizer(self.longGestureCustomization())
                return cell
            } else if let item = item as? DataForLastCell{
                let cell = collectionView.dequeueConfiguredReusableCell(using: self.lastCell,
                                                                        for: indexPath,
                                                                        item: item)
                return cell
            }
            return nil
        }
        
        guard let viewModel = viewModel else { return dataSource }
        
        var snapshot = Snapshot()
        snapshot.appendSections([.cards])
        snapshot.appendItems(viewModel.dataForDiffableDataSource(), toSection: .cards)
        snapshot.appendItems([
            DataForLastCell(score: viewModel.configureCompletionPercent(), delegate: self)
        ], toSection: .cards)
        dataSource.apply(snapshot, animatingDifferences: true)
        
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
            cell.cardShadowViewTest.layer.shadowOpacity = 0
            cell.cardView.subviews.forEach { view in
                view.alpha = 0
            }
        }
        //Scale cell to the view's bounds and sliding it down.
        slide.addCompletion { _ in
            let neededScale: CGFloat
            let neededLength = self.view.bounds.height - cell.frame.minY

            //Preparation for the future support.
            if UIDevice.current.userInterfaceIdiom == .pad {
                if UIDevice.current.orientation.isLandscape {
                    neededScale = UIWindow().screen.bounds.width / cell.bounds.width / 2
                } else {
                    neededScale = UIWindow().screen.bounds.width / cell.bounds.width
                }
            } else {
                neededScale = UIWindow().screen.bounds.width / cell.bounds.width
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
            self.present(controller, animated: false)
        }
        
        slide.startAnimation()
    }



    
    //MARK: Others
    private func configureDetailedVCFor(cellAt: IndexPath) -> UIViewController{
        guard let data = viewModel?.didSelectCellAt(indexPath: cellAt) else { return UIViewController() }
        let vm = viewModelFactory.configureGameDetailsViewModel(dictionary: data.dictionary, word: data.word, delegate: self)
        let vc = GameDetailsVC(viewModel: vm)
        vc.modalPresentationStyle = .overFullScreen
        vc.navBarTopInset = view.safeAreaInsets.top
        return vc
    }
    
    private func longGestureCustomization() -> UILongPressGestureRecognizer {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureDidPress(sender: )))
        gesture.minimumPressDuration = 0.01
        gesture.delegate = self
        return gesture
    }
    
    ///Reload labels in case of the language change.
    private func configureLabels(){
        navigationItem.title = "game.title".localized
    }
    ///Reload all the view's which display labels.
    private func reloadFont(){
        guard selectedCell != nil, let cell = collectionView.cellForItem(at: selectedCell!) as? CollectionViewCell else{
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
            return
        }
        
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        let point = sender.location(in: cell)
        
        switch sender.state {
        case .began:
            impactGenerator.prepare()
            longPressCompleted = false
            longGestureOcured = isOneSidesMode
            selectedCell = selectedIndex
            
            shrinkCellIn(cell: cell) {
                if sender.state == .began {
                    impactGenerator.impactOccurred()
                    self.longGestureOcured = true
                    self.longPressCompleted = true
                } else {
                    self.longGestureOcured = self.isOneSidesMode
                }
            }
            
        case .changed:
            return
            
        case .ended:
            if longGestureOcured && !longPressCompleted {
                impactGenerator.impactOccurred()
            }
            if cell.bounds.contains(point) {
                if longGestureOcured || isOneSidesMode {
                    let controllerToPresent: UIViewController = configureDetailedVCFor(cellAt: selectedIndex)
                    animateCellTransition(from: cell, to: controllerToPresent)
                } else {
                    animateCellFlip(cell: cell, frontToBack: !cell.isFlipped)
                    shrinkCellOut(cell: cell)
                }
            } else {
                shrinkCellOut(cell: cell)
                selectedCell = nil
            }
        
        default:
            guard cell.transform == .identity else {
                UIView.animate(withDuration: 0.2) {
                    cell.transform = .identity
                    self.selectedCell = nil
                }
                break
            }
        }
    }
}
//MARK: MainGameVC Delegate
extension MainGameVC: MainGameVCDelegate {
    func restoreAnimation() -> UIViewPropertyAnimator{
        guard selectedCell != nil,
              let cell = collectionView.cellForItem(at: selectedCell!) as? CollectionViewCell
        else {
            return UIViewPropertyAnimator()
        }
        
        let dimming = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut){
            cell.transform = .identity
            cell.cardView.subviews.forEach { view in
                view.alpha = 1
            }
            cell.translationTestLabel.alpha = cell.isFlipped ? 1 : 0
            cell.cardShadowViewTest.layer.shadowOpacity = cell.shadowOpacity
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
            guard let self = self, let item = dataSource.itemIdentifier(for: selectedCell!) else { return }
            var snapshot = self.dataSource.snapshot()
            self.viewModel?.deleteWord(word: item as! WordsEntity)
            snapshot.deleteItems([item])
            
            self.dataSource.apply(snapshot, animatingDifferences: true)
            self.selectedCell = nil
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                if snapshot.numberOfItems == 1 {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })
//            if snapshot.numberOfItems == 1 {
//                self.navigationController?.popToRootViewController(animated: true)
//            }
        }
        animation.startAnimation()

    }
    func updateCardCell(){
        let animation = restoreAnimation()
        
        guard let currentValue = self.dataSource.itemIdentifier(for: self.selectedCell!) as? WordsEntity else {
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
        
        ///Ensures, that if cell was edited, it will flip to it's initial appearence.
        if let cell = collectionView.cellForItem(at:selectedCell!) as? CollectionViewCell, cell.isFlipped {
            animateCellFlip(cell: cell, frontToBack: false)
        }

        animation.addCompletion { [weak self] _ in
            guard let self = self else { return }
                                    
            var snapshot = self.dataSource.snapshot()
            currentValue.word = currentValue.word
            currentValue.meaning = currentValue.meaning
            
            snapshot.reloadItems([currentValue as AnyHashable])
            
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
        
        guard let indexPath = collectionView.indexPathForItem(at: center),
              let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewLastCell
        else {
            return
        }
        collectionView.isScrollEnabled = false

        UIView.animate(withDuration: 1, delay: 0) {
            let targetScale: CGFloat = 1.1
            cell.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
        }
    }
    
    ///Ensures, that before reuse all cells will have default, non altered appearence.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard selectedCell == nil else {
            let cell = collectionView.cellForItem(at: selectedCell!)
            let longGesture = cell?.gestureRecognizers?.first(where: { $0 is UILongPressGestureRecognizer })
            longGesture?.state = .cancelled
            
            if let cardCell = collectionView.cellForItem(at: selectedCell!) as? CollectionViewCell  {
                guard !cardCell.isFlipped else {
                    animateCellFlip(cell: cardCell, frontToBack: !cardCell.isFlipped)
                    return
                }
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

//MARK: - Custom CollectionViewDelegate
class CustomFlowLayout: UICollectionViewFlowLayout {

    let scaleForTransition: CGFloat = 0.8

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }

        let itemHeight = collectionView.bounds.height * 0.7
        let itemWidth = itemHeight * 0.7
        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
    
        scrollDirection = .horizontal

        let horizontalInset = (collectionView.bounds.width - itemWidth) / 2
        let verticalInset = (collectionView.bounds.height - itemHeight) / 2
        sectionInset = UIEdgeInsets(top: verticalInset - 40, left: horizontalInset, bottom: verticalInset + 40, right: horizontalInset)

        minimumLineSpacing = 30
        minimumInteritemSpacing = 10
        collectionView.decelerationRate = .normal
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView, !collectionView.bounds.isEmpty else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        let midX = collectionView.bounds.width / 2
        let proposedContentOffsetCenterX = proposedContentOffset.x + midX

        var targetContentOffset: CGPoint = .zero

        if let layoutAttributesForVisibleItems = layoutAttributesForElements(in: collectionView.bounds) {
            layoutAttributesForVisibleItems.forEach { attributes in
                if attributes.representedElementCategory != .cell {
                    return
                }
                if targetContentOffset == .zero || abs(attributes.center.x - proposedContentOffsetCenterX) < abs(targetContentOffset.x - proposedContentOffsetCenterX) {
                    targetContentOffset = CGPoint(x: attributes.center.x - midX, y: proposedContentOffset.y)
                }
            }
        }
        return targetContentOffset
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView,
              let attributesArray = super.layoutAttributesForElements(in: rect) else {
            return nil
        }
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        var newAttributeArray: [UICollectionViewLayoutAttributes] = []
        
        for attribute in attributesArray {
            guard let newAttribute = attribute.copy() as? UICollectionViewLayoutAttributes else {
                return attributesArray
            }
            
            let distanceToCenter = abs(newAttribute.center.x - centerX)

            let scaleFactor = 1 - (distanceToCenter / collectionView.bounds.width) * (1 - scaleForTransition)

            newAttribute.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            newAttributeArray.append(newAttribute)
        }
        return newAttributeArray
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
         true
    }
}
