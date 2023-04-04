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
        return view
    }()
    let dataForCells = [["Theme", "Language", "Colour preferences", "Enable Siri", "Preferred appearance"],
                        ["Separate simbols", "bla bla", "bla bla", "bla bla"],
                        ["Separate simbols", "bla bla", "bla bla", "bla bla", "Bla"],
                        ["Separate simbols", "bla bla", "bla bla", "bla bla"]
    ]
    let dataForHeaders = ["General", "Dictionary", "Search", "SomeThing"]
    
    let firstParamView: UIView = {
        let view = UIView()
        view.setUpBorderedView(true)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let secondParamView: UIView = {
        let view = UIView()
        view.setUpBorderedView(true)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let thirdParamView: UIView = {
        let view = UIView()
        view.setUpBorderedView(true)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBarCustomization()
        tableViewCustomization()
        
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
        navigationItem.title = "Setting"
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
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

    func firstViewCustomization(){
                
        let label = {
            let label = UILabel()
            label.attributedText = NSAttributedString().fontWithString(string: "Preffered mode", bold: false, size: 18)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        let segment = {
            let segment = UISegmentedControl()
            segment.isSpringLoaded = true
            
            segment.insertSegment(withTitle: "Light", at: 0, animated: true)
            segment.insertSegment(withTitle: "Dark", at: 1, animated: true)
            segment.addTarget(self, action: #selector(self.segmentTap(sender: )), for: .valueChanged)
            segment.translatesAutoresizingMaskIntoConstraints = false
            return segment
        }()
        
        view.addSubview(firstParamView)
        firstParamView.addSubviews(label, segment)

        NSLayoutConstraint.activate([
            firstParamView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
            firstParamView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstParamView.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
            firstParamView.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
            
            label.leadingAnchor.constraint(equalTo: firstParamView.leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: firstParamView.centerYAnchor),
            
            segment.trailingAnchor.constraint(equalTo: firstParamView.trailingAnchor, constant: -15),
            segment.centerYAnchor.constraint(equalTo: firstParamView.centerYAnchor),
            segment.widthAnchor.constraint(equalTo: firstParamView.widthAnchor, multiplier: 0.4),
            segment.heightAnchor.constraint(equalTo: firstParamView.heightAnchor, multiplier: 0.5)
        ])
    }
    
    func secondViewCustomization(){
        view.addSubview(secondParamView)
        NSLayoutConstraint.activate([
        secondParamView.topAnchor.constraint(equalTo: firstParamView.bottomAnchor, constant: 23),
        secondParamView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        secondParamView.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
        secondParamView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    func thirdViewCustomization(){
        view.addSubview(thirdParamView)
        NSLayoutConstraint.activate([
        thirdParamView.topAnchor.constraint(equalTo: secondParamView.bottomAnchor, constant: 23),
        thirdParamView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        thirdParamView.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
        thirdParamView.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
        ])
    }
    @objc func segmentTap(sender: UISegmentedControl){
        
    }
    func viewForHeader(name: String) -> UITableViewHeaderFooterView{
        let vieww = UITableViewHeaderFooterView()
        var content = vieww.defaultContentConfiguration()
        content.text = name
        content.attributedText = NSAttributedString(string: name, attributes:
                                                        [NSAttributedString.Key.font :
                                                            UIFont(name: "Helvetica Neue Medium", size: 20) ?? UIFont(),
                                                         NSAttributedString.Key.foregroundColor: UIColor.label
                                                        ])

        vieww.contentConfiguration = content
        vieww.backgroundColor = .systemGray6.withAlphaComponent(0.8)
        
        
        let view : UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.8)
            return view
        }()
        
        
        
        let label : UILabel = {
            let label = UILabel()
            label.font = UIFont(name: "Helvetica Neue Medium", size: 20)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .label
            return label
        }()
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
        return vieww
    }
}
extension SettingsVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        viewForHeader(name: dataForHeaders[section])
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        44
    }
}

extension SettingsVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataForCells[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsTBCell
        cell.label.text = dataForCells[indexPath.section][indexPath.row]
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
    
    
}
