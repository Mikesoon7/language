//
//  NotificationTextCell.swift
//  Language
//
//  Created by Star Lord on 06/05/2023.
//



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
    private let label : UILabel = {
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
    private let image : UIImageView = {
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
        label.text = nil
        value.text = nil
        image.image = UIImage(systemName: "chevron.right")
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
        self.label.text = data.label
        self.value.text = data.value
    }
    
    //MARK: Configure layout
    private func configureCellSubviews(){
        contentView.addSubviews(label, value,image)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            image.centerYAnchor.constraint(equalTo: centerYAnchor),
            image.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            
            value.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -5),
            value.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
