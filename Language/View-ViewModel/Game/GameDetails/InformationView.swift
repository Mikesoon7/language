//
//  InformationView.swift
//  Language
//
//  Created by Star Lord on 23/08/2023.
//

import UIKit

//MARK: Custom sheet controller for information presentaition.
class InformationView: UIViewController {
    
    let informationLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .attributedString(
            string: "gameDetails.information".localized,
            with: .georgianItalic,
            ofSize: 18,
            foregroundColour: .label)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: Inherited and initialization.
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureInformationLabel()
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
    //MARK: Layout view subviews.
    func configureInformationLabel(){
        view.addSubview(informationLabel)
        
        NSLayoutConstraint.activate([
            informationLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.05),
            informationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            informationLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91)
        
        ])
    }
    
}
