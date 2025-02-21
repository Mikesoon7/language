//
//  SettingsTBCell.swift
//  Language
//
//  Created by Star Lord on 04/04/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit

//MARK: - Data type for cell
struct DataForSettingsTextCell{
    var title: String
    var value: String?
}

class SettingsTextCell: UITableViewCell {
    static let identifier = "settingsTextCell"
    
    //MARK: Views
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    private let valueLabel : UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let chevronImage : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "chevron.right")
        view.tintColor = .label
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: Inherited
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellsView()
        configureCellsSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unable to use Coder")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        valueLabel.text = nil
    }
    
    //MARK: Settings up cells view.
    func configureCellsView(){
        contentView.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.8)

    }
    //MARK: Configure cell with passed data.
    //Called after dequing in table view delegate.
    func configureCellWithData(_ data: DataForSettingsTextCell){
        self.titleLabel.text = data.title
        self.valueLabel.text = data.value ?? ""
        titleLabel.font = .selectedFont.withSize(.bodyTextSize)
    }
    
    //MARK: Configure subviews layout.
    func configureCellsSubviews(){
        contentView.addSubviews(titleLabel, valueLabel, chevronImage)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .longInnerSpacer),
            titleLabel.centerYAnchor.constraint(
                equalTo: centerYAnchor),
            
            chevronImage.centerYAnchor.constraint(
                equalTo: centerYAnchor),
            chevronImage.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -.longInnerSpacer),
            
            valueLabel.trailingAnchor.constraint(
                equalTo: chevronImage.leadingAnchor, constant: -.nestedSpacer),
            valueLabel.centerYAnchor.constraint(
                equalTo: centerYAnchor)
        ])
    }
}
