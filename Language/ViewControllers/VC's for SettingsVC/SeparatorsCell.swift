//
//  SeparatorsCell.swift
//  Language
//
//  Created by Star Lord on 29/04/2023.
//

import UIKit

class SeparatorsCell: UITableViewCell {
    
    let identifier = "separatorCell"
    
    lazy var view : UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.tintColor = .systemGray4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let addImage : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "plus.circle")
        image.tintColor = .clear
        image.contentMode = .center
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    let selectedImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "checkmark")
        image.tintColor = .clear
        image.contentMode = .center
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cellCustomization()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Could not load from coder")
    }
    override func prepareForReuse() {
            super.prepareForReuse()
            label.text = nil
            addImage.tintColor = .clear
            selectedImage.tintColor = .clear
        }
        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            if traitCollection.userInterfaceStyle == .dark {
                self.view.backgroundColor = .secondarySystemBackground
            } else {
                self.view.backgroundColor = .systemGray6.withAlphaComponent(0.8)
            }
        }
    }
    func cellCustomization(){
        contentView.addSubview(view)
        view.addSubviews(label, addImage, selectedImage)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            addImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            addImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            addImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8),
            addImage.widthAnchor.constraint(equalTo: addImage.heightAnchor),
            
            selectedImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            selectedImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            selectedImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8),
            selectedImage.widthAnchor.constraint(equalTo: addImage.heightAnchor),
        ])
    }
    func didSelect(){
        selectedImage.tintColor = .label
        addImage.tintColor = .clear
    }
}
