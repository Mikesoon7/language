//
//  CollectionSearchToolBar.swift
//  Learny
//
//  Created by Star Lord on 02/05/2025.
//
//TODO: Polish

import Foundation
import UIKit

protocol CollectionSearchToolBarEventHandler: AnyObject {
    func searchQueryDidChange(_ text: String)
    func searchDidBegin()
    func searchDidEnd(_ query: String)
    func searchDidCancel()
}

class CollectionSearchToolBar: UIView {
    
    weak var coordinator: CollectionSearchToolBarEventHandler?
    
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
    
//    var topStroke = CAShapeLayer()
    
    //MARK: Constraints and releated
    private var cancelButtonLeadingAnchor: NSLayoutConstraint = .init()
    private var cancelButtonTrailingAnchor: NSLayoutConstraint = .init()
    
    //MARK: - Inherited
    convenience init(coordinator: CollectionSearchToolBarEventHandler){
        self.init(frame: .zero)
        self.coordinator = coordinator
    }
    override private init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureLabels()
        configureSubviews()
        searchBar.delegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Views properties setUp
    private func configureView(){
        self.backgroundColor = .systemBackground
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //MARK: Settings up contraints and related variables
    private func configureSubviews(){
        self.addSubviews(searchBar, cancelButton)
        
        cancelButtonLeadingAnchor = cancelButton.leadingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
        cancelButtonTrailingAnchor = cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.outerSpacer)

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            cancelButton.heightAnchor.constraint(equalTo: heightAnchor),
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
    
    func enterBackgroundState(){
        self.searchBar.resignFirstResponder()
    }
    func isFirstResponder() -> Bool{
        return searchBar.isFirstResponder
    }
    
    func activateSearchView() {
        self.searchBar.becomeFirstResponder()
        self.animateTransitionTo(isActivated: true)
    }
    
    func deactivateSearchView() {
        self.searchBar.resignFirstResponder()
        self.animateTransitionTo(isActivated: false)
    }

    
    
    private func animateTransitionTo(isActivated: Bool, time: TimeInterval = 0.3){
        UIView.animate(withDuration: time) { [ weak self ] in
            guard let self = self else { return }
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
    
    @objc private func cancelButtonDidTap(sender: UIButton){
        searchBar.text = nil
        searchBar.resignFirstResponder()
        coordinator?.searchDidCancel()
    }
    
    
}

extension CollectionSearchToolBar: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        animateTransitionTo(isActivated: true)
        coordinator?.searchDidBegin()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        animateTransitionTo(isActivated: false)
        coordinator?.searchDidEnd(searchBar.text ?? "")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        coordinator?.searchQueryDidChange(searchText)
    }
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
