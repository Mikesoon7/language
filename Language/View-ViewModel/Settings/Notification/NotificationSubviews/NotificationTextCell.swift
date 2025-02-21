//
//  NotificationTextCell.swift
//  Language
//
//  Created by Star Lord on 06/05/2023.
//
//  REFACTORING STATE: NOT CHECKED

import UIKit


//MARK: Data for textCell
struct DataForNotificationTextCell{
    var label: String
    var value: String?
    
    var delegate: NotificationsStateDelegate?
}

class NotificationTextCell: UITableViewCell {
    
    static let identifier = "notificationTextCell"
    
    //MARK: Views
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    private let value : UILabel = {
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
        configureCellView()
        configureCellSubviews()
    }
    required init?(coder: NSCoder) {
        fatalError("Unable to use Coder")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        value.text = nil
        chevronImage.image = UIImage(systemName: "chevron.right")
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            configureCellView()
        }
    }
    
    //MARK: Setting up properties of view.
    private func configureCellView(){
        contentView.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                                                       ? UIColor.systemGray5
                                                                       : UIColor.systemGray6.withAlphaComponent(0.8))

    }
    
    //MARK: Configure cell with passed data.
    func configureCellWithData(_ data: DataForNotificationTextCell){
        self.titleLabel.text = data.label
        self.value.text = data.value
    }
    
    //MARK: Configure layout
    private func configureCellSubviews(){
        contentView.addSubviews(titleLabel, value,chevronImage)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .longInnerSpacer),
            titleLabel.centerYAnchor.constraint(
                equalTo: centerYAnchor),
            
            chevronImage.centerYAnchor.constraint(
                equalTo: centerYAnchor),
            chevronImage.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -.longInnerSpacer),
            
            value.trailingAnchor.constraint(
                equalTo: chevronImage.leadingAnchor, constant: -.nestedSpacer),
            value.centerYAnchor.constraint(
                equalTo: centerYAnchor)
        ])
    }
}
