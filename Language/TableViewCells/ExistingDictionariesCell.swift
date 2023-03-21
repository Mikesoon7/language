//
//  ExistingDictionariesCell.swift
//  Language
//
//  Created by Star Lord on 14/02/2023.
//

import UIKit

class DictionaryCell: UITableViewCell{

    var languageLabel : UILabel = {
        var label = UILabel()
        label.attributedText = NSAttributedString().fontWithString(string: "Language", bold: true, size: 20)
        return label
    }()
    
    var cardsLabel : UILabel = {
        var label = UILabel()
        label.attributedText = NSAttributedString().fontWithString(string: "Total words", bold: true, size: 20)
        return label
    }()
    
    var languageResultLabel : UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Georgia-Italic", size: 15)
        label.textAlignment = .right
        label.text = "???"
        return label
    }()
    
    var cardsResultLabel : UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Georgia-Italic", size: 15)
        label.textAlignment = .right
        label.text = "???"
        return label
    }()
    
//MARK: - Prepare Func
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .systemGray5
        self.layer.cornerRadius = 9
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.clipsToBounds = true
        setConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("coder wasn't imported")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setConstraints(){
        languageResultLabel.translatesAutoresizingMaskIntoConstraints = false
        languageLabel.translatesAutoresizingMaskIntoConstraints = false
        cardsResultLabel.translatesAutoresizingMaskIntoConstraints = false
        cardsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(languageResultLabel, languageLabel, cardsLabel, cardsResultLabel)
        
        NSLayoutConstraint.activate([
            languageLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            languageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            languageLabel.heightAnchor.constraint(equalToConstant: 25),
            
            cardsLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 64),
            cardsLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            cardsLabel.heightAnchor.constraint(equalToConstant: 25),

            languageResultLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            languageResultLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            languageResultLabel.heightAnchor.constraint(equalToConstant: 25),
            
            cardsResultLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 64),
            cardsResultLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            cardsResultLabel.heightAnchor.constraint(equalToConstant: 25),
        ])
    }
}

//MARK: -AddSubviews method.
extension UIView{
    func addSubviews(_ views: UIView...){
        for i in views{
            self.addSubview(i)
        }
    }
}


