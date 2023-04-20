//
//  SettingsImageCell.swift
//  Language
//
//  Created by Star Lord on 08/04/2023.
//

import UIKit

class SettingsImageCell: UITableViewCell {
    let identifier = "settingsImageCell"

    let segmentControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.backgroundColor = .clear
        control.insertSegment(with: UIImage(systemName: "platter.filled.top.iphone"), at: 0, animated: true)
        control.insertSegment(with: UIImage(systemName: "platter.filled.bottom.iphone"), at: 1, animated: true)
        
        return control
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        segmentCustomization()
    }
    required init?(coder: NSCoder) {
        fatalError("Unable to use Coder")
    }
    
    func segmentCustomization(){
        self.addSubview(segmentControl)
        
        NSLayoutConstraint.activate([
//            segmentControl.heightAnchor.constraint(equalToConstant: 100),
//            segmentControl.widthAnchor.constraint(equalToConstant: 300),
            segmentControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            segmentControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
}
