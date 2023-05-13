//
//  SearchVIewBar.swift
//  Language
//
//  Created by Star Lord on 07/05/2023.
//

import UIKit

class SearchBarView: UITableViewHeaderFooterView {
    
    let searchBar: UISearchBar
    
    init(searchBar: UISearchBar, reuseIdentifier: String?) {
        self.searchBar = searchBar
        super.init(reuseIdentifier: reuseIdentifier)
        setupSearchBar()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSearchBar() {
        addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: searchBar.intrinsicContentSize.height)
    }
    
}
