//
//  NotificationViewController.swift
//  Language
//
//  Created by Star Lord on 12/04/2023.
//

import UIKit

class NotificationViewController: UIViewController {
    
    var notificationData = SettingsData.shared.settings.notification
    
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
    
    let firstStackView: UIView = {
        let view = UIView()
        view.backgroundColor = .tertiarySystemGroupedBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let notificationLabel : UILabel = {
        let label = UILabel()
        label.text = "allowNotification".localized
        label.font = UIFont(name: " ", size: 17)
        label.textColor = .label
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var isAllowSwitch : UISwitch = {
        let controller = UISwitch()
        controller.isOn = {
            switch notificationData{
            case .allowed: return true
            case .notAllowed: return false
            }
        }()
        controller.addTarget(self, action: #selector(switchToggle(sender:)), for: .valueChanged)
        controller.translatesAutoresizingMaskIntoConstraints = false
        return controller
    }()
    
    let secondStackView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGroupedBackground
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var frequencyLabel : UILabel = {
        let label = UILabel()
        label.text = "frequency".localized
        label.font = UIFont(name: " ", size: 17)
        label.textAlignment = .left
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var frequencyPicker : UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
//    lazy var timeLabel: UILabel = {
//        let label = UILabel()
//        label.text = "chooseTime".localized
//        label.font = UIFont().withSize(16)
//        label.textAlignment = .left
//        label.textColor = .label
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
    let dismissHeight: CGFloat = 100
    let heightForFirstStage: CGFloat = 150
    let heightForSecondStage: CGFloat = 350
    let heightForThirdStage: CGFloat = 550
    
    var currentContainerHeight: CGFloat = 150
    
    var containerViewHeightConstraits: NSLayoutConstraint?
    var containerViewBottomConstraits: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewCustomization()
        containerViewCustomization()
        panGestureCustomization()
        firstPartCustomization()
//        secondPartCustomization()
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
                containerView.backgroundColor = .secondarySystemBackground
            } else {
                containerView.backgroundColor = .systemBackground
            }
        }
    }
    func viewCustomization(){
        view.backgroundColor = .clear
    }
    func containerViewCustomization(){
        view.addSubviews(dimmedView, containerView)
        
        NSLayoutConstraint.activate([
            //Dimmed View attached with the frame.
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        containerViewHeightConstraits = containerView.heightAnchor.constraint(
            equalToConstant: isAllowSwitch.isOn ? heightForSecondStage : heightForFirstStage)
        containerViewBottomConstraits = containerView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor, constant: isAllowSwitch.isOn ? heightForSecondStage : heightForFirstStage)

        containerViewBottomConstraits?.isActive = true
        containerViewHeightConstraits?.isActive = true
        
    }
    func firstPartCustomization(){
        containerView.addSubview(firstStackView)
        firstStackView.addSubviews(notificationLabel, isAllowSwitch)
        
        NSLayoutConstraint.activate([
            firstStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 45),
            firstStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            firstStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -45),
            firstStackView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.91),

            notificationLabel.centerYAnchor.constraint(equalTo: firstStackView.topAnchor, constant: 30),
            notificationLabel.leadingAnchor.constraint(equalTo: firstStackView.leadingAnchor, constant: 15),
            
            isAllowSwitch.centerYAnchor.constraint(equalTo: firstStackView.topAnchor, constant: 30),
            isAllowSwitch.centerXAnchor.constraint(equalTo: firstStackView.trailingAnchor, constant: -45)
        ])
    }
    func secondPartCustomization(){
        firstStackView.addSubviews(frequencyLabel, frequencyPicker)
        
        NSLayoutConstraint.activate([
            frequencyPicker.topAnchor.constraint(equalTo: isAllowSwitch.bottomAnchor, constant: 5),
            frequencyPicker.trailingAnchor.constraint(equalTo: firstStackView.trailingAnchor, constant: -15),
            frequencyPicker.widthAnchor.constraint(equalTo: firstStackView.widthAnchor, multiplier: 0.5),
            
            frequencyLabel.centerYAnchor.constraint(equalTo: frequencyPicker.centerYAnchor),
            frequencyLabel.leadingAnchor.constraint(equalTo: firstStackView.leadingAnchor, constant: 15),
        ])
    }
    func panGestureCustomization(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gesture: )))
        
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        
        view.addGestureRecognizer(panGesture)
    }
    func animatePresentContainer(){
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.containerViewBottomConstraits?.constant = 0
            self?.view.layoutIfNeeded()
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
            self?.containerViewBottomConstraits?.constant = self!.heightForFirstStage
            self?.view.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.dimmedView.alpha = 0
        }completion: { _ in
            self.dismiss(animated: false)
        }
    
    }
    func animateTransitionTo(_ height: CGFloat){
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.containerViewHeightConstraits?.constant = height
            self?.view.layoutIfNeeded()
            if height == self?.heightForSecondStage{
                self?.secondPartCustomization()
            }
        }
        currentContainerHeight = height
    }
    //MARK: - Actions
    @objc func switchToggle(sender: UISwitch){
        SettingsData.shared.update(newValue: sender.isOn
                                   ? SettingsData.AppNotification.allowed
                                   : SettingsData.AppNotification.notAllowed )
        animateTransitionTo(sender.isOn
                            ? heightForSecondStage
                            : heightForFirstStage)
    }
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view)
        
        let isDraggingDown = translation.y > 0
        print(isDraggingDown ? "Going down" : "Going Up")
        
        let newHeight = currentContainerHeight - translation.y
        
        switch gesture.state {
        case .changed:
            if newHeight < heightForThirdStage{
                containerViewHeightConstraits?.constant = newHeight
                view.layoutIfNeeded()
            }
        case .ended:
            if newHeight < dismissHeight{
                self.animateViewDismiss()
            } else if newHeight < heightForFirstStage{
                animateTransitionTo(heightForFirstStage)
            } else if newHeight < heightForSecondStage && isDraggingDown{
                animateTransitionTo(heightForFirstStage)
            } else if newHeight > heightForFirstStage && !isDraggingDown{
                animateTransitionTo(heightForSecondStage)
            }
        default: break
        }
    }
}

extension NotificationViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return 7
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row{
        case 0: return "every".localized + " " + "day".localized
        case 6: return "onceAWeek".localized
        default: return "every".localized + " " + String(row + 1) + " " + "day".localized
        }
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    let title = {
        switch row{
        case 0: return "every".localized + " " + "day".localized
        case 6: return "onceAWeek".localized
        default: return "every".localized + " " + String(row + 1) + " " + "day".localized
        }
    }()
        return NSAttributedString(string: title,
                                  attributes: [NSAttributedString.Key.font :
                                                UIFont(name: " ", size: 15)])
    }
//    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        return 60
//    }
}
