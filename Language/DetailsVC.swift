//
//  DetailsVC.swift
//  Language
//
//  Created by Star Lord on 21/02/2023.
//

import UIKit

class DetailsVC: UIViewController {

    var dictionary = DictionaryDetails()
    
    let randomiseCardsView : UIView = {
        var view = UIView()
        view.setUpBorderedView(true)
        return view
    }()
    
    let setTheGoalView : UIView = {
        var view = UIView()
        view.setUpBorderedView(true)
        return view
    }()

    let usePictureView : UIView = {
        var view = UIView()
        view.setUpBorderedView(true)
        return view
    }()
    
    let addNewWordsBut : UIButton = {
        var button = UIButton()
        button.layer.cornerRadius = 9
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.backgroundColor = .systemGray5
        
        button.setAttributedTitle(NSAttributedString(string: "Add new words",
                                                     attributes: [NSAttributedString.Key.font:
                                                                    UIFont(name: "Georgia-BoldItalic",
                                                                           size: 20) ?? UIFont()]), for: .normal)

        return button
    }()
    
    let beginBut : UIButton = {
        var button = UIButton()
        button.layer.cornerRadius = 9
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.backgroundColor = .systemGray4

        button.setAttributedTitle(NSAttributedString(string: "Start",
                                                     attributes: [NSAttributedString.Key.font:
                                                                    UIFont(name: "Georgia-BoldItalic",
                                                                           size: 20) ?? UIFont()]), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navBarCustomization()
        randomizeCardCustomization()
        setTheGoalCustomization()
        usePictureCustomization()
        beginButCustomization()
        addNewWordsCustomization()

        }
    
//MARK: - NavigationBar SetUp
    func navBarCustomization(){
        navigationItem.title = "Source Details"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Georgia-BoldItalic", size: 23)!]
        navigationController?.navigationItem.setRightBarButton(
            UIBarButtonItem(image:UIImage(systemName: "gearshape"),
                            style: .plain,
                            target: self,
                            action: #selector(settingsButTap(sender:))), animated: true)
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationItem.backButtonTitle = "Menu"
    }
    
//MARK: - RandomCardView SetUp
    func randomizeCardCustomization(){
        view.addSubview(randomiseCardsView)
                
        let label : UILabel = {
            var label = UILabel()
            label.attributedText = NSAttributedString(
                string: "Randomize cards",
                attributes: [NSAttributedString.Key.font :
                                UIFont(name: "Georgia-BoldItalic", size: 18) ?? UIFont(),
                             NSAttributedString.Key.foregroundColor :
                                UIColor.label
                            ])
            return label
        }()
        
        let switchForState : UISwitch = {
            let switchForState = UISwitch()
            switchForState.onTintColor = .systemGray2
            switchForState.tintColor = .systemBackground
            switchForState.setOn(true, animated: true)
            switchForState.addTarget(self, action: #selector(randomSwitchToggle(sender:)), for: .valueChanged)
            return switchForState
        }()
        
        randomiseCardsView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        switchForState.translatesAutoresizingMaskIntoConstraints = false
        
        randomiseCardsView.addSubviews(label, switchForState)
        
        NSLayoutConstraint.activate([
            randomiseCardsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 22),
            randomiseCardsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            randomiseCardsView.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
            randomiseCardsView.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
            
            label.centerYAnchor.constraint(equalTo: randomiseCardsView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: randomiseCardsView.leadingAnchor, constant: 15),
            
            switchForState.centerYAnchor.constraint(equalTo: randomiseCardsView.centerYAnchor),
            switchForState.trailingAnchor.constraint(equalTo: randomiseCardsView.trailingAnchor, constant: -25)
        ])
    }
    
//MARK: - SetTheGoal SetUp
    func setTheGoalCustomization(){
        view.addSubview(setTheGoalView)

        let label : UILabel = {
            var label = UILabel()
            label.attributedText = NSAttributedString(
                string: "Set the goal",
                attributes: [NSAttributedString.Key.font :
                                UIFont(name: "Georgia-BoldItalic", size: 18) ?? UIFont(),
                             NSAttributedString.Key.foregroundColor :
                                UIColor.label
                            ])
            return label
        }()
        
        let picker : UIPickerView = {
            let picker = UIPickerView()
            picker.delegate = self
            picker.dataSource = self
            return picker
        }()

        setTheGoalView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        setTheGoalView.addSubviews(label, picker)
        
        NSLayoutConstraint.activate([
            setTheGoalView.topAnchor.constraint(equalTo: self.randomiseCardsView.bottomAnchor, constant: 23),
            setTheGoalView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            setTheGoalView.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
            setTheGoalView.heightAnchor.constraint(equalToConstant: 60),
            
            label.leadingAnchor.constraint(equalTo: setTheGoalView.leadingAnchor, constant: 15),
            label.centerYAnchor.constraint(equalTo: setTheGoalView.centerYAnchor),
            
            picker.trailingAnchor.constraint(equalTo: setTheGoalView.trailingAnchor, constant: 0),
            picker.centerYAnchor.constraint(equalTo: setTheGoalView.centerYAnchor),
            picker.widthAnchor.constraint(equalTo: setTheGoalView.widthAnchor, multiplier: 0.3)
        ])
        
    }

//MARK: - UsePicture SetUp
    func usePictureCustomization(){
        view.addSubview(usePictureView)
        usePictureView.translatesAutoresizingMaskIntoConstraints = false
        
        let label : UILabel = {
            var label = UILabel()
            label.attributedText = NSAttributedString(
                string: "Use pictures",
                attributes: [NSAttributedString.Key.font :
                                UIFont(name: "Georgia-BoldItalic", size: 18) ?? UIFont(),
                             NSAttributedString.Key.foregroundColor :
                                UIColor.label
                            ])
            return label
        }()
        
        let switchForState : UISwitch = {
            let switchForState = UISwitch()
            switchForState.onTintColor = .systemGray2
            switchForState.tintColor = .systemBackground
            switchForState.setOn(false, animated: true)
            switchForState.addTarget(self, action: #selector(usePicturesSwitchToggle(sender:)), for: .valueChanged)
            return switchForState
        }()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        switchForState.translatesAutoresizingMaskIntoConstraints = false
        
        usePictureView.addSubviews(label, switchForState)
        
        NSLayoutConstraint.activate([
            usePictureView.topAnchor.constraint(equalTo: self.setTheGoalView.bottomAnchor, constant: 23),
            usePictureView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usePictureView.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
            usePictureView.heightAnchor.constraint(lessThanOrEqualToConstant: 60),
            
            label.centerYAnchor.constraint(equalTo: usePictureView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: usePictureView.leadingAnchor, constant: 15),
            
            switchForState.centerYAnchor.constraint(equalTo: usePictureView.centerYAnchor),
            switchForState.trailingAnchor.constraint(equalTo: usePictureView.trailingAnchor, constant: -25)
        ])

    }
//MARK: - AddNewWord SetUp
    func addNewWordsCustomization(){
        view.addSubview(addNewWordsBut)
        addNewWordsBut.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addNewWordsBut.bottomAnchor.constraint(equalTo: self.beginBut.topAnchor, constant: -23),
            addNewWordsBut.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addNewWordsBut.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
            addNewWordsBut.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
//MARK: - Toolbar SetUp
    func beginButCustomization(){
        view.addSubview(beginBut)
        beginBut.translatesAutoresizingMaskIntoConstraints = false
    
        NSLayoutConstraint.activate([
            beginBut.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -11),
            beginBut.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            beginBut.widthAnchor.constraint(equalToConstant: view.bounds.width - 44),
            beginBut.heightAnchor.constraint(equalToConstant: 50)
            ])
    }
    


//MARK: - Actions
    @objc func settingsButTap(sender: Any){
        let vc = LoadDataVC()
        self.present(vc, animated: true)
    }
    @objc func randomSwitchToggle(sender: Any){
        
    }
    @objc func usePicturesSwitchToggle(sender: Any){
        
    }

}
extension DetailsVC: UIPickerViewDelegate{
}
extension DetailsVC: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if ((Int(dictionary.numberOfCards)!) / 50) > 0{
           return ((Int(dictionary.numberOfCards)!) / 50) + 1
        } else {
            return 1
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row != (pickerView.numberOfRows(inComponent: component) - 1)  {
            return "\((row + 1) * 50)"
//            return dictionary.numberOfCards
//        } else if row != (pickerView.numberOfRows(inComponent: component) - 1) {
//            return "\((row + 1) * 50)"
        } else {
            return dictionary.numberOfCards
        }
    }
    
    
    
}

