//
//  SettingsVC.swift
//  Language
//
//  Created by Star Lord on 05/03/2023.
//

import UIKit

struct Sections{
    var title: String
    var data: [UserSettingsPresented]
}

class SettingsVC: UIViewController {
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(SettingsHeaderCell.self, forCellReuseIdentifier: SettingsHeaderCell().identifier)
        view.register(SettingsTextCell.self, forCellReuseIdentifier: SettingsTextCell().identifier)
        view.register(SettingsImageCell.self, forCellReuseIdentifier: SettingsImageCell().identifier)
        view.backgroundColor = .systemBackground
        view.separatorStyle = .none
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.subviews.forEach { sections in
            sections.addShadowWhichOverlays(false)
        }
        return view
    }()
    
    var settingsData: [Sections] = [
        Sections(title: "first", data: [
        UserSettingsPresented.header("generalSection"),
        UserSettingsPresented.theme(UserSettings.shared.settings.theme),
        UserSettingsPresented.language(UserSettings.shared.settings.language),
        UserSettingsPresented.notificationsNew(UserSettings.shared.settings.notifications)]),
        
        Sections(title: "second", data: [
        UserSettingsPresented.header("searchSection"),
        UserSettingsPresented.searchBar(UserSettings.shared.settings.searchBar)]),
    
        Sections(title: "third", data: [
            UserSettingsPresented.header("dictionaries"),
            UserSettingsPresented.separators(UserSettings.shared.settings.separators),
            UserSettingsPresented.duplicates(UserSettings.shared.settings.duplicates)
        ])]
    
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
        configureNavBar()
        configureTableView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureStrokes()
    }
    
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                bottomStroke.strokeColor = UIColor.white.cgColor
                topStroke.strokeColor = UIColor.white.cgColor
                tableView.subviews.forEach { section in
                    section.layer.shadowColor = shadowColorForDarkIdiom
                }
            } else {
                bottomStroke.strokeColor = UIColor.black.cgColor
                topStroke.strokeColor = UIColor.black.cgColor
                tableView.subviews.forEach { section in
                    section.layer.shadowColor = shadowColorForLightIdiom
                }
            }
        }
    }
    func configureController(){
        view.backgroundColor = .systemBackground

        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
    }
    //MARK: - Stroke SetUp
    func configureStrokes(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
    
    //MARK: - NavigationBar SetUp
    func configureNavBar(){
        self.navigationItem.title = "settingsVCTitle".localized
        self.navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString( bold: true, size: 23)

        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }
    //MARK: - TableView SetUp
    func configureTableView(){
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    //MARK: - Methods for settings cell
    func createThemeActions(indexPath: IndexPath) -> [UIAlertAction] {
        let action1 = UIAlertAction(title: LanguageChangeManager.shared.localizedString(forKey: "lightTheme"), style: .default) { [weak self] _ in
            self?.handleThemeSelection(theme: .light, index: indexPath)
        }
        let action2 = UIAlertAction(title: LanguageChangeManager.shared.localizedString(forKey: "darkTheme"), style: .default) { [weak self] _ in
            self?.handleThemeSelection(theme: .dark, index: indexPath)
        }
        let action3 = UIAlertAction(title: LanguageChangeManager.shared.localizedString(forKey: "systemTheme"), style: .default) { [weak self] _ in
            self?.handleThemeSelection(theme: .system, index: indexPath)
        }
        return [action1, action2, action3]
    }

    func createLanguageActions(indexPath: IndexPath) -> [UIAlertAction] {
        let action1 = UIAlertAction(title: "English", style: .default) { [weak self] _ in
            self?.handleLanguageSelection(language: .english, index: indexPath)
        }
        let action2 = UIAlertAction(title: "Русский", style: .default) { [weak self] _ in
            self?.handleLanguageSelection(language: .russian, index: indexPath)
        }
        let action3 = UIAlertAction(title: "Українська", style: .default) { [weak self] _ in
            self?.handleLanguageSelection(language: .ukrainian, index: indexPath)
        }
        return [action1, action2, action3]
    }
    func createDuplicatesActions(indexPath: IndexPath) -> [UIAlertAction] {
        let action1 = UIAlertAction(title: "keep".localized, style: .default) { [weak self] _ in
            self?.handleDuplicatesChange(value: .keep, index: indexPath)
        }
        let action2 = UIAlertAction(title: "remove".localized, style: .default) { [weak self] _ in
            self?.handleDuplicatesChange(value: .remove, index: indexPath)
        }
        return [action1, action2]
    }

    
    //Upfating theme
    func handleThemeSelection(theme: UserSettings.AppTheme, index: IndexPath) {
        settingsData[index.section].data[index.row] = .theme(theme)
        UserSettings.shared.reload(newValue: theme)
        tableView.reloadRows(at: [index], with: .fade)
    }
    //Updating data and posting notification
    func handleLanguageSelection(language: UserSettings.AppLanguage, index: IndexPath) {
        UserSettings.shared.reload(newValue: language)
        settingsData[index.section].data[index.row] = .language(language)
    }
    //Update search bar position
    func handleSearchBarPositionChange(position: UserSettings.AppSearchBarOnTop, index: IndexPath){
        UserSettings.shared.reload(newValue: position)
        settingsData[index.section].data[index.row] = .searchBar(position)
    }
    func handleDuplicatesChange(value: UserSettings.AppDuplicates, index: IndexPath){
        UserSettings.shared.reload(newValue: value)
        settingsData[index.section].data[index.row] = .duplicates(value)
        tableView.reloadRows(at: [index], with: .fade)
    }
    //MARK: - Actions
    //Language change
    @objc func languageDidChange(sender: Any){
        navigationItem.title = "settingsVCTitle".localized
        tableView.reloadData()
    }
}
extension SettingsVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertMessage = UIAlertController(title: "There is no action", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "system.cancel".localized, style: .cancel)
        alertMessage.addAction(cancelAction)
        switch (indexPath.section, indexPath.row){
        case (0, 1):
            alertMessage.title = nil
            createThemeActions(indexPath: indexPath).forEach { alertMessage.addAction($0)}
            present(alertMessage, animated: true)
        case (0, 2):
            alertMessage.title = nil
            createLanguageActions(indexPath: indexPath).forEach { alertMessage.addAction($0)}
            present(alertMessage, animated: true)

        case (0, 3):
            let vc = NotificationView()
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
        case (1, 1):
            break
        case (2, 1):
            let vc = SeparatorsVC()
            self.present(vc, animated: true)
        case (2, 2):
            alertMessage.title = nil
            createDuplicatesActions(indexPath: indexPath).forEach { alertMessage.addAction($0)}
            present(alertMessage, animated: true)
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsData[section].data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = settingsData[indexPath.section].data[indexPath.row]
        
        let cellToPresent: UITableViewCell = {
            switch data{
            case .header:
                let headerCell = tableView.dequeueReusableCell(
                    withIdentifier: SettingsHeaderCell().identifier,
                    for: indexPath) as! SettingsHeaderCell
                headerCell.isUserInteractionEnabled = false
                headerCell.selectionStyle = .none
                headerCell.label.text = data.title.localized
                return headerCell
            case .language(_),
                    .theme(_),
                    .notificationsNew(_),
                    .duplicates(_):
                let textCell = tableView.dequeueReusableCell(
                    withIdentifier: SettingsTextCell().identifier,
                    for: indexPath) as! SettingsTextCell
                textCell.label.text = data.title
                textCell.value.text = data.value as? String
                return textCell
            case .searchBar(let position):
                let imageCell = tableView.dequeueReusableCell(
                    withIdentifier: SettingsImageCell().identifier,
                    for: indexPath) as! SettingsImageCell
                imageCell.selectedImage = {[weak self] option in
                    self?.handleSearchBarPositionChange(position: option, index: indexPath)
                }
                switch position{
                case .onTop:
                    imageCell.topImageView.tintColor = .label
                    imageCell.bottomImageView.tintColor = .systemGray3
                case .onBottom:
                    imageCell.topImageView.tintColor = .systemGray3
                    imageCell.bottomImageView.tintColor = .label
                }
                imageCell.label.text = data.title
                imageCell.selectionStyle = .none
                return imageCell
            case .separators(_):
                let textCell = tableView.dequeueReusableCell(
                    withIdentifier: SettingsTextCell().identifier,
                    for: indexPath) as! SettingsTextCell
                textCell.label.text = data.title
                textCell.value.text = nil
                return textCell
            }
        }()
        return cellToPresent
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        settingsData.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 1{
            return 150
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 80
        }
        return UITableView.automaticDimension
    }
}
