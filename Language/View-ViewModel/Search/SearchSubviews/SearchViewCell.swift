//
//  SearchViewCell.swift
//  Language
//
//  Created by Star Lord on 22/04/2023.
//
//  REFACTORING STATE: CHECKED

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

class SearchCell: UICollectionViewCell {
    
    static let identifier = "searchCell"
    
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
    
    //MARK: - Inherited Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureContentView()
        configureCellSubviews()
    }
    required init?(coder: NSCoder) {
        fatalError("Unable to use Coder")
    }
    
    override func prepareForReuse() {
        wordLabel.text = nil
        descriptionLabel.text = nil
        wordLabel.numberOfLines = 1
        descriptionLabel.numberOfLines = 1
    }
    
    //MARK: - Data SetUp
    func configureCellWith(data: DataForSearchCell){
        wordLabel.text = data.word
        descriptionLabel.text = data.description
    
        wordLabel.font = .selectedFont.withSize(.assosiatedTextSize)
        descriptionLabel.font = .selectedFont.withSize(.captionTextSize)

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
        contentView.layer.cornerRadius = .cornerRadius
    }

    //MARK: - Cell SetUp
    func configureCellSubviews(){
        contentView.addSubviews(wordLabel, descriptionLabel)
        
        wordLabelConstraints = [
            wordLabel.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: .nestedSpacer ),
            wordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, 
                                               constant: .nestedSpacer),
            wordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -.nestedSpacer),

        ]
        
        descriptionLabelConstraints = [
            wordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: .nestedSpacer),
            wordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, 
                                           constant: .nestedSpacer),
            wordLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -.nestedSpacer),
            
            descriptionLabel.topAnchor.constraint(equalTo: wordLabel.bottomAnchor, 
                                                  constant: .nestedSpacer),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                      constant: .nestedSpacer),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                     constant: -.nestedSpacer),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                       constant: -.nestedSpacer)
        ]
    }
}
