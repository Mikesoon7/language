//
//  TableViewCell.swift
//  Language
//
//  Created by Star Lord on 23/03/2023.
//

import UIKit
import SwiftUI
import Combine

enum Direction{
    case left
    case right
}

class MenuDictionaryCell: UITableViewCell{

    private struct ViewConstants{
        static let cornerRadius = CGFloat(9)
        static let overlayPoints = CGFloat(2)
    }
    static let identifier = "dictCell"
    
    private var viewModel: StatisticCellViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    private var direction: Direction!
    private var isActionActive: Bool = false
    private var isActionLooped: Bool = false
    private var isStatActive: Bool = false

    private var statisticHostingController: UIHostingController<MenuStatisticView>!
    private weak var delegate: CustomCellDataDelegate?
    
    //MARK: - Views
    lazy var statisticView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6

        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true

        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var holderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var mainView : UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var languageLabel : UILabel = {
        var label = UILabel()
        label.attributedText = NSAttributedString(
            string: LanguageChangeManager.shared.localizedString(forKey: "tableCellName"),
            attributes: [NSAttributedString.Key.font : UIFont(name: "Georgia-BoldItalic", size: 20) ?? UIFont(),
                         NSAttributedString.Key.foregroundColor: UIColor.label])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cardsLabel : UILabel = {
        var label = UILabel()
        label.attributedText = NSAttributedString().fontWithString(
            string: LanguageChangeManager.shared.localizedString(forKey: "tableCellNumberOfCards"),
            bold: true,
            size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var languageResultLabel : UILabel = {
        var label = UILabel()
        label.font = UIFont(name: .SelectedFonts.georigaItalic.rawValue, size: 15)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cardsResultLabel : UILabel = {
        var label = UILabel()
        label.font = UIFont(name: .SelectedFonts.georigaItalic.rawValue, size: 15)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var statView: UIView = configureCustomActions(imageName: "chart.bar",
                                                       colour: .systemGray5)

    lazy var editView: UIView = configureCustomActions(imageName: "pencil",
                                                       colour: .systemGray4)
    
    lazy var deleteView: UIView = configureCustomActions(imageName: "trash",
                                                         colour: .systemGray3)
    
    
    //MARK: Constrait related properties
    let cornerRadius: CGFloat = 9

    var contentViewWidth: CGFloat!
    var contentViewHeight: CGFloat!
    
    var holderViewLeadingAnchor: NSLayoutConstraint!
    var initialHolderConstant: CGFloat!
    var currentHolderConstant: CGFloat!
    var finalHolderConstant: CGFloat!
    
    var deleteViewLeadingAnchor: NSLayoutConstraint!
    var initialActionConstant: CGFloat!
    var currentDeleteConstant: CGFloat!
    var finalDeleteConstant: CGFloat!

    var editViewLeadingAnchor: NSLayoutConstraint!
    var initialEditConstant: CGFloat!
    var currentEditConstant: CGFloat!
    var finalEditConstant: CGFloat!
        
    var statViewLeadingAnchor: NSLayoutConstraint!
    var initilStatConstant: CGFloat!
    var finalStatConstant: CGFloat!
    
    var statViewInitialLeadingAnchor: NSLayoutConstraint!
    var statViewFinalLeadingAnchor: NSLayoutConstraint!
    
    var statViewWidthAnchor: NSLayoutConstraint!
    var statViewInitialWidth: CGFloat!
    var statViewFinalWifth: CGFloat!
    
    private lazy var temoraryRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellDidTap(sender: )))
    //MARK: - Inherited Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHolderView()
        configureMainView()

        configurePanGesture()
        configureTapGesture()
        
        contentView.backgroundColor = .clear
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("coder wasn't imported")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        statView.layer.mask = UIView().configureActionMaskWith(size: CGSize(
            width: contentView.frame.width * 0.2 + ViewConstants.overlayPoints,
            height: contentView.frame.height), cornerRadius: cornerRadius)
        editView.layer.mask = UIView().configureActionMaskWith(size: CGSize(
            width: contentView.frame.width * 0.2 + ViewConstants.overlayPoints,
            height: contentView.frame.height), cornerRadius: cornerRadius)
        deleteView.layer.mask = UIView().configureActionMaskWith(size: CGSize(
            width: contentView.frame.width * 0.2 + ViewConstants.overlayPoints,
            height: contentView.frame.height), cornerRadius: cornerRadius)
    }
    
    override func prepareForReuse() {
        if isStatActive {
            animateTransitionToStat(activate: false)
        }
        guard !isActionActive else {
            activate(false)
            return
        }
    }
    //MARK: - Cell SetUp
    func configureCellWith(viewModel: StatisticCellViewModel, delegate: CustomCellDataDelegate) {
        self.languageResultLabel.text = viewModel.dictionary.language
        self.cardsResultLabel.text = String(viewModel.dictionary.numberOfCards)
        self.viewModel = viewModel
        self.delegate = delegate
        self.bind()
    }
    
    func bind(){
        viewModel.output
            .sink { output in
                switch output {
                case .error(let error):
                    print(error.localizedDescription)
                case .data(let data):
                    self.configureChartWith(data: data)
                }
            }
            .store(in: &cancellables)
    }
    //MARK: - HolderView SetUp
    func configureHolderView(){
        contentView.addSubview(holderView)
        holderView.addSubviews(mainView, statisticView, statView, editView, deleteView)

        contentViewWidth = contentView.frame.width
        contentViewHeight = contentView.frame.height
        initialActionConstant = -cornerRadius

        //Related to the holder
        initialHolderConstant = 0
        currentHolderConstant = 0
        finalHolderConstant = -(contentViewWidth * 0.6 - cornerRadius * 2)
        holderViewLeadingAnchor = holderView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor, constant: currentHolderConstant)
        
        //Related to Delete
        currentDeleteConstant = -cornerRadius
        finalDeleteConstant = contentViewWidth * 0.4 - cornerRadius * 2
        deleteViewLeadingAnchor = deleteView.leadingAnchor.constraint(
            equalTo: mainView.trailingAnchor, constant: initialActionConstant)
        
        //Related to Edit
        currentEditConstant = -cornerRadius
        finalEditConstant = contentViewWidth * 0.2 - cornerRadius * 1.5
        editViewLeadingAnchor = editView.leadingAnchor.constraint(
            equalTo: mainView.trailingAnchor, constant: initialActionConstant)
        
        finalStatConstant = -(contentViewWidth * 0.2) - cornerRadius * 0.5
        statViewLeadingAnchor = statView.leadingAnchor.constraint(
            equalTo: mainView.trailingAnchor, constant: initialActionConstant)
        
        statViewInitialWidth = -contentViewWidth
        statViewFinalWifth = 0
        statViewWidthAnchor = statisticView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: statViewInitialWidth)
        
        statViewInitialLeadingAnchor = statisticView.leadingAnchor.constraint(equalTo: statView.leadingAnchor)
        statViewFinalLeadingAnchor = statisticView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        
        NSLayoutConstraint.activate([
            holderViewLeadingAnchor,
            holderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            holderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            holderView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.6),
            
            mainView.topAnchor.constraint(equalTo: holderView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: holderView.leadingAnchor),
            mainView.bottomAnchor.constraint(equalTo: holderView.bottomAnchor),
            mainView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            
            deleteView.topAnchor.constraint(equalTo: mainView.topAnchor),
            deleteViewLeadingAnchor,
            deleteView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            deleteView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),

            editView.topAnchor.constraint(equalTo: mainView.topAnchor),
            editViewLeadingAnchor,
            editView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            editView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
            
            statView.topAnchor.constraint(equalTo: mainView.topAnchor),
            statViewLeadingAnchor,
            statView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            statView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
            
            statViewInitialLeadingAnchor,
            statisticView.topAnchor.constraint(equalTo: statView.topAnchor),
            statisticView.bottomAnchor.constraint(equalTo: statView.bottomAnchor),
            statisticView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8, constant: ViewConstants.cornerRadius + ViewConstants.overlayPoints)
            ])
    }
    func configureMainView(){
        mainView.addSubviews(languageResultLabel, languageLabel, cardsLabel, cardsResultLabel)
        
        NSLayoutConstraint.activate([
            languageLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 15),
            languageLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 15),
            languageLabel.heightAnchor.constraint(equalToConstant: 25),
            
            cardsLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 64),
            cardsLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 15),
            cardsLabel.heightAnchor.constraint(equalToConstant: 25),

            languageResultLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 15),
            languageResultLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -15),
            languageResultLabel.heightAnchor.constraint(equalToConstant: 25),
            
            cardsResultLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 64),
            cardsResultLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -15),
            cardsResultLabel.heightAnchor.constraint(equalToConstant: 25)
        ])

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
        
        imageView.centerXAnchor.constraint(equalTo: actionView.centerXAnchor, constant: cornerRadius / 2).isActive = true
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
        let statTap = UITapGestureRecognizer(target: self, action: #selector(statViewDidTap(sender: )))
        
        editView.addGestureRecognizer(editTap)
        deleteView.addGestureRecognizer(deleteTap)
        statView.addGestureRecognizer(statTap)
    }
    func configureChartWith(data: [WeekLog] ){
        statisticHostingController = UIHostingController(rootView: MenuStatisticView(data: data, width: contentViewWidth * 0.8, height: contentViewHeight ))
        guard let statiscticCharts = statisticHostingController?.view else { return }
        statiscticCharts.alpha = 0
        statiscticCharts.backgroundColor = .clear
        statiscticCharts.translatesAutoresizingMaskIntoConstraints = false
        statisticView.addSubview(statiscticCharts)
        
        NSLayoutConstraint.activate([
            statiscticCharts.centerYAnchor.constraint(equalTo: statisticView.centerYAnchor),
            statiscticCharts.heightAnchor.constraint(equalTo: statisticView.heightAnchor),
            statiscticCharts.centerXAnchor.constraint(equalTo: statisticView.centerXAnchor),
            statiscticCharts.widthAnchor.constraint(equalTo: statisticView.widthAnchor)
        ])
        UIView.animate(withDuration: 0.3) {
            statiscticCharts.alpha = 1
        }
    }
    func animateTransitionToStat(activate: Bool){
        if activate {
            self.viewModel.fetchDataForStatisticCell()
        } else {
            self.statisticHostingController?.view.removeFromSuperview()
        }
        
        let animation = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            self.statViewLeadingAnchor.constant = activate ? self.finalStatConstant : self.initialActionConstant
            
            self.statViewInitialLeadingAnchor.isActive = !activate
            self.statViewFinalLeadingAnchor.isActive = activate
            self.layoutIfNeeded()

       
        }
        self.activate(!activate)
        animation.startAnimation()
    }
    
    //Animation for swipe transition
    func activate(_ activate: Bool){
        let animation = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut){
            self.holderViewLeadingAnchor.constant = activate ? self.finalHolderConstant : 0
            self.deleteViewLeadingAnchor.constant = activate ? self.finalDeleteConstant : self.initialActionConstant
            self.editViewLeadingAnchor.constant = activate ? self.finalEditConstant : self.initialActionConstant
            self.layoutIfNeeded()
        }
        
        if activate {
            mainView.addGestureRecognizer(temoraryRecognizer)
        } else {
            mainView.removeGestureRecognizer(temoraryRecognizer)
        }
        
        editView.isUserInteractionEnabled = activate ? true : false
        statView.isUserInteractionEnabled = isStatActive ? true : (activate ? true : false )
        deleteView.isUserInteractionEnabled = activate ? true : false

        animation.startAnimation()
        
        isActionActive = activate
        currentHolderConstant = holderViewLeadingAnchor.constant
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
        
        let holderConstant = currentHolderConstant + translation
        let editConstant = currentEditConstant + -(translation / 3)
        let deleteConstant = currentDeleteConstant + -(translation / 1.5)
//        let actionConstant = currentDeleteConstant + -(translation / 2)
        
        direction = (0 < translation ? .right : .left)

        switch sender.state{
        case .began:
            delegate?.panningBegan(for: self)
        case .changed:
            if holderConstant >= finalHolderConstant && holderConstant <= 0{
                holderViewLeadingAnchor.constant = holderConstant
                editViewLeadingAnchor.constant = editConstant
                deleteViewLeadingAnchor.constant = deleteConstant
                
                if direction == .left && holderConstant < -10{
                    isActionLooped = true
                }
            } else if holderConstant < finalHolderConstant{
                self.transform = CGAffineTransform(translationX: (holderConstant + abs(finalHolderConstant)) / 4, y: 0)
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
            } else if holderConstant < finalHolderConstant {
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self.transform = .identity
                }
            }
            if direction == .left && (holderConstant <= finalHolderConstant * 0.1 || abs(velocity) > 800){
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
    @objc func statViewDidTap(sender: UITapGestureRecognizer){
        let point = sender.location(in: statView)
        guard statView.maskedViewContaintPoint(point) else {
            return
        }
        self.isStatActive.toggle()
        self.animateTransitionToStat(activate: isStatActive)
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
        languageLabel.text = LanguageChangeManager.shared.localizedString(forKey: "tableCellName")
        cardsLabel.text = LanguageChangeManager.shared.localizedString(forKey: "tableCellNumberOfCards")
    }
}
//private
class CustomActionView: UIView{
    //MARK: Views
    var titleFrontView: UIView
    
    lazy var statView: UIView = configureCustomActions(
        imageName: "chart.bar",
        colour: .systemGray5)
    lazy var editView: UIView = configureCustomActions(
        imageName: "pencil",
        colour: .systemGray4)
    lazy var deleteView: UIView = configureCustomActions(
        imageName: "trash",
        colour: .systemGray3)
    
    //MARK: Dimentions
    private let cornerRadius: CGFloat = 9
    private let overlayPoints: CGFloat = 2
    private let actionButtonWidthRatio: CGFloat = 0.2
    
    //MARK: Constants

    
    init(frontView: UIView){
        self.titleFrontView = frontView
        super.init(frame: .zero)
        configureView()
    }
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported.")
    }
    
    private func configureView(){
        backgroundColor = .clear
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    func configureMasks(){
        statView.layer.mask = UIView().configureActionMaskWith(size: CGSize(
            width: self.frame.width * 0.2 + overlayPoints,
            height: self.frame.height), cornerRadius: cornerRadius)
        editView.layer.mask = UIView().configureActionMaskWith(size: CGSize(
            width: self.frame.width * 0.2 + overlayPoints,
            height: self.frame.height), cornerRadius: cornerRadius)
        deleteView.layer.mask = UIView().configureActionMaskWith(size: CGSize(
            width: self.frame.width * 0.2 + overlayPoints,
            height: self.frame.height), cornerRadius: cornerRadius)
    }
    
        
    private func configureCustomActions(imageName: String, colour: UIColor) -> UIView{
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
        
        imageView.centerXAnchor.constraint(equalTo: actionView.centerXAnchor, constant: 9 / 2).isActive = true
        imageView.centerYAnchor.constraint(equalTo: actionView.centerYAnchor).isActive = true
        
        return actionView
    }
    var contentViewWidth: CGFloat!
    var contentViewHeight: CGFloat!
    
    var holderViewLeadingAnchor: NSLayoutConstraint!
    var initialHolderConstant: CGFloat!
    var currentHolderConstant: CGFloat!
    var finalHolderConstant: CGFloat!
    
    var deleteViewLeadingAnchor: NSLayoutConstraint!
    var initialActionConstant: CGFloat!
    var currentDeleteConstant: CGFloat!
    var finalDeleteConstant: CGFloat!

    var editViewLeadingAnchor: NSLayoutConstraint!
    var initialEditConstant: CGFloat!
    var currentEditConstant: CGFloat!
    var finalEditConstant: CGFloat!
        
    var statViewLeadingAnchor: NSLayoutConstraint!
    var initilStatConstant: CGFloat!
    var finalStatConstant: CGFloat!
    
    var statViewInitialLeadingAnchor: NSLayoutConstraint!
    var statViewFinalLeadingAnchor: NSLayoutConstraint!
    
    var statViewWidthAnchor: NSLayoutConstraint!
    var statViewInitialWidth: CGFloat!
    var statViewFinalWifth: CGFloat!
    
    private func configureSubviews(){
        self.addSubviews(deleteView, editView, statView, titleFrontView)
        
        NSLayoutConstraint.activate([
            titleFrontView.topAnchor.constraint(equalTo: topAnchor),
            titleFrontView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleFrontView.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleFrontView.topAnchor.constraint(equalTo: topAnchor),

            
            
        ])
    }

//    func configureHolderView(){
//        contentView.addSubview(holderView)
//        holderView.addSubviews(mainView, statisticView, statView, editView, deleteView)
//
//        contentViewWidth = contentView.frame.width
//        contentViewHeight = contentView.frame.height
//        initialActionConstant = -cornerRadius
//
//        //Related to the holder
//        initialHolderConstant = 0
//        currentHolderConstant = 0
//        finalHolderConstant = -(contentViewWidth * 0.6 - cornerRadius * 2)
//        holderViewLeadingAnchor = holderView.leadingAnchor.constraint(
//            equalTo: contentView.leadingAnchor, constant: currentHolderConstant)
//
//        //Related to Delete
//        currentDeleteConstant = -cornerRadius
//        finalDeleteConstant = contentViewWidth * 0.4 - cornerRadius * 2
//        deleteViewLeadingAnchor = deleteView.leadingAnchor.constraint(
//            equalTo: mainView.trailingAnchor, constant: initialActionConstant)
//
//        //Related to Edit
//        currentEditConstant = -cornerRadius
//        finalEditConstant = contentViewWidth * 0.2 - cornerRadius * 1.5
//        editViewLeadingAnchor = editView.leadingAnchor.constraint(
//            equalTo: mainView.trailingAnchor, constant: initialActionConstant)
//
//        finalStatConstant = -(contentViewWidth * 0.2) - cornerRadius * 0.5
//        statViewLeadingAnchor = statView.leadingAnchor.constraint(
//            equalTo: mainView.trailingAnchor, constant: initialActionConstant)
//
//        statViewInitialWidth = -contentViewWidth
//        statViewFinalWifth = 0
//        statViewWidthAnchor = statisticView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: statViewInitialWidth)
//
//        statViewInitialLeadingAnchor = statisticView.leadingAnchor.constraint(equalTo: statView.leadingAnchor)
//        statViewFinalLeadingAnchor = statisticView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
//
//        NSLayoutConstraint.activate([
//            holderViewLeadingAnchor,
//            holderView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            holderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            holderView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.6),
//
//            mainView.topAnchor.constraint(equalTo: holderView.topAnchor),
//            mainView.leadingAnchor.constraint(equalTo: holderView.leadingAnchor),
//            mainView.bottomAnchor.constraint(equalTo: holderView.bottomAnchor),
//            mainView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
//
//            deleteView.topAnchor.constraint(equalTo: mainView.topAnchor),
//            deleteViewLeadingAnchor,
//            deleteView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
//            deleteView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
//
//            editView.topAnchor.constraint(equalTo: mainView.topAnchor),
//            editViewLeadingAnchor,
//            editView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
//            editView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
//
//            statView.topAnchor.constraint(equalTo: mainView.topAnchor),
//            statViewLeadingAnchor,
//            statView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
//            statView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
//
//            statViewInitialLeadingAnchor,
//            statisticView.topAnchor.constraint(equalTo: statView.topAnchor),
//            statisticView.bottomAnchor.constraint(equalTo: statView.bottomAnchor),
//            statisticView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8, constant: ViewConstants.cornerRadius + ViewConstants.overlayPoints)
//            ])
//    }
//    func configureMainView(){
//        mainView.addSubviews(languageResultLabel, languageLabel, cardsLabel, cardsResultLabel)
//
//        NSLayoutConstraint.activate([
//            languageLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 15),
//            languageLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 15),
//            languageLabel.heightAnchor.constraint(equalToConstant: 25),
//
//            cardsLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 64),
//            cardsLabel.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 15),
//            cardsLabel.heightAnchor.constraint(equalToConstant: 25),
//
//            languageResultLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 15),
//            languageResultLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -15),
//            languageResultLabel.heightAnchor.constraint(equalToConstant: 25),
//
//            cardsResultLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 64),
//            cardsResultLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -15),
//            cardsResultLabel.heightAnchor.constraint(equalToConstant: 25)
//        ])
//
//    }
//
}
