//
//  TimedDetailView.swift
//  Learny
//
//  Created by Star Lord on 07/11/2024.
//
//  REFACTORING STATE: CHECKED


import UIKit

class TimedDetailView: UIViewController {
    //MARK: Variables
    private let key = "selectedTimerDurationInSec"
    private let minuteOptions: Int

    private var viewModelFactory: ViewModelFactory
    private var viewModel: DetailsViewModel?
    private var delegate: Presenter
    
    //MARK: - Views
    private let timePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let preselectTimeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = .innerSpacer
        return stackView
    }()

    private let fiveMinButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .popoverSubviewsBackgroundColour
        button.setTitle("5" + " " + "system.min.shortned".localized, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 9
        button.tag = 5
        return button
    }()
    private let tenMinButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .popoverSubviewsBackgroundColour
        button.setTitle("10" + " " + "system.min.shortned".localized, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 9
        button.tag = 10
        return button
    }()
    private let fifteenMinButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .popoverSubviewsBackgroundColour

        button.setTitle("15" + " " + "system.min.shortned".localized, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 9
        button.tag = 15
        return button
    }()
    
    let startButton: UIButton = {
        let button = UIButton()
        button.setUpCustomButton()
        button.backgroundColor = .popoverSubviewsBackgroundColour
        button.setAttributedTitle(
            .attributedString(
                string: "details.start".localized,
                with: .selectedFont,
                ofSize: 20), for: .normal
        )
        return button
    }()
    
    //MARK: - Inherited
    required init(viewModelFactory: ViewModelFactory, viewModel: DetailsViewModel?, delegate: Presenter, timeIntervalUpTo: Int){
        self.viewModel = viewModel
        self.viewModelFactory = viewModelFactory
        self.delegate = delegate
        self.minuteOptions = timeIntervalUpTo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureSubviews()
        configureTimePicker()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            startButton.layer.shadowColor = (traitCollection.userInterfaceStyle == .dark  
                                             ? shadowColorForDarkIdiom
                                             : shadowColorForLightIdiom
            )
        }
    }
    
    //MARK: Views SetUp
    private func configureView() {
        view.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                ? .secondarySystemBackground
                                : .systemBackground
        )
    }
    
    private func configureSubviews(){
        view.addSubviews(timePicker, preselectTimeStackView, startButton)
        preselectTimeStackView.addArrangedSubviews(fiveMinButton, tenMinButton, fifteenMinButton)
        
        timePicker.delegate = self
        timePicker.dataSource = self
        
        NSLayoutConstraint.activate([
            
            timePicker.topAnchor.constraint(equalTo: view.topAnchor,
                                            constant: .longOuterSpacer),
            timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            timePicker.widthAnchor.constraint(equalToConstant: 320 ),
            
            timePicker.heightAnchor.constraint(equalToConstant: 216 ),

            
            preselectTimeStackView.topAnchor.constraint(equalTo: timePicker.bottomAnchor,
                                                        constant: .longInnerSpacer),
            preselectTimeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                        constant: .longOuterSpacer),
            preselectTimeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                        constant: -.longOuterSpacer),
            preselectTimeStackView.bottomAnchor.constraint(lessThanOrEqualTo: startButton.topAnchor,
                                                           constant: -.innerSpacer),
            preselectTimeStackView.heightAnchor.constraint(equalToConstant: .genericButtonHeight),
            
            
            startButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -.longOuterSpacer ),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                 constant: .longOuterSpacer),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -.longOuterSpacer),
            startButton.heightAnchor.constraint(equalToConstant: .genericButtonHeight)
        ])
        
        startButton.addTarget(self, action: #selector(startButtonDidTap(sender: )), for: .touchUpInside)
        fiveMinButton.addTarget(self, action: #selector(timeButtonDidTap(sender:)), for: .touchUpInside)
        tenMinButton.addTarget(self, action: #selector(timeButtonDidTap(sender:)), for: .touchUpInside)
        fifteenMinButton.addTarget(self, action: #selector(timeButtonDidTap(sender:)), for: .touchUpInside)
    }
    
    private func configureTimePicker(){
        if let timeInSeconds = UserDefaults.standard.value(forKey: key) as? Int{
            let min = timeInSeconds / 60
            let sec = timeInSeconds % min
            timePicker.selectRow(min - 1 ,  inComponent: 0, animated: true)
            timePicker.selectRow(sec     ,  inComponent: 1, animated: true)
        }
    }
    //MARK: - Actions
    @objc func timeButtonDidTap(sender: UIButton){
        var selectedTime: Int = 0
        guard let viewModel = viewModel else { return }
        switch sender.tag {
        case 5: selectedTime = 5
        case 10: selectedTime = 10
        case 15: selectedTime = 15
        default: return
        }
        let vc = MainGameVC(viewModelFactory: self.viewModelFactory,
                            dictionary: viewModel.dictionary,
                            selectedOrder: viewModel.selectedCardsOrder(),
                            hideTransaltion: viewModel.isHideTranslationOn(),
                            selectedNumber: viewModel.selectedNumberOfCards(),
                            selectedTime: selectedTime * 60)
        self.dismiss(animated:  true)
        delegate.startTheGame(vc: vc)

    }
    @objc func startButtonDidTap(sender: Any) {
        guard let viewModel = viewModel else { return }
        let timeInSeconds = (timePicker.selectedRow(inComponent: 0) + 1) * 60 + timePicker.selectedRow(inComponent: 1)
        UserDefaults.standard.setValue(timeInSeconds, forKey: key)
        
        let vc = MainGameVC(viewModelFactory: self.viewModelFactory,
                            dictionary: viewModel.dictionary,
                            selectedOrder: viewModel.selectedCardsOrder(),
                            hideTransaltion: viewModel.isHideTranslationOn(),
                            selectedNumber: viewModel.selectedNumberOfCards(),
                            selectedTime: timeInSeconds)
        self.dismiss(animated:  true)
        delegate.startTheGame(vc: vc)
    }
}

// MARK: - UIPickerViewDelegate
extension TimedDetailView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return minuteOptions - 1
        } else {
            return 60
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(row + 1)"
        } else {
            if row < 10 {
                return "0\(row)"
            } else {
                return "\(row)"
            }
        }
    }
}
