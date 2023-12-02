//
//  StatisticVC.swift
//  Language
//
//  Created by Star Lord on 16/02/2023.
//

import UIKit
import Combine
import SwiftUI
import DGCharts


private enum ActivePicker{
    case left
    case right
    case custom
}
class StatisticView: UIViewController {
    //MARK: Properties
    private var viewModel: StatisticViewModel?
    private var cancellable = Set<AnyCancellable>()
    
    var input: PassthroughSubject<StatisticViewModel.Input, Never>? = .init()
    
    private lazy var pieChartView: PieStatisticView? = PieStatisticView()
    ///Keep information about selected and visible picker.
    private var activePicker: ActivePicker? = nil {
        didSet {
            dismissPanGesture.isEnabled = activePicker == nil ? false : true
        }
    }
    
    //MARK: Views
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .attributedString(
            string: "statistic.title".localized,
            with: .helveticaNeueBold,
            ofSize: 23)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let legendTableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(StatisticViewCell.self, forCellReuseIdentifier: StatisticViewCell.id)
        
        view.separatorStyle = .none
        view.backgroundColor = .clear
        
        view.allowsSelection = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    //MARK: Pickers call views and buttons
    private lazy var leftPickerView: PickerCallView = {
        let view = PickerCallView(
            title: "statistic.beginDate".localized,
            subtitle: "---"
        )
        
        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor.label.cgColor
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var rightPickerView: PickerCallView = {
        let view = PickerCallView(
            title: "statistic.endDate".localized,
            subtitle: "---"
        )
        
        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor.label.cgColor
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let customPickerCallButton: UIButton = {
        let button = UIButton()
        button.setImage(
            UIImage(
                systemName: "slider.vertical.3",
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold, scale: .medium)) ,
            for: .normal)
        
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: Pickers
    private let leftDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .wheels
        picker.datePickerMode = .date
        picker.maximumDate = .now
        picker.alpha = 0
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    private let rightDatePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .wheels
        picker.datePickerMode = .date
        picker.alpha = 0
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let customRangePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.alpha = 0
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    //MARK: Gestures
    private var dismissPanGesture = UIPanGestureRecognizer()
    
    //MARK: Dimensions
    private let subviewsInset: CGFloat = 20
    private let customButtonsHeight: CGFloat = 50
    
    private var pieViewTopAnchorToButton: NSLayoutConstraint!
    private var pieViewTopAnchorToPicker: NSLayoutConstraint!
    
    //MARK: Inherited
    required init(viewModel: StatisticViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil , bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: NSCoder) wasn't imported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bind()
        configureTitleLabel()
        configureCustomButton()
        configurePickersButton()
        configureCustomRangePicker()
        configureDatePickers()
        configurePieChartView()
        configureTableView()
        configurePickerDismissGesture()
        
        input?.send(.viewDidLoad)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            leftPickerView.layer.borderColor = UIColor.label.cgColor
            rightPickerView.layer.borderColor = UIColor.label.cgColor
        }
    }
        
    //MARK: Binding.
    func bind(){
        guard let output = viewModel?.transform(input: input?.eraseToAnyPublisher()) else { return }
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output{
                case .shouldUpdatePieChartWith(let data):
                    self?.pieChartView?.setUpChartData(data)
                    self?.legendTableView.reloadData()
                case .shouldUpdateSelectedInterval(let interval):
                    self?.updateSelectedInterval(interval)
                case .shouldUpdateCustomInterval:
                    self?.updateCustomPicker()
                case .shouldPresent(let error):
                    self?.presentError(error)
                }
            }
            .store(in: &cancellable)
    }
    
    //MARK: Subviews configuration
    ///Laying out title label.
    private func configureTitleLabel(){
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: subviewsInset),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: subviewsInset),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -subviewsInset),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    ///Laying out and setting up customPickerButton
    private func configureCustomButton(){
        view.addSubview(customPickerCallButton)
        
        customPickerCallButton.addTarget(self, action: #selector(customViewDidTap(sender:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            
            customPickerCallButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            customPickerCallButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -subviewsInset),
            
        ])
    }
    
    ///Laying out and setting up  right and left picker call buttons
    private func configurePickersButton(){
        view.addSubviews(leftPickerView, rightPickerView)
        
        let viewWidth: CGFloat = (view.bounds.width - subviewsInset * 2) / 2
        
        leftPickerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftPickerViewDidTap(sender: ))))
        rightPickerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightPickerViewDidTap(sender: ))))
        
        NSLayoutConstraint.activate([
            leftPickerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: subviewsInset),
            leftPickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: subviewsInset),
            leftPickerView.widthAnchor.constraint(equalToConstant: viewWidth),
            leftPickerView.heightAnchor.constraint(equalToConstant: customButtonsHeight),
            
            
            rightPickerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: subviewsInset),
            rightPickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -subviewsInset),
            rightPickerView.widthAnchor.constraint(equalToConstant: viewWidth),
            rightPickerView.heightAnchor.constraint(equalToConstant: customButtonsHeight),
            
        ])
    }
    private func configureDatePickers(){
        view.addSubviews(leftDatePicker, rightDatePicker)
        
        leftDatePicker.addTarget(self, action: #selector(dataPickerDidSelect(sender: )), for: .valueChanged )
        rightDatePicker.addTarget(self, action: #selector(dataPickerDidSelect(sender: )), for: .valueChanged )
        
        NSLayoutConstraint.activate([
            leftDatePicker.topAnchor.constraint(equalTo: leftPickerView.bottomAnchor, constant: subviewsInset),
            leftDatePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            rightDatePicker.topAnchor.constraint(equalTo: rightPickerView.bottomAnchor, constant: subviewsInset),
            rightDatePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    private func configureCustomRangePicker(){
        view.addSubview(customRangePicker)
        
        customRangePicker.delegate = self
        customRangePicker.dataSource = self

        NSLayoutConstraint.activate([
            customRangePicker.topAnchor.constraint(equalTo: leftPickerView.bottomAnchor, constant: subviewsInset),
            customRangePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func configurePickerDismissGesture(){
        dismissPanGesture = UIPanGestureRecognizer(target: self, action: #selector(viewDidPan(sender:)))
        dismissPanGesture.isEnabled = false
        self.view.addGestureRecognizer(dismissPanGesture)
    }
    
    private func configurePieChartView(){
        guard let pieChartView = pieChartView else { return }
        
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        pieChartView.delegate = self
        
        pieViewTopAnchorToButton = pieChartView.topAnchor.constraint(equalTo: leftPickerView.bottomAnchor, constant: subviewsInset)
        pieViewTopAnchorToPicker = pieChartView.topAnchor.constraint(equalTo: leftDatePicker.bottomAnchor, constant: subviewsInset)
        
        view.addSubview(pieChartView)
        
        NSLayoutConstraint.activate([
            pieViewTopAnchorToButton,
            pieChartView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pieChartView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            pieChartView.heightAnchor.constraint(equalTo: pieChartView.widthAnchor, multiplier: 1),
        ])
    }
    private func configureTableView(){
        view.addSubview(legendTableView)
        
        legendTableView.delegate = self
        legendTableView.dataSource = self
        
        NSLayoutConstraint.activate([
            legendTableView.topAnchor.constraint(equalTo: pieChartView?.bottomAnchor ?? leftPickerView.bottomAnchor, constant: 20),
            legendTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            legendTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            legendTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    //MARK: System
    private func updateSelectedInterval(_ interval: DateInterval){
        self.leftPickerView.updateSubtitleLabel(with: convertDateToString(interval.start))
        leftDatePicker.setDate(interval.start, animated: false)
        self.rightPickerView.updateSubtitleLabel(with: convertDateToString(interval.end))
        rightDatePicker.setDate(interval.end, animated: false)
    }
    
    
    private func convertDateToString(_ date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = viewModel?.currentLocale()
        
        return formatter.string(from: date)
    }
    
    ///Update custom picker selected value.
    private func updateCustomPicker(){
        let row = viewModel?.selectedRowForPicker() ?? 0
        self.customRangePicker.selectRow(row, inComponent: 0, animated: false)
    }
    
    //MARK: Animations
    ///Checks if passed picker is active. If so, deactivate it. If not - changing chart  layout and reval picker.
    private func updateDisplayedPicker(for picker: ActivePicker){
        var selectedDatePicker: UIDatePicker = .init()
        var selectedDatePickerView: PickerCallView?
        
        switch picker{
        case .custom:
            updateDisplayedCustomPicker(for: customRangePicker)
            return
        case .left:
            selectedDatePicker = leftDatePicker
            selectedDatePickerView = leftPickerView
        case .right:
            selectedDatePicker = rightDatePicker
            selectedDatePickerView = rightPickerView
        }
        
        if activePicker == picker{
            self.updatePieChartLayout(toInitial: true)
            UIView.animate(withDuration: 0.6) {
                selectedDatePickerView?.backgroundColor = .systemBackground
                selectedDatePicker.alpha = 0
            }
            activePicker = nil
        } else {
            UIView.animate(withDuration: 0.6) { [weak self] in
                switch self?.activePicker {
                case .custom:
                    self?.customRangePicker.alpha = 0
                case .left:
                    self?.leftDatePicker.alpha = 0
                    self?.leftPickerView.backgroundColor = .systemBackground
                case .right:
                    self?.rightDatePicker.alpha = 0
                    self?.rightPickerView.backgroundColor = .systemBackground
                case .none:
                    self?.updatePieChartLayout(toInitial: false)
                }
                selectedDatePickerView?.backgroundColor =
                    .tertiarySystemGroupedBackground
                selectedDatePicker.alpha = 1
            }
            self.activePicker = picker
        }
    }
    ///Checks if custom picker active and deactivating it if so. Activating with animation, if not.
    private func updateDisplayedCustomPicker(for picker: UIPickerView){
        UIView.animate(withDuration: 0.6) { [weak self] in
            switch self?.activePicker {
            case .custom:
                self?.customRangePicker.alpha = 0
                self?.updatePieChartLayout(toInitial: true)
                self?.activePicker = nil
                return
            case .right:
                self?.rightDatePicker.alpha = 0
                self?.rightPickerView.backgroundColor = .systemBackground
            case .left:
                self?.leftDatePicker.alpha = 0
                self?.leftPickerView.backgroundColor = .systemBackground
            case .none:
                self?.updatePieChartLayout(toInitial: false)
            }
            self?.customRangePicker.alpha = 1
            self?.activePicker = .custom
            
        }
    }
    
    //Since there shouldn't be two constraints with the same anchor active together, we need to change order.
    ///Changing the constraints for PieView.
    private func updatePieChartLayout(toInitial: Bool){
        UIView.animate(withDuration: 0.6) { [weak self] in
            if toInitial {
                self?.pieViewTopAnchorToPicker.isActive = !toInitial
                self?.pieViewTopAnchorToButton.isActive = toInitial
            } else {
                self?.pieViewTopAnchorToButton.isActive = toInitial
                self?.pieViewTopAnchorToPicker.isActive = !toInitial
            }
            self?.view.layoutIfNeeded()
        }
    }
    
    //MARK: System
    ///Checks if end date greater than begin date. If not, update values with active picker as primary.
    func validateDatePickerInput(sender: UIDatePicker){
        print("validate")
        if leftDatePicker.date > rightDatePicker.date {
            print("needed")
            if sender === rightDatePicker {
                print("completed")
                leftDatePicker.date = sender.date
                leftPickerView.updateSubtitleLabel(with: convertDateToString(sender.date))
            } else {
                print("completed")
                rightDatePicker.date = sender.date
                rightPickerView.updateSubtitleLabel(with: convertDateToString(sender.date))
            }
        }
    }
    
}
//MARK: - Actions
extension StatisticView {
    //Ralated to picekes,
    @objc func leftPickerViewDidTap(sender: UIView){
        updateDisplayedPicker(for: .left)
    }
    @objc func rightPickerViewDidTap(sender: UIView){
        updateDisplayedPicker(for: .right)
    }
    @objc func customViewDidTap(sender: Any){
        updateDisplayedPicker(for: .custom)
    }
    
    ///Called in responce on attached dataPicker value change.
    @objc func dataPickerDidSelect(sender: UIDatePicker){
        validateDatePickerInput(sender: sender)
        let interval = DateInterval(start: leftDatePicker.date, end: rightDatePicker.date)
        input?.send(.selectedIntervalUpdated(interval))
    }

    ///Related to panGesture, which becoming accessable with picker..
    @objc func viewDidPan(sender: UIPanGestureRecognizer){
        guard let picker = activePicker else { return }

        let translation = sender.translation(in: view).y
        
        if translation < -10 {
            updateDisplayedPicker(for: picker)
        }
    }
}
//MARK: - Extend for TableView delegate and DataSource
extension StatisticView: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.numberOfRowsInTableView() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticViewCell.id, for: indexPath) as? StatisticViewCell, let data = viewModel?.dataForTableViewCell(at: indexPath) else {
            return UITableViewCell()
        }
        cell.configureCellWith(data)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
}
//MARK: - Extend for PickerView Delegate and DataSource
extension StatisticView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel?.numberOfRowsInPicker() ?? 0
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel?.didSelectPickerRowAt(row)
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel?.titleForPickerRowAt(row).localized
    }
}

extension StatisticView: ChartViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        chartView.highlightValue(nil)
        guard let pieEntry = entry as? PieChartDataEntry else { return }
        input?.send(.selectedChartEntryUpdated(pieEntry))
    }
}
