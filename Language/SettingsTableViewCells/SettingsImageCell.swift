//
//  SettingsImageCell.swift
//  Language
//
//  Created by Star Lord on 08/04/2023.
//

import UIKit

class SettingsImageCell: UITableViewCell {
    let identifier = "settingsImageCell"
    
    let view : UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6.withAlphaComponent(0.8)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let leftImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.tintColor = .white
        view.image = UIImage(systemName: "platter.filled.top.iphone")
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let rightImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.tintColor = .gray
        view.contentMode = .scaleAspectFill
        view.image = UIImage(systemName: "platter.filled.bottom.iphone")
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var imageStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [UIView(), leftImageView, UIView(), rightImageView, UIView()])
        stackView.backgroundColor = .systemGray6.withAlphaComponent(0.8)
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        cellViewCustomization()
    }
    required init?(coder: NSCoder) {
        fatalError("Unable to use Coder")
    }
    func cellViewCustomization(){
        contentView.addSubview(view)
        view.addSubviews(label, imageStackView)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            label.heightAnchor.constraint(equalToConstant: 20),

            imageStackView.topAnchor.constraint(equalTo: label.bottomAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            leftImageView.heightAnchor.constraint(equalTo: imageStackView.heightAnchor, multiplier: 0.5),
            leftImageView.widthAnchor.constraint(equalTo: leftImageView.heightAnchor),

            rightImageView.heightAnchor.constraint(equalTo: imageStackView.heightAnchor, multiplier: 0.5),
            rightImageView.widthAnchor.constraint(equalTo: rightImageView.heightAnchor),

        ])
        gestures()
    }
    
    func gestures() {
        let tapGestureLeft = UITapGestureRecognizer()
        tapGestureLeft.addTarget(self, action: #selector(imageTapped(sender:)))
        leftImageView.addGestureRecognizer(tapGestureLeft)
        
        let tapGestureRight = UITapGestureRecognizer()
        tapGestureRight.addTarget(self, action: #selector(imageTapped(sender:)))
        rightImageView.addGestureRecognizer(tapGestureRight)
    }

    @objc func imageTapped(sender: UITapGestureRecognizer){
        let tappedImageView = sender.view as? UIImageView
        
        if tappedImageView === leftImageView {
            leftImageView.tintColor = .white
            rightImageView.tintColor = .gray
            print("left")
        } else {
            leftImageView.tintColor = .gray
            rightImageView.tintColor = .white
            print("right")
        }
        print(contentView.bounds)
        print(imageStackView.bounds)
        print(leftImageView.bounds)
        print(rightImageView.bounds)

        
    }
    
}
