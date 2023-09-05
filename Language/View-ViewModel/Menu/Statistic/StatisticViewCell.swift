//
//  StatisticViewCell.swift
//  Language
//
//  Created by Star Lord on 31/08/2023.
//

import UIKit


struct StatisticCellData{
    var colour: UIColor
    var title: String
    var value: Int
    var percents: String
}

final class StatisticViewCell: UITableViewCell {
    static let id = "StatisticViewCell"
    
    private let subviewsInsets: CGFloat = 10
    
    private let colourView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 5.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .helveticaNeueMedium.withSize(18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .helveticaNeueMedium.withSize(14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()
    private let percentsLabel: UILabel = {
        let label = UILabel()
        label.font = .helveticaNeue.withSize(10)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()


    //MARK: Inherited and initializers.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureSubviews()
    }
    required init?(coder: NSCoder) {
        fatalError("coder wasn't imported")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func configureCellWith(_ data: StatisticCellData){
        self.colourView.backgroundColor = data.colour
        self.titleLabel.text = data.title
        self.valueLabel.text = String(data.value)
        self.percentsLabel.text = data.percents
    }
    func configureView(){
        contentView.backgroundColor = .clear
    }

    func configureSubviews(){
        contentView.addSubviews(colourView, titleLabel, valueLabel, percentsLabel)
        
        NSLayoutConstraint.activate([
            colourView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colourView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: subviewsInsets * 2 ),
            colourView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
            colourView.widthAnchor.constraint(equalTo: colourView.heightAnchor),
            
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: colourView.trailingAnchor, constant: subviewsInsets),
            
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -subviewsInsets * 2 ),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -subviewsInsets / 3),
            
            percentsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -subviewsInsets * 2 ),
            percentsLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: subviewsInsets / 3),
        ])
    }
}
