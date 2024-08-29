//
//  CustomHeaderView.swift
//  Language
//
//  Created by Star Lord on 10/04/2023.
//

import UIKit

//MARK: - Data type for cell
struct DataForSettingsHeaderCell{
    var title: String
}

class SettingsHeaderCell: UITableViewCell {
    static let identifier = "settingsHeaderCell"
    
    //MARK: Views
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    //MARK: Inherited
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellsView()
        configureCellsSubviews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    //MARK: Settings up cells view.
    func configureCellsView(){
        contentView.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.8)
        self.selectionStyle = .none
    }
    
    //MARK: Configure cell with passed data.
    //Called after dequing in table view delegate.
    func configureCellWithData(_ data: DataForSettingsHeaderCell){
        label.text = data.title
        label.font = .selectedFont.withSize(19)
    }
    
    //MARK: Configure subviews layout.
    func configureCellsSubviews(){
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([

            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),

        ])
    }
}
