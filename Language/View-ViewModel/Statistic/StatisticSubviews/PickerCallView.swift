//
//  PickerButtonView.swift
//  Language
//
//  Created by Star Lord on 01/09/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit

class PickerCallView: UIView {
    
    //MARK: Views
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .helveticaNeue.withSize(.assosiatedTextSize)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let subtitleDateLabel: UILabel = {
        let label = UILabel()
        label.font = .helveticaNeue.withSize(.captionTextSize)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
//    //MARK: Dimensions
//    private let subviewsInset: CGFloat = 10

    
    //MARK: Inherited
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        configureTitleLabel(with: title)
        configureSubtitleLabel()
        updateSubtitleLabel(with: subtitle)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder: NSCoder) wasn't imported")
    }
    
    //MARK: Configure Subviews
    ///Layout  title label and assign text to it.
    private func configureTitleLabel(with title: String) {
        titleLabel.text = title
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(
                equalTo: centerYAnchor, constant: -(.nestedSpacer / 3)),
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .nestedSpacer),
        ])
    }
    
    ///Layout subtitle label, which represents selected time.
    private func configureSubtitleLabel() {
        addSubview(subtitleDateLabel)
        
        NSLayoutConstraint.activate([
            subtitleDateLabel.topAnchor.constraint(
                equalTo: centerYAnchor, constant: .nestedSpacer / 3),
            subtitleDateLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .nestedSpacer),
        ])
    }
    
    ///Update text value for subtitle label..
    open func updateSubtitleLabel(with text: String){
        self.subtitleDateLabel.text = text
    }
}
