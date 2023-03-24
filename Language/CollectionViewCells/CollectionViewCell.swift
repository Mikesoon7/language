//
//  TestCell.swift
//  Language
//
//  Created by Star Lord on 21/03/2023.
//

import UIKit

enum Section: CaseIterable{
    case cards
}
class CollectionViewCell: UICollectionViewCell {
    
    var inset = CGFloat(10)
    
    var word: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Georgia-BoldItalic", size: 20)
        label.numberOfLines = 0
        label.textColor = .black
        label.text = "???"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var translation: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Georgia-Italic", size: 18)
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.text = "???"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let cardView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 9
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 5, height: 3)
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = 3.0
        view.layer.shadowPath = CGPath(rect: view.bounds, transform: nil)
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        cardViewCustomiation()
    }
    required init?(coder: NSCoder) {
        fatalError("Faild to present cells")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    func cardViewCustomiation(){
        self.contentView.addSubview(cardView)
        cardView.addSubviews(word, translation)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            cardView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, constant: -inset),
            cardView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, constant: -inset),
            
            word.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            word.centerXAnchor.constraint(equalTo: cardView.centerXAnchor, constant: 20),
            word.widthAnchor.constraint(equalTo: cardView.widthAnchor, constant: -40),
    
            translation.topAnchor.constraint(equalTo: word.bottomAnchor, constant: 20),
            translation.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            translation.widthAnchor.constraint(equalTo: cardView.widthAnchor, constant: -40)

        ])
        
    }

    func configure(with data: DataForCells){
        word.text = data.word
        translation.text = data.translation
    }
}
