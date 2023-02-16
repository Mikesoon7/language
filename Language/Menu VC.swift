//
//  Menu VC.swift
//  Language
//
//  Created by Star Lord on 10/02/2023.
//

import UIKit

class MenuVC: UIViewController {
    
    var tableView: UITableView = {
        var tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .insetGrouped)
        tableView.register(DictionaryCell.self, forCellReuseIdentifier: "dictCell")
        tableView.register(AddDictionaryCell.self, forCellReuseIdentifier: "addCell")
        tableView.rowHeight = 104
        tableView.backgroundColor = .systemBackground
        tableView.selectionFollowsFocus = true
        return tableView
    }()
    
//MARK: - Prepare Func
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navBarCustomization()
        toolBarCustomization()
        tableViewCustomization()
    }
    
//MARK: - TableView SetUP
    func tableViewCustomization(){
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

//MARK: - NavigationBar SetUp
    func navBarCustomization(){
        // Title adjustment.
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.black,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body).withSize(25)
        ]
        navigationItem.title = "Menu"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Georgia-BoldItalic", size: 23)!]
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(3, for: .default)
        
        
        // Buttons
        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(action(sender:)))
                self.navigationItem.setRightBarButton(rightButton, animated: true)
        
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
//MARK: - ToolBar SetUp
    func toolBarCustomization(){
        
        let rightToolbarButton = UIBarButtonItem(customView: standartToolbarButton(withText: "Choose Randomly"))
        rightToolbarButton.width = 166

        let leftToolbarButton = UIBarButtonItem(customView: standartToolbarButton(withText: "View Statistics"))
        leftToolbarButton.width = 166
        
        navigationController?.setToolbarHidden(false, animated: true)
        
        self.navigationController?.toolbar.setItems([
            leftToolbarButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            rightToolbarButton], animated: true)
        
        self.navigationController?.toolbar.backgroundColor = .systemBackground
        self.toolbarItems = navigationController?.toolbar.items
        
//Action Register
//        self.toolbarItems![0].action =
        self.toolbarItems![1].action = #selector(rightToolBarButTap(sender:))
        
    }
    func standartToolbarButton(withText: String) -> UIView {
        
        let customLabel : UILabel = {
            let label = UILabel()
            label.attributedText = NSAttributedString(
                string: withText,
                attributes: [NSAttributedString.Key.font:
                                UIFont(name: "Georgia-Italic", size: 15) ?? UIFont(),
                             NSAttributedString.Key.foregroundColor:
                                UIColor.label
                            ])
            return label
        }()
        
        let customView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.systemGray4
            view.layer.cornerRadius = 9
            view.layer.masksToBounds = true
            
            view.clipsToBounds = true
            
            view.addSubview(customLabel)

            view.translatesAutoresizingMaskIntoConstraints = false

            view.heightAnchor.constraint(equalToConstant: 166).isActive = true
//            view.heightAnchor.constraint(equalToConstant: 44).isActive = true

            return view
        }()
        
        view.addSubview(customView)
        
        customLabel.translatesAutoresizingMaskIntoConstraints = false
        
        customLabel.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
        customLabel.centerYAnchor.constraint(equalTo: customView.centerYAnchor).isActive = true
        customLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        return customView
    }
    
//MARK: - Actions
    @objc func action(sender: Any){
        navigationController?.showDetailViewController(AddDictionaryVC(), sender: self.navigationController)
    }
    @objc func rightToolBarButTap(sender: Any){
        let vc = StatisticVC()
        navigationController?.present(vc, animated: true)
    }
        
}

//MARK: - UITableViewDelegate
extension MenuVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return AppData().availableDictionary.count + 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == tableView.numberOfSections - 1{
            self.navigationController?.pushViewController(AddDictionaryVC(), animated: true)
        } else {
            self.navigationController?.pushViewController(LoadDataVC(), animated: true)
        }
    }
}
//MARK: - UITableViewDataSource
extension MenuVC: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dictCell", for: indexPath) as? DictionaryCell
        cell?.languageResultLabel.text = "English"
        cell?.cardsResultLabel.text = "11"
        let addCell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as? AddDictionaryCell
        
        if indexPath.section == tableView.numberOfSections - 1{
            print(indexPath.section)
            print(tableView.numberOfSections)
            return addCell!
        } else {
            print(indexPath.section)
            print(tableView.numberOfSections)
            return cell!
        }
    }
}
