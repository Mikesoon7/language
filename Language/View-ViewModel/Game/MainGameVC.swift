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
    
    //MARK: Views
    private var collectionView: UICollectionView!
    
    private var longPressGesture = UILongPressGestureRecognizer()
    
    //MARK: Inherited and required
    required init(viewModelFactory: ViewModelFactory, dictionary: DictionariesEntity, isRandom: Bool, selectedNumber: Int){
        self.viewModelFactory = viewModelFactory
        self.viewModel = viewModelFactory.configureGameViewmModel(
            dictionary: dictionary,
            isRandom: isRandom,
            selectedNumber: selectedNumber)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
        prepareCells()
        configureLabels()
        configureCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout = CustomFlowLayout()
    }
    

    func bind(){
        viewModel?.output
            .sink(receiveValue: { [weak self] output in
                switch output{
                case .error(let error):
                    self?.presentError(error)
                case .updateLables:
                    self?.configureLabels()
                }
            })
            .store(in: &cancellable)
    }
    //MARK: - Controller SetUp
    func configureController(){
        longPressGesture = longGestureCustomization()
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
    
    private func configureLabels(){
        navigationItem.title = "gameTitle".localized
    }

    private func longGestureCustomization() -> UILongPressGestureRecognizer {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(viewDidPress(sender: )))
        gesture.minimumPressDuration = 0.01
        gesture.cancelsTouchesInView = true
        gesture.delegate = self
        return gesture
    }
    
    //MARK: - Cell SetUp
    private func prepareCells(){
        self.mainCell = UICollectionView.CellRegistration<CollectionViewCell, WordsEntity> { cell, indexPath, data in
            cell.configure(with: data)
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
        snapshot.appendItems(viewModel.words, toSection: .cards)
        snapshot.appendItems([
            DataForLastCell(score: viewModel.configureCompletionPercent(), delegate: self)
        ], toSection: .cards)
        dataSource.apply(snapshot, animatingDifferences: true)
        
        return dataSource
    }
    
    //MARK: Animations
    private func shrinkCellIn(cell: CollectionViewCell){
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            cell.cardView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            cell.cardShadowView.layer.shadowOffset = cell.initialShadowValue
        }
    }
    private func shrinkCellOut(cell: CollectionViewCell){
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            cell.cardView.transform = .identity
            cell.cardShadowView.layer.shadowOffset = cell.finalShadowValue
        }
    }
    private func animateCellTransition(from cell: CollectionViewCell, to controller: UIViewController){
        collectionView.isUserInteractionEnabled = false
        let rotationAnimation = CABasicAnimation.rotationAnimation()
        
        cell.layer.add(rotationAnimation, forKey: "rotation")
        
        let slide = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut){
            cell.cardView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -50)
            cell.cardView.subviews.forEach { view in
                view.alpha = 0
            }
            cell.cardShadowView.layer.shadowOffset = cell.finalShadowValue
            cell.cardShadowView.layer.shadowOpacity = 0
        }
        
        slide.addCompletion { _ in
            let neededScale = UIWindow().screen.bounds.width / cell.bounds.width
            let neededLength = self.view.bounds.height - cell.frame.minY
            let scaleAndSlide = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) { //0.6
                let scaleTransform = CGAffineTransform(scaleX: neededScale, y: neededScale)
                let slideTransform = CGAffineTransform.identity.translatedBy(x: 0, y: neededLength )
                cell.cardView.transform = scaleTransform.concatenating(slideTransform)
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
}


//MARK: - Actions
extension MainGameVC {
    @objc func viewDidPress(sender: UILongPressGestureRecognizer) {
        guard let cell = sender.view as? CollectionViewCell,
              let selectedIndex = collectionView.indexPath(for: cell) else {
            return
        }
        let point = sender.location(in: cell)
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)

        switch sender.state {
        case .began, .changed:
            impactGenerator.prepare()
            selectedCell = selectedIndex
            shrinkCellIn(cell: cell)
        case .ended:
            if cell.bounds.contains(point) {
                impactGenerator.impactOccurred()
    
                let controllerToPresent: UIViewController = configureDetailedVCFor(cellAt: selectedIndex)
                animateCellTransition(from: cell, to: controllerToPresent)
                
            } else {
                selectedCell = nil
                shrinkCellOut(cell: cell)
            }
        default:
            guard cell.cardView.transform == .identity else {
                UIView.animate(withDuration: 0.2, delay: 0) {
                    cell.cardView.transform = .identity
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
            cell.cardView.transform = .identity
            cell.cardShadowView.layer.shadowOffset = cell.finalShadowValue
            cell.cardShadowView.layer.shadowOpacity = cell.shadowOpacity
            cell.cardView.subviews.forEach { view in
                view.alpha = 1
            }
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

        let itemWidth = collectionView.bounds.width * 0.8
        let itemHeight = collectionView.bounds.height * 0.7
        itemSize = CGSize(width: itemWidth, height: itemHeight)
    
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
