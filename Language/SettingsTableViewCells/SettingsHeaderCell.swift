//
//  CustomHeaderView.swift
//  Language
//
//  Created by Star Lord on 10/04/2023.
//

import UIKit

class SettingsHeaderCell: UITableViewCell {
    let identifier = "settingsHeaderCell"
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray2
        label.font = UIFont(name: "Helvetica Neue Medium", size: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    let view: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6.withAlphaComponent(0.8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        viewCustomization()
        contentView.isUserInteractionEnabled = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func viewCustomization(){
        contentView.addSubview(view)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),

        ])
    }
}
