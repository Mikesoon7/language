//
//  StatisticVC.swift
//  Language
//
//  Created by Star Lord on 16/02/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit
import Combine


private enum ActivePicker{
    case left
    case right
    case custom
}
class StatisticView: UIViewController {
    
    //MARK: HardCoded Values
    internal struct ViewInsets {
        static var tableCellHeight: CGFloat = 50
        static var tableSelectedCellHeight: CGFloat = 200
    }
    
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
    
    //MARK: HolderViews
    private var verticalEmbededStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.alignment = .fill
        view.distribution = .fillProportionally
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        view.alwaysBounceVertical = false
        view.isScrollEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.canCancelContentTouches = false
        return view
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    //MARK: Views
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = .attributedString(
            string: "statistic.title".localized,
            with: .helveticaNeueBold,
            ofSize: .titleSize)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
        
    private let legendTableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(StatisticViewCell.self, forCellReuseIdentifier: StatisticViewCell.id)
        view.register(StatisticViewSelectedCell.self, forCellReuseIdentifier: StatisticViewSelectedCell.id)
        
        view.separatorStyle = .none
        view.backgroundColor = .systemBackground
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = true
        view.showsVerticalScrollIndicator = false
        view.bounces = false

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
    private var pieViewTopAnchorToButton: NSLayoutConstraint = .init()
    private var pieViewTopAnchorToPicker: NSLayoutConstraint = .init()
    
    private var tableViewTopAnchorToButton: NSLayoutConstraint = .init()
    private var tableViewTopAnchorToPicker: NSLayoutConstraint = .init()
    
    private var tableViewHeightAnchor: NSLayoutConstraint = .init()
    
    private var widthCompactSizeConstraints: [NSLayoutConstraint] = []
    private var widthRegularSizeConstraints: [NSLayoutConstraint] = []
    
    
    //MARK: Inherited
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        bind()
        
        configureTitleLabel()
        configureCustomButton()
        configurePickersButton()
        configureContentView()
        configureCustomRangePicker()
        configureDatePickers()
        configurePieChartView()
        configureTableView()
        configurePickerDismissGesture()
        
        applyConstraints(for: self.traitCollection)
        
        input?.send(.viewDidLoad)
    }
    
    required init(viewModel: StatisticViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil , bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: NSCoder) wasn't imported")
    }


    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            applyConstraints(for: traitCollection)
        }

        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            leftPickerView.layer.borderColor = UIColor.label.cgColor
            rightPickerView.layer.borderColor = UIColor.label.cgColor
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //Reload the chart view and interval picker.
        coordinator.animate { _ in
            if let picker = self.activePicker{
                self.updateDisplayedPicker(for: picker)
            }
        } completion: { _ in
            self.pieChartView?.chartView?.layoutSubviews()
            self.pieChartView?.chartView?.sizeHasChanged()
        }
    }

    private func applyConstraints(for traitCollection: UITraitCollection) {
        if traitCollection.horizontalSizeClass == .regular {
                NSLayoutConstraint.deactivate(widthCompactSizeConstraints)
                NSLayoutConstraint.activate(widthRegularSizeConstraints)
            } else {
                NSLayoutConstraint.deactivate(widthRegularSizeConstraints)
                NSLayoutConstraint.activate(widthCompactSizeConstraints)
            }
        view.layoutIfNeeded()
    }

    //MARK: Binding.
    func bind(){
        guard let output = viewModel?.transform(input: input?.eraseToAnyPublisher()) else { return }
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                guard let self = self else {return}
                switch output{
                case .shouldUpdatePieChartWith(let data):
                    pieChartView?.setUpChartData(data)
                case .shouldUpdateSelectedInterval(let interval):
                    updateSelectedInterval(interval)
                case .shouldUpdateCustomInterval:
                    updateCustomPicker()
                case .shouldPresent(let error):
                    presentError(error, sourceView: view)
                case .shouldUpdateSelectedTableCell:
                    legendTableView.beginUpdates()
                    legendTableView.reloadSections(IndexSet(integersIn: 0...legendTableView.numberOfSections - 1 ), with: .left)
                    legendTableView.endUpdates()
                    updateTableConstrait()
                }
            }
            .store(in: &cancellable)
    }
    
    
    //MARK: Subviews configuration
    ///Laying out title label.
    private func configureTitleLabel(){
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.topAnchor, constant: .outerSpacer),
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer),
            titleLabel.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: 0.5),
            titleLabel.heightAnchor.constraint(
                equalToConstant: .longOuterSpacer),
        ])
    }
    
    ///Laying out and setting up customPickerButton
    private func configureCustomButton(){
        view.addSubview(customPickerCallButton)
        
        customPickerCallButton.addTarget(self, action: #selector(customViewDidTap(sender:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            
            customPickerCallButton.centerYAnchor.constraint(
                equalTo: titleLabel.centerYAnchor),
            customPickerCallButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.outerSpacer),
        ])
    }
    
    ///Laying out and setting up  right and left picker call buttons
    private func configurePickersButton(){
        view.addSubviews(leftPickerView, rightPickerView)
                
        leftPickerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftPickerViewDidTap(sender: ))))
        rightPickerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightPickerViewDidTap(sender: ))))
        
        NSLayoutConstraint.activate([
            leftPickerView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: .outerSpacer),
            leftPickerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer),
            leftPickerView.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: 0.5, constant: -.outerSpacer),
            leftPickerView.heightAnchor.constraint(
                equalToConstant: ViewInsets.tableCellHeight),
            
            rightPickerView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: .outerSpacer),
            rightPickerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.outerSpacer),
            rightPickerView.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: 0.5, constant: -.outerSpacer),
            rightPickerView.heightAnchor.constraint(
                equalToConstant: ViewInsets.tableCellHeight),
        ])
    }
    
    //MARK: - Scroll View + Subviews SetUp
    private func configureContentView(){
        view.addSubviews(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: rightPickerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(
                equalTo: view.widthAnchor),
        ])
    }

    private func configureDatePickers(){
        contentView.addSubviews(leftDatePicker, rightDatePicker)
        
        leftDatePicker.addTarget(self, action: #selector(dataPickerDidSelect(sender: )), for: .valueChanged )
        rightDatePicker.addTarget(self, action: #selector(dataPickerDidSelect(sender: )), for: .valueChanged )
        
        widthRegularSizeConstraints.append(contentsOf: [
            leftDatePicker.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: .outerSpacer),
            leftDatePicker.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -.outerSpacer / 2 ),
            leftDatePicker.widthAnchor.constraint(
                equalTo: contentView.widthAnchor, multiplier: 0.45,  constant: -.outerSpacer),
            
            rightDatePicker.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: .outerSpacer),
            rightDatePicker.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -.outerSpacer / 2),
            rightDatePicker.widthAnchor.constraint(
                equalTo: contentView.widthAnchor, multiplier: 0.45,  constant: -.outerSpacer)
        ])

        widthCompactSizeConstraints.append(contentsOf: [
            
            leftDatePicker.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: .outerSpacer),
            leftDatePicker.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor),
            rightDatePicker.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: .outerSpacer),
            rightDatePicker.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor),
        ])
    }
    private func configureCustomRangePicker(){
        contentView.addSubview(customRangePicker)
        
        customRangePicker.delegate = self
        customRangePicker.dataSource = self

        widthRegularSizeConstraints.append(contentsOf: [
            customRangePicker.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: .outerSpacer),
            customRangePicker.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -.outerSpacer / 2 ),
            customRangePicker.widthAnchor.constraint(
                equalTo: contentView.widthAnchor, multiplier: 0.45, constant: -.outerSpacer)

        ])

        widthCompactSizeConstraints.append(contentsOf: [
            customRangePicker.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: .outerSpacer),
            customRangePicker.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor),
        ])
    }
    

    private func configurePieChartView(){
        guard let pieChartView = pieChartView else { return }
        
        
        pieChartView.translatesAutoresizingMaskIntoConstraints = false
        pieChartView.delegate = self
        
        pieViewTopAnchorToButton = verticalEmbededStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .outerSpacer)
        pieViewTopAnchorToPicker = verticalEmbededStackView.topAnchor.constraint(equalTo: leftDatePicker.bottomAnchor, constant: .outerSpacer)

        widthRegularSizeConstraints.append(contentsOf: [
            verticalEmbededStackView.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: .outerSpacer),
            
            verticalEmbededStackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: .outerSpacer),
            verticalEmbededStackView.trailingAnchor.constraint(
                equalTo: customRangePicker.leadingAnchor, constant: -.outerSpacer),
            verticalEmbededStackView.heightAnchor.constraint(
                equalTo: contentView.widthAnchor, multiplier: 0.65),
            verticalEmbededStackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor)
        ])

        widthCompactSizeConstraints.append(contentsOf: [
            pieViewTopAnchorToButton,
            verticalEmbededStackView.centerXAnchor.constraint(
                equalTo: contentView.centerXAnchor),
            verticalEmbededStackView.widthAnchor.constraint(
                equalTo: contentView.widthAnchor, multiplier: 0.8),
            verticalEmbededStackView.heightAnchor.constraint(
                equalTo: contentView.widthAnchor, multiplier: 0.8),
        ])

        contentView.addSubview(verticalEmbededStackView)
        verticalEmbededStackView.addArrangedSubview(pieChartView)
    }
    private func configureTableView(){
        contentView.addSubview(legendTableView)
        
        legendTableView.delegate = self
        legendTableView.dataSource = self
        
        tableViewTopAnchorToButton = legendTableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .outerSpacer)
        tableViewTopAnchorToPicker = legendTableView.topAnchor.constraint(equalTo: rightDatePicker.bottomAnchor, constant: .outerSpacer)
        
        tableViewHeightAnchor = legendTableView.heightAnchor.constraint(
            equalToConstant: CGFloat(legendTableView.numberOfRows(inSection: 0)) * ViewInsets.tableCellHeight + CGFloat(legendTableView.numberOfRows(inSection: 1)) * ViewInsets.tableSelectedCellHeight)


        widthRegularSizeConstraints.append(contentsOf: [
            tableViewTopAnchorToButton,
            legendTableView.widthAnchor.constraint(
                equalTo: leftDatePicker.widthAnchor),
            legendTableView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -.outerSpacer),
            legendTableView.heightAnchor.constraint(
                equalTo: verticalEmbededStackView.heightAnchor),

        ])

        widthCompactSizeConstraints.append(contentsOf: [
            legendTableView.topAnchor.constraint(
                equalTo: pieChartView?.bottomAnchor ?? leftPickerView.bottomAnchor,
                constant: .outerSpacer),
            legendTableView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor),
            legendTableView.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor),
            legendTableView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor),
            
            tableViewHeightAnchor
        ])
    }
    
    func updateTableConstrait(){
        tableViewHeightAnchor.constant = CGFloat(legendTableView.numberOfRows(inSection: 0)) * ViewInsets.tableCellHeight + CGFloat(legendTableView.numberOfRows(inSection: 1)) * ViewInsets.tableSelectedCellHeight
        view.layoutIfNeeded()
    }
    
    //MARK: System
    private func configurePickerDismissGesture(){
        dismissPanGesture = UIPanGestureRecognizer(target: self, action: #selector(viewDidPan(sender:)))
        dismissPanGesture.isEnabled = false
        self.contentView.addGestureRecognizer(dismissPanGesture)
    }

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
    
    ///Checks if end date greater than begin date. If not, update values with active picker as primary.
    private func validateDatePickerInput(sender: UIDatePicker){
        if leftDatePicker.date > rightDatePicker.date {
            if sender === rightDatePicker {
                leftDatePicker.date = sender.date
                leftPickerView.updateSubtitleLabel(with: convertDateToString(sender.date))
            } else {
                rightDatePicker.date = sender.date
                rightPickerView.updateSubtitleLabel(with: convertDateToString(sender.date))
            }
        }
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
        let regularWidth = traitCollection.horizontalSizeClass == .regular
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let self = self else { return }
            if toInitial {
                dismissPanGesture.isEnabled = false
                if regularWidth {
                    tableViewTopAnchorToPicker.isActive = !toInitial
                    tableViewTopAnchorToButton.isActive = toInitial
                } else {
                    pieViewTopAnchorToPicker.isActive = !toInitial
                    pieViewTopAnchorToButton.isActive = toInitial
                }
            } else {
                dismissPanGesture.isEnabled = true
                scrollView.setContentOffset(.zero, animated: true)
                if regularWidth {
                    tableViewTopAnchorToButton.isActive = toInitial
                    tableViewTopAnchorToPicker.isActive = !toInitial
                } else {
                    pieViewTopAnchorToButton.isActive = toInitial
                    pieViewTopAnchorToPicker.isActive = !toInitial
                }
            }
            view.layoutIfNeeded()
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
        
        if translation < -10 || translation > 10{
            updateDisplayedPicker(for: picker)
        }
    }
}
//MARK: - Extend for TableView delegate and DataSource
extension StatisticView: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRowsInSection(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = viewModel?.dataForTableViewCell(at: indexPath) else { return UITableViewCell() }
        if data.isSelected {
            let cell = tableView.dequeueReusableCell(withIdentifier: StatisticViewSelectedCell.id, for: indexPath) as? StatisticViewSelectedCell
            cell?.configureCellWith(data)
            return cell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: StatisticViewCell.id, for: indexPath) as? StatisticViewCell
            cell?.configureCellWith(data, isExpanded: data.isSelected)
            return cell ?? UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? ViewInsets.tableCellHeight : ViewInsets.tableSelectedCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.didSelectRow(at: indexPath)
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
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

extension StatisticView: PieChartViewDelegate {
    func chartValueSelected(entry: ChartEntityData?){
        input?.send(.selectedChartEntryUpdated(entry))
    }
    
}

