//
//  SearchViewCell.swift
//  Language
//
//  Created by Star Lord on 22/04/2023.
//

import UIKit

class SearchViewCell: UITableViewCell {
    
    static let identifier = "searchCell"

    private let inset = CGFloat(10)
    
    var isExpanded: Bool = false {
        didSet {
            changeLabelsAppearence(expand: isExpanded)
        }
    }

    //MARK: - Views
    let wordLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue Medium", size: 14)
        label.tintColor = .label
        label.numberOfLines = 1
        label.contentMode = .topLeft
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue Medium", size: 11)
        label.numberOfLines = 1
        label.tintColor = .systemGray3
        label.contentMode = .topLeft
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: Constrait related properties
    private var descriptionLabelConstraints: [NSLayoutConstraint] = []
    private var wordLabelConstraints: [NSLayoutConstraint] = []
    
    //MARK: - Inherited Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureContentView()
        configureCellView()
    }
    required init?(coder: NSCoder) {
        fatalError("Unable to use Coder")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        wordLabel.numberOfLines = 1
        descriptionLabel.numberOfLines = 1
    }
    
    //MARK: - Data SetUp
    func configureCellWith(data: DataForSearchCell){
        wordLabel.text = data.word
        descriptionLabel.text = data.description
        
        //If cell have onlu word, we use first first set og constraits.
        if !data.description.isEmpty {
            NSLayoutConstraint.deactivate(wordLabelConstraints)
            NSLayoutConstraint.activate(descriptionLabelConstraints)
        } else {
            NSLayoutConstraint.deactivate(descriptionLabelConstraints)
            NSLayoutConstraint.activate(wordLabelConstraints)
        }
    }
    
    func configureContentView(){
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 9
    }

    //MARK: - Cell SetUp
    func configureCellView(){
        contentView.addSubviews(wordLabel, descriptionLabel)
        
        wordLabelConstraints = [
            wordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset * 2 ),
            wordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            wordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            wordLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset * 2)
        ]
        
        descriptionLabelConstraints = [
            wordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            wordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            wordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            
            descriptionLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, constant: inset),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset)
        ]

    }
    //Smoothly changing lines number.
    func changeLabelsAppearence(expand: Bool){
        UIView.transition(with: wordLabel, duration: 0.5, options: [ .transitionCrossDissolve, .curveEaseOut] ) {
            self.wordLabel.numberOfLines = expand ? 0: 1
            self.setNeedsUpdateConstraints()
            print("wordsLabel is changing")
            self.layoutIfNeeded()
            
        }
        UIView.transition(with: self.descriptionLabel, duration: 0.5, options: [ .transitionCrossDissolve, .curveEaseOut], animations: {
            self.descriptionLabel.numberOfLines = expand ? 0: 1
            self.setNeedsUpdateConstraints()
            print("descriptionLabel is changing")
            self.layoutIfNeeded()
        })
    }

}
