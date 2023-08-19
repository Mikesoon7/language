//
//  NotificationSwitchCell.swift
//  Language
//
//  Created by Star Lord on 13/04/2023.
//

import UIKit

protocol NotificationsStateDelegate: AnyObject{
    func switchValueChanged(isOn: Bool)
}

class NotificationSwitchCell: UITableViewCell {
    
    static let identifier = "notificationSwitchCell"
    
    weak var delegate: NotificationsStateDelegate?
    
    //MARK: Views
    private let label : UILabel = {
        let label = UILabel()
        label.text = "notification.allowNotification".localized
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let control : UISwitch = {
        let control = UISwitch()
        control.setUpCustomSwitch(isOn: false)
        return control
    }()
    //MARK: Inherited
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellSubviews()
    }
    required init?(coder: NSCoder) {
        fatalError("Unable to use Coder")
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            contentView.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                    ? UIColor.systemGray5
                                    : UIColor.systemGray6.withAlphaComponent(0.8))
        }
    }
    
    //MARK: Configure properies of cell.
    private func configureCellView(){
        selectionStyle = .none
        contentView.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                ? UIColor.systemGray5
                                : UIColor.systemGray6.withAlphaComponent(0.8))

    }
    
    //MARK: Layout Subviews.
    private func configureCellSubviews(){
        contentView.addSubviews(label, control)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            control.centerYAnchor.constraint(equalTo: centerYAnchor),
            control.centerXAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        ])
        control.addTarget(self, action: #selector(switchDidToggle(sender: )), for: .valueChanged)
    }
    @objc func switchDidToggle(sender: UISwitch){
        delegate?.switchValueChanged(isOn: sender.isOn)
    }
}
