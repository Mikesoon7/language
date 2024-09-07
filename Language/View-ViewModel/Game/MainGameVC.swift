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
    private var isLongGestureActive: Bool = false 
    //MARK: Views
    private var collectionView: UICollectionView!
    private var hideTranslation: Bool
    
    //MARK: Inherited and required
    required init(viewModelFactory: ViewModelFactory, dictionary: DictionariesEntity, isRandom: Bool, hideTransaltion: Bool, selectedNumber: Int) {
        self.viewModelFactory = viewModelFactory
        self.viewModel = viewModelFactory.configureGameViewmModel(
            dictionary: dictionary,
            isRandom: isRandom,
            hideTranslation: hideTransaltion,
            selectedNumber: selectedNumber)
        self.hideTranslation = hideTransaltion
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupViews()
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
                    print("attepmpted to update font")
                }
                
            })
            .store(in: &cancellable)
    }
    
    //MARK: Test
    private var backView = UIView()
    private var labelFotBackSide: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .selectedFont.withSize(18)
        label.tintColor = .label
        return label
    }()
    func setupViews() {
            // Configure the appearance of front and back views
        backView.addSubview(labelFotBackSide)
        NSLayoutConstraint.activate([
            labelFotBackSide.centerYAnchor.constraint(equalTo: backView.centerYAnchor),
            labelFotBackSide.centerXAnchor.constraint(equalTo: backView.centerXAnchor)
        ])
        backView.backgroundColor = .label
            backView.layer.cornerRadius = 10
            backView.isHidden = true // Initially hide the back view
        }
//    var isFlipped = false

    
    func animateCellFlip(cell: CollectionViewCell, frontToBack: Bool) {
        guard cell.isAccessable else {
            UIView.animate(withDuration: 1) {
                let shakingAnimation = CAKeyframeAnimation.shakingAnimation()
                cell.layer.add(shakingAnimation, forKey: "animation")
            } completion: { _ in
//                cell.layer.removeAllAnimations()
            }
//            let shakingAnimation = CAKeyframeAnimation.shakingAnimation()
//            cell.layer.add(shakingAnimation, forKey: "rotation")
            return
        }
        let duration = 0.3
        self.collectionView.isUserInteractionEnabled = false
        
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 5000.0
        
        let liftTransform = CATransform3DTranslate(perspective, 0, -50, 0)
        let initialTransfrom = CATransform3DTranslate(perspective, 0, 0, 0)
        
//        let initialClockwiseTransform  = CATransform3DRotate(perspective, 0, 0, 1, 0)
        let halfwayClockwiseTransform  = CATransform3DRotate(perspective, .pi / 2, 0, 1, 0)
        let finalClockwiseTransform    = CATransform3DRotate(perspective, .pi, 0, 1, 0)
        
//        let opositeInitialTransform = CATransform3DRotate(perspective, .pi, 0, 1, 0)
        let opositeHalfwayTransform = CATransform3DRotate(perspective, .pi / 2, 0, 1, 0)
        let opositeFinalTransform   = CATransform3DRotate(perspective, 0, 0, 1, 0)

                
        let animation = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            if frontToBack {
//                cell.cardView.layer.transform = initialClockwiseTransform
//                cell.cardShadowViewTest.layer.transform = opositeInitialTransform
                UIView.animate(withDuration: duration / 2, animations: {
                    cell.cardView.layer.transform = CATransform3DConcat(halfwayClockwiseTransform, liftTransform)
//                    cell.cardShadowViewTest.layer.transform = opositeHalfwayTransform
                    
                }) { _ in
                    UIView.animate(withDuration: duration / 2) {
                        cell.cardView.layer.transform = CATransform3DConcat(finalClockwiseTransform, initialTransfrom)
//                        cell.cardShadowViewTest.layer.transform = opositeFinalTransform
                    }
                }
            } else {
//                cell.cardView.layer.transform = opositeInitialTransform
//                cell.cardShadowViewTest.layer.transform = initialClockwiseTransform
                
                UIView.animate(withDuration: duration / 2, animations: {
                    cell.cardView.layer.transform = CATransform3DConcat(opositeHalfwayTransform, liftTransform)

                    
//                    cell.cardShadowViewTest.layer.transform = halfwayClockwiseTransform
                }) { _ in
                    UIView.animate(withDuration: duration / 2) {
                        cell.cardView.layer.transform = CATransform3DConcat(opositeFinalTransform, initialTransfrom)
                        
//                        cell.cardShadowViewTest.layer.transform = finalClockwiseTransform
                    }
                }
            }

        }
        animation.addCompletion { _ in
            cell.word.alpha = frontToBack ? 0 : 1
            cell.translation.alpha = !self.hideTranslation ? (frontToBack ? 0 : 1) : 0
            cell.translationTestLabel.alpha = frontToBack ? 1 : 0
            self.collectionView.isUserInteractionEnabled = true
        }
        animation.startAnimation()
        cell.isFlipped.toggle()
    }

    
    //MARK: Subviews SetUp
    private func configureCollectionView(){
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
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
            cell.configure(with: data, oneSideMode: !self.hideTranslation)
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
                cell.translation.alpha = hideTranslation ? 0 : 1
                cell.oneSideMode = !hideTranslation
//                cell.isUserInteractionEnabled = false
//                cell.cardView.layer.transform = CATransform3DIdentity
//                cell.translationTestLabel.alpha = 0
//                cell.word.alpha = 1
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
    private func shrinkCellIn(cell: CollectionViewCell, completion: @escaping () -> (Void)){

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
//            var currentTransform = cell.cardView.layer.transform
//            let scaleTransform = CATransform3DScale(currentTransform, 0.95, 0.95, 1)
//            cell.cardView.layer.transform = scaleTransform
            cell.transform = cell.transform.scaledBy(x: 0.95, y: 0.95)
//            cell.cardShadowView.layer.shadowOffset = cell.initialShadowValue
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: completion)
        }
    }
    private func shrinkCellOut(cell: CollectionViewCell){
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
//            var currentTransform = cell.cardView.layer.transform
//            let scaleTransform = CATransform3DScale(currentTransform, 1/0.95, 1/0.95, 1)
//            cell.cardView.layer.transform = scaleTransform
            cell.transform = .identity /*cell.transform.scaledBy(x: 1/0.95, y: 1/0.95)*/
//            cell.cardShadowView.layer.shadowOffset = cell.finalShadowValue
        }
    }
    private func animateCellTransition(from cell: CollectionViewCell, to controller: UIViewController){
//        UIView.animate(withDuration: 0.2) {
//            cell.transform = .identity
//        }
            collectionView.isUserInteractionEnabled = false
        
        func rotationAnimation() -> CABasicAnimation {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
                rotationAnimation.fromValue = 0
                rotationAnimation.toValue = -Double.pi
                rotationAnimation.duration = 0.5 //0.6
                rotationAnimation.isRemovedOnCompletion = false
                rotationAnimation.fillMode = .forwards
            return rotationAnimation
            }
//        if cell.transform != .identity || cell.transform != .identity.translatedBy(x: 0.95, y: 0.95) {
//            print("animating return to the identity")
//            UIView.animate(withDuration: 0.4, delay: 0) {
//                cell.transform = .identity
//            }
//        }
        let rotationAnimation = rotationAnimation()
//        cell.layer.transform.m34 = -1 / 1000

            cell.layer.add(rotationAnimation, forKey: "rotation")
            
            let slide = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut){

                cell.transform = cell.transform.translatedBy(x: 0, y: -50)
                cell.cardShadowViewTest.layer.shadowOpacity = 0
                cell.cardView.subviews.forEach { view in
                    view.alpha = 0
                }
//                fadeTheContent()
//                cell.cardShadowView.layer.shadowOffset = cell.finalShadowValue
//                cell.cardShadowView.layer.shadowOpacity = 0

            }
            
            slide.addCompletion { _ in
            
                let neededScale = UIWindow().screen.bounds.width / cell.bounds.width
                let neededLength = self.view.bounds.height - cell.frame.minY
                let scaleAndSlide = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) { //0.6
                    let scaleTransform = CGAffineTransform(scaleX: neededScale, y: neededScale)
                    let slideTransform = CGAffineTransform.identity.translatedBy(x: 0, y: neededLength )
                    cell.transform = scaleTransform.concatenating(slideTransform)
                }
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
//        gesture.cancelsTouchesInView = true
        gesture.delegate = self
        return gesture
    }
    private func configureLabels(){
        navigationItem.title = "game.title".localized
    }
    private var longGestureOcured = false
    private var longPressCompleted = false
}


//MARK: - Actions
extension MainGameVC {
    @objc func longGestureDidPress(sender: UILongPressGestureRecognizer) {
        guard let cell = sender.view as? CollectionViewCell,
              let selectedIndex = collectionView.indexPath(for: cell) else {
            return
        }
        
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        let point = sender.location(in: cell)
        
        switch sender.state {
        case .began:
            print("touch was discovered")
            impactGenerator.prepare()
            longPressCompleted = false
            longPressCompleted = false
            longGestureOcured = hideTranslation ? false : true
            selectedCell = selectedIndex
            
//            if hideTranslation {
                shrinkCellIn(cell: cell) {
                    if sender.state == .began {
                        impactGenerator.impactOccurred()
                        self.longGestureOcured = true
                        self.longPressCompleted = true
                    } else {
                        self.longGestureOcured = self.hideTranslation ? false : true
                    }
                }
//            }
            
        case .changed:
            print("state has changed")
        case .ended:
            if longGestureOcured && !longPressCompleted {
                impactGenerator.impactOccurred()
            }
//            guard hideTranslation else {
//                let controllerToPresent: UIViewController = configureDetailedVCFor(cellAt: selectedIndex)
//                animateCellTransition(from: cell, to: controllerToPresent)
//                return
//            }
            if cell.bounds.contains(point) {
                if longGestureOcured || hideTranslation != true {
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
extension MainGameVC: MainGameVCDelegate {
    func restoreAnimation() -> UIViewPropertyAnimator{
        guard selectedCell != nil,
              let cell = collectionView.cellForItem(at: selectedCell!) as? CollectionViewCell
        else {
            return UIViewPropertyAnimator()
        }
        
        let dimming = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut){
            cell.transform = .identity
//            cell.cardShadowView.layer.shadowOffset = cell.finalShadowValue
//            cell.cardShadowView.layer.shadowOpacity = cell.shadowOpacity
            cell.cardView.subviews.forEach { view in
                view.alpha = 1
            }
            cell.translationTestLabel.alpha = cell.isFlipped ? 1 : 0
            cell.cardShadowViewTest.layer.shadowOpacity = cell.shadowOpacity
//            self.collectionView.isUserInteractionEnabled = true
        }
        dimming.addCompletion { _ in
            cell.layer.removeAllAnimations()
        }
        return dimming
    }

    func restoreCardCell() {
        let animation = restoreAnimation()
        animation.addCompletion { _ in
            self.collectionView.isUserInteractionEnabled = true
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
        }
        animation.startAnimation()

    }
    func updateCardCell(){
        let animation = restoreAnimation()
        animation.addCompletion { [weak self] _ in
            guard let self = self else { return }
            guard let currentValue = self.dataSource.itemIdentifier(for: self.selectedCell!) as? WordsEntity else {
                let alert = UIAlertController
                    .alertWithAction(
                        alertTitle: "unknownGameError.title".localized,
                        alertMessage: "unknownGameError.message".localized,
                        alertStyle: .alert,
                        action1Title: "system.agreeFormal".localized
                    )
                self.present(alert, animated: true)
                return
            }

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
        collectionView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 1, delay: 0) {
            let targetScale: CGFloat = 1.1
            cell.cardShadowView.layer.shadowRadius *= 3
            cell.cardView.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard selectedCell == nil else {
            let cell = collectionView.cellForItem(at: selectedCell!)
            let longGesture = cell?.gestureRecognizers?.first(where: { $0 is UILongPressGestureRecognizer })
            longGesture?.state = .cancelled
            if let cardCell = cell as? CollectionViewCell  {
                guard !cardCell.isFlipped else {
                    animateCellFlip(cell: cardCell, frontToBack: false)
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
//        if gestureRecognizer is UITapGestureRecognizer || otherGestureRecognizer is UILongPressGestureRecognizer {
//            print ("Seems to be a long gesture")
//            return true
//        }
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
