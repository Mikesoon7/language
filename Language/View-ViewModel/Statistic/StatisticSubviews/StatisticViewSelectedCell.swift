//
//  StatisticViewSelectedCell.swift
//  Learny
//
//  Created by Star Lord on 30/11/2024.
//
//  REFACTORING STATE: CHECKED

import UIKit

final class StatisticViewSelectedCell: UITableViewCell {
    static let id = "StatisticViewSelectedCell"
    
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
        label.font = .helveticaNeueMedium.withSize(18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()

    let creationDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeueMedium.withSize(14)
        label.textColor = .label.withAlphaComponent(0.9)
        label.text = "statistic.creationDate".localized
        label.isHidden = false
        return label
    }()
    let creationDateResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeue.withSize(12)
        label.textColor = .label.withAlphaComponent(0.9)
        label.isHidden = false
        label.textAlignment  = .right
        return label
    }()

    let accessNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeueMedium.withSize(14)
        label.textColor = .label.withAlphaComponent(0.9)
        label.text = "statistic.accessNumber".localized
        label.isHidden = false
        return label
    }()
    let accessNumberResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeue.withSize(12)
        label.textColor = .label.withAlphaComponent(0.9)
        label.isHidden = false
        label.textAlignment  = .right
        return label
    }()
    
    let cardsNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeueMedium.withSize(14)
        
        label.textColor = .label.withAlphaComponent(0.9)
        label.text = "statistic.cardsNumber".localized
        label.isHidden = false
        return label
    }()
    let cardsNumberResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeue.withSize(12)
        label.textColor = .label.withAlphaComponent(0.9)
        label.isHidden = false
        label.textAlignment  = .right
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
        self.colourView.backgroundColor = data.entityColour
        self.nameLabel.text = data.entityName
        self.creationDateResultLabel.text = data.entityCreationDate
        self.accessNumberResultLabel.text = String(data.entityAccessNumber) + " " + (data.entityAccessNumber > 1 ? "statistic.accessNumber.times".localized : "statistic.accessNumber.time".localized)
        self.cardsNumberResultLabel.text = String(data.entityCardsNumber) + " " + (data.entityCardsNumber > 1 ? "statistic.cardsNumber.cards".localized : "statistic.cardsNumber.card".localized)

    }
    
    //MARK: ViewSetUp
    func configureView(){
        contentView.backgroundColor = .clear
        selectionStyle = .none
    }

    func configureSubviews(){
        contentView.addSubviews(colourView, nameLabel)
        contentView.addSubviews(creationDateLabel, creationDateResultLabel, accessNumberLabel, accessNumberResultLabel, cardsNumberLabel, cardsNumberResultLabel)
        
        NSLayoutConstraint.activate([
            colourView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
            colourView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: subviewsInsets * 2 ),
            colourView.heightAnchor.constraint(equalToConstant: 50 * 0.7),
            colourView.widthAnchor.constraint(equalTo: colourView.heightAnchor),
            
            nameLabel.centerYAnchor.constraint(equalTo: colourView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: colourView.trailingAnchor, constant: subviewsInsets),
            
            creationDateLabel.topAnchor.constraint(equalTo: colourView.bottomAnchor, constant: 20),
            creationDateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            creationDateLabel.heightAnchor.constraint(equalToConstant: 20),
            
            creationDateResultLabel.topAnchor.constraint(equalTo: colourView.bottomAnchor, constant: 20),
            creationDateResultLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -subviewsInsets * 2),
            creationDateResultLabel.heightAnchor.constraint(equalToConstant: 20),
            
            accessNumberLabel.topAnchor.constraint(equalTo: creationDateLabel.bottomAnchor, constant: 20),
            accessNumberLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            accessNumberLabel.heightAnchor.constraint(equalToConstant: 20),
            
            accessNumberResultLabel.topAnchor.constraint(equalTo: creationDateLabel.bottomAnchor, constant: 20),
            accessNumberResultLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -subviewsInsets * 2),
            accessNumberResultLabel.heightAnchor.constraint(equalToConstant: 20),
            
            cardsNumberLabel.topAnchor.constraint(equalTo: accessNumberLabel.bottomAnchor, constant: 20),
            cardsNumberLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            cardsNumberLabel.heightAnchor.constraint(equalToConstant: 20),
            
            cardsNumberResultLabel.topAnchor.constraint(equalTo: accessNumberLabel.bottomAnchor, constant: 20),
            cardsNumberResultLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -subviewsInsets * 2),
            cardsNumberResultLabel.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
}
