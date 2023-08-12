//
//  AddWordsVC.swift
//  Language
//
//  Created by Star Lord on 05/03/2023.
//

//TODO: Add localization for alerts.
import UIKit
import Combine

class AddWordsView: UIViewController {

    //MARK: - ViewModel related
    private var viewModel: AddWordsViewModel!
    private var cancellable = Set<AnyCancellable>()
    
    //MARK: - Views
    private lazy var textInputView: TextInputView = TextInputView(delegate: self)

    private let saveButton : UIButton = {
        let button = UIButton()
        button.setUpCustomButton()
        return button
    }()
    var topStroke = CAShapeLayer()
    var bottomStroke = CAShapeLayer()
    
    //MARK: Constraints related
    private var textInputViewHeightAnchor: NSLayoutConstraint!
    private var textInputViewBottomAnchor: NSLayoutConstraint!
    
    private var subviewsVerticalInset: CGFloat = 13
    private var buttonHeight: CGFloat = 60

    //MARK: Inherited
    required init(dictionary: DictionariesEntity){
        viewModel = AddWordsViewModel(dictionary: dictionary)
        super.init(nibName:  nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Coder wasn't imported")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureController()
        configureNavBar()
        configureTextInputView()
        configureText()
        configureSaveButton()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureStrokes()
    }

    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.bottomStroke.strokeColor = UIColor.label.cgColor
            self.topStroke.strokeColor = UIColor.label.cgColor
            if traitCollection.userInterfaceStyle == .dark {
                saveButton.layer.shadowColor = shadowColorForDarkIdiom
                textInputView.layer.shadowColor = shadowColorForDarkIdiom
            } else {
                saveButton.layer.shadowColor = shadowColorForLightIdiom
                textInputView.layer.shadowColor = shadowColorForLightIdiom

            }
        }
    }
    //MARK: Binding
    private func bind(){
        viewModel.output
            .sink { output in
                switch output {
                case .shouldPresentEerror(let error):
                    self.presentError(error)
                case .shouldPop:
                    self.navigationController?.popViewController(animated: true)
                case .shouldUpdatePlaceholder:
                    self.textInputView.updatePlaceholder()
                case .shouldUpdateText:
                    self.textInputView.updatePlaceholder()
                    self.configureText()
                }
            }
            .store(in: &cancellable)
    }
    //MARK: - Controller SetUp
    func configureController(){
        view.backgroundColor = .systemBackground
        
        //Observer on keyboard.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    //MARK: - Stroke SetUp
    func configureStrokes(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
    //MARK: - NavBar SetUp
    func configureNavBar(){
        self.navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.isTranslucent = true
    }
    //MARK: - TextInputView SetUp
    func configureTextInputView(){
        view.addSubview(textInputView)
        
        textInputViewHeightAnchor = textInputView.heightAnchor.constraint(equalTo: textInputView.widthAnchor, multiplier: 0.66)
        textInputViewBottomAnchor = textInputView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -subviewsVerticalInset)
        NSLayoutConstraint.activate([
            textInputView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            textInputView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textInputView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            textInputViewHeightAnchor
        ])
    }
    //MARK: - Save Button SetUp
    func configureSaveButton(){
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -subviewsVerticalInset),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            saveButton.heightAnchor.constraint(equalToConstant: buttonHeight),
        ])
        saveButton.addTargetTouchBegin()
        saveButton.addTargetInsideTouchStop()
        saveButton.addTargetOutsideTouchStop()
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender: )), for: .touchUpInside)
    }
    
    //MARK: - Other
    //When user trying to save information, checks is it empty and return String if not.
    func validateText() -> String?{
        let insertTextAllert = UIAlertController(
            title: "textAlert".localized,
            message: "textInfo".localized ,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: "system.agreeInformal".localized,
            style: .cancel)
        insertTextAllert.addAction(action)
        action.setValue(UIColor.label, forKey: "titleTextColor")

        guard let text = textInputView.textView.text, text != "" else {
            self.present(insertTextAllert, animated: true)
            return nil
        }
        return text
    }
    //Uses as initial configurator for text values and in order to update them.
    func configureText(){
        navigationItem.title = "addWordTitle".localized
        saveButton.setAttributedTitle(
            .attributedString(string: "system.save".localized, with: .georgianBoldItalic, ofSize: 18), for: .normal)

        if let doneButton = navigationItem.rightBarButtonItem {
            doneButton.title = "system.done".localized
        }
    }
    //Switch between standalone contrait and attached to saveButton
    func updateTextViewConstraits(keyboardIsvisable: Bool){
        textInputViewHeightAnchor.isActive = !keyboardIsvisable
        textInputViewBottomAnchor.isActive = keyboardIsvisable
        view.layoutIfNeeded()
    }

//MARK: - Actions
    //Done button, which appears when user activate keyboard.
    @objc func rightBarButDidTap(sender: Any){
        navigationItem.rightBarButtonItem = nil
        textInputView.textView.resignFirstResponder()
    }
    //Addding input text to the dictionary.
    @objc func saveButtonDidTap(sender: UIButton){
        guard let text = validateText() else { return }
        
        viewModel.getNewWordsFrom(text)
    }
    //Small animation of bottom stroke dissapearence
    @objc func keyboardWillShow(sender: Notification){
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        bottomStroke.add(animation, forKey: "strokeOpacity")
        
        updateTextViewConstraits(keyboardIsvisable: true)
    }
    //Animate bottom stroke back to 1 alpha.
    @objc func keyboardWillHide(sender: Notification){
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 1.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        bottomStroke.add(animation, forKey: "strokeOpacity")
        
        updateTextViewConstraits(keyboardIsvisable: false)
    }
}

extension AddWordsView: PlaceholderTextViewDelegate{
    func textViewWillAppear() {
        if self.navigationController?.navigationItem.rightBarButtonItem == nil{
            self.navigationItem.setRightBarButton(UIBarButtonItem(title: "system.done".localized, style: .plain, target: self, action: #selector(rightBarButDidTap(sender:))), animated: true)
        }
    }
    
    func configurePlaceholderText() -> String {
        self.viewModel.configureTextPlaceholder()
    }
    
}
