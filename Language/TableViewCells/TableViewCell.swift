//
//  TableViewCell.swift
//  Language
//
//  Created by Star Lord on 23/03/2023.
//

import UIKit

class TableViewCell: UITableViewCell{

    let identifier = "dictCell"
    var indexPath: IndexPath!
    
    var isActionActive: Bool = false
    var isActionLooped: Bool = false
    
//    var delegate: CustomCellDataDelegate!
    
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
        label.font = UIFont(name: "Georgia-Italic", size: 15)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cardsResultLabel : UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Georgia-Italic", size: 15)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var editView: UIView = configureCustomActions(imageName: "pencil",
                                                       colour: .systemGray5)
    
    lazy var deleteView: UIView = configureCustomActions(imageName: "trash",
                                                         colour: .systemGray4)
    
    //MARK: - Dimensions
    let cornerRadius: CGFloat = 9

    var contentViewWidth: CGFloat!
    
    var holderViewLeadingAnchor: NSLayoutConstraint!
    var initialHolderConstant: CGFloat!
    var currentHolderConstant: CGFloat!
    var finalHolderConstant: CGFloat!
    
    var deleteViewLeadingAnchor: NSLayoutConstraint!
    var initialActionConstant: CGFloat!
    var currentActionConstant: CGFloat!
    var finalActionConstant: CGFloat!

        
//MARK: - Prepare Func
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHolderView()
        configureMainView()

        configurePanGesture()

        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
        
    }
    required init?(coder: NSCoder) {
        fatalError("coder wasn't imported")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        editView.layer.mask = configureMaskFor(size: CGSize(width: contentView.frame.width * 0.2 , height: contentView.frame.height))
        deleteView.layer.mask = configureMaskFor(size: CGSize(width: contentView.frame.width * 0.2 , height: contentView.frame.height))
        
    }
    
    func configureHolderView(){
        contentView.addSubview(holderView)
        holderView.addSubviews(mainView, editView, deleteView)

        contentViewWidth = contentView.frame.width
        
        //Related to the holder
        initialHolderConstant = 0
        currentHolderConstant = 0
        finalHolderConstant = -(contentViewWidth * 0.4 - cornerRadius)
        holderViewLeadingAnchor = holderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: currentHolderConstant)
        
        //Related to the Action
        initialActionConstant = -cornerRadius
        currentActionConstant = -cornerRadius
        finalActionConstant = contentViewWidth * 0.2 - cornerRadius * 1.5
        deleteViewLeadingAnchor = deleteView.leadingAnchor.constraint(equalTo: mainView.trailingAnchor,
                                                                      constant: -cornerRadius)
        
        NSLayoutConstraint.activate([
            holderViewLeadingAnchor,
            holderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            holderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            holderView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.4),
            
            mainView.topAnchor.constraint(equalTo: holderView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: holderView.leadingAnchor),
            mainView.bottomAnchor.constraint(equalTo: holderView.bottomAnchor),
            mainView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            
            deleteView.topAnchor.constraint(equalTo: mainView.topAnchor),
            deleteViewLeadingAnchor,
            deleteView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            deleteView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),

            editView.topAnchor.constraint(equalTo: mainView.topAnchor),
            editView.leadingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -cornerRadius),
            editView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            editView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2)
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
        
        imageView.centerXAnchor.constraint(equalTo: actionView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: actionView.centerYAnchor).isActive = true
        
        return actionView
    }
    
    func configureMaskFor(size: CGSize) -> CAShapeLayer{
        let cornerRadius: CGFloat = 9

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
        let pan = UIPanGestureRecognizer(target: self, action: #selector(viewDidPan(sender: )))
        mainView.addGestureRecognizer(pan)
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
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
                self.deleteViewLeadingAnchor.constant = self.finalActionConstant
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
    
    //Animation for swipe transition
    func activate(_ activate: Bool){
        let animation = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut){
            self.holderViewLeadingAnchor.constant = activate ? self.finalHolderConstant : 0
            self.deleteViewLeadingAnchor.constant = activate ? self.finalActionConstant : -self.cornerRadius
            self.layoutIfNeeded()
            self.isActionActive = activate
        }
        animation.startAnimation()
    }
    //MARK: - Actions
    //Panning
    @objc func viewDidPan(sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: mainView).x
        
        let holderConstant = currentHolderConstant + translation
        let actionConstant = currentActionConstant + -(translation / 2)
        
        switch sender.state{
        case .began, .changed:
            
//            delegate.panningBegan(for: indexPath)

            if holderConstant >= finalHolderConstant &&  holderConstant <= 0{
                holderViewLeadingAnchor.constant = holderConstant
                deleteViewLeadingAnchor.constant = actionConstant
            }
            if isActionActive {
                if holderConstant < finalHolderConstant{
                    self.transform = CGAffineTransform(translationX: (holderConstant + abs(finalHolderConstant)) / 4, y: 0)
                } else if holderConstant > -1 {
                    isActionLooped = true
                    isActionActive = false
                }
            } else {
                if holderConstant < finalHolderConstant * 0.9{
                    isActionActive = true
                }
                else if holderConstant > 0 && holderConstant < 100 && !isActionLooped {
                    self.transform = CGAffineTransform(translationX: translation / 4, y: 0)
                }
            }
        default:
            if holderConstant > 0 || holderConstant < finalHolderConstant {
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self.transform = .identity
                }
            }
            if !isActionActive && holderConstant <= finalHolderConstant * 0.2
                        || isActionActive && translation < finalHolderConstant * 1.2 {
                activate(true)
            } else {
                activate(false)
//                delegate.panningEnded(for: indexPath)

            }
            currentActionConstant = deleteViewLeadingAnchor.constant
            currentHolderConstant = holderViewLeadingAnchor.constant
            isActionLooped = false
        }
    }
    @objc func viewDidTap(sender: UITapGestureRecognizer){
        
    }
    //LanguageChange
    @objc func languageDidChange(sender: Any){
        languageLabel.text = LanguageChangeManager.shared.localizedString(forKey: "tableCellName")
        cardsLabel.text = LanguageChangeManager.shared.localizedString(forKey: "tableCellNumberOfCards")
    }
}
//extension TableViewCell: UIGestureRecognizerDelegate{
//
//}
