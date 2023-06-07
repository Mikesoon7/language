//
//  TestGameVC.swift
//  Language
//
//  Created by Star Lord on 15/03/2023.
//

import UIKit

protocol MainGameVCDelegate: AnyObject{
    func restoreCardCell()
}

class MainGameVC: UIViewController, MainGameVCDelegate {
    var currentDictionary: DictionariesEntity!
    var currentRandomDictionary: [WordsEntity]!
    var numberOFCards = Int()
    var random = Bool()
    
    var collectionView : UICollectionView!
    var contentViewSize : CGSize! = nil
    
    var dimView = UIView()
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellPreparation()
        collectionViewCustomization()
        controllerCustomization()
        navBarCustomization()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout = CustomFlowLayout()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    //MARK: - Controller SetUp
    func controllerCustomization(){
        view.backgroundColor = .systemBackground
        dimView = UIView(frame: view.frame)
        dimView.backgroundColor = .black
        dimView.alpha = 0.0
        view.addSubview(dimView)
    }
    //MARK: - NavBar SetUp
    func navBarCustomization(){
        navigationItem.title = "gameTitle".localized
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    func tabBarCastomization(){
        tabBarController?.tabBar.isHidden = true
    }
    //MARK: - CollectionView SetUp
    func collectionViewCustomization(){
        
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
        
        collectionView.dataSource = dataSourceCustomization(random: random)

    }
    func longGestureCustomization() -> UILongPressGestureRecognizer {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(viewDidPress(sender: )))
        gesture.minimumPressDuration = 0
        return gesture
    }
    
    //MARK: - Cell SetUp
    func cellPreparation(){
        self.mainCell = UICollectionView.CellRegistration<CollectionViewCell, WordsEntity> { cell, indexPath, data in
            cell.configure(with: data)
        }
        self.lastCell = UICollectionView.CellRegistration<CollectionViewLastCell, DataForLastCell> { cell, indexPath, data in
            cell.configure(with: data)
        }
    }
    
    //MARK: - DataSource SetUp
    func dataSourceCustomization(random: Bool) -> DataSource{
        self.dataSource = DataSource(collectionView: collectionView) { [ weak self ] (collectionView,indexPath,item) -> UICollectionViewCell? in
            if let item = item as? WordsEntity{
                let cell = collectionView.dequeueConfiguredReusableCell(using: self!.mainCell,
                                                                        for: indexPath,
                                                                        item: item)
                cell.addGestureRecognizer(self!.longGestureCustomization())
                return cell
            } else if let item = item as? DataForLastCell{
                let cell = collectionView.dequeueConfiguredReusableCell(using: self!.lastCell,
                                                                        for: indexPath,
                                                                        item: item)
                return cell
            }
            return nil
        }
        var snapshot = Snapshot()
        snapshot.appendSections([.cards])
        if random {
            snapshot.appendItems(currentRandomDictionary, toSection: .cards)
        } else {
            snapshot.appendItems(Array(currentDictionary.words!) as! [WordsEntity], toSection: .cards)
        }
        snapshot.appendItems([
            DataForLastCell(score: (Float(numberOFCards) / Float(currentRandomDictionary.count)) * 100.0, delegate: self)
        ], toSection: .cards)
        dataSource.apply(snapshot, animatingDifferences: true)

        return dataSource
    }
    func confugureSnapShot(){
        var snapshot = Snapshot()
        snapshot.appendSections([.cards])
        if random {
            snapshot.appendItems(currentRandomDictionary, toSection: .cards)
        } else {
            snapshot.appendItems(Array(currentDictionary.words!) as! [WordsEntity], toSection: .cards)
        }
        snapshot.appendItems([
            DataForLastCell(score: (Float(numberOFCards) / Float(currentRandomDictionary.count)) * 100.0, delegate: self)
        ], toSection: .cards)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func restoreCardCell() {
        guard let cell = collectionView.cellForItem(at: selectedCell) as? CollectionViewCell else {
            print("problems with cell")
            return
        }
        let dimming = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut){
            cell.cardView.transform = .identity
            cell.cardShadowView.layer.shadowOffset = cell.finalShadowValue
            cell.cardShadowView.layer.shadowOpacity = cell.shadowOpacity
            cell.cardView.subviews.forEach { view in
                view.alpha = 1
            }
        }
        dimming.startAnimation()
    }
    
    //MARK: - Actions
    
    @objc func viewDidPress(sender: UILongPressGestureRecognizer) {
        guard let cell = sender.view as? CollectionViewCell else { return }
        let point = sender.location(in: cell)
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        selectedCell = collectionView.indexPath(for: cell)

        switch sender.state {
        case .began:
            impactGenerator.prepare()
            let shrinkIn = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut) {
                cell.cardView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                cell.cardShadowView.layer.shadowOffset = cell.initialShadowValue
            }
            shrinkIn.startAnimation()

        case .ended:
            impactGenerator.impactOccurred()
            if cell.bounds.contains(point){
                let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
                rotationAnimation.fromValue = 0
                rotationAnimation.toValue = Double.pi
                rotationAnimation.duration = 0.5 //0.6
                rotationAnimation.isRemovedOnCompletion = false
                rotationAnimation.fillMode = .forwards

                let text: String = {
                    guard let word = cell.word.text else { return " " }
                    guard let definition = cell.translation.text else { return word }
                    return word + "\n" + "\n" + definition
                }()
                
                let controllerToPresent: UIViewController = {
                    let vc = GameDetailsVC()
                    vc.textToPresent = text
                    vc.delegate = self
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
                let shrinkOut = UIViewPropertyAnimator(duration: 0.15, curve: .easeInOut){
                    cell.cardView.transform = .identity
                    cell.cardShadowView.layer.shadowOffset = cell.finalShadowValue
                }
                shrinkOut.startAnimation()
            }
        default: break
        }
    }
}

extension MainGameVC: UICollectionViewDelegateFlowLayout, CustomCellDelegate{
    func finishButtonTap() {
        guard self.navigationController != nil else { return }
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popToRootViewController(animated: true)
    }
//    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
//        let cell = collectionView.cellForItem(at: indexPaths.first!) as? CollectionViewCell
////        cell?.cardShadowView.alpha = 0
//
//        let config = UIContextMenuConfiguration { _ in
//            let edit = UIAction(title: "Edit",
//                                image: UIImage(systemName: "pencil"),
//                                attributes: .disabled, state: .on) { _ in
//                print("edit tapped")
//            }
//            return UIMenu(title: "", options: .displayInline, children: [edit])
//
//        }
//        return config
//    }
}
extension MainGameVC: UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let indexPath = collectionView.indexPathForItem(at: CGPoint(x: centerX, y: collectionView.bounds.height / 2))
        if let indexPath = indexPath, indexPath.row == currentRandomDictionary.count {
            collectionView.isScrollEnabled = false
            collectionView.isUserInteractionEnabled = true
            if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewLastCell{
                view.bringSubviewToFront(collectionView)
                UIView.animate(withDuration: 1, delay: 0) { [weak self] in
                    let targetScale: CGFloat = 1.1
                    self!.dimView.alpha = 0.6
                    let transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
                    cell.cardView.transform = transform
                }
            }
        }
    }
}
extension MainGameVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
}

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





