//
//  TableViewCell.swift
//  Language
//
//  Created by Star Lord on 23/03/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit
import SwiftUI
import Combine

private enum Direction1{
    case left
    case right
}

struct DataForMenuCell {
    var name: String
    var numberOfCards: Int64
}
private enum ViewConstants {
    static let overlayPoints: CGFloat = 2
    static let actionViewMultiplier: CGFloat = 0.2
}

class MenuDictionaryCVCell: UICollectionViewCell {
    private enum ViewConstants{
        static let cornerRadius: CGFloat = .cornerRadius
        static let overlayPoints: CGFloat = 2
        static let actionViewMultiplier: CGFloat = 0.2
    }
    
    static let identifier = "dictCell"
        
    private var direction: Direction1 = .right
    private var isActionActive: Bool = false
    private var isActionLooped: Bool = false
    private var isStatActive: Bool = false

    private weak var delegate: MenuCellDelegate?
    
    //MARK: - Views
    //Delete view
    //Edit
    //Share
    //MainView
    //Labels
    lazy var mainView : UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        
        view.layer.cornerRadius = .cornerRadius
        view.clipsToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var languageLabel : UILabel = {
        var label = UILabel()
        label.text = "menu.cell.name".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var cardsLabel : UILabel = {
        var label = UILabel()
        label.text = "menu.cell.number".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var languageResultLabel : UILabel = {
        var label = UILabel()
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cardsResultLabel : UILabel = {
        var label = UILabel()
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var shareView: UIView = configureCustomActions(
        imageName: "square.and.arrow.up",
        colour: .systemGray5)

    lazy var editView: UIView = configureCustomActions(
        imageName: "pencil",
        colour: .systemGray4)
    
    lazy var deleteView: UIView = configureCustomActions(
        imageName: "trash",
        colour: .systemGray3)
    
    
    //MARK: Constrait related properties
    var contentViewWidth: CGFloat = 0
    var contentViewHeight: CGFloat = 0
    
    var initialActionConstant: CGFloat = 0

    var mainViewLeadingAnchor: NSLayoutConstraint = .init()
    var mainViewInitital: CGFloat = 0
    var mainViewCurrent: CGFloat = 0
    var mainViewFinal: CGFloat = 0
    
    //Delete button
    var deleteViewLeadingAnchor: NSLayoutConstraint = .init()
    var currentDeleteConstant: CGFloat = 0
    var finalDeleteConstant: CGFloat = 0

    //Edit button
    var editViewLeadingAnchor: NSLayoutConstraint = .init()
    var currentEditConstant: CGFloat = 0
    var finalEditConstant: CGFloat = 0
    
    //SHare button
    var shareViewLeadingAnchor: NSLayoutConstraint = .init()

    //Animation final stage.
    var editViewFinalConstant: NSLayoutConstraint = .init()
    var deleteViewFinalConstant: NSLayoutConstraint = .init()
    var statViewFinalConstant: NSLayoutConstraint = .init()
        
    var initialPreparationWereMade: Bool = false
    
    private lazy var temporaryRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellDidTap(sender: )))
    
    //MARK: - Inherited Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHolderView()
        configureMainView()

        configurePanGesture()
        configureTapGesture()
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = ViewConstants.cornerRadius

    }

    required init?(coder: NSCoder) {
        fatalError("coder wasn't imported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
        shareView.layer.mask = UIView().configureActionMaskWith(size: CGSize(
            width: contentView.frame.width * 0.2 + ViewConstants.overlayPoints,
            height: contentView.frame.height), cornerRadius: .cornerRadius)
        editView.layer.mask = UIView().configureActionMaskWith(size: CGSize(
            width: contentView.frame.width * 0.2 + ViewConstants.overlayPoints,
            height: contentView.frame.height), cornerRadius: .cornerRadius)
        deleteView.layer.mask = UIView().configureActionMaskWith(size: CGSize(
            width: contentView.frame.width * 0.2 + ViewConstants.overlayPoints,
            height: contentView.frame.height), cornerRadius: .cornerRadius)
        
        
        contentViewWidth = contentView.bounds.width

        mainViewFinal = -(contentViewWidth * 0.6 - ViewConstants.cornerRadius * 3.5)

        finalDeleteConstant = contentViewWidth * 0.4 - ViewConstants.cornerRadius * 3

        finalEditConstant = contentViewWidth * 0.2 - ViewConstants.cornerRadius * 2


        editViewFinalConstant = editView.leadingAnchor.constraint(equalTo: shareView.trailingAnchor, constant: -ViewConstants.cornerRadius)
        deleteViewFinalConstant = deleteView.leadingAnchor.constraint(equalTo: editView.trailingAnchor, constant: -ViewConstants.cornerRadius)
        statViewFinalConstant = shareView.leadingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -ViewConstants.cornerRadius)
    }
    
    override func prepareForReuse() {
        guard !isActionActive else {
            activate(false)
            return
        }
    }

    
    //MARK: - Cell SetUp
    func configureCellWith(data: DataForMenuCell, delegate: MenuCellDelegate) {
        self.languageResultLabel.text = data.name
        self.cardsResultLabel.text = String(data.numberOfCards)
        self.delegate = delegate
        self.configureFonts()
    }
    
    //MARK: - HolderView SetUp
    private func configureHolderView(){
        contentView.frame = self.bounds

        contentView.backgroundColor = .clear
        contentView.addSubviews(mainView, shareView, editView, deleteView)

        contentViewWidth = contentView.bounds.width
        initialActionConstant = -ViewConstants.cornerRadius

        //Related to the holder
        mainViewFinal = -(contentViewWidth * 0.6 - ViewConstants.cornerRadius * 2)
        mainViewLeadingAnchor = mainView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor, constant: mainViewCurrent)
        
        //Related to Delete
        currentDeleteConstant = -ViewConstants.cornerRadius
        finalDeleteConstant = contentViewWidth * 0.4 - .cornerRadius * 2
        deleteViewLeadingAnchor = deleteView.leadingAnchor.constraint(
            equalTo: mainView.trailingAnchor, constant: initialActionConstant)
        
        //Related to Edit
        currentEditConstant = -ViewConstants.cornerRadius
        finalEditConstant = contentViewWidth * 0.2 - .cornerRadius * 1.5
        editViewLeadingAnchor = editView.leadingAnchor.constraint(
            equalTo: mainView.trailingAnchor, constant: initialActionConstant)
        
        //Related to Stat
        shareViewLeadingAnchor = shareView.leadingAnchor.constraint(
            equalTo: mainView.trailingAnchor, constant: initialActionConstant)
                
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(
                equalTo: contentView.topAnchor),
            mainView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor),
            mainView.widthAnchor.constraint(
                equalTo: contentView.widthAnchor),
            mainViewLeadingAnchor,
            
            
            deleteView.topAnchor.constraint(
                equalTo: mainView.topAnchor),
            deleteView.bottomAnchor.constraint(
                equalTo: mainView.bottomAnchor),
            deleteView.widthAnchor.constraint(
                equalTo: contentView.widthAnchor,
                multiplier: ViewConstants.actionViewMultiplier),
            deleteViewLeadingAnchor,
            

            editView.topAnchor.constraint(
                equalTo: mainView.topAnchor),
            editView.bottomAnchor.constraint(
                equalTo: mainView.bottomAnchor),
            editView.widthAnchor.constraint(
                equalTo: contentView.widthAnchor,
                multiplier: ViewConstants.actionViewMultiplier),
            editViewLeadingAnchor,
            
            shareView.topAnchor.constraint(
                equalTo: mainView.topAnchor),
            shareView.bottomAnchor.constraint(
                equalTo: mainView.bottomAnchor),
            shareView.widthAnchor.constraint(
                equalTo: contentView.widthAnchor,
                multiplier: ViewConstants.actionViewMultiplier),
            shareViewLeadingAnchor,
            
            ])
    }

    private func configureMainView(){
        mainView.addSubviews(languageResultLabel, languageLabel, cardsLabel, cardsResultLabel)
        
        NSLayoutConstraint.activate([
            languageLabel.topAnchor.constraint(
                equalTo: mainView.topAnchor, constant: .longInnerSpacer),
            languageLabel.leadingAnchor.constraint(
                equalTo: mainView.leadingAnchor, constant: .longInnerSpacer),
            
            cardsLabel.bottomAnchor.constraint(
                equalTo: mainView.bottomAnchor, constant: -.longInnerSpacer),
            cardsLabel.leadingAnchor.constraint(
                equalTo: mainView.leadingAnchor, constant: .longInnerSpacer),

            languageResultLabel.centerYAnchor.constraint(
                equalTo: languageLabel.centerYAnchor),
            languageResultLabel.trailingAnchor.constraint(
                equalTo: mainView.trailingAnchor, constant: -.longInnerSpacer),
            
            cardsResultLabel.centerYAnchor.constraint(
                equalTo: cardsLabel.centerYAnchor),
            cardsResultLabel.trailingAnchor.constraint(
                equalTo: mainView.trailingAnchor, constant: -.longInnerSpacer),
        ])

    }
    
    private func configureFonts(){
        self.cardsLabel.font = .selectedFont.withSize(.subtitleSize)
        self.cardsResultLabel.font = .selectedFont.withSize(.assosiatedTextSize)
        
        self.languageLabel.font = .selectedFont.withSize(.subtitleSize)
        self.languageResultLabel.font = .selectedFont.withSize(.assosiatedTextSize)

    }
    
    func configureCustomActions(imageName: String, colour: UIColor) -> UIView{
        let actionView: UIView = {
            let view = UIView()
            view.backgroundColor = colour
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        let imageView: UIImageView = {
            let view = UIImageView()
            view.image = UIImage(systemName: imageName)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.tintColor = .label
            view.contentMode = .center
            return view
        }()
        
        actionView.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: actionView.centerXAnchor, constant: ViewConstants.cornerRadius / 2).isActive = true
        imageView.centerYAnchor.constraint(equalTo: actionView.centerYAnchor).isActive = true
        
        return actionView
    }
    
    func configurePanGesture(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(viewDidPan(sender:)))
        pan.delegate = self
        mainView.addGestureRecognizer(pan)
    }
    
    func configureTapGesture(){
        let editTap = UITapGestureRecognizer(target: self, action: #selector(editViewDidTap(sender: )))
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(deleteViewDidTap(sender: )))
        let statTap = UITapGestureRecognizer(target: self, action: #selector(shareViewDidTap(sender: )))
        
        editView.addGestureRecognizer(editTap)
        deleteView.addGestureRecognizer(deleteTap)
        shareView.addGestureRecognizer(statTap)
    }

    func deactivateConstraints(){
        NSLayoutConstraint.deactivate([
            self.deleteViewLeadingAnchor,
            self.editViewLeadingAnchor,
            self.shareViewLeadingAnchor
        ])
        NSLayoutConstraint.activate([
            self.editViewFinalConstant,
            self.deleteViewFinalConstant,
            self.statViewFinalConstant
        ])
    }
    
    //Animation for swipe transition
    func activate(_ activate: Bool){
        let animation = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut){
            self.mainViewLeadingAnchor.constant = activate ? self.mainViewFinal : 0
            self.deleteViewLeadingAnchor.constant = activate ? self.finalDeleteConstant : self.initialActionConstant
            self.editViewLeadingAnchor.constant = activate ? self.finalEditConstant : self.initialActionConstant
            self.layoutIfNeeded()
        }
        
        if activate {
            mainView.addGestureRecognizer(temporaryRecognizer)
        } else {
            mainView.removeGestureRecognizer(temporaryRecognizer)
        }
        
        
        editView.isUserInteractionEnabled = activate ? true : false
        shareView.isUserInteractionEnabled = isStatActive ? true : (activate ? true : false )
        deleteView.isUserInteractionEnabled = activate ? true : false

        animation.startAnimation()
        
        isActionActive = activate
        mainViewCurrent = mainViewLeadingAnchor.constant
        currentDeleteConstant = deleteViewLeadingAnchor.constant
        currentEditConstant = editViewLeadingAnchor.constant
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGestureRecognizer.velocity(in: mainView)
            return abs(velocity.y) < abs(velocity.x)
        }
        return true
    }
    
    //MARK: - Actions
    //Panning
    @objc func viewDidPan(sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: mainView).x
        let velocity = sender.velocity(in: mainView).x
            
        let holderConstant = mainViewCurrent + translation
        let editConstant = currentEditConstant + -(translation / 3)
        let deleteConstant = currentDeleteConstant + -(translation / 1.5)
        
        direction = (0 < translation ? .right : .left)

        switch sender.state{
        case .began:
            delegate?.panningBegan(for: self)
        case .changed:
            if holderConstant >= mainViewFinal && holderConstant <= 0{
                mainViewLeadingAnchor.constant = holderConstant
                editViewLeadingAnchor.constant = editConstant
                deleteViewLeadingAnchor.constant = deleteConstant
                
                if direction == .left && holderConstant < -10{
                    isActionLooped = true
                }
            } else if holderConstant < mainViewFinal{
                self.transform = CGAffineTransform(translationX: (holderConstant + abs(mainViewFinal)) / 4, y: 0)
            } else if holderConstant > 0 && holderConstant < 100 && !isActionActive && !isActionLooped {
                self.transform = CGAffineTransform(translationX: translation / 4, y: 0)
            }
            
        case .cancelled:
            if direction == .left {
                activate(true)
            } else {
                activate(false)
            }
        default:
            if holderConstant > 0 && !isActionActive{
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self.transform = .identity
                }
            } else if holderConstant < mainViewFinal {
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self.transform = .identity
                }
            }
            if direction == .left && (holderConstant <= mainViewFinal * 0.1 || abs(velocity) > 800){
                activate(true)
            } else {
                activate(false)
            }
            isActionLooped = false
            
            delegate?.panningEnded(active: isActionActive)
        }
    }
    @objc func cellDidTap(sender: UITapGestureRecognizer){
        activate(false)
    }
    
    @objc func shareViewDidTap(sender: UITapGestureRecognizer){
        
        let point = sender.location(in: shareView)
        guard shareView.maskedViewContaintPoint(point) else {
            return
        }
        activate(false)
        delegate?.shareButtonDidTap(for: self)
    }
    
    @objc func editViewDidTap(sender: UITapGestureRecognizer){
        let point = sender.location(in: editView)
        guard editView.maskedViewContaintPoint(point) else {
            return
        }
        activate(false)
        delegate?.editButtonDidTap(for: self)

    }
    @objc func deleteViewDidTap(sender: UITapGestureRecognizer){
        let point = sender.location(in: deleteView)
        guard deleteView.maskedViewContaintPoint(point) else {
            return
        }
        activate(false)
        delegate?.deleteButtonDidTap(for: self)
    }
    //LanguageChange
    @objc func languageDidChange(sender: Any){
        languageLabel.text = LanguageChangeManager.shared.localizedString(forKey: "menu.cell.name")
        cardsLabel.text = LanguageChangeManager.shared.localizedString(forKey: "menu.cell.number")
    }

}
extension MenuDictionaryCVCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

