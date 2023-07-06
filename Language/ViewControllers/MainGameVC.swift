//
//  TestGameVC.swift
//  Language
//
//  Created by Star Lord on 15/03/2023.
//

import UIKit

protocol MainGameVCDelegate: AnyObject{
    func restoreCardCell()
    func deleteCardCell()
    func updateCardCell()
}

class MainGameVC: UIViewController{
    
    var dictionary: DictionariesEntity!
    var words: [WordsEntity]!
    
    var initialNumber: Int!
    var passedNumber: Int!
    
    var collectionView : UICollectionView!
    var contentViewSize : CGSize! = nil
    
    var dimmerView: UIView!
    var shadowView = UIView()
    
    var mainCell : MainCell!
    var lastCell : LastCell!
    var dataSource : DataSource!
    
    var selectedCell: IndexPath!
    var itemSize: CGSize!
    
    // MARK: - TypeAliases
    typealias MainCell = UICollectionView.CellRegistration<CollectionViewCell, WordsEntity>
    typealias LastCell = UICollectionView.CellRegistration<CollectionViewLastCell, DataForLastCell>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    var longPressGesture: UILongPressGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
        prepareCells()
        configureCollectionView()
        configureNavBar()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout = CustomFlowLayout()
        configureDimmerView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    //MARK: - Controller SetUp
    func configureController(){
        view.backgroundColor = .systemBackground
        
        longPressGesture = longGestureCustomization()
    }
    //MARK: - NavBar SetUp
    func configureNavBar(){
        navigationItem.title = "gameTitle".localized
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    func tabBarCastomization(){
        tabBarController?.tabBar.isHidden = true
    }
    func configureDimmerView(){
        dimmerView = UIView(frame: self.view.bounds)
        dimmerView.backgroundColor = .black
        dimmerView.alpha = 0.0
        view.addSubview(dimmerView)
    }
    //MARK: - CollectionView SetUp
    func configureCollectionView(){
        
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
    func longGestureCustomization() -> UILongPressGestureRecognizer {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(viewDidPress(sender: )))
        gesture.minimumPressDuration = 0.01
        //        gesture.minimumPressDuration = 0.0
        gesture.cancelsTouchesInView = true
        gesture.delegate = self
        return gesture
    }
    
    //MARK: - Cell SetUp
    func prepareCells(){
        self.mainCell = UICollectionView.CellRegistration<CollectionViewCell, WordsEntity> { cell, indexPath, data in
            cell.configure(with: data)
        }
        self.lastCell = UICollectionView.CellRegistration<CollectionViewLastCell, DataForLastCell> { cell, indexPath, data in
            cell.configure(with: data)
        }
    }
    
    //MARK: - DataSource SetUp
    func dataSourceCustomization() -> DataSource{
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
        var snapshot = Snapshot()
        snapshot.appendSections([.cards])
        snapshot.appendItems(words, toSection: .cards)
        snapshot.appendItems([
            DataForLastCell(score: (Float(passedNumber) / Float(initialNumber)) * 100.0, delegate: self)
        ], toSection: .cards)
        dataSource.apply(snapshot, animatingDifferences: true)
        
        return dataSource
    }
}


//MARK: - Actions
extension MainGameVC {
    @objc func viewDidPress(sender: UILongPressGestureRecognizer) {
        guard let cell = sender.view as? CollectionViewCell else { return }
        print(self.words.count)

        let point = sender.location(in: cell)
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)

        let shrinkInAnimation = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) { [weak self] in
            cell.cardView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            cell.cardShadowView.layer.shadowOffset = cell.initialShadowValue
            self?.selectedCell = self?.collectionView.indexPath(for: cell)
        }
        let shrinkOutAnimation = UIViewPropertyAnimator(duration: 0.15, curve: .easeInOut){ [weak self] in
            cell.cardView.transform = .identity
            cell.cardShadowView.layer.shadowOffset = cell.finalShadowValue
            self?.selectedCell = nil
        }
        
        switch sender.state {
        case .began, .changed:
            impactGenerator.prepare()
            shrinkInAnimation.startAnimation()
        case .ended:
            print(sender)
            if cell.bounds.contains(point){
                impactGenerator.impactOccurred()
                collectionView.isUserInteractionEnabled = false
                let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
                rotationAnimation.fromValue = 0
                rotationAnimation.toValue = -Double.pi
                rotationAnimation.duration = 0.5 //0.6
                rotationAnimation.isRemovedOnCompletion = false
                rotationAnimation.fillMode = .forwards
                
                let controllerToPresent: UIViewController = {
                    let vc = GameDetailsVC()
                    vc.dictionary = dictionary
                    vc.words = words
                    vc.pairIndex = selectedCell.row
                    vc.word = words[self.selectedCell.row]
                    vc.delegate = self
                    vc.navBarTopInset = self.view.safeAreaInsets.top
                    vc.modalPresentationStyle = .overFullScreen
                    return vc
                }()
                cell.layer.add(rotationAnimation, forKey: "rotation")
                
                let slide = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut){ // 0.4
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
                    self.present(controllerToPresent, animated: false)
                    
                }
                slide.startAnimation()
            } else {
                shrinkOutAnimation.startAnimation()
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
        guard let cell = collectionView.cellForItem(at: selectedCell) as? CollectionViewCell else {
            print("problems with cell")
            return UIViewPropertyAnimator()
        }
        let dimming = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut){
            cell.cardView.transform = .identity
            cell.cardShadowView.layer.shadowOffset = cell.finalShadowValue
            cell.cardShadowView.layer.shadowOpacity = cell.shadowOpacity
            cell.cardView.subviews.forEach { view in
                view.alpha = 1
            }
        }
        return dimming
    }

    func restoreCardCell() {
        let animation = restoreAnimation()
        animation.addCompletion { _ in
            self.selectedCell = nil
            self.collectionView.isUserInteractionEnabled = true
        }
        animation.startAnimation()
    }
    func deleteCardCell() {
        let animation = restoreAnimation()
        animation.addCompletion { [ weak self ] _ in
            guard let self = self else { return }
            let item = self.words.remove(at: self.selectedCell.row)
            var snapshot = self.dataSource.snapshot()
            snapshot.deleteItems([item])
            self.dataSource.apply(snapshot, animatingDifferences: true)
            if self.words.count == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.navigationController?.popToRootViewController(animated: true)
                })
            }
            self.selectedCell = nil
            self.collectionView.isUserInteractionEnabled = true
        }
        animation.startAnimation()

    }
    func updateCardCell(){
        guard let cell = collectionView.cellForItem(at: selectedCell) as? CollectionViewCell else {
            return
        }
        cell.configure(with: words[self.selectedCell.row])
        let animation = restoreAnimation()
        animation.addCompletion { [weak self] _ in
            guard let self = self else { return }
            guard let currentValue = self.dataSource.itemIdentifier(for: self.selectedCell) as? WordsEntity else {
                let  alert = UIAlertController().alertWithAction(alertTitle: "Something unexpected happend", alertMessage: "We have saved your changes, but they will display only in new game session")
                self.present(alert, animated: true)
                return
            }
            
            var snapshot = self.dataSource.snapshot()
            currentValue.word = currentValue.word
            currentValue.meaning = currentValue.meaning
            
            snapshot.reloadItems([currentValue as AnyHashable])
        
            self.dataSource.apply(snapshot, animatingDifferences: true)
            self.selectedCell = nil
            self.collectionView.isUserInteractionEnabled = true
        }
        animation.startAnimation()
    }

}
//MARK: - CustomCellDelegate
extension MainGameVC: UICollectionViewDelegateFlowLayout, CustomCellDelegate{
    func finishButtonTap() {
        guard self.navigationController != nil else { return }
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popToRootViewController(animated: true)
    }
}
//MARK: - CollectionView Delegate
extension MainGameVC: UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let indexPath = collectionView.indexPathForItem(at: CGPoint(x: centerX, y: collectionView.bounds.height / 2))
        if let indexPath = indexPath, indexPath.row == passedNumber {
            collectionView.isScrollEnabled = false
            collectionView.isUserInteractionEnabled = true
            if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewLastCell{
                view.bringSubviewToFront(collectionView)
                UIView.animate(withDuration: 1, delay: 0) { [weak self] in
                    let targetScale: CGFloat = 1.1
                    self!.dimmerView.alpha = 0.6
                    let transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
                    cell.cardView.transform = transform
                }
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard selectedCell == nil else {
            let cell = collectionView.cellForItem(at: selectedCell)
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





