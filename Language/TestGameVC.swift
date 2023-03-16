//
//  TestGameVC.swift
//  Language
//
//  Created by Star Lord on 15/03/2023.
//

import UIKit

class CardDetails{
    var word : String
    var translation : String?
    
    init(word: String){
        self.word = word
    }
    init(word: String, translation: String){
        self.word = word
        self.translation = translation
    }
}

class TestGameVC: UIViewController {
    
    let actualDictionary : DictionaryDetails! = nil
    let numberOFCards = Int()
    let random = Bool()
    
    var collectionView = UICollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    func prepareDictionary(){
        
    }
//MARK: - CollectionView SetUp
    func collectionViewCustomization(){
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayoutCustomization())
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
            

        ])
        collectionView.register(CardCell.self, forCellWithReuseIdentifier: "card")
    }
    func collectionViewLayoutCustomization() -> UICollectionViewLayout{
        
        
        let layout = UICollectionViewLayout()
        return layout
    }
    
}

extension TestGameVC: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        <#code#>
    }
}
extension TestGameVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOFCards
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CardCell
        switch random{
        case true: cell
        }
        
    }
    
    
}
