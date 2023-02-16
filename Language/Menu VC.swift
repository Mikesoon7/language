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
        tableView.backgroundColor = .white
        tableView.selectionFollowsFocus = true
        return tableView
    }()
    
    var existingFolders: UIView = {
        var view = UIView()
        view.backgroundColor = .lightText
        view.layer.cornerRadius = 9
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.clipsToBounds = true
        return view
    }()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        
        navBarCustomization()
        toolBarCustomization()
        tableViewCustomization()
    }
    
    func existingFolderLayout(){
        view.addSubview(existingFolders)
        
        existingFolders.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            existingFolders.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            existingFolders.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22),
            existingFolders.widthAnchor.constraint(lessThanOrEqualToConstant: 330),
            existingFolders.heightAnchor.constraint(lessThanOrEqualToConstant: 104)
        ])
    }
    
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
    
    func tableViewCustomization(){
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0 ).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func toolBarCustomization(){
        
        let rightToolbarButton = UIBarButtonItem(customView: standartToolbarButton(withText: "Choose Randomly"))
        rightToolbarButton.width = 166
        let leftToolbarButton = UIBarButtonItem(customView: standartToolbarButton(withText: "View Statistics"))
        leftToolbarButton.width = 166
        
        navigationController?.setToolbarHidden(false, animated: true)
        self.navigationController?.toolbar.setItems([
            rightToolbarButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            leftToolbarButton], animated: true)
        
        self.toolbarItems = navigationController?.toolbar.items
        
    }
    func standartToolbarButton(withText: String) -> UIView {
        
        let customLabel : UILabel = {
            let label = UILabel()
            label.attributedText = NSAttributedString(
                string: withText,
                attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body).withSize(15),
                             NSAttributedString.Key.foregroundColor: UIColor.label
                            ])
            label.tintColor = .black
            
            
            return label
        }()
        
        let customView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.systemGray4
            view.layer.cornerRadius = 9
            view.layer.masksToBounds = true
            
            view.clipsToBounds = true
            
            
            view.translatesAutoresizingMaskIntoConstraints = false

            view.heightAnchor.constraint(equalToConstant: 166).isActive = true
            view.heightAnchor.constraint(equalToConstant: 55).isActive = true
            
            view.addSubview(customLabel)
            return view
        }()
        
        customLabel.translatesAutoresizingMaskIntoConstraints = false
        customLabel.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
        customLabel.centerYAnchor.constraint(equalTo: customView.centerYAnchor).isActive = true
        customLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        view.addSubview(customView)
        return customView
    }
    @objc func action(sender: Any){
        navigationController?.showDetailViewController(AddDictionaryVC(), sender: self.navigationController)
    }
        
}
extension MenuVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "dictCell", for: indexPath) as? DictionaryCell
        cell?.languageName.text = "English"
        cell?.cardsNumberName.text = "11"
        var addCell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as? AddDictionaryCell
        if indexPath.section == 5{
            return addCell!
        } else {
            return cell!
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    
    
}

