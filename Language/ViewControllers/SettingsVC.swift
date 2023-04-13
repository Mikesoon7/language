//
//  SettingsVC.swift
//  Language
//
//  Created by Star Lord on 05/03/2023.
//

import UIKit

struct Sections{
    var title: String
    var options: [SettingsItems]
    mutating func reload(index: Int) -> String{
        switch index{
        case 0: return LanguageChangeManager.shared.localizedString(forKey: "generalSection")
        case 1: return LanguageChangeManager.shared.localizedString(forKey: "searchSection")
        default: return " "
        }
    }
}

class SettingsVC: UIViewController {
    
    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(SettingsHeaderCell.self, forCellReuseIdentifier: SettingsHeaderCell().identifier)
        view.register(SettingsTextCell.self, forCellReuseIdentifier: SettingsTextCell().identifier)
        view.register(SettingsImageCell.self, forCellReuseIdentifier: SettingsImageCell().identifier)
        view.rowHeight = 20
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorStyle = .none
        return view
    }()
    

    var settingsItems: [Sections] = [
        Sections(title: LanguageChangeManager.shared.localizedString(forKey: "generalSection"),
                 options: [ SettingsItems.header,
                            SettingsItems.theme(SettingsData.shared.settings.theme),
                            SettingsItems.language(SettingsData.shared.settings.language),
                            SettingsItems.notification(SettingsData.shared.settings.notification)]),
        Sections(title: LanguageChangeManager.shared.localizedString(forKey: "searchSection"),
                 options: [SettingsItems.header,
                           SettingsItems.searchBarPosition(SettingsData.shared.settings.searchBar)])
    ]
    
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBarCustomization()
        tableViewCustomization()
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange(sender:)), name: .appThemeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        strokeCustomization()
    }
    
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                self.bottomStroke.strokeColor = UIColor.white.cgColor
                self.topStroke.strokeColor = UIColor.white.cgColor
                
            } else {
                self.bottomStroke.strokeColor = UIColor.black.cgColor
                self.topStroke.strokeColor = UIColor.black.cgColor
            }
        }
    }
    func navBarCustomization(){
        navigationItem.title = LanguageChangeManager.shared.localizedString(forKey: "settingsVCTitle")

        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
        
        self.navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString( bold: true, size: 23)

    }
    
    func tableViewCustomization(){
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    //MARK: - Stroke SetUp
    func strokeCustomization(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }

    //Update data in userDefaults and sending notification through update(_:)
    func handleThemeSelection(theme: SettingsData.AppTheme) {
        SettingsData.shared.update(newValue: theme)
    }
    
    func handleLanguageSelection(language: SettingsData.AppLanguage) {
        SettingsData.shared.update(newValue: language)
        let currentLanguage = SettingsData.shared.settings.language
        let languageCode: String
        switch currentLanguage {
        case .english:
            languageCode = "en"
        case .russian:
            languageCode = "ru"
        case .ukrainian:
            languageCode = "uk"
        }
        LanguageChangeManager.shared.changeLanguage(to: languageCode)
    }
    //MARK: - Actions
    //Updating local instance of userDefault and row value
    @objc func themeDidChange(sender: Any){
        let indexPath = IndexPath(item: 1, section: 0)
        settingsItems[0].options[1] = .theme(SettingsData.shared.settings.theme)
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    //Updating data for cells and reload table for new language appearence
    @objc func languageDidChange(sender: Any){
        let indexPath = IndexPath(item: 2, section: 0)
        settingsItems[0].options[2] = .language(SettingsData.shared.settings.language)
        handleLanguageChange()
    }
}
extension SettingsVC: UITableViewDelegate{
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentData = settingsItems[indexPath.section].options[indexPath.row]
        let alertMessage = UIAlertController(title: "There is no action", message: nil, preferredStyle: .actionSheet)
        if indexPath.section == 0 && indexPath.row == 1{
            let action1 = UIAlertAction(
                title: LanguageChangeManager.shared.localizedString(forKey: "lightTheme"),
                style: .default) { [weak self] _ in
                self?.handleThemeSelection(theme: .light)
            }
            let action2 = UIAlertAction(
                title:  LanguageChangeManager.shared.localizedString(forKey: "darkTheme"),
                style: .default){ [weak self] _ in
                self?.handleThemeSelection(theme: .dark)
            }
            let action3 = UIAlertAction(
                title:  LanguageChangeManager.shared.localizedString(forKey: "systemTheme"),
                style: .default){ [weak self] _ in
                self?.handleThemeSelection(theme: .deviceSettings)
            }
            alertMessage.title = nil
            alertMessage.addAction(action1)
            alertMessage.addAction(action2)
            alertMessage.addAction(action3)
                        
        }
        if indexPath.section == 0 && indexPath.row == 2{
            let action1 = UIAlertAction(title: "English", style: .default) { [weak self] _ in
                self?.handleLanguageSelection(language: .english)
            }
            let action2 = UIAlertAction(title: "Русский", style: .default){ [weak self] _ in
                self?.handleLanguageSelection(language: .russian)
            }
            let action3 = UIAlertAction(title: "Українська", style: .default){ [weak self] _ in
                self?.handleLanguageSelection(language: .ukrainian)
            }
            alertMessage.title = nil
            alertMessage.addAction(action1)
            alertMessage.addAction(action2)
            alertMessage.addAction(action3)
        }
        let action4 = UIAlertAction(
            title: LanguageChangeManager.shared.localizedString(forKey: "cancel"),
            style: .cancel,
            handler: nil)
        alertMessage.addAction(action4)
            if indexPath.section == 0 && indexPath.row == 3 {
                let vc = NotificationViewController()
                
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: false)
            } else {
                self.present(alertMessage, animated: true)
            }
    }
}

extension SettingsVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsItems[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = settingsItems[indexPath.section]
        let data = settingsItems[indexPath.section].options[indexPath.row]
        
        
        let cellToPresent: UITableViewCell = {
            switch data{
            case .header:
                let headerCell = tableView.dequeueReusableCell(
                    withIdentifier: SettingsHeaderCell().identifier,
                    for: indexPath) as! SettingsHeaderCell
                headerCell.label.text = section.title
                return headerCell
            case .language(SettingsData.shared.settings.language),
                    .theme(SettingsData.shared.settings.theme),
                    .notification(SettingsData.shared.settings.notification):
                let textCell = tableView.dequeueReusableCell(
                    withIdentifier: SettingsTextCell().identifier,
                    for: indexPath) as! SettingsTextCell
                textCell.label.text = data.title
                textCell.value.text = data.value
                return textCell
            case .searchBarPosition(SettingsData.shared.settings.searchBar):
                let imageCell = tableView.dequeueReusableCell(
                    withIdentifier: SettingsImageCell().identifier,
                    for: indexPath) as! SettingsImageCell
                return imageCell
            default:
                return UITableViewCell()
            }
        }()
        return cellToPresent
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        settingsItems.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1{
            return 100
        } else {
            return 44
        }
        
    }
}
extension SettingsVC{
    func handleLanguageChange(){
        navigationItem.title = LanguageChangeManager.shared.localizedString(forKey: "settingsVCTitle")
        for index in 0..<settingsItems.count{
            settingsItems[index].title = settingsItems[index].reload(index: index)
        }
        tableView.reloadData()
        if let barItems = tabBarController?.tabBar.items{
            for index in 0..<(barItems.count){
                barItems[index].title = {
                    switch index{
                    case 0: return LanguageChangeManager.shared.localizedString(forKey: "tabBarDictionaries")
                    case 1: return LanguageChangeManager.shared.localizedString(forKey: "tabBarSearch")
                    case 2: return LanguageChangeManager.shared.localizedString(forKey: "tabBarSettings")
                    default: return " "
                    }
                }()
            }
        }
    }
}
