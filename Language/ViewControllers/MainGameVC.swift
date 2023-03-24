//
//  TestGameVC.swift
//  Language
//
//  Created by Star Lord on 15/03/2023.
//

import UIKit

class MainGameVC: UIViewController {
    
    var currentDictionary : DictionaryDetails! = nil
    var currentRandomDictionary : [DataForCells]! = nil
    var numberOFCards = Int()
    var random = Bool()
        
    var collectionView : UICollectionView!
    var contentViewSize : CGSize! = nil
    
    var mainCell : MainCell!
    var lastCell : LastCell!
    var dataSource : DataSource!
    
// MARK: - TypeAliases
    typealias MainCell = UICollectionView.CellRegistration<CollectionViewCell, DataForCells>
    typealias LastCell = UICollectionView.CellRegistration<CollectionViewLastCell, DataForLastCell>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        cellPreparation()
        navBarCustomization()
        collectionViewCustomization()
    }
    //MARK: - NavBar SetUp
    func navBarCustomization(){
        // Title adjustment.
        navigationItem.title = "Game"
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }
//MARK: - CollectionView SetUp
    func collectionViewCustomization(){
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = dataSourceCustomization(random: random)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dragInteractionEnabled = true
        collectionView.isUserInteractionEnabled = true
        collectionView.delegate = self
        
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
        ])
        contentViewSize = CGSize(width: view.bounds.width / 1.3, height: view.bounds.height / 1.8)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: (view.bounds.width - contentViewSize.width) / 2, bottom: 0, right:  (view.bounds.width - contentViewSize.width) / 2)
    }
    func layout() -> UICollectionViewFlowLayout{
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = contentViewSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: (view.bounds.width - contentViewSize.width) / 2, bottom: 0, right:  (view.bounds.width - contentViewSize.width) / 2)
        layout.minimumLineSpacing = 30
        layout.scrollDirection = .horizontal
        
        return layout
    }
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(0.6))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8),
                                               heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 0 , bottom: 30, trailing: 0)
        section.contentInsetsReference = .layoutMargins
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        let x = UICollectionViewCompositionalLayoutConfiguration()
        x.interSectionSpacing = 60
        x.contentInsetsReference = .safeArea
        x.scrollDirection = .vertical
        layout.configuration = x
        return layout
    }
    func layout() -> UICollectionViewLayout{
        var layout = UICollectionViewLayout().
        
        return UICollectionViewLayout()
    }
    func cellPreparation(){
        self.mainCell = UICollectionView.CellRegistration<CollectionViewCell, DataForCells> { cell, indexPath, data in
            cell.configure(with: data)
        }
        self.lastCell = UICollectionView.CellRegistration<CollectionViewLastCell, DataForLastCell> { cell, indexPath, data in
            cell.configure(with: data)
        }
    }
//MARK: - DataSource SetUp
    func dataSourceCustomization(random: Bool) -> DataSource{
        self.dataSource = DataSource(collectionView: collectionView) { [weak self ] (collectionView,indexPath,item) -> UICollectionViewCell? in
            if let item = item as? DataForCells{
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
        
        var snaphot = Snapshot()
        snaphot.appendSections([.cards])
        if random {
            snaphot.appendItems(currentRandomDictionary, toSection: .cards)
        } else {
            snaphot.appendItems(currentDictionary.dictionary!, toSection: .cards)
        }
        snaphot.appendItems([DataForLastCell(score: numberOFCards,
                                             image: UIImage(named: "LastCardImage")!)], toSection: .cards)
        dataSource.apply(snaphot, animatingDifferences: true)
        
        return dataSource
    }
    
}

extension MainGameVC: UICollectionViewDelegateFlowLayout{
    }

/*
extension TestGameVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOFCards + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "card", for: indexPath) as! CardCell
        let lastCell = collectionView.dequeueReusableCell(withReuseIdentifier: "lastCard", for: indexPath) as! LastCell
        guard indexPath.row != numberOFCards else {return lastCell}
        let currentStraightPair = currentDictionary.dictionary![indexPath.row]
        let currentRandomPair = currentRandomDictionary[indexPath.row]
        if random{
            cell.word.text = currentRandomPair.word
//            cell.configureCard(with: viewModel[indexPath.row])
            cell.translation.text = currentRandomPair.translation
        } else {
            cell.word.text = currentStraightPair.word
//            cell.configureCard(with: viewModel[indexPath.row])
            cell.translation.text = currentStraightPair.translation
        }
        return cell
    }
}
 */
class MyCollectionViewLayout: UICollectionViewLayout {
    
    // Определение размеров ячеек в коллекции
    let itemSize = CGSize(width: 100, height: 100)
    
    // Определение отступов между ячейками в коллекции
    let minimumInteritemSpacing: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    
    // Определение количества колонок в коллекции
    let numberOfColumns = 3
    
    // Определение массива, в котором будут храниться атрибуты элементов
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    // Метод, который будет вызываться перед отображением коллекции
    override func prepare() {
        super.prepare()
        
        // Определение ширины содержимого коллекции, учитывая отступы и размер ячеек
        let contentWidth = collectionView!.frame.width - collectionView!.contentInset.left - collectionView!.contentInset.right
        let availableWidth = contentWidth - CGFloat(numberOfColumns - 1) * minimumInteritemSpacing
        let itemWidth = availableWidth / CGFloat(numberOfColumns)
        
        // Определение массива, содержащего количество элементов в каждой секции коллекции
        var itemsInSection = [Int]()
        let numberOfSections = collectionView!.numberOfSections
        for section in 0..<numberOfSections {
            let numberOfItems = collectionView!.numberOfItems(inSection: section)
            itemsInSection.append(numberOfItems)
        }
        
        // Определение позиций элементов в коллекции
        var xOffset = [CGFloat]()
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * (itemWidth + minimumInteritemSpacing))
        }
        
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        for section in 0..<numberOfSections {
            for item in 0..<itemsInSection[section] {
                let indexPath = IndexPath(item: item, section: section)
                
                // Создание атрибутов для каждого элемента в коллекции
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                // Определение размеров и позиции элемента
                let column = item % numberOfColumns
                let xPosition = xOffset[column]
                let yPosition = yOffset[column]
                let height = itemSize.height
                
                attributes.frame = CGRect(x: xPosition, y: yPosition, width: itemWidth, height: height)
                
                layoutAttributes.append(attributes)
                
                // Обновление yOffset и xOffset для следующего элемента
                yOffset[column] += height + minimumLineSpacing
            }
        }
    }
    
    // Метод, который возвращает атрибуты для элементов, находящихся в заданной области
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Поиск всех элементов, которые находятся в заданной области
        for attributes in layoutAttributes {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    // Метод, который возвращает атрибуты для заданного элемента в коллекции
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath.item]
    }
    
    // Метод, который возвращает размер содержимого коллекции
    override var collectionViewContentSize: CGSize {
        let contentWidth = collectionView!.frame.width - collectionView!.contentInset.left - collectionView!.contentInset.right
        let numberOfItems = layoutAttributes.count
        let numberOfRows = Int(ceil(Double(numberOfItems) / Double(numberOfColumns)))
        let contentHeight = CGFloat(numberOfRows) * itemSize.height + CGFloat(numberOfRows - 1) * minimumLineSpacing + collectionView!.contentInset.top + collectionView!.contentInset.bottom
        
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    // Метод, который возвращает true, если layout должен быть обновлен при изменении размеров коллекции
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
