//
//  TableViewCell.swift
//  Language
//
//  Created by Star Lord on 23/03/2023.
//

import UIKit

class TableViewCell: UITableViewCell{

    let identifier = "dictCell"
    var isActionActive: Bool = false
    var leftToRight: Bool!
    var isActionLooped: Bool = false
    
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
    var editView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .blue
        return view
    }()
    var deleteView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()
    
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
        configureViews()
        configureEditView()
        configureDeleteView()
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
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureViews(){
        contentView.addSubview(holderView)
        holderView.addSubviews(mainView, editView, deleteView)
        mainView.addSubviews(languageResultLabel, languageLabel, cardsLabel, cardsResultLabel)

        contentViewWidth = contentView.frame.width
        
        initialActionConstant = 0
        currentHolderConstant = 0
        finalHolderConstant = -(contentViewWidth * 0.4 - cornerRadius)
        
        holderViewLeadingAnchor = holderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: currentHolderConstant)
        
        NSLayoutConstraint.activate([
            holderViewLeadingAnchor,
            holderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            holderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            holderView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.4),
            
            mainView.topAnchor.constraint(equalTo: holderView.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: holderView.leadingAnchor),
            mainView.bottomAnchor.constraint(equalTo: holderView.bottomAnchor),
            mainView.widthAnchor.constraint(equalTo: contentView.widthAnchor),

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
            cardsResultLabel.heightAnchor.constraint(equalToConstant: 25),
        ])
    }
    func configureEditView(){
        let label : UIImageView = {
            let view = UIImageView()
            view.image = UIImage(systemName: "pencil")
            view.translatesAutoresizingMaskIntoConstraints = false
            view.tintColor = .white
            view.contentMode = .center
            return view
        }()

        editView.addSubview(label)

        NSLayoutConstraint.activate([
            editView.topAnchor.constraint(equalTo: mainView.topAnchor),
            editView.leadingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -cornerRadius),
            editView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            editView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
            
            label.centerYAnchor.constraint(equalTo: editView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: editView.centerXAnchor, constant: cornerRadius / 2)
        ])
    }
    func configureDeleteView(){
        let label : UIImageView = {
            let view = UIImageView()
            view.image = UIImage(systemName: "trash")
            view.translatesAutoresizingMaskIntoConstraints = false
            view.tintColor = .white
            view.contentMode = .center
            return view
        }()
        
        deleteView.addSubview(label)

        initialActionConstant = -cornerRadius
        currentActionConstant = -cornerRadius
        finalActionConstant = contentViewWidth * 0.2 - cornerRadius * 1.5
        deleteViewLeadingAnchor = deleteView.leadingAnchor.constraint(equalTo: mainView.trailingAnchor,
                                                                      constant: -cornerRadius)
        
        NSLayoutConstraint.activate([
            deleteView.topAnchor.constraint(equalTo: mainView.topAnchor),
            deleteViewLeadingAnchor,
            deleteView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor),
            deleteView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2),
            
            label.centerYAnchor.constraint(equalTo: deleteView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: deleteView.centerXAnchor)
        ])
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
    }
    func activate(_ activate: Bool){
        let animation = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut){
            self.holderViewLeadingAnchor.constant = activate ? self.finalHolderConstant : 0
            self.deleteViewLeadingAnchor.constant = activate ? self.finalActionConstant : -self.cornerRadius
            self.layoutIfNeeded()
            self.isActionActive = activate
        }
        animation.startAnimation()
    }
    @objc func viewDidPan(sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: mainView).x
        let velocity = sender.velocity(in: mainView)
        let magnitude = sqrt((velocity.x * velocity.x) + ( velocity.y * velocity.y))
        print(magnitude)
        let holderConstant = currentHolderConstant + translation
        let actionConstant = currentActionConstant + -(translation / 2)
        
        

        switch sender.state{
        case .began, .changed:
//            guard abs(velocity.x) < 2000 else {
//                activate(false)
//                sender.state = .failed
//                return
//            }

            if isActionActive {
                if holderConstant >= finalHolderConstant && holderConstant < -50 {
                    holderViewLeadingAnchor.constant = holderConstant
                    deleteViewLeadingAnchor.constant = actionConstant
                } else if holderConstant < finalHolderConstant{
//                    print("to forward")
                    self.transform = CGAffineTransform(translationX: (holderConstant + abs(finalHolderConstant)) / 4, y: 0)
                } else if holderConstant > -50 {
                    isActionLooped = true
                    isActionActive = false
                }
            } else {
                if holderConstant > finalHolderConstant && holderConstant <= 0 {
                    holderViewLeadingAnchor.constant = holderConstant
                    deleteViewLeadingAnchor.constant = actionConstant
                } else if holderConstant < finalHolderConstant * 0.9{
                    isActionActive = true
                }
                else if holderConstant > 0 && holderConstant < 100 && !isActionLooped {
                    self.transform = CGAffineTransform(translationX: translation / 4, y: 0)
                }
            }
        case .failed:
            break
        default:
            if holderConstant > 0 || holderConstant < finalHolderConstant {
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self.transform = .identity
                }
            }
            if !isActionActive && holderConstant <= finalHolderConstant * 0.2
                        || isActionActive && translation < finalHolderConstant * 1.2 {
                activate(true)
            } else if isActionActive && translation >= finalHolderConstant * 1.2
                        || !isActionActive && holderConstant > finalHolderConstant * 0.2 {
                activate(false)

            } else {
                activate(false)

            }
            currentActionConstant = deleteViewLeadingAnchor.constant
            currentHolderConstant = holderViewLeadingAnchor.constant
            isActionLooped = false
            print("but where is ")
        }
    }

    @objc func languageDidChange(sender: Any){
        languageLabel.text = LanguageChangeManager.shared.localizedString(forKey: "tableCellName")
        cardsLabel.text = LanguageChangeManager.shared.localizedString(forKey: "tableCellNumberOfCards")
    }
}



