//
//  SettingsVC.swift
//  Language
//
//  Created by Star Lord on 05/03/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit
import Combine

class SettingsVC: UIViewController {
    
    private let viewModelFactory: ViewModelFactory
    private let viewModel:  SettingsViewModel
    private var cancellable = Set<AnyCancellable>()
    
    //MARK: Views.
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.register(SettingsHeaderCell.self, forCellReuseIdentifier: SettingsHeaderCell.identifier)
        view.register(SettingsTextCell.self, forCellReuseIdentifier: SettingsTextCell.identifier)
        view.register(SettingsImageCell.self, forCellReuseIdentifier: SettingsImageCell.identifier)
        
        view.backgroundColor = .clear
        view.separatorStyle = .none
    
        view.translatesAutoresizingMaskIntoConstraints = false
        view.subviews.forEach { sections in
            sections.addCenterShadows()
        }
        return view
    }()
    
    //MARK: Inherited
    required init(factory: ViewModelFactory){
        self.viewModelFactory = factory
        self.viewModel = factory.configureSettingsViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureTableView()
        configureLabels()
    }
        
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            tableView.subviews.forEach { view in
                view.layer.shadowColor = (traitCollection.userInterfaceStyle == .dark
                                          ? shadowColorForDarkIdiom
                                          : shadowColorForLightIdiom )
            }
        }
    }
    //MARK: Binding View and ViewModel
    private func bind(){
        viewModel.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output{
                case .needPresentAlertWith(let actions, let index):
                    self?.presentAlertWith(action: actions, indexPath: index)
                case .needUpdateRowAt(let index):
                    self?.tableView.reloadRows(at: [index], with: .fade)
                case .needUpdateFont:
                    self?.tableView.reloadData()
                case .needUpdateLanguage:
                    self?.configureLabels()
                    self?.tableView.reloadData()
                case .needPresentFontView:
                    self?.presentFontVC()
                case .needPresentNotificationView:
                    self?.presentNotificationVC()
                case .needPresentSeparatorsView:
                    self?.presentSeparatorVC()
                case .needPresentExceptionsView:
                    self?.presentExceptionVC()
                case .needPresentTutorialView:
                    self?.presentTutorialVC()
                }
            }
            .store(in: &cancellable)
    }
    //MARK: Subviews SetUp
    private func configureTableView(){
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    //MARK: System
    private func presentNotificationVC(){
        let vc = NotificationView(factory: viewModelFactory)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
    private func presentFontVC(){
        let fontConfig = UIFontPickerViewController.Configuration()
        fontConfig.includeFaces = true
        let fontPicker = UIFontPickerViewController(configuration: fontConfig)
        fontPicker.delegate = self
        self.present(fontPicker, animated: true, completion: nil)
    }
    private func presentSeparatorVC(){
        let vc = SeparatorsView(factory: viewModelFactory)
        self.present(vc, animated: true)
    }
    private func presentExceptionVC(){
        let vc = ExceptionsVC(factory: viewModelFactory)
        self.present(vc, animated: true)
    }
    private func presentTutorialVC(){
        let vc = TutorialVCTest()
        self.navigationController?.present(vc, animated: true)
    }
    //Attaching cancel action to passed action.
    private func presentAlertWith(action: [UIAlertAction], indexPath: IndexPath) {
        let alertMessage = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "system.cancel".localized, style: .cancel)
        action.forEach { alertMessage.addAction($0) }
        alertMessage.addAction(cancelAction)

        guard let cell = tableView.cellForRow(at: indexPath),
              let cellFrame = cell.superview?.convert(cell.frame, to: self.view) else {
            return
        }

        //Defining center of the selected cell.
        let tapLocation = CGPoint(x: cellFrame.midX, y: cellFrame.midY)

        // Blank for the future iPad support.
        if let popoverController = alertMessage.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: tapLocation.x, y: tapLocation.y, width: 1, height: 1)
            popoverController.permittedArrowDirections = .left
        }

        self.present(alertMessage, animated: true)
    }

    private func configureLabels(){
        navigationItem.title = "settings.title".localized
        
    }
}

//MARK: - UITableView Delegate & DataSource
extension SettingsVC: UITableViewDelegate,  UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberofRowsInSection(section: section)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRowAt(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = UITableViewCell()
        let data = viewModel.dataForCellAt(indexPath: indexPath)
        if let data = data as? DataForSettingsHeaderCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsHeaderCell.identifier, for: indexPath) as? SettingsHeaderCell else { return defaultCell }
            cell.configureCellWithData(data)
            return cell
        } else
        if let data = data as? DataForSettingsTextCell{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTextCell.identifier, for: indexPath) as? SettingsTextCell else { return defaultCell }
            cell.configureCellWithData(data)
            return cell
        } else
        if let data = data as? DataForSettingsImageCell{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsImageCell.identifier, for: indexPath) as? SettingsImageCell  else { return defaultCell }
            cell.configureCellWithData(data)
            return cell
        }
        return defaultCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.heightForRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 80
        }
        return UITableView.automaticDimension
    }
}

extension SettingsVC: UIFontPickerViewControllerDelegate {
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        guard let selectedFont = viewController.selectedFontDescriptor else { return }
        viewModel.updateSelectedFont(font: selectedFont)
        
        viewController.dismiss(animated: true)
    }
}
