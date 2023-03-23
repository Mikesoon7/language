//
//  TestGameVC.swift
//  Language
//
//  Created by Star Lord on 15/03/2023.
//

import UIKit

class TestGameVC: UIViewController {
    
    var currentDictionary : DictionaryDetails! = nil
    var currentRandomDictionary : [DataForCards]! = nil
    var numberOFCards = Int()
    var random = Bool()
        
    var collectionView : UICollectionView!
    var contentViewSize : CGSize! = nil
    var card : UICollectionView.CellRegistration<TestCell, DataForCards>!
    var lastCard : UICollectionView.CellRegistration<LastCell, DataForLastCard>!
    var dataSource : UICollectionViewDiffableDataSource<Section, AnyHashable>!
    var data : UICollectionViewDiffableDataSource<Section, DataForCards>!
    
//    var viewModel = [ViewModel()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        viewModel = Array(0..<numberOFCards).map({ _ in
        //            ViewModel()
        //        })
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
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = cellPreparation(random: random)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
        ])
//        collectionView.register(CardCell.self, forCellWithReuseIdentifier: "card")
//        collectionView.register(LastCell.self, forCellWithReuseIdentifier: "lastCard")
    }
    func layout() -> UICollectionViewFlowLayout{
        let layout = UICollectionViewFlowLayout()
        contentViewSize = CGSize(width: view.bounds.width / 1.3, height: view.bounds.height / 1.8)
        layout.scrollDirection = .horizontal
        layout.itemSize = contentViewSize
        return layout
    }
    func cellPreparation(random: Bool) -> UICollectionViewDiffableDataSource<Section, AnyHashable>{
        self.card = UICollectionView.CellRegistration<TestCell, DataForCards> { cell, indexPath, data in
            cell.configure(with: data)        }
        self.lastCard = UICollectionView.CellRegistration<LastCell, DataForLastCard> { cell, indexPath, data in
            cell.configure(with: data)
        }
        self.dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: collectionView) { [weak self ] (collectionView,indexPath,item) -> UICollectionViewCell? in
            if let item = item as? DataForCards{
                 let cell = collectionView.dequeueConfiguredReusableCell(using: self!.card, for: indexPath, item: item)
                return cell
            } else if let item = item as? DataForLastCard{
                let cell = collectionView.dequeueConfiguredReusableCell(using: self!.lastCard, for: indexPath, item: item)
                return cell
            }
            return nil
        }
        
        var snaphot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snaphot.appendSections([.cards])
        if random {
            snaphot.appendItems(currentRandomDictionary, toSection: .cards)
        } else {
            snaphot.appendItems(currentDictionary.dictionary!, toSection: .cards)
        }
        snaphot.appendItems([DataForLastCard(score: numberOFCards, image: UIImage(named: "LastCardImage")!)], toSection: .cards)
        dataSource.apply(snaphot, animatingDifferences: true)
        
        return dataSource
    }
/*
    
    func collectionViewLayoutCustomization() -> UICollectionViewLayout{
        let cardSize = NSCollectionLayoutSize(widthDimension: .absolute(view.bounds.width / 1.2), heightDimension: .absolute(view.bounds.height / 1.8))
        let card = NSCollectionLayoutItem(layoutSize: cardSize)

        let cardStack = NSCollectionLayoutGroup.vertical(layoutSize: cardSize, repeatingSubitem: card, count: numberOFCards)
        let section = NSCollectionLayoutSection(group: cardStack)
        section.interGroupSpacing = 50
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
     */
    
}

extension TestGameVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath)?.contentView{

        }

    }
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


extension TestGameVC: UICollectionViewDataSourcePrefetching{
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        for index in indexPaths{
//            guard index.row != indexPaths.count else {return}
//            let viewModel = viewModel[index.row]
//            viewModel.getAnImage(completion: nil)
//                print("Prefetch is working")
//        }
        
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
//        return
//    }
}

