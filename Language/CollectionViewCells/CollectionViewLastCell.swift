//
//  LastCell.swift
//  Language
//
//  Created by Star Lord on 16/03/2023.
//

import UIKit

class DataForLastCell: Hashable{
    var identifier = UUID()
    var score : Int
    var image : UIImage
    
    init(score: Int, image: UIImage) {
        self.score = score
        self.image = image
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: DataForLastCell, rhs: DataForLastCell) -> Bool{
        lhs.identifier == rhs.identifier
    }
}
class CollectionViewLastCell: UICollectionViewCell {
    
    let cardView : UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 9
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.layer.opacity = 0.7
        view.clipsToBounds = true
        
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 5, height: 3)
        view.layer.shadowOpacity = 0.8
        view.layer.shadowRadius = 3.0
        view.layer.shadowPath = CGPath(rect: view.bounds, transform: nil)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let scoreLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Georgia-BoldItalic", size: 40)
        label.textColor = .label
        label.text = "???"
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        cardViewCustomiation()
    }
    required init?(coder: NSCoder) {
        fatalError("Faild to present cells")
    }
    func cardViewCustomiation(){
        self.contentView.addSubview(cardView)
        cardView.addSubviews(scoreLabel)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            cardView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, constant: -10),
            cardView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, constant: -10),
            
            scoreLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            scoreLabel.heightAnchor.constraint(equalTo: cardView.heightAnchor),
            scoreLabel.widthAnchor.constraint(equalTo: cardView.widthAnchor)


        ])
        
    }
    func configure(with data: DataForLastCell){
        scoreLabel.text = "\(data.score)%"
        cardView.image = data.image
    }

}
