//
//  AddWordsPartitialController.swift
//  Learny
//
//  Created by Star Lord on 13/11/2024.
//

import UIKit
import Combine

class AddWordsPartitialController: UIViewController, UISheetPresentationControllerDelegate {

    private var viewModel: AddWordsViewModel?
    private var viewModelFactory: ViewModelFactory
    
    private var cancellable = Set<AnyCancellable>()
    
    private var contentWasSaved: Bool = false
    //MARK: Views
    
    private var addNewWordsLabel: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(20)
        label.text = "Add new words"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var textInputView: TextInputView = TextInputView(delegate: self)
    
    //Navigation bar button to dismiss keyboard.
    private lazy var doneButton = configureButtonWith(title: "system.done".localized)
    
    let textShadowView = UIView()

    private let saveButton : UIButton = {
        let button = UIButton()
        button.setUpCustomButton()
        return button
    }()
    
    var doneButtonTrailingAnchor: NSLayoutConstraint = .init()

    
    //MARK: Constraints related
    private var textInputViewHeightAnchor: NSLayoutConstraint!
    private var textInputViewBottomAnchor: NSLayoutConstraint!
    
    private var textViewActiveBottomAnchor: NSLayoutConstraint!
    private var textViewInactiveBottomAnchor: NSLayoutConstraint!
    
    
    private var subviewsVerticalInset: CGFloat = 13
    private var buttonHeight: CGFloat = 60

    //MARK: Inherited
    required init(factory: ViewModelFactory, dictionary: DictionariesEntity){
        self.viewModelFactory = factory
        self.viewModel = factory.configureAddWordsViewModel(dictionary: dictionary)
        super.init(nibName:  nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("Coder wasn't imported")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        

        bind()
        configureView()
        configureTextInputView()
        configureText()
        configureSaveButton()
    }
    
    override func viewDidLayoutSubviews() {
        view.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                ? .secondarySystemBackground
                                : .systemBackground)
        self.modalPresentationStyle = .pageSheet

        sheetPresentationController?.detents = [.custom(resolver: { context in
            return self.view.bounds.width

        })]
        sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true

    }
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear")
        if !textInputView.textView.text.isEmpty && self.contentWasSaved != true {
            let alert = UIAlertController.alertWithAction(alertTitle: "Content wasn't saved you", alertMessage: "Would you like to save your new words ?", alertStyle: .actionSheet, action1Title: "Dismiss", action1Handler: { _ in super.viewWillDisappear(animated) },  action1Style: .default, action2Title: "Save") { _ in
                self.saveButtonDidTap(sender: self.saveButton)
            }
            print("should present the alert")
            print(self.navigationController?.topViewController)
            self.parent?.present(alert, animated: true)
            self.present(alert, animated: true)
        } else {
            print("should dismiss")
            super.viewWillDisappear(animated)
        }
    
    }

    
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                saveButton.layer.shadowColor = shadowColorForDarkIdiom
            } else {
                saveButton.layer.shadowColor = shadowColorForLightIdiom
            }
        }
    }
    //MARK: Binding
    private func bind(){
        viewModel?.output
            .sink { [weak self] output in
                guard let self = self else {return}
                switch output {
                case .shouldPresentError(let error):
                    self.presentError(error)
                case .shouldPop:
                    print("should pop")
                    self.contentWasSaved = true
                    self.dismiss(animated: true)
                    self.navigationController?.popViewController(animated: true)
                    //                    self.navigationController?.popViewController(animated: true)
                case .shouldUpdateFont:
                    self.textInputView.updatePlaceholder()
                case .shouldUpdatePlaceholder:
                    self.textInputView.updatePlaceholder()
                case .shouldUpdateText:
                    self.textInputView.updatePlaceholder()
                    self.configureText()
                case .shouldHighlightError(let word):
                    self.highlightErrorFor(word)
                }
            }
            .store(in: &cancellable)
    }
    
    
    //MARK: View Setup
    private func configureView(){
        
        //Observer on keyboard.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let sheetPresentationController = self.presentationController as? UISheetPresentationController {
                sheetPresentationController.delegate = self
            }
    }

    //MARK: Subviews SetUp
    private func configureTextInputView(){
        
        textShadowView.setUpCustomView()
        
        view.addSubviews(addNewWordsLabel, doneButton, textShadowView, textInputView)
        
        textInputViewHeightAnchor = textShadowView.heightAnchor.constraint(equalToConstant: 150)
        textInputViewBottomAnchor = textShadowView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -subviewsVerticalInset)

        doneButtonTrailingAnchor = doneButton.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)

        NSLayoutConstraint.activate([
            
            addNewWordsLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 20),
            addNewWordsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: (view.bounds.width - view.bounds.width * .widthMultiplerFor(type: .forViews)) / 2),
            
            doneButton.centerYAnchor.constraint(equalTo: addNewWordsLabel.centerYAnchor),
            doneButtonTrailingAnchor,
            
            textShadowView.topAnchor.constraint(
                equalTo: addNewWordsLabel.bottomAnchor,
                constant: 20),
            textShadowView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            textShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            textInputViewHeightAnchor,
            textShadowView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150),
//            textShadowView.heightAnchor.constraint(
//                equalToConstant: 150),
            
            
            textInputView.topAnchor.constraint(equalTo: textShadowView.topAnchor),
            textInputView.leadingAnchor.constraint(equalTo: textShadowView.leadingAnchor),
            textInputView.trailingAnchor.constraint(equalTo: textShadowView.trailingAnchor),
            textInputView.bottomAnchor.constraint(equalTo: textShadowView.bottomAnchor)
        ])
        doneButton.addTarget(self, action: #selector(rightBarButDidTap(sender: )), for: .touchUpInside)

    }
    private func configureSaveButton(){
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(greaterThanOrEqualTo: view.keyboardLayoutGuide.topAnchor, constant: -subviewsVerticalInset),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            saveButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            saveButton.topAnchor.constraint(greaterThanOrEqualTo: textShadowView.bottomAnchor, constant: subviewsVerticalInset)
        ])
        saveButton.addTargetTouchBegin()
        saveButton.addTargetInsideTouchStop()
        saveButton.addTargetOutsideTouchStop()
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender: )), for: .touchUpInside)
    }
    
    //MARK: System
    ///Returns textView value. If value equals nil, return nil and present an error.
    private func validateText() -> String?{
        guard let text = textInputView.textView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let insertTextAllert = UIAlertController(
                title: "textAlert".localized,
                message: "textInfo".localized ,
                preferredStyle: .actionSheet)
            let action = UIAlertAction(
                title: "system.agreeInformal".localized,
                style: .cancel)
            insertTextAllert.addAction(action)
            action.setValue(UIColor.label, forKey: "titleTextColor")
            self.present(insertTextAllert, animated: true)
            return nil
        }
        return text
    }
    /// Congifure all text properties of the view.
    private func configureText(){
        navigationItem.title = "addWord.title".localized
        saveButton.setAttributedTitle(
            .attributedString(string: "system.save".localized, with: .georgianBoldItalic, ofSize: 18), for: .normal)
        doneButton.setAttributedTitle(
            .attributedString(string: "system.done".localized, with: .systemBold, ofSize: 15), for: .normal)
        textInputView.textView.isTextUpdateRequired = true
    }
    
    private func changeDoneButtonState(activate: Bool){
        UIView.animate(withDuration: 0.2, delay: 0) { [weak self] in
            self?.doneButtonTrailingAnchor.constant = activate ? -(self?.doneButton.frame.width ?? 65) : 0
//            self?.informationButton.alpha = activate ? 0 : 1
            self?.view.layoutIfNeeded()
        }
    }
    ///Switch between standalone contrait and attached to saveButton
    private func updateTextViewConstraits(keyboardIsvisable: Bool){
        textInputViewHeightAnchor.isActive = !keyboardIsvisable
        textInputViewBottomAnchor.isActive = keyboardIsvisable
        view.layoutIfNeeded()
    }
    
    private func highlightErrorFor(_ word: String){
        guard let text = self.textInputView.textView.text, let range = text.range(of: word, options: .caseInsensitive, range: word.startIndex..<text.endIndex) else {
            return
        }
        
        let NSRAnge = NSRange(range, in: text)
        self.textInputView.highlightError(NSRAnge)
    }
    
    ///Configure button by assigning title and font.
    private func configureButtonWith(title: String) -> UIButton{
        let button = UIButton()
        button.configuration = .plain()
        button.setAttributedTitle(.attributedString(string: title, with: .systemBold, ofSize: 15), for: .normal)
        button.configuration?.baseForegroundColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        // Show your alert here instead of in viewWillDisappear
        if !textInputView.textView.text.isEmpty && self.contentWasSaved != true {
            let alert = UIAlertController.alertWithAction(
                alertTitle: "Content wasn't saved",
                alertMessage: "Would you like to save your new words?",
                alertStyle: .actionSheet,
                action1Title: "Dismiss",
                action1Handler: { _ in
                    // Dismiss the view controller after confirming
                    self.dismiss(animated: true)
                },
                action1Style: .default,
                action2Title: "Save"
            ) { _ in
                self.saveButtonDidTap(sender: self.saveButton)
                self.dismiss(animated: true)
            }
            
            self.present(alert, animated: true)
        } else {
            // If no changes need saving, allow the dismissal
            self.dismiss(animated: true)
        }
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
        
        viewModel?.getNewWordsFrom(text)
    }
    //Small animation of bottom stroke dissapearence
    @objc func keyboardWillShow(sender: Notification){
        
        updateTextViewConstraits(keyboardIsvisable: true)
    }
    //Animate bottom stroke back to 1 alpha.
    @objc func keyboardWillHide(sender: Notification){
        updateTextViewConstraits(keyboardIsvisable: false)
    }
}

extension AddWordsPartitialController: PlaceholderTextViewDelegate{
    func textViewDidBeginEditing() {
        self.changeDoneButtonState(activate: true)
    }
    func textViewDidEndEditing() {
        self.changeDoneButtonState(activate: false)
    }
    
    func configurePlaceholderText() -> String? {
        viewModel?.configureTextPlaceholder()
    }
}




