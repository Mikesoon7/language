//
//  SearchViewCell.swift
//  Language
//
//  Created by Star Lord on 22/04/2023.
//

import UIKit

class SearchViewCell: UITableViewCell {
    let identifier = "searchCell"
    
    let inset = CGFloat(10)
    
    let view: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 9
        view.addCenterSideShadows(false)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let spacerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let wordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue Medium", size: 14)
        label.tintColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue Medium", size: 11)
        label.numberOfLines = 1
        label.tintColor = .systemGray3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cellViewCustomization()
    }
    required init?(coder: NSCoder) {
        fatalError("Unable to use Coder")
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            if traitCollection.userInterfaceStyle == .dark{
                view.layer.shadowColor = shadowColorForDarkIdiom
            } else {
                view.layer.shadowColor = shadowColorForLightIdiom
            }
        }
    }
    func cellViewCustomization(){
        contentView.addSubview(spacerView)
        spacerView.addSubview(view)
        view.addSubviews(wordLabel, descriptionLabel)
        
        NSLayoutConstraint.activate([
            spacerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            spacerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            spacerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            spacerView.topAnchor.constraint(equalTo: contentView.topAnchor),

            view.topAnchor.constraint(equalTo: spacerView.topAnchor, constant: inset),
            view.bottomAnchor.constraint(equalTo: spacerView.bottomAnchor, constant: -inset),
            view.widthAnchor.constraint(equalTo: spacerView.widthAnchor, multiplier: 0.91),
            view.centerXAnchor.constraint(equalTo: spacerView.centerXAnchor),

            wordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            wordLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            wordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            descriptionLabel.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -((contentView.bounds.height - inset * 2)) * 0.6),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
    }
}
