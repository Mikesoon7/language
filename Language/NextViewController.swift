//
//  NextViewController.swift
//  Language
//
//  Created by Star Lord on 08/02/2023.
//

import UIKit

class NextViewController: UIViewController {
    
    var nextButton : UIButton = {
        var button = UIButton(type: .custom)
        button.configuration = .plain()
        button.configuration?.background.backgroundColor = .lightGray
        button.configuration?.baseForegroundColor = .black
        button.layer.cornerRadius = 7
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "darkGray")?.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 1
        button.configuration?.title = "Next Card"
        
    return button
    }()
    
    var generatedImage : UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 9
        image.clipsToBounds = true
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFit
    
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
    }
    
    
    

}
