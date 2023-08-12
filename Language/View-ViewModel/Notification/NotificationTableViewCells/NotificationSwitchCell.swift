//
//  NotificationSwitchCell.swift
//  Language
//
//  Created by Star Lord on 13/04/2023.
//

import UIKit

protocol NotificationsStateDelegate {
    func switchValueChanged(isOn: Bool)
}

class NotificationSwitchCell: UITableViewCell {
    
    static let identifier = "notificationSwitchCell"
    
    var delegate: NotificationsStateDelegate!
    
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
        label.text = "notification.allowNotification".localized
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var control : UISwitch = {
        let control = UISwitch()
        control.setUpCustomSwitch(isOn: false)
        return control
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cellViewsCustomization()
        self.selectionStyle = .none
    }
    required init?(coder: NSCoder) {
        fatalError("Unable to use Coder")
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            if traitCollection.userInterfaceStyle == .dark{
                self.view.backgroundColor = .systemGray5
            } else {
                self.view.backgroundColor = .systemGray6.withAlphaComponent(0.8)
            }
        }
    }
    func cellViewsCustomization(){
        self.contentView.addSubview(view)
        view.addSubviews(label, control)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            control.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            control.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        control.addTarget(self, action: #selector(switchDidToggle(sender: )), for: .valueChanged)
    }
    @objc func switchDidToggle(sender: UISwitch){
        delegate.switchValueChanged(isOn: sender.isOn)
    }
}
