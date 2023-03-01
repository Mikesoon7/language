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
    var statisticButton : UIButton = {
        let button = UIButton()
        button.configuration = .gray()
        button.configuration?.baseBackgroundColor = .systemGray4
        button.configuration?.baseForegroundColor = .label
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 9
        button.clipsToBounds = true
        return button
    }()
    
    var randomButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGray4
        button.tintColor = .label
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 9
        button.layer.masksToBounds = true
        return button
    }()
    
    var leftToolbarButton = UIBarButtonItem()
    var rightToolbarButton = UIBarButtonItem()

    
//MARK: - Prepare Func
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navBarCustomization()
        bottomButtonCustomization()
        tableViewCustomization()
        /*
         toolBarCustomization()
         */

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
//MARK: - TableView SetUP
    func tableViewCustomization(){
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.randomButton.topAnchor, constant: -5).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 0).isActive = true
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

//MARK: - NavigationBar SetUp
    func navBarCustomization(){
        // Title adjustment.
        navigationItem.title = "Menu"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:
                                                                    UIFont(name: "Georgia-BoldItalic",
                                                                           size: 23)!]
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(3, for: .default)
        
        // Buttons
        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsButTap(sender:)))
                self.navigationItem.setRightBarButton(rightButton, animated: true)
        
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }
//MARK: - BottomBut SetUp
    func bottomButtonCustomization(){
        view.addSubview(statisticButton)
        view.addSubview(randomButton)

        statisticButton.translatesAutoresizingMaskIntoConstraints = false
        randomButton.translatesAutoresizingMaskIntoConstraints = false

        statisticButton.setAttributedTitle(NSAttributedString(
            string: "View Statistic",
            attributes: [NSAttributedString.Key.font :
                            UIFont(name: "Georgia-Italic",
                                   size: 18) ?? UIFont()]),
                                           for: .normal)
        
        randomButton.setAttributedTitle(NSAttributedString(
            string: "Choose Randomly",
            attributes: [NSAttributedString.Key.font :
                            UIFont(name: "Georgia-Italic",
                                   size: 18) ?? UIFont()]),
                                           for: .normal)
        NSLayoutConstraint.activate([
            statisticButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -11),
            statisticButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            statisticButton.widthAnchor.constraint(equalToConstant: (view.bounds.width - 30 - 10) / 2),
            statisticButton.heightAnchor.constraint(equalToConstant: 50),
            
            randomButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -11),
            randomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            randomButton.widthAnchor.constraint(equalToConstant: (view.bounds.width - 30 - 10) / 2),
            randomButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        statisticButton.addTarget(self, action: #selector(animationBegin(sender:)), for: .touchDown)
        statisticButton.addTarget(self, action: #selector(statiscticButTap(sender:)), for: .touchUpInside)
        statisticButton.addTarget(self, action: #selector(animationEnded(sender: )), for: .touchUpOutside)
        
        randomButton.addTarget(self, action: #selector(animationBegin(sender:)), for: .touchDown)
        randomButton.addTarget(self, action: #selector(randomButTap(sender:)), for: .touchUpInside)
        randomButton.addTarget(self, action: #selector(animationEnded(sender: )), for: .touchUpOutside)

    }
//MARK: - ToolBar SetUp
    /*
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
    */
    
//MARK: - Actions
    @objc func settingsButTap(sender: Any){
        navigationController?.showDetailViewController(AddDictionaryVC(), sender: self.navigationController)
    }
    @objc func randomButTap(sender: UIButton){
        animationEnded(sender: sender)
        let allertMessage = UIAlertController(title: "Nothing to randomize", message: "Please, add card stack to start learning.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Understand", style: .cancel)
        action.setValue(UIColor.black, forKey: "titleTextColor")
        allertMessage.addAction(action)
        
        if AppData.shared.availableDictionary.count == 0{
            self.present(allertMessage, animated: true)
        } else {
            let vc = DetailsVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    @objc func statiscticButTap(sender: UIButton){
        animationEnded(sender: sender)
        let vc = StatisticVC()
        navigationController?.present(vc, animated: true)
    }
    @objc func animationBegin( sender: UIView){
        UIView.animate(withDuration: 0.20, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        })
    }
    @objc func animationEnded( sender: UIView){
        UIView.animate(withDuration: 0.10, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            sender.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }

    /*
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
        let action = UIAlertAction(title: "Understand", style: .cancel)
        action.setValue(UIColor.black, forKey: "titleTextColor")
        allertMessage.addAction(action)
        if AppData.shared.availableDictionary.count < 1{
            self.present(allertMessage, animated: true)
        } else {
            let vc = DetailsVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
     */
        
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
        return AppData.shared.availableDictionary.count + 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == tableView.numberOfSections - 1{
            self.navigationController?.pushViewController(AddDictionaryVC(), animated: true)
        } else {
            let vc = DetailsVC()
            let dictionary = AppData.shared.availableDictionary
            vc.dictionary = dictionary[indexPath.section]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
//MARK: - UITableViewDataSource
extension MenuVC: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dictionary = AppData.shared.availableDictionary
        let cell = tableView.dequeueReusableCell(withIdentifier: "dictCell", for: indexPath) as? DictionaryCell
        let addCell = tableView.dequeueReusableCell(withIdentifier: "addCell", for: indexPath) as? AddDictionaryCell
        
        if indexPath.section == tableView.numberOfSections - 1{
            return addCell!
        } else {
            cell?.languageResultLabel.text = dictionary[indexPath.section].language
            cell?.cardsResultLabel.text =  dictionary[indexPath.section].numberOfCards
            return cell!
        }
    }
}
extension MenuVC: UIToolbarDelegate{
    
}
