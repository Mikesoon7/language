//
//  SeparatorsVC.swift
//  Language
//
//  Created by Star Lord on 29/04/2023.
//

import UIKit
import Combine
import Foundation
class SeparatorsView: UIViewController{
    
    private enum InputError{
        case containsDuplicates
        case containsSpaceOnly
    }

    private let viewModel = SeparatorsViewModel()
    private var cancellabel = Set<AnyCancellable>()
    
    private var input = PassthroughSubject<SeparatorsViewModel.Input, Never>()
    
    private var selectedSeparator: String { viewModel.selectedSeparator() }
    private var availableSeparators: [String] { viewModel.availableSeparators() }
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(SeparatorsCell.self, forCellReuseIdentifier: SeparatorsCell.identifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let headerInfoLabel: UILabel = {
        let label = UILabel()
        label.font = .helveticaNeueMedium.withSize(30)
        label.text = "separators.title".localized
        label.numberOfLines = 0
        label.textAlignment = .left
        label.tintColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let firstInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.tintColor = .label
        label.font = .helveticaNeue.withSize(18)
        label.text = "separators.infoFirstPart".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let secondInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.tintColor = .label
        label.font = .helveticaNeue.withSize(18)
        label.text = "separators.infoSecondPart".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let lastInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.tintColor = .label
        label.font = .helveticaNeue.withSize(18)
        label.text = "separators.infoFinalPart".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //Custom subview with separator passing as variable value.
    private lazy var exampleView: SeparatorsExampleView = SeparatorsExampleView(frame: .zero, separator: selectedSeparator)
    
    //MARK: - Constraints and related
    private let heightForExampleViews: CGFloat = 80
    private let insetForSubviews: CGFloat = 20
    
    private var tableViewHeightAnchor : NSLayoutConstraint!
    private var lastInfoLabelTopAnchor: NSLayoutConstraint!
    
    //MARK: - Inherited and initializing methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureViewController()
        configureSubviews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            if traitCollection.userInterfaceStyle == .dark{
                exampleView.backgroundColor = .secondarySystemBackground
            } else {
                exampleView.backgroundColor = .clear
            }
        }
    }
    
    //MARK: - Binding with viewModel
    func bind(){
        let output = viewModel.transform(input: self.input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self ]output in
                guard let self = self else { return }
                switch output {
                case .shouldPresentAlertController:
                    self.addAlertMessage()
                case .shouldUpdateTable:
                    self.tableView.reloadData()
                    self.exampleView.updateSeparatorWith(self.selectedSeparator)
                case .shouldUpdateTablesHeight:
                    self.updateTableConstrait()
                }
                
            }
            .store(in: &cancellabel)
    }
    
    func configureViewController(){
        view.backgroundColor = .systemBackground
    }
    //MARK: Setting up every subviews layout
    func configureSubviews(){
        view.addSubviews(headerInfoLabel, firstInfoLabel, exampleView, secondInfoLabel, tableView, lastInfoLabel)

        tableView.delegate = self
        tableView.dataSource = self

        tableViewHeightAnchor = tableView.heightAnchor.constraint(
            equalToConstant: CGFloat(tableView.numberOfRows(inSection: 0) * 35) + 50.0)
        lastInfoLabelTopAnchor = lastInfoLabel.topAnchor.constraint(
            equalTo: tableView.topAnchor, constant: (tableViewHeightAnchor?.constant ?? 0) + insetForSubviews )

        NSLayoutConstraint.activate([
            headerInfoLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            headerInfoLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: insetForSubviews),
            headerInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            firstInfoLabel.topAnchor.constraint(equalTo: headerInfoLabel.bottomAnchor, constant: insetForSubviews),
            firstInfoLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            firstInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            exampleView.topAnchor.constraint(equalTo: firstInfoLabel.bottomAnchor, constant: insetForSubviews),
            exampleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exampleView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            exampleView.heightAnchor.constraint(equalToConstant: heightForExampleViews),
            
            secondInfoLabel.topAnchor.constraint(equalTo: exampleView.bottomAnchor, constant: insetForSubviews),
            secondInfoLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            secondInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: secondInfoLabel.bottomAnchor),
            tableViewHeightAnchor,
                        
            lastInfoLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            lastInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lastInfoLabelTopAnchor
        ])
    }
    //MARK: Updating subviewsConstraints.
    //Called in response to changing number of rows in tableView.
    func updateTableConstrait(){
        tableView.reloadData()
        tableViewHeightAnchor?.constant = CGFloat(tableView.numberOfRows(inSection: 0) * 35 + 50)
        lastInfoLabelTopAnchor?.constant = (tableViewHeightAnchor?.constant ?? 0 ) + insetForSubviews
        view.layoutIfNeeded()
    }
    
    //MARK: Text input alerts.
    func addAlertMessage(){
        let textInputAlert = UIAlertController(
            title: "separators.alertTitle".localized,
            message: nil, preferredStyle: .alert)
        
        textInputAlert.addTextField { (textField) in
            textField.placeholder = "separators.placeholder".localized
            textField.keyboardType = .numbersAndPunctuation
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }
                
        let confirmAction = UIAlertAction(title: "system.save".localized, style: .default) { [weak self] _ in
            if let textField = textInputAlert.textFields?.first, var text = textField.text {
                guard !text.isEmpty, let self = self else {
                    return
                }
                text = text.trimmingCharacters(in: CharacterSet(charactersIn: " "))
                
                if text.isEmpty {
                    self.presentErrorAlertWith(.containsSpaceOnly)
                    return
                } else if self.availableSeparators.contains(text) {
                    self.presentErrorAlertWith(.containsDuplicates)
                    return
                }
                self.input.send(.addSeparator(text))
            }
        }
        confirmAction.setValue(UIColor.label, forKey: "titleTextColor")
        textInputAlert.addAction(confirmAction)
        self.present(textInputAlert, animated: true, completion: nil)
    }
    
    //Calling in responce on empty or containing duplicates textField.
    private func presentErrorAlertWith(_ errorType: InputError){
        let title = "separators.alertErrorTitle"
        let message: String  = {
            switch errorType {
            case .containsDuplicates:
                return "separators.alertDuplicateMessage"
            case .containsSpaceOnly:
                return "separators.alertSpaceMessage"
            }
        }()
        let errorAlert = UIAlertController(
            title: title.localized,
            message: message.localized,
            preferredStyle: .alert)
        
        let agreeAction = UIAlertAction(title: "system.agreeInformal".localized, style: .default)
        agreeAction.setValue(UIColor.label, forKey: "titleTextColor")
        
        errorAlert.addAction(agreeAction)
        self.present(errorAlert, animated: true)
    }
        
    //MARK: Actions
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, text.count > 3 {
            textField.text = String(text.prefix(3))
        }
    }
    
}
//MARK: - TAbleViewDelegate & Source
extension SeparatorsView: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInTable()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = viewModel.dataForCellAt(indexPath: indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SeparatorsCell.identifier, for: indexPath) as? SeparatorsCell else { return UITableViewCell() }
        cell.configureCellWithData(cellData)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectCellAt(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        viewModel.canEditRowAt(indexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [UIContextualAction(style: .destructive, title: "system.delete".localized, handler: { action, view, completion in
            self.input.send(.deleteSeparator(indexPath))
        })])
    }
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         35
    }
}
