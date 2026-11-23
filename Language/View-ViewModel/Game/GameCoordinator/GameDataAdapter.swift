//
//  GameGestureHandler.swift
//  Learny
//
//  Created by Star Lord on 15/10/2025.
//
//TODO: Polish

import UIKit

//MARK: - CellDataWrapper
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
//MARK: - HashableWordsEntity
///Game collection view main data entity
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


//MARK: - GameDataAdapter
class GameDataAdapter: NSObject {
    typealias MainCell = UICollectionView.CellRegistration<CollectionViewCell, HashableWordsEntity>
    typealias LastCell = UICollectionView.CellRegistration<CollectionViewLastCell, DataForLastCell>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, CellDataWrapper>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, CellDataWrapper>


    private var mainCell : MainCell!
    private var lastCell : LastCell!

    
    private var isOneSidesMode: Bool
    private var isFlippedGlobally: Bool = false
    
    private(set) var dataSource: UICollectionViewDiffableDataSource<Section, CellDataWrapper>!
    private var seenCards: Set<UUID> = []
        
    private var interactionCoordinator: GameInteractionCoordinator
    
    // MARK: - Reading
    var numberOfCards: Int { cards(in: dataSource.snapshot()).count }
    var lastCellIndexPath: IndexPath? {
        guard let item = dataSource.snapshot().itemIdentifiers.last,
              case .lastCellData = item else { return nil }
        return dataSource.indexPath(for: item)
    }
    
    var checkedCardsCount: Int { seenCards.count }

    //MARK: Inherited
    init(isOneSideMode: Bool, interactioncoordinator: GameInteractionCoordinator) {
        self.isOneSidesMode = isOneSideMode
        self.interactionCoordinator = interactioncoordinator
        
        super.init()
        prepareCells()
    }
    
    //MARK: Data preparation
    private func prepareCells() {
        self.mainCell = MainCell { [weak self] cell, _, data in
            guard let self else { return }
            cell.configure(with: self.transformer(wordEntity: data), oneSideMode: self.isOneSidesMode)
        }
        self.lastCell = LastCell { cell, _, data in
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

    func apply(entries: [CellDataWrapper],
               lastCellData: [CellDataWrapper] = [],
               animating: Bool = true) {
        
        var snapshot = Snapshot()
        snapshot.appendSections([.cards])
        snapshot.appendItems(entries, toSection: .cards)

        if !lastCellData.isEmpty {
            snapshot.appendItems(lastCellData, toSection: .cards)
        }

        // The first card is on screen from the start, so it counts as checked.
        if case .mainCellData(let first)? = entries.first { seenCards.insert(first.identifier) }

        dataSource.apply(snapshot, animatingDifferences: animating)
    }

    //MARK: Assist

    func indexPath(of card: HashableWordsEntity) -> IndexPath? {
        dataSource.indexPath(for: .mainCellData(card))
    }
    
    func flipGlobaly() {
        self.isFlippedGlobally.toggle()
    }

    
    // MARK: - Changing
    /// Timed mode: adds another pass of the deck when the user nears the end.
    func appendCards(_ items: [CellDataWrapper]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(items, toSection: .cards)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    /// Statistics: remembers every card that reached the centre of the screen.
    func markCardAsSeen(at indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath),
              case .mainCellData(let card) = item else { return }
        seenCards.insert(card.identifier)
    }

    /// The word changed: re-creates every copy of its card (the cell is re-dequeued, so the image reloads too).
    func reloadCards(of word: WordsEntity) {
        var snapshot = dataSource.snapshot()
        let items = items(of: word, in: snapshot)
        guard !items.isEmpty else { return }
        snapshot.reloadItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    /// The word was deleted: removes every copy of its card. Returns how many cards are left.
    @discardableResult
    func removeCards(of word: WordsEntity) -> Int {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems(items(of: word, in: snapshot))
        dataSource.apply(snapshot, animatingDifferences: true)
        return cards(in: snapshot).count
    }

    func word(at indexPath: IndexPath) -> HashableWordsEntity? {
        guard
            let item = dataSource?.itemIdentifier(for: indexPath),
            case let .mainCellData(data) = item
        else { return nil }

        return data
    }

    private func items(of word: WordsEntity, in snapshot: Snapshot) -> [CellDataWrapper] {
        snapshot.itemIdentifiers(inSection: .cards).filter {
            guard case .mainCellData(let data) = $0 else { return false }
            return data.wordEntity == word      // object identity, safe even after deletion
        }
    }
    
    private func cards(in snapshot: Snapshot) -> [HashableWordsEntity] {
        snapshot.itemIdentifiers(inSection: .cards).compactMap {
            if case .mainCellData(let data) = $0 { return data }
            return nil
        }
    }
}
