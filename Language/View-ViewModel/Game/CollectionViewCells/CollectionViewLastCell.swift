//
//  LastCell.swift
//  Language
//
//  Created by Star Lord on 16/03/2023.
//

import UIKit

//MARK: - Data for LastCell
class DataForLastCell: Hashable{
    var identifier = UUID()
    var score : Float
    var delegate : CustomCellDelegate?
    init(score: Float, delegate: CustomCellDelegate) {
        self.score = score
        self.delegate = delegate
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: DataForLastCell, rhs: DataForLastCell) -> Bool{
        lhs.identifier == rhs.identifier
    }
}
//MARK: - Protocol for VC pop
protocol CustomCellDelegate: AnyObject{
    func finishButtonTap()
}
class CollectionViewLastCell: UICollectionViewCell {
    
    var staticCardSize : CGSize!
    weak var delegate: CustomCellDelegate?
    
    let cardView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 9
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var cardShadowView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 5.0
        view.layer.shadowOffset = CGSize(width: 10, height: 10)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let scoreLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Georgia-BoldItalic", size: 40)
        label.textColor = .black
        label.text = "???"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let finishButton : UIButton = {
        let button = UIButton()
        button.setUpBorderedView(false)
        button.layer.borderWidth = 0
        button.setTitle(
            "great".localized,
            for: .normal)
        button.setTitleColor(.label, for: .normal) 
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        cardViewCustomiation()
        staticCardSize = CGSize(width: UIWindow().bounds.width * 0.64, height: UIWindow().bounds.height * 0.48)
    }
    required init?(coder: NSCoder) {
        fatalError("Faild to present cells")
    }
    func cardViewCustomiation(){
        self.contentView.addSubview(cardShadowView)
        cardShadowView.addSubview(cardView)
        cardView.addSubviews(scoreLabel, finishButton)
//        cardShadowView.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            cardShadowView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            cardShadowView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            cardShadowView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
            cardShadowView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor ),
                        
            cardView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            cardView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
            cardView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor ),


            scoreLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
//            scoreLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 30),
//            scoreLabel.bottomAnchor.constraint(equalTo: cardView.topAnchor, constant: 80),
        
            finishButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -30 ),
            finishButton.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            finishButton.heightAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.2),
            finishButton.widthAnchor.constraint(equalTo: cardView.heightAnchor, multiplier: 0.2)
        ])
        finishButton.addTarget(self, action: #selector(buttonTap(sender:)), for: .touchUpInside)
        finishButton.addTargetTouchBegin()
        finishButton.addTargetInsideTouchStop()
        finishButton.addTargetOutsideTouchStop()
    }
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        cardShadowView.layer.shadowOffset = CGSize(
            width: (layoutAttributes.frame.width - staticCardSize.width) / 4 ,
            height: ( layoutAttributes.frame.height - staticCardSize.height) / 3)
    }

    func configure(with data: DataForLastCell){
        scoreLabel.text = "\((data.score).rounded())%"
        delegate = data.delegate
    }

    @objc func buttonTap(sender: Any){
        delegate?.finishButtonTap()
    }
}
