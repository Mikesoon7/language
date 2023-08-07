//
//  NotificationWeekCell.swift
//  Language
//
//  Created by Star Lord on 30/07/2023.
//

import UIKit

private class NotificationWeekCell: UITableViewCell {
    
    static let identifier = "notificationWeekCell"
    
    let arrayOfDays: [String] = {
        let calendar = Calendar.current
        let firstDay = calendar.firstWeekday
        let formatter = DateFormatter()
        var array: [String] = []
        for i in 0..<7 {
            let index = (firstDay - 1 + i) % 7
            array.append(formatter.weekdaySymbols[index])
        }
        return array
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureStackView()
        
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Coder wasn't imported")
    }
    
    func configureStackView(){
        var arrayOfButton: [UIButton] = []
        let spacer = UIView()
        for i in arrayOfDays {
            arrayOfButton.append(createDayButton(with: i, textColour: .label))
        }
        let stackView = UIStackView(arrangedSubviews: [spacer,
                                                       arrayOfButton[0],
                                                       spacer,
                                                       arrayOfButton[1],
                                                       spacer,
                                                       arrayOfButton[2],
                                                       spacer,
                                                       arrayOfButton[3],
                                                       spacer,
                                                       arrayOfButton[4],
                                                       spacer,
                                                       arrayOfButton[5],
                                                       spacer,
                                                       arrayOfButton[6],
                                                       spacer
                                                      ])
        stackView.backgroundColor = .clear
        stackView.alignment = .center
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
    }
    func createDayButton(with title: String, textColour: UIColor) -> UIButton{
        let button = UIButton(configuration: .tinted())
        button.configuration?.background = .clear()
        button.configuration?.title = title
        button.contentMode = .center
        button.tintColor = textColour
        button.addTarget(self, action: #selector(buttonDidTap(sender: )), for: .touchUpInside)
        return button
    }
    
    @objc func buttonDidTap(sender: UIButton){
        if sender.backgroundColor == .systemGray3 {
            sender.backgroundColor = .systemOrange
        } else {
            sender.backgroundColor = .systemGray3

        }
    }
}
