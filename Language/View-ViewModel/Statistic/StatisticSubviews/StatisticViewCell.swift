//
//  StatisticViewCell.swift
//  Language
//
//  Created by Star Lord on 31/08/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit


struct StatisticCellData{
    var entityColour: UIColor
    var entityName: String
    var entityAccessTime: String
    var entityAccessTimeRatio: String
    var entityCreationDate: String
    var entityCardsNumber: Int
    var entityAccessNumber: Int
    
    var isSelected: Bool
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
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .helveticaNeueMedium.withSize(.bodyTextSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    private let accessTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .helveticaNeueMedium.withSize(.assosiatedTextSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()
    private let accessTimeRationLabel: UILabel = {
        let label = UILabel()
        label.font = .helveticaNeue.withSize(.captionTextSize)
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
    
    func configureCellWith(_ data: StatisticCellData, isExpanded: Bool){
        self.colourView.backgroundColor = data.entityColour
        self.nameLabel.text = data.entityName
        self.accessTimeLabel.text = data.entityAccessTime
        self.accessTimeRationLabel.text = data.entityAccessTimeRatio
    }
    
    func configureView(){
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }

    func configureSubviews(){
        contentView.addSubviews(colourView, nameLabel, accessTimeLabel, accessTimeRationLabel)
        
        NSLayoutConstraint.activate([
            colourView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colourView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: subviewsInsets * 2 ),
            colourView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7),
            colourView.widthAnchor.constraint(equalTo: colourView.heightAnchor),
            
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: colourView.trailingAnchor, constant: subviewsInsets),
            
            accessTimeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -subviewsInsets * 2 ),
            accessTimeLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -subviewsInsets / 3),
            
            accessTimeRationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -subviewsInsets * 2 ),
            accessTimeRationLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: subviewsInsets / 3),
        ])
    }
}
