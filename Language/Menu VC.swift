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
    
    var rightToolbarButton = UIBarButtonItem()
    var leftToolbarButton = UIBarButtonItem()

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
        
        leftToolbarButton = UIBarButtonItem(customView: standartToolbarButton(withText: "View Statistics"))
        leftToolbarButton.width = 166
        rightToolbarButton = UIBarButtonItem(customView: standartToolbarButton(withText: "Choose Randomly"))
        rightToolbarButton.width = 166
        
        navigationController?.setToolbarHidden(false, animated: false)
        
        self.navigationController?.toolbar.setItems([
            leftToolbarButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            rightToolbarButton], animated: true)
        
        self.navigationController?.toolbar.backgroundColor = .systemBackground
        self.navigationController?.toolbar.isUserInteractionEnabled = true
        self.toolbarItems = navigationController?.toolbar.items

//Action Register
        leftToolbarButton.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftToolBarButTap(sender:))))
        rightToolbarButton.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightToolBarButTap(sender:))))
            }
    
    func standartToolbarButton(withText: String) -> UIView {
        
        let customLabel : UILabel = {
            let label = UILabel()
            label.isUserInteractionEnabled = true
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
            view.isUserInteractionEnabled = true
            view.backgroundColor = UIColor.systemGray4
            view.layer.cornerRadius = 9
            view.clipsToBounds = true
            
            view.addSubview(customLabel)
            return view
        }()
        
        customLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customLabel.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
            customLabel.centerYAnchor.constraint(equalTo: customView.centerYAnchor),
            customLabel.leadingAnchor.constraint(greaterThanOrEqualTo: customView.leadingAnchor, constant: 10),
            customLabel.trailingAnchor.constraint(lessThanOrEqualTo: customView.trailingAnchor, constant: -10),
            customLabel.topAnchor.constraint(greaterThanOrEqualTo: customView.topAnchor, constant: 10),
            customLabel.bottomAnchor.constraint(lessThanOrEqualTo: customView.bottomAnchor, constant: -10)
        ])
        return customView
        
    }
    
//MARK: - Actions
    @objc func action(sender: Any){
        navigationController?.showDetailViewController(AddDictionaryVC(), sender: self.navigationController)
    }
    @objc func leftToolBarButTap(sender: Any){
//        Tap animation.
        if leftToolbarButton.customView != nil{
            UIView.animate(withDuration: 0.1, animations: {
                self.leftToolbarButton.customView!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.leftToolbarButton.customView!.transform = CGAffineTransform.identity
                })
            })
        }
        let vc = StatisticVC()
        print("the problem isn't here")
        navigationController?.present(vc, animated: true)
    }
    @objc func rightToolBarButTap(sender: Any){
//        Tap animation.
        if rightToolbarButton.customView != nil{
            UIView.animate(withDuration: 0.1, animations: {
                self.rightToolbarButton.customView!.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.rightToolbarButton.customView!.transform = CGAffineTransform.identity
                })
            })
        }
        
        let allertMessage = UIAlertController(title: "Nothing to randomize", message: "Please, add card stack to start learning.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Understand", style: .default)
        action.setValue(UIColor.black, forKey: "titleTextColor")
        allertMessage.addAction(action)
        if AppData().availableDictionary.count < 1{
            self.present(allertMessage, animated: true)
        }
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
        return AppData().availableDictionary.count + 6
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
            return addCell!
        } else {
            return cell!
        }
    }
}
extension MenuVC: UIToolbarDelegate{
    
}
