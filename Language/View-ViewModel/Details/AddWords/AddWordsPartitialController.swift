//
//  AddWordsPartitialController.swift
//  Learny
//
//  Created by Star Lord on 13/11/2024.
//
//  REFACTORING STATE: CHECKED

import UIKit
import Combine

class AddWordsPartitialController: UIViewController {

    private var viewModel: AddWordsViewModel?
    private var viewModelFactory: ViewModelFactory
    private var cancellable = Set<AnyCancellable>()
    
    private var isSavingRequired: Bool = false
    
    private var displayWithText: String?
    //MARK: Views
    
    private var addNewWordsLabel: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.subtitleSize)
        label.text = "addWord.title".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textInputView: TextInputView = TextInputView(delegate: self)
    
    //Navigation bar button to dismiss keyboard.
    private lazy var doneButton = UIButton.configureNavButtonWith(title: "system.done".localized)
    
    private let saveButton : UIButton = {
        let button = UIButton()
        button.setUpCustomButton()
        button.backgroundColor = .popoverSubviewsBackgroundColour
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    
    //MARK: Constraints related
    private var subviewsInactiveConstraints: [NSLayoutConstraint] = []
    private var subviewsActiveConstraints: [NSLayoutConstraint] = []
    
    //MARK: Inherited
    required init(factory: ViewModelFactory, dictionary: DictionariesEntity, text: String?){
        self.viewModelFactory = factory
        self.viewModel = factory.configureAddWordsViewModel(dictionary: dictionary)
        self.displayWithText = text
        
        super.init(nibName:  nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("Coder wasn't imported")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        configureView()
        configureDoneButton()
        configureTextInputView()
        configureText()
        configureSaveButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.textInputView.textView.becomeFirstResponder()
    }
    deinit { NotificationCenter.default.removeObserver(self) }

            
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                textInputView.layer.shadowColor = shadowColorForDarkIdiom
                saveButton.layer.shadowColor = shadowColorForDarkIdiom
            } else {
                textInputView.layer.shadowColor = shadowColorForLightIdiom
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
                    self.presentError(error, sourceView: view)
                case .shouldPop:
                    self.dismiss(animated: true)
                case .shouldUpdatePlaceholder:
                    self.textInputView.updatePlaceholder()
                case .shouldHighlightError(let word):
                    self.highlightErrorFor(word)
                }
            }
            .store(in: &cancellable)
    }
    
    
    //MARK: View Setup
    private func configureView(){
        view.backgroundColor = ((traitCollection.userInterfaceStyle == .dark)
                                ? .secondarySystemBackground
                                : .systemBackground)

        if let sheetPresentationController = self.presentationController as? UISheetPresentationController {
                sheetPresentationController.delegate = self
            }
    }

    //MARK: Subviews SetUp
    
    private func configureTextInputView(){
        if let text = displayWithText {
            self.textInputView.textViewDidChange(textInputView.textView)
            self.textInputView.textView.text = text
        }
        
        textInputView.setUpCustomView()
        textInputView.backgroundColor = .popoverSubviewsBackgroundColour
    
        view.addSubviews(textInputView)
        
        let textViewHeightInactive = textInputView.heightAnchor.constraint(
            equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews) * 0.66)
        
        let textViewHeightActive = textInputView.bottomAnchor.constraint(
            equalTo: ( UIDevice.isIPadDevice 
                       ? view.keyboardLayoutGuide.topAnchor
                       : saveButton.topAnchor ),
            constant: -.longInnerSpacer)

        subviewsInactiveConstraints.append(textViewHeightInactive)
        subviewsActiveConstraints.append(textViewHeightActive)

        NSLayoutConstraint.activate([
            textInputView.topAnchor.constraint(
                equalTo: addNewWordsLabel.bottomAnchor, constant: .outerSpacer),
            textInputView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .longInnerSpacer),
            textInputView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.longInnerSpacer),
            textViewHeightInactive
        ])
    }
    
    private func configureDoneButton(){
        view.addSubviews( addNewWordsLabel, doneButton )
        let doneButtonTrailingInactive = doneButton.leadingAnchor.constraint(
            equalTo: view.trailingAnchor, constant: .longInnerSpacer)
        let doneButtonTrailingActive = doneButton.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,  constant: -.longInnerSpacer)
        
        subviewsInactiveConstraints.append(doneButtonTrailingInactive)
        subviewsActiveConstraints.append(doneButtonTrailingActive)

        NSLayoutConstraint.activate([
            
            addNewWordsLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .outerSpacer),
            addNewWordsLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer ),
            addNewWordsLabel.heightAnchor.constraint(
                equalToConstant: addNewWordsLabel.font.lineHeight),
        
            doneButton.centerYAnchor.constraint(
                equalTo: addNewWordsLabel.centerYAnchor),
            doneButtonTrailingInactive,
            
        ])
        
        doneButton.addTarget(self, action: #selector(rightBarButDidTap(sender: )), for: .touchUpInside)


    }
    private func configureSaveButton(){
        view.addSubview(saveButton)
        
        let saveButtonBottomInactive = saveButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.longInnerSpacer)
        let saveButtonBottomActive = saveButton.bottomAnchor.constraint(
            equalTo: view.keyboardLayoutGuide.topAnchor, constant: -.longInnerSpacer)

        if !UIDevice.isIPadDevice {
            subviewsInactiveConstraints.append(saveButtonBottomInactive)
            subviewsActiveConstraints.append(saveButtonBottomActive)
        }
        
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .longInnerSpacer),
            saveButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.longInnerSpacer),
            saveButton.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            saveButtonBottomInactive
        ])

        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender: )), for: .touchUpInside)
    }
    
    //MARK: System
    /// Congifure all text properties of the view.
    private func configureText(){
        navigationItem.title = "addWord.title".localized
        saveButton.setAttributedTitle(
            .attributedString(string: "system.save".localized, with: .georgianBoldItalic, ofSize: .bodyTextSize), for: .normal)
        doneButton.setAttributedTitle(
            .attributedString(string: "system.done".localized, with: .systemBold, ofSize: .assosiatedTextSize), for: .normal)
        textInputView.updatePlaceholder()
    }

    ///Defines the range of passed word in textView and highlighting it.
    private func highlightErrorFor(_ word: String){
        guard let text = self.textInputView.textView.text, let range = text.range(of: word, options: .caseInsensitive, range: word.startIndex..<text.endIndex) else {
            return
        }
        
        let NSRAnge = NSRange(range, in: text)
        self.textInputView.highlightError(NSRAnge)
        self.textInputView.textView.resignFirstResponder()
        
    }

//MARK: - Actions
    //Done button, which appears when user activate keyboard.
    @objc func rightBarButDidTap(sender: Any){
        textInputView.textView.resignFirstResponder()
    }
    //Addding input text to the dictionary.
    @objc func saveButtonDidTap(sender: UIButton){
        guard let text = textInputView.validateText() else { return }
        viewModel?.getNewWordsFrom(text)
    }

    ///Changing textView layout and displaying done button
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        let curve = UIView.AnimationOptions(rawValue: curveValue << 16)
        
        NSLayoutConstraint.deactivate(subviewsInactiveConstraints )
        NSLayoutConstraint.activate(subviewsActiveConstraints)

        UIView.animate(withDuration: duration, delay: 0, options: curve, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    ///Changing textView layout and hiding done button
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        let curve = UIView.AnimationOptions(rawValue: curveValue << 16)
        
        NSLayoutConstraint.deactivate(subviewsActiveConstraints )
        NSLayoutConstraint.activate(subviewsInactiveConstraints)

        UIView.animate(withDuration: duration, delay: 0, options: curve, animations: {
            self.view.layoutIfNeeded()
        })
    }
}

//MARK: - PlaceholderTextViewDelegate delegate
extension AddWordsPartitialController: PlaceholderTextViewDelegate{
    func textViewDidBeginEditing(sender: UITextView)  {   }
    func textViewDidEndEditing(sender: UITextView)    {   }
    func textViewDidChange(sender: UITextView)        {   }
    
    func presentErrorAlert(alert: UIAlertController) {
        self.presentErrorAlert(alert: alert)
    }
    func configurePlaceholderText(sender: UITextView) -> String? {
        viewModel?.configureTextPlaceholder()
    }
    func currentSeparatorSymbol() -> String? {
        viewModel?.textSeparator()
    }
}

//MARK: UISheetPresentationController delegate.
extension AddWordsPartitialController: UISheetPresentationControllerDelegate {
    ///Insures, that view won't be accedentaly dismissed without saving the data.
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        guard !textInputView.textView.isFirstResponder else {
            textInputView.textView.resignFirstResponder()
            return false
        }
        guard !isSavingRequired else { return true }
        
        if let text = textInputView.textView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let alert = UIAlertController.alertWithAction(
                alertTitle: "addWords.contentSaving.title".localized,
                alertMessage: "addWords.contentSaving.text".localized,
                alertStyle: .actionSheet,
                action1Title: "addWords.contentSaving.save".localized,
                action1Handler: { _ in
                    self.saveButtonDidTap(sender: self.saveButton)
                },
                
                action1Style: .default,
                action2Title: "addWords.contentSaving.clear".localized,
                action2Handler: { _ in
                    self.dismiss(animated: true)
                },
                action2Style: .destructive,
                sourceView: textInputView
            )
            let editAction = UIAlertAction.init(title: "system.edit".localized, style: .cancel) { [ weak self ] _ in
                self?.textInputView.textView.becomeFirstResponder()
            }
            editAction.setValue(UIColor.label, forKey: "titleTextColor")
            alert.addAction(editAction)
            self.present(alert, animated: true)
            return false
        } else {
            return true
        }
        
    }
}


