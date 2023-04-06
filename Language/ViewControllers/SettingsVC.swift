//
//  SettingsVC.swift
//  Language
//
//  Created by Star Lord on 05/03/2023.
//

import UIKit

class SettingsVC: UIViewController {
    
    let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(SettingsTBCell.self, forCellReuseIdentifier: "settingsCell")
        view.rowHeight = 20
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorStyle = .none
        return view
    }()
    var dataForSettings: [[SettingsSection]] = [
        [SettingsSection(
            settingsType: SettingsType.General.rawValue ,
            title: "Theme" ,
            value: SettingsData.shared.appTheme.rawValue),
         SettingsSection(
            settingsType: SettingsType.General.rawValue,
            title: "Language",
            value: SettingsData.shared.appLanguage.rawValue)
        ],
        [SettingsSection(
            settingsType: SettingsType.Search.rawValue,
            title: "Seaarch bar",
            value: "On Top")]
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
        navigationItem.title = "Settings"

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

    @objc func segmentTap(sender: UISegmentedControl){
        
    }
    func viewForHeader(name: String) -> UITableViewHeaderFooterView{
        let view = UITableViewHeaderFooterView()
        var content = view.defaultContentConfiguration()
        content.text = name
        content.attributedText = NSAttributedString(string: name, attributes:
                                                        [NSAttributedString.Key.font :
                                                            UIFont(name: "Helvetica Neue Medium", size: 20) ?? UIFont(),
                                                         NSAttributedString.Key.foregroundColor: UIColor.label
                                                        ])

        view.contentConfiguration = content
        view.backgroundColor = .systemGray6.withAlphaComponent(0.8)
        return view
    }
    func handleThemeSelection(theme: SettingsData.AppTheme) {
        SettingsData.shared.updateTheme(theme: theme)
        // Обновите интерфейс приложения с учетом новой темы, если это необходимо.
        
    }
    @objc func themeDidChange(sender: Any){
        let indexPath = IndexPath(item: 0, section: 0)
        dataForSettings[0][0].value = SettingsData.shared.appTheme.rawValue
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    @objc func languageDidChange(sender: Any){
        let indexPath = IndexPath(item: 1, section: 0)
        dataForSettings[0][1].value = SettingsData.shared.appLanguage.rawValue
    }
}
extension SettingsVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        viewForHeader(name: dataForSettings[section][0].title)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertMessage = UIAlertController(title: "There is no action", message: nil, preferredStyle: .actionSheet)
        if indexPath.section == 0 && indexPath.row == 0{
            let action1 = UIAlertAction(title: "Always light mode", style: .default) { [weak self] _ in
                self?.handleThemeSelection(theme: .light)
            }
            let action2 = UIAlertAction(title: "Always dark mode", style: .default){ [weak self] _ in
                self?.handleThemeSelection(theme: .dark)
            }
            let action3 = UIAlertAction(title: "Use system mode", style: .default){ [weak self] _ in
                self?.handleThemeSelection(theme: .deviceSettings)
            }
            let action4 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertMessage.title = nil
            alertMessage.addAction(action1)
            alertMessage.addAction(action2)
            alertMessage.addAction(action3)
            alertMessage.addAction(action4)
        }
        self.present(alertMessage, animated: true)
    }
}

extension SettingsVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataForSettings[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsTBCell
        let data = dataForSettings[indexPath.section][indexPath.row]
        cell.label.text = data.title
        cell.value.text = data.value
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        dataForSettings.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
}
