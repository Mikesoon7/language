//
//  StatisticVC.swift
//  Language
//
//  Created by Star Lord on 16/02/2023.
//

import UIKit

class StatisticVC: UIViewController {

    var statisticView: UIView = {
        var view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 9
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.clipsToBounds = true
        return view
    }()
    
    var repeatedLabel : UILabel = {
        var label = UILabel()
        label.attributedText = NSAttributedString(
            string: "Repeated:",
            attributes: [ NSAttributedString.Key.font: UIFont(name: "Georgia-BoldItalic" , size: 20) ?? UIFont.systemFont(ofSize: 18)
            ])
        return label
    }()
    
    var totalWordsLabel : UILabel = {
        var label = UILabel()
        label.attributedText = NSAttributedString(
            string: "Total words:",
            attributes: [ NSAttributedString.Key.font: UIFont(name: "Georgia-BoldItalic", size: 20) ?? UIFont.systemFont(ofSize: 18)
                          
            ])
        return label
    }()
    
    var repeatedTimesNumber : UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Georgia-Italic", size: 15)
        label.textAlignment = .right
        label.text = "???"
        return label
    }()
    
    var repeatedWordsLabel : UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Georgia-Italic", size: 15)
        label.textAlignment = .right
        label.text = "???"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        staticViewLayout()
        setConstraints()
    }
    

    func staticViewLayout(){
        view.addSubview(statisticView)
        
        statisticView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            statisticView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            statisticView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            statisticView.widthAnchor.constraint(lessThanOrEqualToConstant: 330),
            statisticView.heightAnchor.constraint(lessThanOrEqualToConstant: 104)
        ])
    }
    func setConstraints(){
        repeatedLabel.translatesAutoresizingMaskIntoConstraints = false
        totalWordsLabel.translatesAutoresizingMaskIntoConstraints = false
        repeatedTimesNumber.translatesAutoresizingMaskIntoConstraints = false
        repeatedWordsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statisticView.addSubviews(repeatedLabel, totalWordsLabel, repeatedWordsLabel, repeatedTimesNumber)
        
        NSLayoutConstraint.activate([
            repeatedLabel.topAnchor.constraint(equalTo: statisticView.topAnchor, constant: 15),
            repeatedLabel.leadingAnchor.constraint(equalTo: statisticView.leadingAnchor, constant: 15),
            repeatedLabel.heightAnchor.constraint(equalToConstant: 25),
            
            totalWordsLabel.topAnchor.constraint(equalTo: statisticView.topAnchor, constant: 64),
            totalWordsLabel.leadingAnchor.constraint(equalTo: statisticView.leadingAnchor, constant: 15),
            totalWordsLabel.heightAnchor.constraint(equalToConstant: 25),

            repeatedTimesNumber.topAnchor.constraint(equalTo: statisticView.topAnchor, constant: 15),
            repeatedTimesNumber.trailingAnchor.constraint(equalTo: statisticView.trailingAnchor, constant: -15),
            repeatedTimesNumber.heightAnchor.constraint(equalToConstant: 25),
            
            repeatedWordsLabel.topAnchor.constraint(equalTo: statisticView.topAnchor, constant: 64),
            repeatedWordsLabel.trailingAnchor.constraint(equalTo: statisticView.trailingAnchor, constant: -15),
            repeatedWordsLabel.heightAnchor.constraint(equalToConstant: 25),
        ])
    }
}
