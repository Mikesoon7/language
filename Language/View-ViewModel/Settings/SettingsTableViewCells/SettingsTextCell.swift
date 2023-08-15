//
//  SettingsTBCell.swift
//  Language
//
//  Created by Star Lord on 04/04/2023.
//

import UIKit

struct DataForSettingsTextCell{
    var title: String
    var value: String
}

class SettingsTextCell: UITableViewCell {
    static let identifier = "settingsTextCell"
    static let dataType = DataForSettingsTextCell.self
    
    let view : UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6.withAlphaComponent(0.8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    let valueLabel : UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let image : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "chevron.right")
        view.tintColor = .label
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cellViewsCustomization()
    }
    required init?(coder: NSCoder) {
        fatalError("Unable to use Coder")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        valueLabel.text = nil
        image.image = UIImage(systemName: "chevron.right")
    }
    func configureCell(with data: DataForSettingsTextCell){
        self.titleLabel.text = data.title
        self.valueLabel.text = data.value
    }

    func cellViewsCustomization(){
        self.contentView.addSubview(view)
        view.addSubviews(titleLabel, valueLabel,image)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            valueLabel.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -5),
            valueLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
