//
//  NotificationViewController.swift
//  Language
//
//  Created by Star Lord on 12/04/2023.
//

import UIKit
import UserNotifications

class NotificationVC: UIViewController {
    
    lazy var data = UserSettings.shared.settings
    
    lazy var tableView : UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.register(NotificationTextCell.self, forCellReuseIdentifier: NotificationTextCell().identifier)
        view.register(NotificationSwitchCell.self, forCellReuseIdentifier: NotificationSwitchCell().identifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = false
        
        view.subviews.forEach { section in
            view.addShadowWhichOverlays(false)
        }
        return view
    }()
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                ? UIColor.secondarySystemBackground
                                : UIColor.systemBackground)
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var frequencyPicker : UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.alpha = 0
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    lazy var timePicker : UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .wheels
        picker.datePickerMode = .time
        picker.alpha = 0
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()


    let heightForSecondStage: CGFloat = 250
    let heightForThirdStage: CGFloat = 400
        
    var currentConstant: CGFloat = 0
    var initialConstant: CGFloat = 400
    var constantForFirstStage: CGFloat = 285
    var constantForSecondStage: CGFloat = 165
    var constantForThirdStage: CGFloat = 0
    
    var containerViewHeightConstraits: NSLayoutConstraint?
    var containerViewBottomConstraits: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewCustomization()
        tableViewCustomization()
        pickerCustomization()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
        animateDimmedView()
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                containerView.subviews.forEach { view in
                    view.layer.shadowColor = shadowColorForDarkIdiom
                }
                containerView.backgroundColor = .secondarySystemBackground
            } else {
                containerView.subviews.forEach { view in
                    view.layer.shadowColor = shadowColorForLightIdiom
                }
                containerView.backgroundColor = .systemBackground
            }
        }
    }
    
    func viewCustomization(){
        view.backgroundColor = .clear
        containerViewCustomization()
        panGestureCustomization()
        tapGestureRecognizer()
    }
    func tableViewCustomization(){
        containerView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
        tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
        tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
        tableView.heightAnchor.constraint(equalToConstant: heightForSecondStage),
        tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    func containerViewCustomization(){
        view.addSubviews(dimmedView, containerView)
        
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        containerViewHeightConstraits = containerView.heightAnchor.constraint(
            equalToConstant: heightForThirdStage)
        containerViewBottomConstraits = containerView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor, constant: initialConstant)

        containerViewBottomConstraits?.isActive = true
        containerViewHeightConstraits?.isActive = true
    }
    func pickerCustomization(){
        containerView.addSubviews(frequencyPicker, timePicker)
        
        NSLayoutConstraint.activate([
            frequencyPicker.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -50),
            frequencyPicker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            frequencyPicker.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.95),
            
            timePicker.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -50),
            timePicker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            timePicker.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.95)
        ])
        timePicker.addTarget(self, action: #selector(timePickerValueChanged(picker: )), for: .valueChanged)
    }
    func panGestureCustomization(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture: )))
        
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        
        view.addGestureRecognizer(panGesture)
    }
    func tapGestureRecognizer(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(gesture: )))
        dimmedView.addGestureRecognizer(tapGesture)
    }
    func animatePresentContainer(){
        UIView.animate(withDuration: 0.3) {
            guard let value = self.data?.notification.value else {
                return
            }
            self.containerViewBottomConstraits?.constant = (value
                                                             ? self.constantForSecondStage
                                                             : self.constantForFirstStage)
            self.currentConstant = self.containerViewBottomConstraits!.constant
            self.view.layoutIfNeeded()
        }
    }
    func animateDimmedView(){
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.dimmedView.alpha = 0.4
        }
    }
    func animateViewDismiss(){
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.containerViewBottomConstraits?.constant = self!.initialConstant
            self?.currentConstant = self!.initialConstant
            self?.view.layoutIfNeeded()
        }
        
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.dimmedView.alpha = 0
        }completion: { _ in
            self.dismiss(animated: false)
        }
    
    }
    func animateTransitionTo(_ newConstant: CGFloat){
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.containerViewBottomConstraits?.constant = newConstant
            self?.currentConstant = newConstant
            self?.view.layoutIfNeeded()
        }
    }
    
    func askPermitionForNotifications(){
        let notification = UNUserNotificationCenter.current()
        notification.requestAuthorization(options: [.alert, .sound, .badge]){ gained, canceled in
            if let cancel = canceled{
                print("Nope")
            } else {
                print("Gained")
            }
        }
    }
    //MARK: - Actions
    @objc func switchToggle(sender: UISwitch){
        askPermitionForNotifications()
        UserSettings.shared.reload(newValue: sender.isOn
                                   ? UserSettings.AppNotification.allowed
                                   : UserSettings.AppNotification.notAllowed )
        animateTransitionTo(sender.isOn
                            ? constantForSecondStage
                            : constantForFirstStage)
    }
    @objc func timePickerValueChanged(picker: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm " 
        let selectedTime = formatter.string(from: picker.date)
        UserSettings.shared.reload(newValue: picker.date)
        data = UserSettings.shared.settings
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? NotificationTextCell{
            cell.value.text = selectedTime
        }
        
    }
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view).y

        let newConstant = currentConstant + translation
                
        switch gesture.state {
        case .began, .changed:
            if newConstant > currentConstant  || newConstant > currentConstant * 0.9{
                containerViewBottomConstraits?.constant = newConstant
                view.layoutIfNeeded()
            }
        case .ended, .cancelled:
            if newConstant > initialConstant * 0.5 {
                animateViewDismiss()
            } else if newConstant > currentConstant || newConstant < currentConstant {
                animateTransitionTo(currentConstant)
            }
        default:
            break
        }
    }
    @objc func handleTapGesture(gesture: UITapGestureRecognizer){
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location){
            animateViewDismiss()
        }
    }
}

extension NotificationVC: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return 4
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row{
        case 0: return "everyDay".localized
        case 1: return "onceAWeek".localized
        case 2: return "onWeekdays".localized
        case 3: return "onTheWeekend".localized
        default: return " "
        }
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return view.bounds.width * 0.91
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let indexPath = IndexPath(row: 0, section: 1)
        if let cell = tableView.cellForRow(at: indexPath) as? NotificationTextCell{
            cell.value.text = {
                switch row{
                case 0:
                    UserSettings.shared.reload(newValue: UserSettings.AppNotificationFrequency.everyDay)
                    return "everyDay".localized
                case 1:
                    UserSettings.shared.reload(newValue: UserSettings.AppNotificationFrequency.onceAWeek)
                    return "onceAWeek".localized
                case 2:
                    UserSettings.shared.reload(newValue: UserSettings.AppNotificationFrequency.onTheWeekday)
                    return "onWeekdays".localized
                case 3:
                    UserSettings.shared.reload(newValue: UserSettings.AppNotificationFrequency.onTheWeekend)
                    return "onTheWeekend".localized
                default: return " "
                }
            }()
        }
        data = UserSettings.shared.settings
    }
}
extension NotificationVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let switchCell = tableView.dequeueReusableCell(
            withIdentifier: NotificationSwitchCell().identifier)
                as? NotificationSwitchCell else { return UITableViewCell() }
        guard let textCell = tableView.dequeueReusableCell(
            withIdentifier: NotificationTextCell().identifier)
                as? NotificationTextCell else {return UITableViewCell() }
        
        switch (indexPath.section, indexPath.row){
        case (0, 0):
            switchCell.control.isOn = data?.notification.value ?? false
            switchCell.control.addTarget(self, action: #selector(switchToggle(sender: )), for: .valueChanged)
            switchCell.selectionStyle = .none
            return switchCell
        case (1, 0):
            textCell.label.text = data?.notificationFrequency.title
            textCell.value.text = data?.notificationFrequency.value.value
            return textCell
        case (1, 1):
            textCell.label.text = data?.notificationTime.title
            textCell.value.text = data?.notificationTime.value.formatted(date: .omitted, time: .shortened)
            return textCell
        default: return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row){
        case (0, 0):
            let thirdStage = (currentConstant == constantForSecondStage)
            if thirdStage {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    print("First select")
                    self.animateTransitionTo(self.constantForSecondStage)
                }
            }
        case (1, 0):
            print("Select")

            guard let index = data?.notificationFrequency.value.index else {
                return
            }
            UIView.animate(withDuration: 0.3, delay: 0.2) {
                self.animateTransitionTo(self.constantForThirdStage)
                self.frequencyPicker.selectRow(index.row, inComponent: index.section, animated: false)
                self.frequencyPicker.alpha = 1
            }
        case (1, 1):
            print("Select")

            UIView.animate(withDuration: 0.3, delay: 0.2) {
                self.animateTransitionTo(self.constantForThirdStage)
                self.timePicker.date = self.data?.notificationTime.value ?? Date()
                self.timePicker.alpha = 1
            }
        default: return
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let thirdStage = (currentConstant == constantForThirdStage)
        switch (indexPath.section, indexPath.row){
        case (1, 0):
            if frequencyPicker.alpha == 1 {
                animateTransitionTo(constantForSecondStage)
                UIView.animate(withDuration: 0.1) { [weak self] in
                    self?.frequencyPicker.alpha = 0
                }
            }
        case (1, 1):
            if timePicker.alpha == 1{
                self.animateTransitionTo(constantForSecondStage)
                UIView.animate(withDuration: 0.1) { [weak self] in
                    self?.timePicker.alpha = 0
                }
            }
        default: return
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        } else {
            return 2
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
