//
//  CardCell.swift
//  Language
//
//  Created by Star Lord on 16/03/2023.
//

import UIKit

//class CardCell: UICollectionViewCell {
//    var inset = CGFloat(10)
//    
//    var word: UILabel = {
//        let label = UILabel()
//        label.font = UIFont(name: "Georgia-BoldItalic", size: 20)
//        label.numberOfLines = 0
//        label.textColor = .label
//        label.text = "???"
//        label.textAlignment = .center
//        return label
//    }()
//    var translation: UILabel = {
//        let label = UILabel()
//        label.font = UIFont(name: "Georgia-Italic", size: 18)
//        label.numberOfLines = 0
//        label.textColor = .label
//        label.textAlignment = .center
//        label.text = "???"
//        return label
//    }()
//    
////    let image : UIImageView = {
////        let image = UIImageView()
////        image.clipsToBounds = true
////        image.contentMode = .scaleAspectFill
////        return image
////    }()
//    let cardView : UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.layer.cornerRadius = 9
//        view.layer.borderColor = UIColor.black.cgColor
//        view.layer.borderWidth = 1
//        view.clipsToBounds = true
//        
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize(width: 5, height: 3)
//        view.layer.shadowOpacity = 0.8
//        view.layer.shadowRadius = 3.0
//        view.layer.shadowPath = CGPath(rect: view.bounds, transform: nil)
//        return view
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        cardViewCustomiation()
//    }
//    required init?(coder: NSCoder) {
//        fatalError("Faild to present cells")
//    }
//    override func prepareForReuse() {
//        super.prepareForReuse()
////        image.image = nil
//    }
//    func cardViewCustomiation(){
//        self.contentView.addSubview(cardView)
////        cardView.addSubview(image)
//        cardView.addSubviews(word, translation)
//        
//        
////        image.translatesAutoresizingMaskIntoConstraints = false
//        cardView.translatesAutoresizingMaskIntoConstraints = false
//        word.translatesAutoresizingMaskIntoConstraints = false
//        translation.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            cardView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
//            cardView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
//            cardView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, constant: -inset),
//            cardView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, constant: -inset),
//            
////            image.topAnchor.constraint(equalTo: cardView.topAnchor),
////            image.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
////            image.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
////            image.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
////
//            word.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
//            word.centerXAnchor.constraint(equalTo: cardView.centerXAnchor, constant: 20),
//            word.widthAnchor.constraint(equalTo: cardView.widthAnchor, constant: -40),
//    
//            translation.topAnchor.constraint(equalTo: word.bottomAnchor, constant: 20),
//            translation.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
//            translation.widthAnchor.constraint(equalTo: cardView.widthAnchor, constant: -40)
//
//        ])
//        
//    }
//    func configure(with: DataForCells){
//        self.word.text = with.word
//        self.translation.text = with.translation
//
//    }
////    func configureCard(with model: ViewModel){
////        model.getAnImage { [weak self] image in
////            DispatchQueue.main.async {
////                self?.image.image = image
////            }
////        }
////    }
//    
//}
