//
//  SearchVC.swift
//  Language
//
//  Created by Star Lord on 02/04/2023.
//

import UIKit

class SearchVC: UIViewController {

    let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.register(SearchViewCell.self, forCellReuseIdentifier: SearchViewCell().identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "yourWord".localized
        return controller
    }()
    private var allData: [DataForCells] = []
    private var filteredData: [DataForCells] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableViewCustomization()
        searchViewCustomization()
        loadData()
    }
    func searchViewCustomization(){
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
    }
    func tableViewCustomization(){
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    private func loadData() {
        var allPairs = [DataForCells]()
        for dictionary in DataForDictionaries.shared.availableDictionary {
            if let pairs = dictionary.dictionary {
                allPairs.append(contentsOf: pairs)
            }
        }
        allData = allPairs
        tableView.reloadData()
    }
}


extension SearchVC: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredData = allData.filter { data in
                data.word.lowercased().contains(searchText.lowercased()) ||
                data.translation.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredData = []
        }
        tableView.reloadData()
    }
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredData.count : allData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchViewCell().identifier, for: indexPath) as? SearchViewCell
        let data = searchController.isActive ? filteredData[indexPath.row] : allData[indexPath.row]
        cell?.wordLabel.text = data.word
        cell?.descriptionLabel.text = data.translation
        return cell!
        
    }
}
