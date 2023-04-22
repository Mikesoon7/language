//
//  SearchViewCell.swift
//  Language
//
//  Created by Star Lord on 22/04/2023.
//

import UIKit

class SearchViewCell: UITableViewCell {
    let identifier = "searchCell"
    
    let view: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
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
        label.numberOfLines = 2
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
    func cellViewCustomization(){
        contentView.addSubview(view)
        view.addSubviews(wordLabel, descriptionLabel)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            wordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            wordLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            wordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),

            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            descriptionLabel.topAnchor.constraint(equalTo: view.centerYAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15)
        ])
    }
}
