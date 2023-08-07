//
//  NotificationViewController.swift
//  Language
//
//  Created by Star Lord on 12/04/2023.
//

//import UIKit
//import Combine
//import UserNotifications
//
//protocol NotificationPermition {
//    func failedToGainPermition()
//}
//
//class NotificationVC: UIViewController {
//
//
//    lazy var data = UserSettings.shared.settings
//    let viewModel = NotificationViewModel()
////    var input = PassthroughSubject<NotificationViewModel.Input, Never>()
//
//    //MARK: - Views
//
//    let stackView: UIStackView = {
//        let view = UIStackView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.axis = .vertical
//        view.distribution = .equalSpacing
//        return view
//    }()
//    lazy var tableView : UITableView = {
//        let view = UITableView(frame: .zero, style: .insetGrouped)
//        view.backgroundColor = .clear
//        view.delegate = self
//        view.dataSource = self
//        view.register(NotificationTextCell.self, forCellReuseIdentifier: NotificationTextCell.identifier)
//        view.register(NotificationSwitchCell.self, forCellReuseIdentifier: NotificationSwitchCell.identifier)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.isScrollEnabled = false
//
////        view.rowHeight = UITableView.automaticDimension
////        view.estimatedRowHeight = 44
//        view.subviews.forEach { section in
//            view.addShadowWhichOverlays(false)
//        }
//        return view
//    }()
//    lazy var containerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
//                                ? UIColor.secondarySystemBackground
//                                : UIColor.systemBackground)
//        view.layer.cornerRadius = 9
//        view.clipsToBounds = true
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    lazy var dimmedView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .black
//        view.alpha = 0
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    lazy var frequencyPicker : UIPickerView = {
//        let picker = UIPickerView()
//        picker.delegate = self
//        picker.dataSource = self
//        picker.alpha = 0
//        picker.translatesAutoresizingMaskIntoConstraints = false
//        return picker
//    }()
//    lazy var timePicker : UIDatePicker = {
//        let picker = UIDatePicker()
//        picker.preferredDatePickerStyle = .wheels
//        picker.datePickerMode = .time
//        picker.alpha = 0
//        picker.translatesAutoresizingMaskIntoConstraints = false
//        return picker
//    }()
//
//    lazy var dayPicker: DayPicker = DayPicker()
//
//    //MARK: Constrait related properties
//    var containerViewHeightConstraits: NSLayoutConstraint!
//    var containerViewBottomConstraits: NSLayoutConstraint!
//
//    //Dimensions
//
////    lazy var containerHeight: CGFloat = {
////
////        view.frame.height * 0.8
////    }()
////
//
////    var currentConstant: CGFloat = 0
////    lazy var initialConstant: CGFloat = containerHeight
////    lazy var constantForFirstStage: CGFloat =  containerHeight * 0.82 || containerHeight * 0.82 + view.safeAreaInsets.bottom
////    lazy var constantForSecondStage: CGFloat = containerHeight * 0.63
////    lazy var constantForThirdStage: CGFloat = containerHeight * 0.32
////    lazy var finalConstant: CGFloat = containerHeight * 0.15
////
////    var bottomAnchorForFirstStage: NSLayoutConstraint!
////    var bottomAnchorForSecondStage: NSLayoutConstraint!
////    var bottomAnchorForThirdStage: NSLayoutConstraint!
////    var bottomAnchorForFinalStage: NSLayoutConstraint!
////
////    lazy var heightConstantForTableView: CGFloat = containerHeight * 0.33
//
//    lazy var containerHeight: CGFloat = view.frame.height
//
//    var currentConstant: CGFloat = 0
//    lazy var initialConstant: CGFloat = containerHeight
//
////    lazy var constantForFirstStage: CGFloat =  containerHeight - ((tableView.cellForRow(at: IndexPath(item: 0, section: 0))?.frame.maxY)! + view.safeAreaInsets.bottom + 20 )
////    lazy var constantForSecondStage: CGFloat = containerHeight - (tableView.frame.maxY + view.safeAreaInsets.bottom + 20 )
////    lazy var constantForThirdStage: CGFloat = containerHeight - (timePicker.frame.maxY +
////                                                                 view.safeAreaInsets.bottom + 20)
////    lazy var finalConstant: CGFloat =  containerHeight - (dayPicker.frame.maxY +
////                                                          view.safeAreaInsets.bottom + 20)
//    lazy var constantForFirstStage: CGFloat =  containerHeight - (tableView.frame.height / 2)
//    lazy var constantForSecondStage: CGFloat = containerHeight - (timePicker.frame.minY)
//    lazy var constantForThirdStage: CGFloat = containerHeight - (dayPicker.frame.minY)
//    lazy var finalConstant: CGFloat =  containerHeight - (dayPicker.frame.maxY +
//                                                          view.safeAreaInsets.bottom + 20)
//
//
//    var bottomAnchorForFirstStage: NSLayoutConstraint!
//    var bottomAnchorForSecondStage: NSLayoutConstraint!
//    var bottomAnchorForThirdStage: NSLayoutConstraint!
//    var bottomAnchorForFinalStage: NSLayoutConstraint!
//
//    lazy var heightConstantForTableView: CGFloat = containerHeight * 0.30
//    var heightConstraitForTableView: NSLayoutConstraint!
//
//    //MARK: - Inherited
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureController()
////        configureStackView()
//
//        configureTableView()
//        configurePickers()
//    }
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        animateDimmedView()
//        animatePresentContainer()
//    }
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//    }
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
//            if traitCollection.userInterfaceStyle == .dark {
//                containerView.subviews.forEach { view in
//                    view.layer.shadowColor = shadowColorForDarkIdiom
//                }
//                containerView.backgroundColor = .secondarySystemBackground
//                dayPicker.backgroundColor = .systemGray5
//            } else {
//                containerView.subviews.forEach { view in
//                    view.layer.shadowColor = shadowColorForLightIdiom
//                }
//                containerView.backgroundColor = .systemBackground
//                dayPicker.backgroundColor = .secondarySystemBackground
//            }
//        }
//    }
//    func bind(){
//
//    }
//
//    func configureController(){
//        view.backgroundColor = .clear
//        configureContainerView()
//        panGestureCustomization()
//        tapGestureRecognizer()
//    }
//
//    func configureStackView(){
//        stackView.addArrangedSubview(tableView)
//        stackView.addArrangedSubview(timePicker)
//        stackView.addArrangedSubview(frequencyPicker)
//        stackView.addArrangedSubview(dayPicker)
//
//        view.addSubview(stackView)
//
//        NSLayoutConstraint.activate([
//            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
//            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
//            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
//            stackView.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor)
//        ])
//    }
//    //MARK: - TableView SetUp
//    func configureTableView(){
//        containerView.addSubview(tableView)
//
//        heightConstraitForTableView = tableView.heightAnchor.constraint(equalToConstant: 0)
//
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//            heightConstraitForTableView,
//            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//        ])
//
//        tableView.reloadData()
//        tableView.layoutIfNeeded()
//        heightConstraitForTableView?.constant = tableView.contentSize.height
//
//    }
//
//    //MARK: - ContainerView SetUp
//    func configureContainerView(){
//        view.addSubviews(dimmedView, containerView)
//
//        containerViewHeightConstraits = containerView.heightAnchor.constraint(
//            equalTo: view.heightAnchor)
//        containerViewBottomConstraits = containerView.bottomAnchor.constraint(
//            equalTo: view.bottomAnchor, constant: initialConstant)
//
//        NSLayoutConstraint.activate([
//            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
//            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//
//            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            containerViewBottomConstraits,
//            containerViewHeightConstraits
//        ])
//    }
//
//    //MARK: - Time & Frequency pickers SetUp
//    func configurePickers(){
//        containerView.addSubviews(frequencyPicker, timePicker, dayPicker)
//
//        NSLayoutConstraint.activate([
//            frequencyPicker.topAnchor.constraint(equalTo: tableView.bottomAnchor),
//            frequencyPicker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//            frequencyPicker.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.95),
//
//            timePicker.topAnchor.constraint(equalTo: tableView.bottomAnchor),
//            timePicker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//            timePicker.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.95),
//
//            dayPicker.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 10),
//            dayPicker.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
//            dayPicker.heightAnchor.constraint(equalToConstant: 66),
//            dayPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor ),
//        ])
//        timePicker.addTarget(self, action: #selector(timePickerValueChanged(picker: )), for: .valueChanged)
//    }
//
//    //MARK: - Gestures
//    func panGestureCustomization(){
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture: )))
//
//        panGesture.delaysTouchesBegan = false
//        panGesture.delaysTouchesEnded = false
//
//        view.addGestureRecognizer(panGesture)
//    }
//
//    func tapGestureRecognizer(){
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(gesture: )))
//        dimmedView.addGestureRecognizer(tapGesture)
//    }
//
//    //MARK: - Animations
//    func animatePresentContainer(){
//        UIView.animate(withDuration: 0.3) {
//            guard let value = self.data?.notification.value else {
//                return
//            }
//            self.containerViewBottomConstraits?.constant = (value
//                                                            ? self.constantForSecondStage
//                                                            : self.constantForFirstStage)
//            self.currentConstant = self.containerViewBottomConstraits!.constant
//            self.view.layoutIfNeeded()
//        }
//    }
//    func animateDimmedView(){
//        dimmedView.alpha = 0
//        UIView.animate(withDuration: 0.4) { [weak self] in
//            self?.dimmedView.alpha = 0.4
//        }
//    }
//    func animateViewDismiss(){
//        UIView.animate(withDuration: 0.3) { [weak self] in
//            self?.containerViewBottomConstraits?.constant = self!.initialConstant
//            self?.currentConstant = self!.initialConstant
//            self?.view.layoutIfNeeded()
//        }
//
//        UIView.animate(withDuration: 0.4) { [weak self] in
//            self?.dimmedView.alpha = 0
//        }completion: { _ in
//            self.dismiss(animated: false)
//        }
//
//    }
//    func animateTransitionTo(_ newConstant: CGFloat){
//        UIView.animate(withDuration: 0.3) { [weak self] in
//            self?.containerViewBottomConstraits?.constant = newConstant
//            self?.currentConstant = newConstant
//            self?.view.layoutIfNeeded()
//        }
//    }
//    func animateTransitionToDayPicker(activate: Bool){
//        UIView.animate(withDuration: 0.3) { [weak self] in
//            guard let self = self else { return }
//            self.containerViewBottomConstraits?.constant = activate ? self.finalConstant : constantForThirdStage
//            self.currentConstant =  activate ? self.finalConstant : constantForThirdStage
//            self.dayPicker.alpha = activate ? 1 : 0
//            self.view.layoutIfNeeded()
//        }
//
//    }
//
//    //MARK: - Ask Permition
//    func askPermitionForNotifications(){
//        let notification = UNUserNotificationCenter.current()
//        notification.requestAuthorization(options: [.alert, .sound, .badge]){ gained, canceled in
//            if let cancel = canceled{
//                print("Nope")
//            } else {
//                print("Gained")
//            }
//        }
//    }
//    func notification(allowed: Bool){
//        if allowed {
//
//            animateTransitionTo(constantForSecondStage)
//
//        }
//    }
//    private func registerForPushNotifications(){
//
//    }
//}
//
////MARK: - Actions
//extension NotificationVC {
//    //depricated
//    @objc func switchToggle(sender: UISwitch){
//        askPermitionForNotifications()
//        UserSettings.shared.reload(newValue: sender.isOn
//                                   ? UserSettings.AppNotificationPermition.granted
//                                   : UserSettings.AppNotificationPermition.denied )
//        animateTransitionTo(sender.isOn
//                            ? constantForSecondStage
//                            : constantForFirstStage)
//    }
//
//    //Done
//    @objc func timePickerValueChanged(picker: UIDatePicker){
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        let selectedTime = formatter.string(from: picker.date)
//        UserSettings.shared.reload(newValue: picker.date)
//        data = UserSettings.shared.settings
//        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? NotificationTextCell{
//            cell.value.text = selectedTime
//        }
//    }
//
//    //Done
//    @objc func handlePanGesture(gesture: UIPanGestureRecognizer){
//        let translation = gesture.translation(in: view).y
//        let velocity = gesture.velocity(in: view).y
//        let newConstant = currentConstant + translation
//
//        switch gesture.state {
//        case .began, .changed:
//            if currentConstant == constantForFirstStage {
//                if translation > -10 {
//                    containerViewBottomConstraits?.constant = newConstant
//                    view.layoutIfNeeded()
//                }
//            } else if translation > -50 {
//                containerViewBottomConstraits?.constant = newConstant
//                view.layoutIfNeeded()
//            }
//        case .ended:
//            if velocity > 500 || translation > 50 {
//                animateViewDismiss()
//            } else {
//                animateTransitionTo(currentConstant)
//            }
//
//        default:
//            break
//        }
//    }
//    //Done
//    @objc func handleTapGesture(gesture: UITapGestureRecognizer){
//        let location = gesture.location(in: view)
//        if !containerView.frame.contains(location){
//            animateViewDismiss()
//        }
//    }
//}
//
////MARK: UIPicker Delegate & DataSource
//extension NotificationVC: UIPickerViewDelegate, UIPickerViewDataSource{
//    //Done
//    func numberOfComponents(in pickerView: UIPickerView) -> Int{
//        return 1
//    }
//    //Done
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
//        return 4
//    }
//    //Done
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        switch row{
//        case 0: return "everyDay".localized
//        case 1: return "onceAWeek".localized
//        case 2: return "onWeekdays".localized
//        case 3: return "onTheWeekend".localized
//        default: return " "
//        }
//    }
//    //Done
//    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        return view.bounds.width * 0.91
//    }
//    //Done
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        let indexPath = IndexPath(row: 0, section: 1)
//        if let cell = tableView.cellForRow(at: indexPath) as? NotificationTextCell{
//            cell.value.text = {
//                switch row{
//                case 0:
//                    UserSettings.shared.reload(newValue: UserSettings.AppNotificationFrequency.everyDay)
//                    if dayPicker.alpha == 1 {
//                        animateTransitionToDayPicker(activate: false)
//                    }
//                    return "everyDay".localized
//                case 1:
//                    UserSettings.shared.reload(newValue: UserSettings.AppNotificationFrequency.custom)
//                    self.animateTransitionToDayPicker(activate: true)
//                    return "Custom"
//                case 2:
//                    UserSettings.shared.reload(newValue: UserSettings.AppNotificationFrequency.onTheWeekday)
//                    if dayPicker.alpha == 1 {
//                        animateTransitionToDayPicker(activate: false)
//                    }
//                    return "onWeekdays".localized
//                case 3:
//                    UserSettings.shared.reload(newValue: UserSettings.AppNotificationFrequency.onTheWeekend)
//                    if dayPicker.alpha == 1 {
//                        animateTransitionToDayPicker(activate: false)
//                    }
//                    return "onTheWeekend".localized
//                default: return " "
//                }
//            }()
//        }
//        data = UserSettings.shared.settings
//    }
//}
////MARK: - Table Delegae & DataSource
//extension NotificationVC: UITableViewDelegate, UITableViewDataSource{
//    //Done
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let switchCell = tableView.dequeueReusableCell(
//            withIdentifier: NotificationSwitchCell.identifier)
//                as? NotificationSwitchCell else { return UITableViewCell() }
//        guard let textCell = tableView.dequeueReusableCell(
//            withIdentifier: NotificationTextCell.identifier)
//                as? NotificationTextCell else { return UITableViewCell() }
//
//        switch (indexPath.section, indexPath.row){
//        case (0, 0):
//            switchCell.control.isOn = data?.notification.value ?? false
//            switchCell.control.addTarget(self, action: #selector(switchToggle(sender: )), for: .valueChanged)
//            switchCell.selectionStyle = .none
//            return switchCell
//        case (1, 0):
//            textCell.label.text = data?.notificationFrequency.title
//            textCell.value.text = data?.notificationFrequency.value.value
//            return textCell
//        case (1, 1):
//            textCell.label.text = data?.notificationTime.title
//            textCell.value.text = data?.notificationTime.value.formatted(date: .omitted, time: .shortened)
//            return textCell
//        default: return UITableViewCell()
//        }
//    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch (indexPath.section, indexPath.row){
//        case (0, 0):
//            let thirdStage = (currentConstant == constantForSecondStage)
//            if thirdStage {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    print("First select")
//                    self.animateTransitionTo(self.constantForSecondStage)
//                }
//            }
//        case (1, 0):
//            print("Select")
//
//            guard let index = data?.notificationFrequency.value.index else {
//                return
//            }
//            UIView.animate(withDuration: 0.3, delay: 0.2) {
//                self.animateTransitionTo(self.constantForThirdStage)
//                self.frequencyPicker.selectRow(index.row, inComponent: index.section, animated: false)
//                self.frequencyPicker.alpha = 1
//            }
//        case (1, 1):
//            print("Select")
//
//            UIView.animate(withDuration: 0.3, delay: 0.2) {
//                self.animateTransitionTo(self.constantForThirdStage)
//                self.timePicker.date = self.data?.notificationTime.value ?? Date()
//                self.timePicker.alpha = 1
//            }
//        default: return
//        }
//    }
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let thirdStage = (currentConstant == constantForThirdStage)
//        switch (indexPath.section, indexPath.row){
//        case (1, 0):
//            if frequencyPicker.alpha == 1 {
//                animateTransitionTo(constantForSecondStage)
//                UIView.animate(withDuration: 0.1) { [weak self] in
//                    self?.frequencyPicker.alpha = 0
//                }
//            }
//        case (1, 1):
//            if timePicker.alpha == 1{
//                self.animateTransitionTo(constantForSecondStage)
//                UIView.animate(withDuration: 0.1) { [weak self] in
//                    self?.timePicker.alpha = 0
//                }
//            }
//        default: return
//        }
//
//    }
//    //Done
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0{
//            return 1
//        } else {
//            return 2
//        }
//    }
//    //DOne
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//    //DOne
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0
//    }
////    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        return 44
////    }
////    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
////        return UITableView.automaticDimension
////    }
//}
//
////class WeekPicker: UIView{
////
////    var selectedDaysSet = Set<Int>()
////    let arrayOfDays: [String] = {
////        let calendar = Calendar.current
////        let firstDay = calendar.firstWeekday
////        let formatter = DateFormatter()
////        var array: [String] = []
////        for i in 0..<7 {
////            let index = (firstDay - 1 + i) % 7
////            array.append(formatter.shortWeekdaySymbols[index])
////        }
////        return array
////    }()
////
////    override init(frame: CGRect) {
////        super.init(frame: .zero)
////        configureStackView()
////    }
////    required init?(coder: NSCoder) {
////        super.init(coder: coder)
////        fatalError("Coder wasn't imported")
////    }
////    override func layoutSubviews() {
////        if let stackView = self.subviews.first as? UIStackView, let firstButton = stackView.arrangedSubviews.first as? UIButton, let lastButton = stackView.arrangedSubviews.last as? UIButton {
////            print("mask was configured")
////            firstButton.layer.mask = configureOneSideRoundedMask(for: firstButton, left: true, cornerRadius: 9)
////            lastButton.layer.mask = configureOneSideRoundedMask(for: lastButton, left: false, cornerRadius: 9)
////        }
////    }
////    func configureStackView(){
////        self.translatesAutoresizingMaskIntoConstraints = false
////        self.layer.cornerRadius = 9
////        self.alpha = 0
////        self.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
////                                ? UIColor.systemGray5
////                                : UIColor.secondarySystemBackground)
////
////
////        self.addShadowWhichOverlays(false)
////        var arrayOfButton: [UIButton] = []
////        let spacer = UIView()
////        for (index, i) in arrayOfDays.enumerated() {
////            arrayOfButton.append(createDayButton(with: i, tag: index))
////        }
////        arrayOfButton.first?.layer.mask = UIView().configureOneSideRoundedMask(for: arrayOfButton.first!, left: true, cornerRadius: 9)
////        let stackView = UIStackView(arrangedSubviews: [
////                                                       arrayOfButton[0],
////                                                       UIView(),
////                                                       arrayOfButton[1],
////                                                       UIView(),
////                                                       arrayOfButton[2],
////                                                       UIView(),
////                                                       arrayOfButton[3],
////                                                       UIView(),
////                                                       arrayOfButton[4],
////                                                       UIView(),
////                                                       arrayOfButton[5],
////                                                       UIView(),
////                                                       arrayOfButton[6],
////                                                       UIView()
////                                                      ])
////        stackView.backgroundColor = .clear
////        stackView.alignment = .fill
////
////        stackView.distribution = .fillEqually
////        stackView.contentMode = .scaleToFill
////
////        stackView.translatesAutoresizingMaskIntoConstraints = false
////
////        self.addSubview(stackView)
////
////        NSLayoutConstraint.activate([
////            stackView.topAnchor.constraint(equalTo: self.topAnchor),
////            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
////            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
////            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
////        ])
////
////    }
////    func createDayButton(with title: String, textColour: UIColor) -> UIButton{
////        let button = UIButton()
////        button.backgroundColor = .clear
////        button.contentMode = .center
////        button.layer.cornerRadius = 9
////        button.addTarget(self, action: #selector(buttonDidTap(sender: )), for: .touchUpInside)
////
////        let imageView = UIImageView(image: UIImage(systemName: "circle"))
////        imageView.contentMode = .scaleAspectFit
////        imageView.tintColor = .label // Set the image color if necessary
////
////        let label = UILabel()
////        label.text = title
////        label.textColor = textColour
////        label.textAlignment = .center
////
////        let stackView = UIStackView(arrangedSubviews: [imageView, label])
////        stackView.axis = .vertical
////        stackView.distribution = .fillEqually
////        stackView.alignment = .center
////        stackView.spacing = 5 // adjust this value as needed
////
////        button.addSubview(stackView)
////        stackView.translatesAutoresizingMaskIntoConstraints = false
////
////        NSLayoutConstraint.activate([
////            stackView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
////            stackView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
////            stackView.heightAnchor.constraint(equalTo: button.heightAnchor), // adjust this value as needed
////            stackView.widthAnchor.constraint(equalTo: button.widthAnchor), // adjust this value as needed
////        ])
////
////        return button
////    }
////    func createDayButton(with title: String, textColour: UIColor) -> UIButton{
////        let button = UIButton()
////        button.backgroundColor = .clear
////        button.frame = CGRect(x: 0, y: 0, width: self.bounds.width / 10 , height: 0)
////
////        button.setTitle(title, for: .normal)
////        button.setTitleColor(textColour, for: .normal)
////
////        button.contentMode = .center
////
////        button.addTarget(self, action: #selector(buttonDidTap(sender: )), for: .touchUpInside)
////        return button
////    }
////    func createDayButton(with title: String, tag: Int) -> UIButton{
////        let button = UIButton(configuration: .plain())
////        button.backgroundColor = .clear
////
//////        button.setTitle(title, for: .normal)
//////        button.setTitleColor(textColour, for: .normal)
////        button.tag = tag
////        button.configuration?.titlePadding = 0
////        button.configuration?.title = title
//////        button.configuration?.titleAlignment = .center
////        button.configuration?.contentInsets = .zero
////        button.configuration?.baseForegroundColor = .label
//////        button.contentMode = .center
//////        button.titleLabel?.textAlignment = .center
//////        button.titleLabel?.numberOfLines = 1
//////        button.titleLabel?.minimumScaleFactor = 0.1
//////        button.setImage(UIImage(systemName: "circle"), for: .normal)
////        button.configuration?.imagePlacement = .bottom
////        button.configuration?.imagePadding = 10
////        button.configuration?.image = UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
////
////
//////        button.setImage(UIImage(systemName: "checkmark.circle"), for: .selected)
////
////        button.addTarget(self, action: #selector(buttonDidTap(sender: )), for: .touchUpInside)
////        return button
////    }
//
//
////    @objc func buttonDidTap(sender: UIButton){
////        if selectedDaysSet.contains(sender.tag){
////            sender.configuration?.image = UIImage(systemName: "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
////            sender.backgroundColor = .clear
////            selectedDaysSet.remove(sender.tag)
////        } else {
////            sender.configuration?.image = UIImage(systemName: "checkmark.circle", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
////            sender.backgroundColor = .systemGray5
////            selectedDaysSet.insert(sender.tag)
////        }
////    }
////    @objc func buttonDidTap(sender: UIButton){
////        if sender.backgroundColor == .clear {
////            sender.backgroundColor = .systemGray5
////            sender.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
////        } else {
////            sender.backgroundColor = .clear
////            sender.setImage(UIImage(systemName: "circle"), for: .normal)
////        }
////    }
//
////}
//
//
