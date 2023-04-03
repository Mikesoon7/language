//
//  SearchVC.swift
//  Language
//
//  Created by Star Lord on 02/04/2023.
//

import UIKit

class SearchVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let label = UILabel()
        label.center = view.center
        label.text = "Come later"
        label.tintColor = .label
        label.shadowOffset = CGSize(width: 1, height: 2)
        view.addSubview(label)
    }

}
