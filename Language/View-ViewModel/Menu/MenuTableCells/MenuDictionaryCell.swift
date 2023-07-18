//
//  TableViewCell.swift
//  Language
//
//  Created by Star Lord on 23/03/2023.
//

import UIKit
import SwiftUI

enum Direction{
    case left
    case right
}

class MenuDictionaryCell: UITableViewCell{

    private struct ViewConstants{
        static let cornerRadius = CGFloat(9)
//        static let offset = CGFloat(10) // due to the concavity of action buttons we use offset.
        static let overlayPoints = CGFloat(2)
    }
    static let identifier = "dictCell"
    
    var direction: Direction!
    var isActionActive: Bool = false
    var isActionLooped: Bool = false
    
    var statiscticCharts: UIView!
    
    var delegate: CustomCellDataDelegate!
    var isStatActive: Bool = false
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
        
        statView.layer.mask = configureMaskFor(size: CGSize(
            width: contentView.frame.width * 0.2 + ViewConstants.overlayPoints,
            height: contentView.frame.height))
        editView.layer.mask = configureMaskFor(size: CGSize(
            width: contentView.frame.width * 0.2 + ViewConstants.overlayPoints,
            height: contentView.frame.height))
        deleteView.layer.mask = configureMaskFor(size: CGSize(
            width: contentView.frame.width * 0.2 + ViewConstants.overlayPoints,
            height: contentView.frame.height))
    }
    override func prepareForReuse() {
        guard !isActionActive else {
            activate(false)
            return
        }
    }
    //MARK: - Cell SetUp
    func configureCellWith(_ dictionary: DictionariesEntity, delegate: CustomCellDataDelegate){
        self.languageResultLabel.text = dictionary.language
        self.cardsResultLabel.text = String(dictionary.numberOfCards)
        self.delegate = delegate
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
//            statViewWidthAnchor
            statisticView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8, constant: ViewConstants.cornerRadius + ViewConstants.overlayPoints)
            ])
//        addChart()
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
    
    func configureMaskFor(size: CGSize) -> CAShapeLayer{
        let cornerRadius: CGFloat = cornerRadius

        let bezierPath = UIBezierPath()
        let startPoint = CGPoint(x: 0, y: 0)
        bezierPath.move(to: startPoint)

        let point1 = CGPoint(x: size.width - cornerRadius, y: 0)
        bezierPath.addLine(to: point1)
        bezierPath.addArc(withCenter: CGPoint(x: point1.x, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat(Double.pi / 2 * 3), endAngle: 0, clockwise: true)

        let point2 = CGPoint(x: size.width, y: size.height - cornerRadius)
        bezierPath.addLine(to: point2)
        bezierPath.addArc(withCenter: CGPoint(x: point1.x, y: point2.y), radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)


        let point3 = CGPoint(x: 0, y: size.height)
        bezierPath.addLine(to: point3)
        bezierPath.addArc(withCenter: CGPoint(x: point3.x, y: point3.y - cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi / 2 , endAngle: 0, clockwise: false)

        let point4 = CGPoint(x: cornerRadius, y: cornerRadius)
        bezierPath.addLine(to: point4)
        bezierPath.addArc(withCenter: CGPoint(x: 0, y: cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi / 2 * 3 , clockwise: false)

        bezierPath.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        return shapeLayer
    }

    func configurePanGesture(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(viewDidPan(sender:)))
        pan.delegate = self
        mainView.addGestureRecognizer(pan)
    }
    func configureTapGesture(){
        let editTap = UITapGestureRecognizer(target: self, action: #selector(viewDidTap(sender: )))
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(viewDidTap(sender: )))
        let statTap = UITapGestureRecognizer(target: self, action: #selector(statDidTap(sender: )))
        
        editView.addGestureRecognizer(editTap)
        deleteView.addGestureRecognizer(deleteTap)
        statView.addGestureRecognizer(statTap)
    }
    func launchHintAnimation(){
        let anim1 = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.transform = CGAffineTransform(translationX: 35, y: 0)
        }
        anim1.addCompletion { _ in
            UIView.animate(withDuration: 0.4, delay: 0) {
                self.transform = .identity
            }
            let anim2 = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut){
                self.holderViewLeadingAnchor.constant = self.finalHolderConstant
                self.deleteViewLeadingAnchor.constant = self.finalDeleteConstant
                self.transform = CGAffineTransform(translationX: -20, y: 0)
                self.layoutIfNeeded()
            }
            anim2.addCompletion { _ in
                let anim3 = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut){
                    self.transform = .identity
                    self.holderViewLeadingAnchor.constant = self.initialHolderConstant
                    self.deleteViewLeadingAnchor.constant = self.initialActionConstant
                    self.layoutIfNeeded()
                }
                anim3.startAnimation(afterDelay: 0.55)
            }
            anim2.startAnimation()
        }
        anim1.startAnimation(afterDelay: 0.5)
    }
    func addChart(){
        let view = UIHostingController(rootView: BarChart(data: fakeData, width: contentViewWidth * 0.8, height: contentViewHeight ))
        guard let statiscticCharts = view.view else { return }
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
        let animation = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            self.statViewLeadingAnchor.constant = activate ? self.finalStatConstant : self.initialActionConstant
            self.layoutIfNeeded()
            UIView.animate(withDuration: 0.4, delay: 0.2) {
//                self.statViewWidthAnchor.constant = activate ? self.statViewFinalWifth : self.statViewInitialWidth
                self.statViewInitialLeadingAnchor.isActive = !activate
                self.statViewFinalLeadingAnchor.isActive = activate
                self.layoutIfNeeded()
            }
        }
        self.activate(!activate)
        animation.addCompletion { _ in
            if activate {
                self.addChart()
            } else {
                self.statiscticCharts?.removeFromSuperview()
            }
        }
        animation.startAnimation()
//        UIView.animate(withDuration: 0.5, delay: 0) {
//            self.statViewLeadingAnchor.constant = activate ? self.finalStatConstant : self.initialActionConstant
//            self.layoutIfNeeded()
//            UIView.animate(withDuration: 0.4, delay: 0.2) {
//                self.statViewWidthAnchor.constant = activate ? self.statViewFinalWifth : self.statViewInitialWidth
//                self.layoutIfNeeded()
//            }
//        }
    }
    //Animation for swipe transition
    func activate(_ activate: Bool){
        let animation = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut){
            self.holderViewLeadingAnchor.constant = activate ? self.finalHolderConstant : 0
            self.deleteViewLeadingAnchor.constant = activate ? self.finalDeleteConstant : self.initialActionConstant
            self.editViewLeadingAnchor.constant = activate ? self.finalEditConstant : self.initialActionConstant
            self.layoutIfNeeded()
            self.isActionActive = activate
        }
                
        animation.startAnimation()
        
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
            delegate.panningBegan(for: self)
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
            
            delegate.panningEnded(active: isActionActive)
        }
    }
    @objc func statDidTap(sender: Any){
        self.isStatActive.toggle()
        self.animateTransitionToStat(activate: isStatActive)
    }
    @objc func viewDidTap(sender: UITapGestureRecognizer){
        guard let view = sender.view else { return }
        if view == deleteView{
            activate(false)
            delegate.deleteButtonDidTap(for: self)

        } else {
            activate(false)
            delegate.editButtonDidTap(for: self)
        }
        
    }
    //LanguageChange
    @objc func languageDidChange(sender: Any){
        languageLabel.text = LanguageChangeManager.shared.localizedString(forKey: "tableCellName")
        cardsLabel.text = LanguageChangeManager.shared.localizedString(forKey: "tableCellNumberOfCards")
    }
}
let fakeData = [
    FakeLogs(date: "10/10/2001", accessCount: 1),
    FakeLogs(date: "11/10/2001", accessCount: 2),
    FakeLogs(date: "12/10/2001", accessCount: 3),
    FakeLogs(date: "13/10/2001", accessCount: 4),
    FakeLogs(date: "14/10/2001", accessCount: 5),
    FakeLogs(date: "15/10/2001", accessCount: 6),
    FakeLogs(date: "16/10/2001", accessCount: 7),
    FakeLogs(date: "17/10/2001", accessCount: 8),
    FakeLogs(date: "18/10/2001", accessCount: 9),
    FakeLogs(date: "19/10/2001", accessCount: 10),
    FakeLogs(date: "20/10/2001", accessCount: 11),
    FakeLogs(date: "21/10/2001", accessCount: 12),
    FakeLogs(date: "22/10/2001", accessCount: 13),
    FakeLogs(date: "23/10/2001", accessCount: 14),
    FakeLogs(date: "24/10/2001", accessCount: 15),
    FakeLogs(date: "25/10/2001", accessCount: 18),
    FakeLogs(date: "10/11/2001", accessCount: 8),
    FakeLogs(date: "11/11/2001", accessCount: 8),
    FakeLogs(date: "12/11/2001", accessCount: 8),
    FakeLogs(date: "13/11/2001", accessCount: 8),
    FakeLogs(date: "14/11/2001", accessCount: 8),
    FakeLogs(date: "15/11/2001", accessCount: 8),
    FakeLogs(date: "16/11/2001", accessCount: 8),
    FakeLogs(date: "17/11/2001", accessCount: 8),
    FakeLogs(date: "18/11/2001", accessCount: 8),
    FakeLogs(date: "19/11/2001", accessCount: 18),
    FakeLogs(date: "20/11/2001", accessCount: 18),
    FakeLogs(date: "21/11/2001", accessCount: 18),
    FakeLogs(date: "22/11/2001", accessCount: 18),
    FakeLogs(date: "23/11/2001", accessCount: 18),
    FakeLogs(date: "24/11/2001", accessCount: 18),
    FakeLogs(date: "25/11/2001", accessCount: 18)
]

