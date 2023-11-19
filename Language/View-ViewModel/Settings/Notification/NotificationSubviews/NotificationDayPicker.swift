//
//  DayPicker.swift
//  Language
//
//  Created by Star Lord on 05/08/2023.
//

//Custom view displaying 7 buttons. Each represents day.
import UIKit

class NotificationDayPicker: UIView{
    
    private var selectedDaysSet : [Int]!
    private weak var viewModel: NotificationViewModel!
        
    //Array of names for each day, starts from the same as in system day.
    private lazy var arrayOfDays: [String] = {
        let calendar = Calendar.current
        let firstDay = calendar.firstWeekday
        let formatter = DateFormatter()
        formatter.locale = viewModel.getCurrentLocale()
        var array: [String] = []
        for i in 0..<7 {
            let index = (firstDay - 1 + i) % 7
            array.append(formatter.shortWeekdaySymbols[index])
        }
        return array
    }()

    //MARK: Inherited
    required init(viewModel: NotificationViewModel){
        super.init(frame: .zero)
        self.selectedDaysSet = viewModel.getSelectedDays()
        self.viewModel = viewModel

        configureView()
        configureStackView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Coder wasn't imported")
    }
    override func layoutSubviews() {
        if let stackView = self.subviews.first as? UIStackView, let firstButton = stackView.arrangedSubviews.first as? UIButton, let lastButton = stackView.arrangedSubviews.last as? UIButton {
            print("mask was configured")
            firstButton.layer.mask = configureOneSideRoundedMask(for: firstButton, left: true, cornerRadius: 9)
            lastButton.layer.mask = configureOneSideRoundedMask(for: lastButton, left: false, cornerRadius: 9)
        }
    }
    //MARK: - View SetUp
    private func configureView(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 9
        self.alpha = 0
        self.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                ? UIColor.systemGray5
                                : UIColor.secondarySystemBackground)
        self.addRightSideShadow()
    }
    //MARK: - StackView SetUp and populating buttons
    private func configureStackView(){
        let stackView = UIStackView()
        
        for (index, i) in arrayOfDays.enumerated() {
            let tag = index + 1
            let button = createDayButton(with: i, tag: tag , isOn: selectedDaysSet.contains(tag))
            stackView.addArrangedSubview(button)
        }
        
        stackView.backgroundColor = .clear
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.contentMode = .scaleToFill
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
    }
    //MARK: - Button SetUp and related.
    private func createDayButton(with title: String, tag: Int, isOn: Bool) -> UIButton{
        let button = UIButton(configuration: .plain())
        button.backgroundColor = .clear

        button.tag = tag
        button.configuration?.titlePadding = 0
        button.configuration?.title = title

        button.configuration?.contentInsets = .zero
        button.configuration?.baseForegroundColor = .label
        button.configuration?.imagePlacement = .bottom
        button.configuration?.imagePadding = 10
        button.configuration?.image = UIImage(systemName: isOn ? "checkmark.circle" : "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
        
        button.addTarget(self, action: #selector(buttonDidTap(sender: )), for: .touchUpInside)
        return button
    }
    
    //Updating array of selected days
    @objc func buttonDidTap(sender: UIButton) {
        if selectedDaysSet.contains(sender.tag) {
            selectedDaysSet.removeAll(where: {$0 == sender.tag})
        } else {
            selectedDaysSet.append(sender.tag)
        }
        updateButtonState(button: sender, isSelected: selectedDaysSet.contains(sender.tag))
        viewModel.updateSelectedDaysSet(with: sender.tag)
    }

    //Reflecting on state change.
    private func updateButtonState(button: UIButton, isSelected: Bool) {
        button.configuration?.image = UIImage(systemName: isSelected ? "checkmark.circle" : "circle", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))
//        button.backgroundColor = isSelected ? .systemGray5 : .clear
    }
}
