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

    let creationDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeueMedium.withSize(.assosiatedTextSize)
        label.textColor = .label.withAlphaComponent(0.9)
        label.text = "statistic.creationDate".localized
        label.isHidden = false
        return label
    }()
    let creationDateResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeue.withSize(.captionTextSize)
        label.textColor = .label.withAlphaComponent(0.9)
        label.isHidden = false
        label.textAlignment  = .right
        return label
    }()

    let accessNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeueMedium.withSize(.assosiatedTextSize)
        label.textColor = .label.withAlphaComponent(0.9)
        label.text = "statistic.accessNumber".localized
        label.isHidden = false
        return label
    }()
    let accessNumberResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeue.withSize(.captionTextSize)
        label.textColor = .label.withAlphaComponent(0.9)
        label.isHidden = false
        label.textAlignment  = .right
        return label
    }()
    
    let cardsNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeueMedium.withSize(.assosiatedTextSize)
        
        label.textColor = .label.withAlphaComponent(0.9)
        label.text = "statistic.cardsNumber".localized
        label.isHidden = false
        return label
    }()
    let cardsNumberResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .helveticaNeue.withSize(.captionTextSize)
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
            colourView.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: .nestedSpacer),
            colourView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: .nestedSpacer * 2 ),
            colourView.heightAnchor.constraint(
                equalToConstant: 50 * 0.7),
            colourView.widthAnchor.constraint(
                equalTo: colourView.heightAnchor),
            
            nameLabel.centerYAnchor.constraint(
                equalTo: colourView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(
                equalTo: colourView.trailingAnchor, constant: .nestedSpacer),
            
            creationDateLabel.topAnchor.constraint(
                equalTo: colourView.bottomAnchor, constant: .outerSpacer),
            creationDateLabel.leadingAnchor.constraint(
                equalTo: nameLabel.leadingAnchor),
            creationDateLabel.heightAnchor.constraint(
                equalToConstant: .outerSpacer),
            
            creationDateResultLabel.topAnchor.constraint(
                equalTo: colourView.bottomAnchor, constant: .outerSpacer),
            creationDateResultLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -.nestedSpacer * 2),
            creationDateResultLabel.heightAnchor.constraint(
                equalToConstant: .outerSpacer),
            
            accessNumberLabel.topAnchor.constraint(
                equalTo: creationDateLabel.bottomAnchor, constant: .outerSpacer),
            accessNumberLabel.leadingAnchor.constraint(
                equalTo: nameLabel.leadingAnchor),
            accessNumberLabel.heightAnchor.constraint(
                equalToConstant: .outerSpacer),
            
            accessNumberResultLabel.topAnchor.constraint(
                equalTo: creationDateLabel.bottomAnchor, constant: .outerSpacer),
            accessNumberResultLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -.nestedSpacer * 2),
            accessNumberResultLabel.heightAnchor.constraint(
                equalToConstant: .outerSpacer),
            
            cardsNumberLabel.topAnchor.constraint(
                equalTo: accessNumberLabel.bottomAnchor, constant: .outerSpacer),
            cardsNumberLabel.leadingAnchor.constraint(
                equalTo: nameLabel.leadingAnchor),
            cardsNumberLabel.heightAnchor.constraint(
                equalToConstant: .outerSpacer),
            
            cardsNumberResultLabel.topAnchor.constraint(
                equalTo: accessNumberLabel.bottomAnchor, constant: .outerSpacer),
            cardsNumberResultLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -.nestedSpacer * 2),
            cardsNumberResultLabel.heightAnchor.constraint(
                equalToConstant: .outerSpacer),
        ])
    }
}
