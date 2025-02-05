//
//  SettingsImageCell.swift
//  Language
//
//  Created by Star Lord on 08/04/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit

//MARK: - Data type for cell
struct DataForSettingsImageCell{
    var title: String
    var isBarOnTop: Bool
    var valueChangeHandler: (AppSearchBarPosition) -> Void
}

class SettingsImageCell: UITableViewCell {
    static let identifier = "settingsImageCell"
    
    //Holds closure to send selected search bar postion
    private var selectedImage: ((AppSearchBarPosition) -> Void)?

    //MARK: Views.
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let topImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(systemName: "platter.filled.top.iphone")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    private let bottomImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .clear
        view.image = UIImage(systemName: "platter.filled.bottom.iphone")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    private let imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    //MARK: Inherited
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCellsView()
        configureCellsSubviews()
    }
    required init?(coder: NSCoder) {
        fatalError("Unable to use Coder")
    }
    
    //MARK: Settings up cells view.
    private func configureCellsView(){
        self.selectionStyle = .none
        contentView.backgroundColor = .secondarySystemBackground.withAlphaComponent(0.8)

        configureGestures()
    }
    //MARK: Configure cell with passed data.
    //Called after dequing in table view delegate.
    func configureCellWithData(_ data: DataForSettingsImageCell){
        self.titleLabel.text = data.title
        titleLabel.font = .selectedFont.withSize(17)
        topImageView.tintColor = data.isBarOnTop ? .label : .systemGray3
        bottomImageView.tintColor = data.isBarOnTop ? .systemGray3 : .label
        selectedImage = data.valueChangeHandler
    }
    //MARK: Configure subviews layout.
    private func configureCellsSubviews(){
        contentView.addSubviews(titleLabel, imageStackView)
        imageStackView.addArrangedSubviews(UIView(), topImageView, UIView(), bottomImageView, UIView())
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: topAnchor, constant: .outerSpacer),
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .outerSpacer),
            titleLabel.heightAnchor.constraint(
                equalToConstant: 20),

            imageStackView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor),
            imageStackView.leadingAnchor.constraint(
                equalTo: leadingAnchor),
            imageStackView.bottomAnchor.constraint(
                equalTo: bottomAnchor),
            imageStackView.trailingAnchor.constraint(
                equalTo: trailingAnchor),

            topImageView.heightAnchor.constraint(
                equalTo: imageStackView.heightAnchor, multiplier: 0.5),
            topImageView.widthAnchor.constraint(
                equalTo: topImageView.heightAnchor),

            bottomImageView.heightAnchor.constraint(
                equalTo: imageStackView.heightAnchor, multiplier: 0.5),
            bottomImageView.widthAnchor.constraint(
                equalTo: bottomImageView.heightAnchor),

        ])
    }
    //MARK: Gestures SetUp
    //Attached to each image.
    private func configureGestures() {
        let tapGestureLeft = UITapGestureRecognizer()
        tapGestureLeft.addTarget(self, action: #selector(imageTapped(sender:)))
        topImageView.addGestureRecognizer(tapGestureLeft)

        let tapGestureRight = UITapGestureRecognizer()
        tapGestureRight.addTarget(self, action: #selector(imageTapped(sender:)))
        bottomImageView.addGestureRecognizer(tapGestureRight)
    }
    
    @objc func imageTapped(sender: UITapGestureRecognizer){
        let tappedImageView = sender.view as? UIImageView
        if tappedImageView === topImageView {
            topImageView.tintColor = .label
            bottomImageView.tintColor = .systemGray3
            selectedImage?(.onTop)
        } else {
            topImageView.tintColor = .systemGray3
            bottomImageView.tintColor = .label
            selectedImage?(.atTheBottom)
        }
    }
}
