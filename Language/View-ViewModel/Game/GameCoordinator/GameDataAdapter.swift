//
//  GameGestureHandler.swift
//  Learny
//
//  Created by Star Lord on 15/10/2025.
//
//TODO: Polish

import UIKit

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

struct HashableWordsEntity: Hashable{
    var identifier = UUID()
    var wordEntity: WordsEntity
    
    var image: UIImage?
    var globalyFliped = false
    
    init(wordEntity: WordsEntity) {
        self.wordEntity = wordEntity
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: HashableWordsEntity, rhs: HashableWordsEntity) -> Bool{
        lhs.identifier == rhs.identifier
    }
}


class GameDataAdapter: NSObject {
    typealias MainCell = UICollectionView.CellRegistration<CollectionViewCell, HashableWordsEntity>
    typealias LastCell = UICollectionView.CellRegistration<CollectionViewLastCell, DataForLastCell>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, CellDataWrapper>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CellDataWrapper>


    
//    weak var eventHandler: CollectionViewCallBack?
//    weak var actionDelegate: SingleModeCellActionDelegate?
    
    private var mainCell : MainCell!
    private var lastCell : LastCell!

    
    private var isOneSidesMode: Bool
    private var isFlippedGlobally: Bool = false


    
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, CellDataWrapper>!
    private var scrolledCards: Set<AnyHashable> = []
    
        
    private var interactionCoordinator: GameInteractionCoordinator
    
    init(isOneSideMode: Bool, interactioncoordinator: GameInteractionCoordinator) {
        self.isOneSidesMode = isOneSideMode
        self.interactionCoordinator = interactioncoordinator
        
        super.init()
        prepareCells()
    }
    
    
    func flipGlobaly() {
        self.isFlippedGlobally.toggle()
    }
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

    func configureDataSource(for collectionView: UICollectionView) {
        dataSource = UICollectionViewDiffableDataSource<Section, CellDataWrapper>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in

            guard let self = self else { return nil }
            
            switch item {
            case .mainCellData(let data):
                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: self.mainCell,
                    for: indexPath,
                    item: data
                )
//                cell.addGestureRecognizer(interactionCoordinator.configureGesture())
//                cell.addGestureRecognizer(self.longGestureCustomization())
                return cell
                
            case .lastCellData(let data):
                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: self.lastCell,
                    for: indexPath,
                    item: data
                )
                return cell
            }
        }
        
    }
    func apply(
        entries: [CellDataWrapper],
        lastCellData: [CellDataWrapper]?,
        animating: Bool = true
    ) {
        
        var snapshot = Snapshot()
        
        snapshot.appendSections([.cards])
        snapshot.appendItems(entries, toSection: .cards)
        
        if let resultData = lastCellData {
            snapshot.appendSections([.results])
            snapshot.appendItems(resultData, toSection: .results)
        } else {
            snapshot.appendItems(entries, toSection: .cards)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }


    func word(at indexPath: IndexPath) -> HashableWordsEntity? {
        guard
            let item = dataSource?.itemIdentifier(for: indexPath),
            case let .mainCellData(data) = item
        else { return nil }

        return data
    }

}
