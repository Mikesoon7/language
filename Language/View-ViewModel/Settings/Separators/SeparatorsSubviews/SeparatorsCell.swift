//
//  SeparatorsCell.swift
//  Language
//
//  Created by Star Lord on 29/04/2023.
//

import UIKit

//MARK: - Data type for cell
struct DataForSeparatorCell{
    var value: String
    
    var isSelected:    Bool
    var isFunctional:  Bool = false
}

class SeparatorsCell: UITableViewCell {
    
    static let identifier = "separatorCell"
    
    //MARK: Views
    private let cellTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        label.tintColor = .systemGray4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let addImage : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "plus.circle")
        image.tintColor = .clear
        image.contentMode = .center
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    private let selectedImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "checkmark")
        image.tintColor = .clear
        image.contentMode = .center
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    //MARK: Dimentions
    private let subviewsInset: CGFloat = 15
    private let subviewsHeightMultiplier: CGFloat = 0.8
    
    //MARK: Inherited
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellView()
        configureCellSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Could not load from coder")
    }
    override func prepareForReuse() {
            super.prepareForReuse()
            cellTitle.text = nil
            addImage.tintColor = .clear
            selectedImage.tintColor = .clear
        }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            contentView.backgroundColor = (traitCollection.userInterfaceStyle == .dark
                                           ? .secondarySystemBackground
                                           : .systemGray6.withAlphaComponent(0.8))
        }
    }
    //MARK: Configure cell with passed data
    func configureCellWithData( _ data: DataForSeparatorCell){
        self.cellTitle.text = data.value
        self.addImage.tintColor = data.isFunctional ? .label : .clear
        self.selectedImage.tintColor = data.isSelected ? .label : .clear
    }

    //MARK: Setting up cell view
    private func configureCellView(){
        contentView.backgroundColor = .secondarySystemBackground
        
    }
        
    //MARK: Configure subviews layout.
    private func configureCellSubviews(){
        contentView.addSubviews(cellTitle, addImage, selectedImage)
        
        NSLayoutConstraint.activate([
            addImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -subviewsInset),
            addImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            addImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: subviewsHeightMultiplier),
            addImage.widthAnchor.constraint(equalTo: addImage.heightAnchor),
            
            selectedImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -subviewsInset),
            selectedImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: subviewsHeightMultiplier),
            selectedImage.widthAnchor.constraint(equalTo: addImage.heightAnchor),
            
            cellTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: subviewsInset),
            cellTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            cellTitle.trailingAnchor.constraint(lessThanOrEqualTo: selectedImage.leadingAnchor, constant: -subviewsInset)
        ])
    }
}
