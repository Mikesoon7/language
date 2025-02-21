//
//  SearchViewHeaderCell.swift
//  Learny
//
//  Created by Star Lord on 30/01/2025.
//
//  REFACTORING STATE: CHECKED

import UIKit


class DictionaryHeaderView: UICollectionReusableView {
    static let headerIdentifier = "FilterHeaderView"
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    //MARK: Inherited
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCellsSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
        
    //MARK: Configure cell with passed data.
    func configureCellWithData(_ data: String){
        label.text = data
        label.font = .selectedFont.withSize(.subtitleSize)
    }
    
    //MARK: Configure subviews layout.
    func configureCellsSubviews(){
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .longInnerSpacer),
            label.heightAnchor.constraint(equalToConstant: .genericButtonHeight),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
