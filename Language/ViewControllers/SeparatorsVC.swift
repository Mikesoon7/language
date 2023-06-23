//
//  SeparatorsVC.swift
//  Language
//
//  Created by Star Lord on 29/04/2023.
//

import UIKit

class SeparatorsVC: UIViewController{
    
    var selectedValue = UserSettings.shared.settings.separators.selectedValue
    var informationToPresent = UserSettings.shared.settings.availabelSeparators
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(SeparatorsCell.self, forCellReuseIdentifier: SeparatorsCell().identifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.delegate = self
        view.dataSource = self
        
        view.subviews.forEach { view in
            view.addShadowWhichOverlays(false)
        }
        return view
    }()
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue Medium", size: 30)
        label.text = "howIt'sWorking".localized
        label.numberOfLines = 0
        label.textAlignment = .left
        label.tintColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let messageLabelFirstPart: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.tintColor = .label
        label.text = "firstMessage".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let messageLabelSecondPart: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.tintColor = .label
        label.text = "secondMessage".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var firstExampleView : UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.addShadowWhichOverlays(true)
        view.layer.cornerRadius = 9
        view.layer.borderWidth = 0.2
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let firstLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let secondLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Helvetica Neue", size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var secondExampleView : UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.addShadowWhichOverlays(false)
        view.layer.cornerRadius = 9
        view.layer.borderWidth = 0.2
        view.layer.masksToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let thirdLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let fourthLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let suggestionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.tintColor = .label
        label.text = "informMessage".localized

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var heightForExampleViews: CGFloat = 100
    
    var heightForTableView : NSLayoutConstraint?
    var suggestionTopAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        exampleViewCustomization()
        viewCustomization()
        gesturesCustomization()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            if traitCollection.userInterfaceStyle == .dark{
                firstExampleView.layer.shadowColor = shadowColorForDarkIdiom
                secondExampleView.layer.shadowColor = shadowColorForDarkIdiom
                tableView.subviews.forEach { view in
                    view.layer.shadowColor = shadowColorForDarkIdiom
                }
            } else {
                firstExampleView.layer.shadowColor = shadowColorForLightIdiom
                secondExampleView.layer.shadowColor = shadowColorForLightIdiom
                tableView.subviews.forEach { view in
                    view.layer.shadowColor = shadowColorForLightIdiom
                }
            }
        }
    }
    func viewCustomization(){
        view.addSubviews(headerLabel, messageLabelFirstPart, firstExampleView,
                         secondExampleView, messageLabelSecondPart, tableView, suggestionLabel)

        NSLayoutConstraint.activate([
            headerLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            headerLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            messageLabelFirstPart.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            messageLabelFirstPart.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            messageLabelFirstPart.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            firstExampleView.topAnchor.constraint(equalTo: messageLabelFirstPart.bottomAnchor, constant: 20),
            firstExampleView.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor, constant: 10),
            firstExampleView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: view.bounds.width * 0.3),
            firstExampleView.heightAnchor.constraint(equalToConstant: heightForExampleViews),
            
            secondExampleView.topAnchor.constraint(equalTo: firstExampleView.centerYAnchor),
            secondExampleView.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: -(view.bounds.width * 0.3)),
            secondExampleView.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: -10),
            secondExampleView.heightAnchor.constraint(equalToConstant: heightForExampleViews),
            
            messageLabelSecondPart.topAnchor.constraint(equalTo: secondExampleView.bottomAnchor, constant: 20),
            messageLabelSecondPart.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            messageLabelSecondPart.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: messageLabelSecondPart.bottomAnchor),
                        
            suggestionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            suggestionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
        ])
        heightForTableView = tableView.heightAnchor.constraint(
            equalToConstant: CGFloat(tableView.numberOfRows(inSection: 0) * 35) + 50.0)
        suggestionTopAnchor = suggestionLabel.topAnchor.constraint(
            equalTo: tableView.topAnchor, constant: (heightForTableView?.constant ?? 0) + 30 )
    
        heightForTableView?.isActive = true
        suggestionTopAnchor?.isActive = true
        
        view.bringSubviewToFront(firstExampleView)
    }
    func exampleViewLabelCustomization(){
        firstLabel.text = "Hello world \(selectedValue) is greeting."
      
        secondLabel.text = "Sun \(selectedValue) it's shine \(selectedValue) but also heat."
        
        let text = NSMutableAttributedString(
            string: "Hello world ",
            attributes: [NSAttributedString.Key.font
                         : UIFont(name: "Helvetica Neue Medium", size: 18) ?? UIFont()])
        text.append(NSAttributedString(
            string: selectedValue,
            attributes: [NSAttributedString.Key.foregroundColor :
                            UIColor.red, NSAttributedString.Key.font :
                            UIFont(name: "Helvetica Neue Bold", size: 18) ?? UIFont()]))
        text.append(NSAttributedString(
            string: " is greeting.",
            attributes: [NSAttributedString.Key.font:
                            UIFont(name: "Helvetica Neue", size: 18) ?? UIFont()]))
        thirdLabel.attributedText = text
        
        let textTwo = NSMutableAttributedString(
            string: "Sun ",
            attributes: [NSAttributedString.Key.font
                         : UIFont(name: "Helvetica Neue Medium", size: 18) ?? UIFont()])
        textTwo.append(NSAttributedString(
            string: selectedValue,
            attributes: [NSAttributedString.Key.foregroundColor :
                            UIColor.red, NSAttributedString.Key.font :
                            UIFont(name: "Helvetica Neue Bold", size: 18) ?? UIFont()]))
        textTwo.append(NSAttributedString(
            string: " it's shine \(selectedValue) but also heat.",
            attributes: [NSAttributedString.Key.font:
                            UIFont(name: "Helvetica Neue", size: 18) ?? UIFont()]))
        fourthLabel.attributedText = textTwo
    }
    func exampleViewCustomization(){
        exampleViewLabelCustomization()
        firstExampleView.addSubviews(firstLabel, secondLabel)
        secondExampleView.addSubviews(thirdLabel, fourthLabel)
        
        NSLayoutConstraint.activate([
            firstLabel.centerYAnchor.constraint(equalTo: firstExampleView.topAnchor, constant: 20),
            firstLabel.leadingAnchor.constraint(equalTo: firstExampleView.leadingAnchor, constant: 10),
            
            secondLabel.topAnchor.constraint(equalTo: firstLabel.bottomAnchor, constant: 0),
            secondLabel.leadingAnchor.constraint(equalTo: firstExampleView.leadingAnchor, constant: 10),
            
            thirdLabel.centerYAnchor.constraint(equalTo: secondExampleView.topAnchor,
                                                constant: heightForExampleViews / 3),
            thirdLabel.leadingAnchor.constraint(equalTo: secondExampleView.leadingAnchor, constant: 10),
            
            fourthLabel.centerYAnchor.constraint(equalTo: secondExampleView.bottomAnchor,
                                                 constant: -(heightForExampleViews / 3)),
            fourthLabel.leadingAnchor.constraint(equalTo: secondExampleView.leadingAnchor, constant: 10),
        ])
        firstExampleView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
    }
    func gesturesCustomization(){
        let first = UITapGestureRecognizer(target: self, action: #selector(exampleViewTapped(sender:)))
        firstExampleView.addGestureRecognizer(first)
        let second = UITapGestureRecognizer(target: self, action: #selector(exampleViewTapped(sender:)))
        secondExampleView.addGestureRecognizer(second)
    }
    func updateTableConstraits(isDeleted: Bool){
        tableView.reloadData()
        if isDeleted{
            heightForTableView?.constant -= 35
        } else {
            heightForTableView?.constant += 35
        }
        suggestionTopAnchor?.constant = heightForTableView?.constant ?? 0
        view.layoutIfNeeded()
    }
    func updateExampleViewSize(_ view: UIView, secondView: UIView ){
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        view.addShadowWhichOverlays(true)
        secondView.transform = .identity
        secondView.addShadowWhichOverlays(false)

    }
    func addAlertMessage(){
        let alert = UIAlertController(title: "Type from 1 to 3 characters", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Text"
            textField.keyboardType = .numbersAndPunctuation
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }
        let invalidInput = UIAlertController(title: "Invalid input", message: "Please, don't use duplicates.", preferredStyle: .alert)
        let spaceInput = UIAlertController(title: "Invalid input", message: "Please, don't use spaces only", preferredStyle: .alert)
        invalidInput.addAction(UIAlertAction(title: "agreeInformal".localized, style: .cancel))
        spaceInput.addAction(UIAlertAction(title: "agreeInformal".localized, style: .cancel))
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            if let textField = alert.textFields?.first, var text = textField.text {
                guard !text.isEmpty, let self = self else {
                    return
                }
                if text.trimmingCharacters(in: CharacterSet(charactersIn: " ")).isEmpty {
                    self.present(spaceInput, animated: true)
                } else {
                    text = text.trimmingCharacters(in: CharacterSet(charactersIn: " "))
                }
                
                guard text.trimmingCharacters(in: CharacterSet(charactersIn: " ")) != "" else{
                    return
                }
                guard !self.informationToPresent.contains(text) else {
                    self.present(invalidInput, animated: false)
                    return
                }

                UserSettings.shared.updateCustomSeparators(newSeparator: text, indexPath: nil)
                self.informationToPresent = UserSettings.shared.settings.availabelSeparators
                if self.informationToPresent.count != 5{
                    self.updateTableConstraits(isDeleted: false)
                } else {
                    self.tableView.reloadData()
                }
            }
        }

        alert.addAction(confirmAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    @objc func exampleViewTapped(sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        if view == firstExampleView {
            self.view.insertSubview(view, aboveSubview: secondExampleView)
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.updateExampleViewSize(view, secondView: self!.secondExampleView)
            }
        } else {
            self.view.insertSubview(view, aboveSubview: firstExampleView)
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.updateExampleViewSize(view, secondView: self!.firstExampleView)
            }
        }
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, text.count > 3 {
            textField.text = String(text.prefix(3))
        }
    }
    
}
extension SeparatorsVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SeparatorsCell().identifier, for: indexPath) as! SeparatorsCell
        if indexPath.row == informationToPresent.endIndex && informationToPresent.count != 5{
            cell.label.text = "Add character"
            cell.addImage.tintColor = .label
            return cell
        } else {
            let text = informationToPresent[indexPath.row]
            cell.label.text = text
            if text == selectedValue{
                cell.didSelect()
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 && indexPath.row > informationToPresent.count - 1{
            addAlertMessage()
        } else {
            UserSettings.shared.reload(
                newValue: UserSettings.AppDictionarySeparators.selected(informationToPresent[indexPath.row]))
            selectedValue = informationToPresent[indexPath.row]
            exampleViewLabelCustomization()
            tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == informationToPresent.firstIndex(of: selectedValue){
            return false
        } else {
            return true
        }
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [UIContextualAction(style: .destructive, title: "Delete", handler: { action, view, completion in
            self.informationToPresent.remove(at: indexPath.row)
            UserSettings.shared.updateCustomSeparators(newSeparator: "", indexPath: indexPath)
            if self.informationToPresent.count < 4 {
                self.updateTableConstraits(isDeleted: true)
            } else {
                self.tableView.reloadData()
            }
        })])
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        min(informationToPresent.count + 1, 5)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         35
    }
}
