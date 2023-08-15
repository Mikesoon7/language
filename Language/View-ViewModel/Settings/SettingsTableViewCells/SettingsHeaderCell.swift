//
//  CustomHeaderView.swift
//  Language
//
//  Created by Star Lord on 10/04/2023.
//

import UIKit

struct DataForSettingsHeaderCell{
    var title: String
}

class SettingsHeaderCell: UITableViewCell {
    static let identifier = "settingsHeaderCell"
    static let dataType = DataForSettingsHeaderCell.self
    
    let view: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6.withAlphaComponent(0.8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let label: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray2
        label.font = UIFont(name: "Helvetica Neue Medium", size: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cellViewCustomization()
        contentView.isUserInteractionEnabled = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    func configureCell(with data: DataForSettingsHeaderCell){
        label.text = data.title
    }
    func cellViewCustomization(){
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
