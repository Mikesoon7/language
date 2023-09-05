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



//"statistic.beginDate" = "Початок:";
//"statistic.endDate" = "Кінець:";
//Custom options
//"statistic.currentWeek" = "Поточний тиждень";
//"statistic.currentMonth" = "Поточний місяць";
//"statistic.previousMonth" = "Попередній місяць";
//"statistic.custom" = "Обрати свій";

enum ActivePicker{
    case left
    case right
    case custom
}
class StatisticVC: UIViewController {
    
    private var viewModel: StatisticViewModel
    
    private var data = [DictionaryLogData]()
    private var pieData: PieChartDataTotal!
    
    private lazy var hostingController = UIHostingController(rootView: StatisticPieView(data: data))
    private lazy var pieChartView = PieStatisticView(delegate: self)
    private var cancellables = Set<AnyCancellable>()
    
    
    private var activePicker: ActivePicker? = nil
    
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
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorStyle = .none
        
        view.backgroundColor = .clear
        return view
    }()
    
    
    //MARK: Pickers and pickers call view
    private lazy var leftPickerView: PickerCallButtonView = {
        let view = PickerCallButtonView(
            title: "statistic.beginDate".localized,
            subtitle: convertDateToString(
                viewModel.initialStatisticDate()))

        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor.label.cgColor
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var rightPickerView: PickerCallButtonView = {
        let view = PickerCallButtonView(
            title: "statistic.endDate".localized,
            subtitle: convertDateToString(
                viewModel.endStatisticDate()))
        
        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor.label.cgColor
        view.layer.borderWidth = 0.5
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let customizeButton: UIButton = {
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
    
//    private let rightPickerButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("End:", for: .normal)
//        button.titleLabel?.textAlignment = .left
//        button.subtitleLabel?.textAlignment = .left
//
//        button.backgroundColor = .systemGray6
//        button.tintColor = .label
//        button.clipsToBounds = true
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()

    private let leftPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .wheels
        picker.datePickerMode = .date
        picker.maximumDate = .now
        picker.alpha = 0
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    private let rightPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .wheels
        picker.datePickerMode = .date
        picker.alpha = 0
//        picker.maximumDate = .now
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let customPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.alpha = 0
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()

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
        print("StatisticVC was initialized")
        bind()
        configureTitleLabel()
        configureCustomButton()
        configurePickersButton()
        configureCustomPicker()
        configurePickers()
        configurePieChartView()
        configureTableView()
        
        print("prepare for viewModel fetch initiation")
        viewModel.fetchDataForStatisticPieView()
        
    }

    //MARK: Binding.
    func bind(){
        viewModel.viewOutput
            .sink { output in
                switch output{
                case .data(let data):
                    self.data = data
                    self.configureStatView()
                case .pieData(let data ):
                    self.pieData = data
                    self.pieChartView.setUpChartData(chartData: data)
                    self.legendTableView.reloadData()
                case .selectedRangeWasUpdated(let range):
                    self.updateSelectedRange(with: range)
                case .shouldUpdateCustomInterval:
                    self.updateCustomPicker()
                case .shouldDefineAllowedRange(let range):
                    self.leftPicker.minimumDate = range.start
                    self.rightPicker.minimumDate = range.start
                    self.leftPicker.maximumDate = range.end
                    
                case .error(let error):
                    self.presentError(error)
            
                }
            
            }
            .store(in: &cancellables)
    }
    
    func configureTitleLabel(){
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: subviewsInset),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: subviewsInset),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -subviewsInset),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    func configureCustomButton(){
        view.addSubview(customizeButton)
        
        customizeButton.addTarget(self, action: #selector(customViewDidTap(sender:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            customizeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            customizeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -subviewsInset),
//            customizeButton.heightAnchor.constraint(equalToConstant: customButtonsHeight),
//            customizeButton.widthAnchor.constraint(equalTo: customizeButton.heightAnchor),
        ])
    }
    func configurePickersButton(){
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
            
            
//            customPickerView.topAnchor.constraint(equalTo: titleLable.bottomAnchor, constant: subviewsInset),
//            customPickerView.leadingAnchor.constraint(equalTo: rightPickerView.trailingAnchor),
//            customPickerView.widthAnchor.constraint(equalToConstant: customButtonsHeight),
//            customPickerView.heightAnchor.constraint(equalToConstant: customButtonsHeight),
            
        ])
    }
    func configurePickers(){
        view.addSubviews(leftPicker, rightPicker)
        
        leftPicker.addTarget(self, action: #selector(dataPickerDidSelect(sender: )), for: .valueChanged )
        rightPicker.addTarget(self, action: #selector(dataPickerDidSelect(sender: )), for: .valueChanged )
        
        NSLayoutConstraint.activate([
            leftPicker.topAnchor.constraint(equalTo: leftPickerView.bottomAnchor, constant: subviewsInset),
            leftPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            rightPicker.topAnchor.constraint(equalTo: rightPickerView.bottomAnchor, constant: subviewsInset),
            rightPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    func configureCustomPicker(){
        view.addSubview(customPicker)
    
        customPicker.delegate = self
        customPicker.dataSource = self
        
        let preselectedRow = viewModel.selectedRowForPicker()
        customPicker.selectRow(preselectedRow, inComponent: 0, animated: false)
        
        NSLayoutConstraint.activate([
            customPicker.topAnchor.constraint(equalTo: leftPickerView.bottomAnchor, constant: subviewsInset),
            customPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    func configurePieChartView(){
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        
        pieViewTopAnchorToButton = pieChartView.topAnchor.constraint(equalTo: leftPickerView.bottomAnchor, constant: subviewsInset)
        pieViewTopAnchorToPicker = pieChartView.topAnchor.constraint(equalTo: leftPicker.bottomAnchor, constant: subviewsInset)

        view.addSubview(pieChartView)

        NSLayoutConstraint.activate([
            pieViewTopAnchorToButton,
            pieChartView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pieChartView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            pieChartView.heightAnchor.constraint(equalTo: pieChartView.widthAnchor, multiplier: 1),
        ])
    }
    func configureTableView(){
        legendTableView.delegate = self
        legendTableView.dataSource = self
        view.addSubview(legendTableView)
        
        NSLayoutConstraint.activate([
            legendTableView.topAnchor.constraint(equalTo: pieChartView.bottomAnchor, constant: 20),
            legendTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            legendTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            legendTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func configureStatView(){
        guard let charts = hostingController.view else { return }
        charts.backgroundColor = .clear
        charts.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubviews(charts)
        
        NSLayoutConstraint.activate([
            
            charts.topAnchor.constraint(equalTo: pieChartView.bottomAnchor, constant: 20),
            charts.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            charts.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10),
            charts.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ])
    }
    private func updateSelectedRange(with range: SelectedRange){
        self.leftPickerView.updateSubtitleLabel(with: convertDateToString(range.beginDate))
        leftPicker.setDate(range.beginDate, animated: false)
        self.rightPickerView.updateSubtitleLabel(with: convertDateToString(range.endDate))
        rightPicker.setDate(range.endDate, animated: false)


    }
    private func convertDateToString(_ date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        return formatter.string(from: date)
//        date.formatted(date: .abbreviated, time: .omitted)
    }
    
    private func updateCustomPicker(){
        let row = viewModel.selectedRowForPicker()
        self.customPicker.selectRow(row, inComponent: 0, animated: false)
    }
    
    //MARK: Animation methods

    private func updateDisplayedPicker(for picker: ActivePicker){
        var selectedDatePicker: UIDatePicker = .init()
        var selectedDatePickerView: PickerCallButtonView?

        switch picker{
        case .custom:
            updateDisplayedCustomPicker(for: customPicker)
            return
        case .left:
            selectedDatePicker = leftPicker
            selectedDatePickerView = leftPickerView
        case .right:
            selectedDatePicker = rightPicker
            selectedDatePickerView = rightPickerView
        }
        
        if activePicker == picker{
            self.updatePieChartLayout(toInitial: true)
            
            selectedDatePickerView?.backgroundColor = .systemBackground
            selectedDatePicker.alpha = 0
            activePicker = nil
        } else {
            UIView.animate(withDuration: 0.6) { [weak self] in
                switch self?.activePicker {
                case .custom:
                    self?.customPicker.alpha = 0
                case .left:
                    self?.leftPicker.alpha = 0
                    self?.leftPickerView.backgroundColor = .systemBackground
                case .right:
                    self?.rightPicker.alpha = 0
                    self?.rightPickerView.backgroundColor = .systemBackground
                case .none:
                    self?.updatePieChartLayout(toInitial: false)
                }
                selectedDatePickerView?.backgroundColor = .systemGray6
                selectedDatePicker.alpha = 1
            }
            self.activePicker = picker
        }
        
    }
    private func updateDisplayedCustomPicker(for picker: UIPickerView){
        UIView.animate(withDuration: 0.6) { [weak self] in
            switch self?.activePicker {
            case .custom:
                self?.customPicker.alpha = 0
                self?.updatePieChartLayout(toInitial: true)
                self?.activePicker = nil
                return
            case .right:
                self?.rightPicker.alpha = 0
                self?.rightPickerView.backgroundColor = .systemBackground
            case .left:
                self?.leftPicker.alpha = 0
                self?.leftPickerView.backgroundColor = .systemBackground
            case .none:
                self?.updatePieChartLayout(toInitial: false)
            }
            self?.customPicker.alpha = 1
            self?.activePicker = .custom
            
        }
    }
//    private func animateCustomPicker(activate: Bool){
//        UIView.animate(withDuration: 0.6) { [weak self] in
//            switch self?.activePicker{
//            case .custom:
//                self?.customPicker.alpha = 0
//                self?.updatePieChartLayout(toInitial: true)
//                self?.activePicker = nil
//                return
//            case .left:
//                return
//            default: return
//            }
//        }
//    }
    
    private func updatePieChartLayout(toInitial: Bool){
        UIView.animate(withDuration: 0.6) { [weak self] in
            self?.pieViewTopAnchorToButton.isActive = toInitial
            self?.pieViewTopAnchorToPicker.isActive = !toInitial
            self?.view.layoutIfNeeded()
        }
    }
//    private func animateLeftPicker(activate: Bool){
//        guard rightPicker.alpha != 1 else {
//            switchPickers()
//            return
//        }
//        let isActivated = leftPicker.alpha == 1
//
//        UIView.animate(withDuration: 0.6) {
//            self.pieViewTopAnchorToButton.isActive = isActivated
//            self.pieViewTopAnchorToPicker.isActive = !isActivated
//            self.leftPicker.alpha = isActivated ? 0 : 1
//            self.view.layoutIfNeeded()
//        }
//    }
//    private func switchPickers(){
//        let rightPickerActive = rightPicker.alpha == 1
//        UIView.animate(withDuration: 0.5) { [weak self] in
//            self?.rightPicker.alpha = rightPickerActive ? 0 : 1
//            self?.leftPicker.alpha = rightPickerActive ? 1 : 0
//        }
//    }
    
    //MARK: Actions
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
        if sender == leftPicker {
            viewModel.beginDateDidChangeOn(sender.date)
        } else {
            viewModel.endDateDidChangedOn(sender.date)
        }
    }
}
//MARK: - Extend for TableView delegate and DataSource
extension StatisticVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInTableView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticViewCell.id, for: indexPath) as? StatisticViewCell else{
            return UITableViewCell()
        }
        let data = viewModel.dataForTableViewCell(at: indexPath)
        cell.configureCellWith(data)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
}
//MARK: - Extend for PickerView Delegate and DataSource
extension StatisticVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.numberOfRowsInPicker()
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.didSelectPickerRowAt(row)
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel.titleForPickerRowAt(row).localized
    }
}

extension StatisticVC: ChartViewDelegate{
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        viewModel.didSelectEntry(entry as! PieChartDataEntry)
    }
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        viewModel.didSelectEntry(nil)
    }
}
