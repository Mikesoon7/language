//In purpose of more controll over the presentaintion appearence, we are  working with container view, which relacing ViewControllers view.
//It helps us to controll the visible part of view by changing bottom constrait of the container view.

import UIKit
import Combine

class NotificationView: UIViewController {

    private let viewModel: NotificationViewModel
    private var cancellable = Set<AnyCancellable>()
    
    //MARK: - Views
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 9
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        
        view.register(NotificationTextCell.self, forCellReuseIdentifier: NotificationTextCell.identifier)
        view.register(NotificationSwitchCell.self, forCellReuseIdentifier: NotificationSwitchCell.identifier)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        
        view.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        view.automaticallyAdjustsScrollIndicatorInsets = false
        view.contentInset = .zero
        view.subviews.forEach { section in
            view.addRightSideShadow()
        }
        return view
    }()
    
    private let frequencyPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.alpha = 0
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .wheels
        picker.datePickerMode = .time
        picker.alpha = 0
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var dayPicker: NotificationDayPicker = NotificationDayPicker(viewModel: viewModel)
        
    //MARK: - Constraints
    private var containerViewBottomAnchor: NSLayoutConstraint!
    private var tableViewHeightAnchor: NSLayoutConstraint!
    
    //Dimenstions
    private lazy var firstStageContainerConstant = containerHeight - tableView.frame.height / 2
    private lazy var secondStageContainerConstant = containerHeight - (timePicker.frame.minY + view.safeAreaInsets.bottom)
    private lazy var thirdStageContainerConstant = containerHeight - dayPicker.frame.minY
    private lazy var finalStageContainerConstant = containerHeight - (dayPicker.frame.maxY + view.safeAreaInsets.bottom + 20)

    //We are using computed properties.
    private lazy var containerHeight = view.frame.height
    private lazy var initalContainerConstant = containerHeight
    private lazy var currentConstant = initalContainerConstant
    
    private var firstStage: CGFloat {
        return viewModel.notificationAreOn() ? secondStageContainerConstant : firstStageContainerConstant
    }
    private var finalStage: CGFloat {
        return viewModel.customFrequencyIsOn() ? finalStageContainerConstant : thirdStageContainerConstant
    }
    
    required init(factory: ViewModelFactory){
        self.viewModel = factory.configureNotificationsModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Inherited
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        
        configureController()
        configureContainerView()
        configureTableView()
        configurePicker()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activateView()
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                containerView.subviews.forEach { view in
                    view.layer.shadowColor = shadowColorForDarkIdiom
                }
                containerView.backgroundColor = .secondarySystemBackground
                dayPicker.backgroundColor = .systemGray5
            } else {
                containerView.subviews.forEach { view in
                    view.layer.shadowColor = shadowColorForLightIdiom
                }
                containerView.backgroundColor = .systemBackground
                dayPicker.backgroundColor = .secondarySystemBackground
            }
        }
    }
    //MARK: - Bind View and VM
    func bind(){
        viewModel.output
            .sink { output in
                switch output{
                case .shouldValidateFirstStage:
                    self.animateTransitionTo(self.firstStage)
                case .shouldValidateFinalStage:
                    self.animateTransitionTo(self.finalStage)

                case .shouldUpdateTableRowAt(let index):
                    self.tableView.reloadRows(at: [index], with: .automatic)
                case .error(let error):
                    self.presentError(error)
                case .presentNotificationInformAlert:
                    self.presentNotificationAlert()
                                }
            }
            .store(in: &cancellable)
    }
    //MARK: - ViewController SetUp
    private func configureController(){
        view.backgroundColor = .clear
        self.modalPresentationStyle = .overFullScreen
        configureGestures()
    }
    //MARK: - TableViewSetUp
    //Because we need to place views in some kind of stack, we forcing reload of tableView and to compute the content heght and assign it to tables constrait. Placing all components is StackView didn't work.
    private func configureTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        
        containerView.addSubview(tableView)
        
        tableViewHeightAnchor = tableView.heightAnchor.constraint(equalToConstant: 100)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableViewHeightAnchor,
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
        
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableViewHeightAnchor?.constant = tableView.contentSize.height
    }
    
    //MARK: - Container SetUp
    private func configureContainerView(){
        containerView.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                ? UIColor.secondarySystemBackground
                                : UIColor.systemBackground)
        
        view.addSubviews(dimmedView, containerView)
                
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor, constant: initalContainerConstant)
        
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor),
            containerViewBottomAnchor,
        ])

    }
    
    //MARK: - Frequency, time and day picker SetUp
    private func configurePicker(){
        frequencyPicker.delegate = self
        frequencyPicker.dataSource = self

        containerView.addSubviews(frequencyPicker, timePicker, dayPicker)
        
        NSLayoutConstraint.activate([
            frequencyPicker.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            frequencyPicker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            frequencyPicker.widthAnchor.constraint(equalTo: containerView.widthAnchor,
                                                   multiplier: CGFloat.widthMultiplerFor(type: .forPickers)),
            
            timePicker.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            timePicker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            timePicker.widthAnchor.constraint(equalTo: containerView.widthAnchor,
                                              multiplier: CGFloat.widthMultiplerFor(type: .forPickers)),
            
            dayPicker.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 10),
            dayPicker.widthAnchor.constraint(equalTo: containerView.widthAnchor,
                                             multiplier: CGFloat.widthMultiplerFor(type: .forViews)),
            dayPicker.heightAnchor.constraint(equalToConstant: 66),
            dayPicker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        ])
        timePicker.addTarget(self, action: #selector(timePickerValueChanged(picker:)), for: .valueChanged)
    }
    
    //MARK: - Gestures
    private func configureGestures(){
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewDidPan(gesture: )))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewDidTap(gesture: )))
        
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        
        dimmedView.addGestureRecognizer(tapGesture)
        view.addGestureRecognizer(panGesture)
    }
    //MARK: - Animations
    //Method to change containers Bottom constrait.
    private func animateTransitionTo(_ newConstant: CGFloat){
        if newConstant == finalStageContainerConstant {
            animateDayPicker(present: true)
        } else if newConstant == thirdStageContainerConstant && dayPicker.alpha != 0{
            animateDayPicker(present: false )
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.containerViewBottomAnchor?.constant = newConstant
            self?.currentConstant = newConstant
            self?.view.layoutIfNeeded()
        }
    }
    //Changing containers bottom anchor
    private func animateContainer(present: Bool){
        if present {
            animateTransitionTo(firstStage)
        } else {
            animateTransitionTo(initalContainerConstant)
        }
    }
    //Changing opacity for dimming view.
    private func animateDimmingView(present: Bool){
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = present ? 0.4 : 0
        }
    }
    private func activateView(){
        animateContainer(present: true)
        animateDimmingView(present: true)
    }
    
    private func dismissView(){
        animateContainer(present: false)
        animateDimmingView(present: false)
        viewModel.save()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss(animated: true)
        }
    }
    
    //MARK: - Specific animations for pickers
    //Since day and frequnccy pickers have same position, check if second is hidden
    private func animateToFrequencyPicker(){
        UIView.animate(withDuration: 0.3) {
            self.frequencyPicker.alpha = 1
            if self.timePicker.alpha > 0 {
                self.timePicker.alpha = 0
            }
        }
        animateTransitionTo(finalStage)
    }
    private func animateToDatePicker(){
        UIView.animate(withDuration: 0.3) {
            self.timePicker.alpha = 1
            if self.frequencyPicker.alpha > 0 {
                self.frequencyPicker.alpha = 0
            }
        }
        
        animateTransitionTo(finalStage)
    }
    
    private func animateDayPicker(present: Bool){
        if present{
            UIView.animate(withDuration: 0.3) {
                self.dayPicker.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.dayPicker.alpha = 0
            }

        }
    }
    //MARK: Alert we presenting in case user declined notifications.
    private func presentNotificationAlert(){
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "notification.alertTitle".localized,
                message: "notification.alertMessage".localized ,
                preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: "system.settings".localized, style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "system.cancel".localized, style: .default, handler: nil)
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: nil)
        }

    }
}
//MARK: - Actions
extension NotificationView{
    //If user taps outside of the container view, we closing the notification setUp
    @objc func viewDidTap(gesture: UITapGestureRecognizer){
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location){
            dismissView()
        }
    }
    @objc func viewDidPan(gesture: UIPanGestureRecognizer){
        let translation = gesture.translation(in: view).y
        let velocity = gesture.velocity(in: view).y
        let newConstant = self.currentConstant + translation
                
        switch gesture.state {
        case .began, .changed:
            if currentConstant == firstStageContainerConstant {
                if translation > -10 {
                    containerViewBottomAnchor?.constant = newConstant
                    view.layoutIfNeeded()
                }
            } else if translation > -50 {
                containerViewBottomAnchor?.constant = newConstant
                view.layoutIfNeeded()
            }
        case .ended:
            if velocity > 500 || translation > 50 {
                dismissView()
            } else {
                animateTransitionTo(currentConstant)
            }

        default:
            break
        }
    }
    @objc func timePickerValueChanged(picker: UIDatePicker){
        let date = picker.date
        print(date)
        viewModel.updateNotificationTime(with: date)
    }
}

//MARK: - Table Delegae & DataSource
extension NotificationView: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let switchCell = tableView.dequeueReusableCell(
            withIdentifier: NotificationSwitchCell.identifier)
                as? NotificationSwitchCell else { return UITableViewCell() }
        guard let textCell = tableView.dequeueReusableCell(
            withIdentifier: NotificationTextCell.identifier)
                as? NotificationTextCell else { return UITableViewCell() }
        
        switch (indexPath.section){
        case 0:
            switchCell.control.isOn = viewModel.notificationAreOn()
            switchCell.delegate = viewModel
            return switchCell
        case 1:
            textCell.configureCellWithData(viewModel.dataForCellAt(indexPath: indexPath))
            return textCell
        default: return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row){
        case (0, 0):
            animateTransitionTo( firstStage )
        case (1, 0):
            let index = viewModel.selectedRowForFrequencyPicker()
            frequencyPicker.selectRow(index.row, inComponent: index.section, animated: true)
            animateToFrequencyPicker()
        case (1, 1):
            let time = viewModel.selectedDateForTimePicker()
            timePicker.date = time
            animateToDatePicker()
        default: break
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCellsIn(section: section)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections()
    }
}

//MARK: - Picker delegate & dataSource
extension NotificationView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.numberOfRowsInComponent()
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel.titleForRow(for: row)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.updateFrequency(row: row)
    }
}

