//
//  TimedDetailView.swift
//  Learny
//
//  Created by Star Lord on 07/11/2024.
//

import UIKit

class TimedDetailView: UIViewController {

    let minuteOptions = Array(1...120) // Array for minutes from 1 to 120

    var viewModelFactory: ViewModelFactory
    var viewModel: DetailsViewModel?
    var delegate: Presenter
    let fiveMinButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .secondarySystemBackground
        button.setTitle("5 min", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 9
        button.tag = 5
        return button
    }()
    let tenMinButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .secondarySystemBackground
        button.setTitle("10 min", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 9
        button.tag = 10
        return button
    }()
    let fifteenMinButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .secondarySystemBackground
        button.setTitle("15 min", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 9
        button.tag = 15
        return button
    }()

    let picker: UIPickerView = {
        let picker = UIPickerView()
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    
    let startButton: UIButton = {
        let button = UIButton()
        button.setUpCustomButton()
        button.setAttributedTitle(
            .attributedString(
                string: "details.start".localized,
                with: .selectedFont,
                ofSize: 20), for: .normal
        )
        
        return button
    }()
    
    required init(viewModelFactory: ViewModelFactory, viewModel: DetailsViewModel?, delegate: Presenter){
        self.viewModel = viewModel
        self.viewModelFactory = viewModelFactory
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        

    }
    

    private func configureView(){
        self.view.addSubviews(fiveMinButton, tenMinButton, fifteenMinButton, picker, startButton)
        
        picker.delegate = self
        picker.dataSource = self
        
        let spacer = (view.bounds.width - (view.bounds.width * .widthMultiplerFor(type: .forViews))) / 2
        let widthWithAllSpacers = ((view.bounds.width * .widthMultiplerFor(type: .forViews)) - spacer * 2) / 3
        NSLayoutConstraint.activate([
            
            picker.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            picker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            picker.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forPickers)),

            fiveMinButton.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 20),
            fiveMinButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: spacer),
            fiveMinButton.heightAnchor.constraint(equalToConstant: 40),
            fiveMinButton.widthAnchor.constraint(equalToConstant: widthWithAllSpacers),
            
            tenMinButton.centerYAnchor.constraint(equalTo: fiveMinButton.centerYAnchor),
            tenMinButton.leadingAnchor.constraint(equalTo: fiveMinButton.trailingAnchor, constant: spacer),
            tenMinButton.heightAnchor.constraint(equalToConstant: 40),
            tenMinButton.widthAnchor.constraint(equalToConstant: widthWithAllSpacers),
            
            fifteenMinButton.centerYAnchor.constraint(equalTo: tenMinButton.centerYAnchor),
            fifteenMinButton.leadingAnchor.constraint(equalTo: tenMinButton.trailingAnchor, constant: spacer),
            fifteenMinButton.heightAnchor.constraint(equalToConstant: 40),
            fifteenMinButton.widthAnchor.constraint(equalToConstant: widthWithAllSpacers),

//            picker.topAnchor.constraint(equalTo: fiveMinButton.bottomAnchor, constant: 20),
//            picker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            picker.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forPickers)),
            
            startButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            startButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        startButton.addTarget(self, action: #selector(startButtonDidTap(sender: )), for: .touchUpInside)
        fiveMinButton.addTarget(self, action: #selector(start(sender:)), for: .touchUpInside)
        tenMinButton.addTarget(self, action: #selector(start(sender:)), for: .touchUpInside)
        fifteenMinButton.addTarget(self, action: #selector(start(sender:)), for: .touchUpInside)
        

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func viewDidLayoutSubviews() {
        view.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                ? .secondarySystemBackground
                                : .systemBackground)
        self.modalPresentationStyle = .pageSheet

        sheetPresentationController?.detents = [.custom(resolver: { context in
            return self.view.bounds.width      
        })]

    }
    
    @objc func start(sender: UIButton){
        var selectedTime: Int = 0
        switch sender.tag {
        case 5: selectedTime = 5
        case 10: selectedTime = 10
        case 15: selectedTime = 15
        default: return
        }
        let vc = MainGameVC(viewModelFactory: self.viewModelFactory, dictionary: viewModel?.dictionary ?? DictionariesEntity(), selectedOrder: viewModel?.selectedCardsOrder() ?? .normal, hideTransaltion: viewModel?.isHideTranslationOn() ?? false, selectedNumber: viewModel?.selectedNumberOfCards() ?? 1, selectedTime: selectedTime)
        self.dismiss(animated:  true)
        delegate.startTheGame(vc: vc)
    }
    @objc func startButtonDidTap(sender: Any) {
        var selectedTime = picker.selectedRow(inComponent: 0) + 1
        let vc = MainGameVC(viewModelFactory: self.viewModelFactory, dictionary: viewModel?.dictionary ?? DictionariesEntity(), selectedOrder: viewModel?.selectedCardsOrder() ?? .normal, hideTransaltion: viewModel?.isHideTranslationOn() ?? false, selectedNumber: viewModel?.selectedNumberOfCards() ?? 1, selectedTime: selectedTime)
        self.dismiss(animated:  true)
        delegate.startTheGame(vc: vc)
    }
    
//    @objc func start(sender: Any){
//            let vc = MainGameVC(viewModelFactory: viewModelFactory, dictionary: dictionary, isRandom:/* random ??*/ self.randomizeSwitch.isOn, hideTransaltion: /*hide ??*/ self.isOneSideModeSwitch.isOn, selectedNumber: number ?? selectedNumber)
//            self.navigationController?.pushViewController(vc, animated: true)
        

//    }
}

extension TimedDetailView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1 // Only one component for minutes
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return minuteOptions.count // Number of options in the array
        }
        
        // MARK: - UIPickerViewDelegate
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return "\(minuteOptions[row]) min"
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let selectedMinutes = minuteOptions[row]
            print("Selected study time: \(selectedMinutes) minutes")
            // Use selectedMinutes to set the study duration
        }

}
