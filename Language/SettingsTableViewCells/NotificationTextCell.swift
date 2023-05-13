//
//  NotificationTextCell.swift
//  Language
//
//  Created by Star Lord on 06/05/2023.
//



import UIKit

protocol NotificationCellDelegate: AnyObject{
    func datePickerValueChanged(_ cell: NotificationTextCell, date: Date)
}
class NotificationTextCell: UITableViewCell {
    
    let identifier = "notificationTextCell"
    
    lazy var view : UIView = {
        let view = UIView()
        view.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                ? UIColor.systemGray5
                                : UIColor.systemGray6.withAlphaComponent(0.8))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let label : UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    let value : UILabel = {
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
        label.text = nil
        value.text = nil
        image.image = UIImage(systemName: "chevron.right")
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            if traitCollection.userInterfaceStyle == .dark{
                view.backgroundColor = .systemGray5
            } else {
                view.backgroundColor = .systemGray6.withAlphaComponent(0.8)
            }
        }
    }
    func cellViewsCustomization(){
        self.contentView.addSubview(view)
        view.addSubviews(label, value,image)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            value.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -5),
            value.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
