//
//  SearchViewCell.swift
//  Language
//
//  Created by Star Lord on 22/04/2023.
//

import UIKit

struct DataForSearchCell{
    var word: String
    var description: String
    
    init(){
        word = ""
        description = ""
    }
    init(word: String, description: String){
        self.word = word
        self.description = description
    }
}

class SearchViewCell: UITableViewCell {
    
    static let identifier = "searchCell"

    //Stores cells dimentions state.
    var isExpanded: Bool = false {
        didSet {
            changeLabelsAppearence(expand: isExpanded)
        }
    }

    //MARK: - Views
    let wordLabel: UILabel = {
        let label = UILabel()
        label.tintColor = .label
        label.numberOfLines = 1
        label.contentMode = .topLeft
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.tintColor = .systemGray3
        label.contentMode = .topLeft
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: Constrait related properties
    private var descriptionLabelConstraints: [NSLayoutConstraint] = []
    private var wordLabelConstraints: [NSLayoutConstraint] = []
    
    private let inset = CGFloat(10)

    //MARK: - Inherited Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureContentView()
        configureCellSubviews()
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
    
        wordLabel.font = .selectedFont.withSize(14)
        descriptionLabel.font = .selectedFont.withSize(11)

        //If cell have onlu word, we use first first set og constraits.
        if !data.description.isEmpty {
            NSLayoutConstraint.deactivate(wordLabelConstraints)
            NSLayoutConstraint.activate(descriptionLabelConstraints)
        } else {
            NSLayoutConstraint.deactivate(descriptionLabelConstraints)
            NSLayoutConstraint.activate(wordLabelConstraints)
        }
    }
    //MARK: Setting up cells properties
    func configureContentView(){
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 9
    }

    //MARK: - Cell SetUp
    func configureCellSubviews(){
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
            self.layoutIfNeeded()
            
        }
        UIView.transition(with: self.descriptionLabel, duration: 0.5, options: [ .transitionCrossDissolve, .curveEaseOut], animations: {
            self.descriptionLabel.numberOfLines = expand ? 0: 1
            self.setNeedsUpdateConstraints()
            self.layoutIfNeeded()
        })
    }

}
