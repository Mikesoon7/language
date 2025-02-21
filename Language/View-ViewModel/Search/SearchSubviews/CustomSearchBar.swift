//
//  CustomSearchBar.swift
//  Language
//
//  Created by Star Lord on 20/08/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit

class CustomSearchBar: UIView {
    
    weak var delegate: UISearchBarDelegate?{
        didSet {
            self.searchBar.delegate = delegate
        }
    }

    //MARK: - Views.
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.tag = 2
        searchBar.backgroundImage = UIImage()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .label
        button.backgroundColor = .systemBackground
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var topStroke = CAShapeLayer()
    
    //MARK: Constraints and releated
    private var cancelButtonLeadingAnchor: NSLayoutConstraint = .init()
    private var cancelButtonTrailingAnchor: NSLayoutConstraint = .init()
    
    //MARK: - Inherited
    convenience init(){
        self.init(frame: .zero)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureLabels()
        configureSubviews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Views properties setUp
    private func configureView(){
        self.backgroundColor = .systemBackground
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //MARK: Strokes SetUp
    func configureStrokes(){
        if topStroke.superlayer == nil {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            let bounds = UIWindow().bounds
            path.addLine(to: CGPoint(x: max(bounds.width, bounds.height) , y: 0))
            
            topStroke.lineWidth = 0.7
            topStroke.path = path.cgPath
            topStroke.strokeColor = UIColor.label.cgColor
            self.layer.addSublayer(topStroke)
        }
    }
    //MARK: Settings up contraints and related variables
    private func configureSubviews(){
        self.addSubviews(searchBar, cancelButton)
        
        cancelButtonLeadingAnchor = cancelButton.leadingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        cancelButtonTrailingAnchor = cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.outerSpacer)

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            cancelButtonLeadingAnchor,
        
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 10),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            searchBar.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -10)
        ])
        
        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap(sender:)), for: .touchUpInside)
    }
    //MARK: String values setUp
    //Called on init and when language changes by parant view.
    func configureLabels(){
        self.searchBar.placeholder = "yourWord".localized
        cancelButton.setAttributedTitle( .attributedString(
                string: "system.cancel".localized,
                with: .systemFont(ofSize: .subBodyTextSize),
                ofSize: .subBodyTextSize), for: .normal)
    }
    
    func animateTransitionTo(isActivated: Bool, time: TimeInterval){
        UIView.animate(withDuration: time) { [ unowned self ] in
            self.cancelButtonLeadingAnchor.isActive = isActivated ? false : true
            self.cancelButtonTrailingAnchor.isActive = isActivated ? true : false
             self.layoutIfNeeded()
        }
    }
    
    @objc func cancelButtonDidTap(sender: UIButton){
        searchBar.resignFirstResponder()
        searchBar.text = nil

        self.animateTransitionTo(isActivated: false, time: 0.3)

        searchBar.delegate?.searchBarTextDidEndEditing?(searchBar)
    }
}
