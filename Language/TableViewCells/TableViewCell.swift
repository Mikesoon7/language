//
//  TableViewCell.swift
//  Language
//
//  Created by Star Lord on 23/03/2023.
//

import UIKit

class TableViewCell: UITableViewCell{

    var view : UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 9
//        view.layer.borderWidth = 1
//        view.layer.borderColor = UIColor.black.cgColor
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var languageLabel : UILabel = {
        var label = UILabel()
        label.attributedText = NSAttributedString(
            string: LanguageChangeManager.shared.localizedString(forKey: "tableCellName"),
            attributes: [NSAttributedString.Key.font : UIFont(name: "Georgia-BoldItalic", size: 20) ?? UIFont(),
                         NSAttributedString.Key.foregroundColor: UIColor.label])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cardsLabel : UILabel = {
        var label = UILabel()
        label.attributedText = NSAttributedString().fontWithString(
            string: LanguageChangeManager.shared.localizedString(forKey: "tableCellNumberOfCards"),
            bold: true,
            size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var languageResultLabel : UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Georgia-Italic", size: 15)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cardsResultLabel : UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Georgia-Italic", size: 15)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//MARK: - Prepare Func
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)

    }
    required init?(coder: NSCoder) {
        fatalError("coder wasn't imported")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setConstraints(){
        contentView.addSubview(view)
        view.addSubviews(languageResultLabel, languageLabel, cardsLabel, cardsResultLabel)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            languageLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            languageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            languageLabel.heightAnchor.constraint(equalToConstant: 25),
            
            cardsLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            cardsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            cardsLabel.heightAnchor.constraint(equalToConstant: 25),

            languageResultLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            languageResultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            languageResultLabel.heightAnchor.constraint(equalToConstant: 25),
            
            cardsResultLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 64),
            cardsResultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            cardsResultLabel.heightAnchor.constraint(equalToConstant: 25),
        ])
    }
    @objc func languageDidChange(sender: Any){
        languageLabel.text = LanguageChangeManager.shared.localizedString(forKey: "tableCellName")
        cardsLabel.text = LanguageChangeManager.shared.localizedString(forKey: "tableCellNumberOfCards")
    }
}


