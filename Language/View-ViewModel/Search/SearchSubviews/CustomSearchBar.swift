//
//  CustomSearchBar.swift
//  Language
//
//  Created by Star Lord on 20/08/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit

protocol CustomSearchBarDelegate: AnyObject {
    func customSearchBarDidBeginEditing(_ searchBar: UISearchBar)
    func customSearchBarDidEndEditing(_ searchBar: UISearchBar)
    func customSearchBar(_ searchBar: UISearchBar, didChangeText text: String)
    func customSearchBarSearchButtonTapped(_ searchBar: UISearchBar)
}

class CustomSearchBarView: UIView {
    
    weak var delegate: CustomSearchBarDelegate?

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
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var topStroke = CAShapeLayer()
    
    //MARK: Constraints and releated
    private var cancelButtonLeadingAnchor: NSLayoutConstraint = .init()
    private var cancelButtonTrailingAnchor: NSLayoutConstraint = .init()
    
    //MARK: - Inherited
    convenience init(){
        self.init(frame: .zero)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        searchBar.delegate = self
        configureView()
        configureLabels()
        configureSubviews()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return searchBar.resignFirstResponder()
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
    //MARK: Subviews setUp
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

    //Called on init and when language changes by parant view.
    private func configureLabels(){
        self.searchBar.placeholder = "yourWord".localized
        cancelButton.setAttributedTitle( .attributedString(
                string: "system.cancel".localized,
                with: .systemFont(ofSize: .subBodyTextSize),
                ofSize: .subBodyTextSize), for: .normal)
    }
    
    private func animateTransitionTo(isActivated: Bool, time: TimeInterval){
        UIView.animate(withDuration: time) { [ unowned self ] in
            NSLayoutConstraint.deactivate([isActivated
                                          ? self.cancelButtonLeadingAnchor
                                          : self.cancelButtonTrailingAnchor
            ])
            NSLayoutConstraint.activate([isActivated
                                        ? self.cancelButtonTrailingAnchor
                                        : self.cancelButtonLeadingAnchor
            ])
            self.layoutIfNeeded()
        }
    }
    
    //Response
    func updateForThemeChange(){
        self.topStroke.strokeColor = UIColor.label.cgColor
    }
    func updateForLanguageChange(){
        self.configureLabels()
    }
    
    func refreshSearchBar() {
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
    
    //MARK: Actions
    @objc private func cancelButtonDidTap(sender: UIButton){
        refreshSearchBar()
    }
    
}

//MARK: - SearchBarDelegate
extension CustomSearchBarView: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        animateTransitionTo(isActivated: true, time: 0.3)
        delegate?.customSearchBarDidBeginEditing(searchBar)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        animateTransitionTo(isActivated: false, time: 0.3)
        delegate?.customSearchBarDidEndEditing(searchBar)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.customSearchBar(searchBar, didChangeText: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        _ = self.resignFirstResponder()
        delegate?.customSearchBarSearchButtonTapped(searchBar)
    }
}
