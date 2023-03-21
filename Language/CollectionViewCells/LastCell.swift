//
//  LastCell.swift
//  Language
//
//  Created by Star Lord on 16/03/2023.
//

import UIKit

class LastCell: UICollectionViewCell {
    
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
        return view
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

        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            cardView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor, constant: -10),
            cardView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, constant: -10),
            
            
        ])
        
    }

}
