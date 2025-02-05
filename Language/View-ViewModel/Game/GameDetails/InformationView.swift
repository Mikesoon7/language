//
//  InformationView.swift
//  Language
//
//  Created by Star Lord on 23/08/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit

//MARK: Custom sheet controller for information presentaition.
class InformationView: UIViewController {
    
    let informationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: Inherited and initialization.
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureInformationLabel()
        configureAttributedText()
    }
    override func viewDidLayoutSubviews() {
        sheetPresentationController?.detents = [.custom(resolver: { context in
            return self.informationLabel.bounds.height * 1.5
        })]

    }
    //MARK: View properties setUp
    func configureView(){
        view.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                ? .secondarySystemBackground
                                : .systemBackground)
        self.modalPresentationStyle = .pageSheet
    }
    
    func configureAttributedText(){
        let mutableText: NSMutableAttributedString =
            .attributedMutableString(
                string: "gameDetails.information".localized,
                with: .helveticaNeueMedium,
                ofSize: 18,
                foregroundColour: .label
            )
        mutableText.append(
            .attributedString(
                string: "\n \n \n" + "gameDetails.suggestion1Part".localized,
                with: .helveticaNeueMedium,
                ofSize: 16,
                foregroundColour: .systemGray
            )
        )
        mutableText.append(
            .attributedString(
                string: "\n \n " + "gameDetails.settingsPath".localized,
                with: .helveticaNeueBold, ofSize: 18)
        )
        mutableText.append(
            .attributedString(
                string: "\n \n" + "gameDetails.suggestion2Part".localized,
                with: .helveticaNeueMedium, ofSize: 16,
                foregroundColour: .systemGray
            )
        )
        informationLabel.attributedText = mutableText
    }
    
    //MARK: Layout view subviews.
    func configureInformationLabel(){
        view.addSubview(informationLabel)
        
        NSLayoutConstraint.activate([
            informationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.05),
            informationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            informationLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews))
        
        ])
    }
    
}
