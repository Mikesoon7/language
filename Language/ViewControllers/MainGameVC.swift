//
//  TestGameVC.swift
//  Language
//
//  Created by Star Lord on 15/03/2023.
//

import UIKit

class MainGameVC: UIViewController {
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
    
    // MARK: - TypeAliases
    typealias MainCell = UICollectionView.CellRegistration<CollectionViewCell, WordsEntity>
    typealias LastCell = UICollectionView.CellRegistration<CollectionViewLastCell, DataForLastCell>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellPreparation()
        navBarCustomization()
        collectionViewCustomization()
        viewCustomization()
        tabBarCastomization()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    func viewCustomization(){
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
    }
    func tabBarCastomization(){
        self.tabBarController?.tabBar.isHidden = true
    }
    //MARK: - CollectionView SetUp
    func collectionViewCustomization(){
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: CustomFlowLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = dataSourceCustomization(random: random)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        self.dataSource = DataSource(collectionView: collectionView) { [weak self ] (collectionView,indexPath,item) -> UICollectionViewCell? in
            if let item = item as? WordsEntity{
                let cell = collectionView.dequeueConfiguredReusableCell(using: self!.mainCell,
                                                                        for: indexPath,
                                                                        item: item)
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
            DataForLastCell(score: (Float(numberOFCards) / Float(currentRandomDictionary.count)) * 100.0, delegate: self)], toSection: .cards)
        dataSource.apply(snapshot, animatingDifferences: true)
        
        return dataSource
    }
}

extension MainGameVC: UICollectionViewDelegateFlowLayout, CustomCellDelegate{
    func finishButtonTap() {
        guard self.navigationController != nil else { return }
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
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


class CustomFlowLayout: UICollectionViewFlowLayout {
    
    let scaleForTransition: CGFloat = 0.8
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        let itemWidth = collectionView.bounds.width * 0.8
        let itemHeight = collectionView.bounds.height * 0.6
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
        
        for attributes in attributesArray {
            let distanceToCenter = abs(attributes.center.x - centerX)

            let scaleFactor = 1 - (distanceToCenter / collectionView.bounds.width) * (1 - scaleForTransition)

            attributes.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)

        }
        return attributesArray
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
        
    }
}
