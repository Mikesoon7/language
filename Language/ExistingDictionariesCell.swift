//
//  ExistingDictionariesCell.swift
//  Language
//
//  Created by Star Lord on 14/02/2023.
//

import UIKit

class DictionaryCell: UITableViewCell{

    
    var languageTitle : UILabel = {
        var label = UILabel()
        label.attributedText = NSAttributedString(
            string: "Language:",
            attributes: [ NSAttributedString.Key.font: UIFont(name: "Georgia-BoldItalic" , size: 20) ?? UIFont.systemFont(ofSize: 18)
            ])
        return label
    }()
    
    var cardsTitle : UILabel = {
        var label = UILabel()
        label.attributedText = NSAttributedString(
            string: "Total words:",
            attributes: [ NSAttributedString.Key.font: UIFont(name: "Georgia-BoldItalic", size: 20) ?? UIFont.systemFont(ofSize: 18)
                          
            ])
        return label
    }()
    
    var languageName : UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Georgia-Italic", size: 15)
        label.textAlignment = .right
        return label
    }()
    
    var cardsNumberName : UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Georgia-Italic", size: 15)
        label.textAlignment = .right
        return label
    }()
    
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
    func setConstraints(){
        languageName.translatesAutoresizingMaskIntoConstraints = false
        languageTitle.translatesAutoresizingMaskIntoConstraints = false
        cardsNumberName.translatesAutoresizingMaskIntoConstraints = false
        cardsTitle.translatesAutoresizingMaskIntoConstraints = false
        
        addSubviews(languageName, languageTitle, cardsTitle, cardsNumberName)
        
        NSLayoutConstraint.activate([
            languageTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            languageTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
//            languageTitle.widthAnchor.constraint(equalToConstant: 100),
            languageTitle.heightAnchor.constraint(equalToConstant: 25),
            
            cardsTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 64),
            cardsTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
//            cardsTitle.widthAnchor.constraint(equalToConstant: 100),
            cardsTitle.heightAnchor.constraint(equalToConstant: 25),

            languageName.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            languageName.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
//            languageName.widthAnchor.constraint(equalToConstant: 100),
            languageName.heightAnchor.constraint(equalToConstant: 25),
            
            cardsNumberName.topAnchor.constraint(equalTo: self.topAnchor, constant: 64),
            cardsNumberName.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
//            cardsNumberName.widthAnchor.constraint(equalToConstant: 100),
            cardsNumberName.heightAnchor.constraint(equalToConstant: 25),
            
            
            
        ])

    }
}
class DictionaryDetails{
    
    var dictionary : [[String: String]]?
    
    var language = String()
    
    var numberOfCards = String()
    
    init(language: String){
        self.language = language
            }
    init(language: String, dictionary: [[String: String]]){
        self.language = language
        self.dictionary = dictionary
        self.numberOfCards = String(dictionary.count)
    }
}

extension UIView{
    func addSubviews(_ views: UIView...){
        for i in views{
            self.addSubview(i)
        }
    }
}


