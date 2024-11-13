//
//  TimedDetailView.swift
//  Learny
//
//  Created by Star Lord on 07/11/2024.
//

import UIKit

class TimedDetailView: UIViewController {

    let minuteOptions = Array(1...120) // Array for minutes from 1 to 120

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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        

    }
    

    private func configureView(){
        self.view.addSubviews(picker, startButton)
        
        picker.delegate = self
        picker.dataSource = self
        
        NSLayoutConstraint.activate([
            picker.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            picker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            picker.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forPickers)),
            
            startButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.91),
            startButton.heightAnchor.constraint(equalToConstant: 55)
        ])
        
//        startButton.addTarget(self, action: <#T##Selector#>, for: <#T##UIControl.Event#>)

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
    
    @objc func start(sender: Any){
//            let vc = MainGameVC(viewModelFactory: viewModelFactory, dictionary: dictionary, isRandom:/* random ??*/ self.randomizeSwitch.isOn, hideTransaltion: /*hide ??*/ self.isOneSideModeSwitch.isOn, selectedNumber: number ?? selectedNumber)
//            self.navigationController?.pushViewController(vc, animated: true)
        

    }
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
