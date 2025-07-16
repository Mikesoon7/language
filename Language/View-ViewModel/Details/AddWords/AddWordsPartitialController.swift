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
    
    private var isRegularModeRequired = true
    private var displayWithText: String?
    
    //MARK: Views
    
    private var fakeNavView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemSecondary_WhiteColour
        return view
    }()
    
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
    
    
    //MARK: Single Mode View's
    
    let contentInset = UIEdgeInsets.init(top: .innerSpacer, left: .outerSpacer, bottom: .outerSpacer, right: .outerSpacer)
    
    lazy var singleModeInputView: SingleModeInputView = {
        let view = SingleModeInputView(frame: view.bounds,  delegate: viewModel!, addDelegate: self, nameDelegate: nil, contentInsets: contentInset)
        print(view.bounds, "viewBounds")
        print(view.frame, "View.frame")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var switchModeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "doc.richtext"), for: .normal)
        button.tintColor = .label
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(sigleModeWasEngaged(sender: )), for: .touchUpInside)
        button.tag = 0
        return button
    }()
    
    
    
    //MARK: Constraints related
    private var subviewsInactiveConstraints: [NSLayoutConstraint] = []
    private var subviewsActiveConstraints: [NSLayoutConstraint] = []
    
    
    private var regularModeConstraints: [NSLayoutConstraint] = []
    private var singleModeConstraints: [NSLayoutConstraint] = []
    
    private var doneButtonTrailingInactive :    NSLayoutConstraint = .init()
    private var doneButtonTrailingActive :      NSLayoutConstraint = .init()
    private var switchButtonTrailingInactive :  NSLayoutConstraint = .init()
    private var switchButtonTrailingActive :    NSLayoutConstraint = .init()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        singleModeInputView.adjustLayoutForSizeClass()
    }
    
    //MARK: Inherited
    required init(factory: ViewModelFactory, dictionary: DictionariesEntity, text: String?, regularMode: Bool){
        self.viewModelFactory = factory
        self.viewModel = factory.configureAddWordsViewModel(dictionary: dictionary)
        self.displayWithText = text
        self.isRegularModeRequired = regularMode
        
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
        configureSingleModeInput()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        if isRegularModeRequired {
            NSLayoutConstraint.activate(regularModeConstraints)
            self.textInputView.textView.becomeFirstResponder()
        } else {
            //            NSLayoutConstraint.activate(singleModeConstraints)
            self.sigleModeWasEngaged(sender: switchModeButton)
        }
    }
    
    
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            singleModeInputView.collectionView.subviews.forEach { section in
                section.layer.shadowColor = (traitCollection.userInterfaceStyle == .dark
                                             ? shadowColorForDarkIdiom
                                             : shadowColorForLightIdiom)
            }
            
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
        viewModel?.singleOutput
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {
                case .shouldPresent(let view):
                    self?.present(view, animated: true)
                case .shouldAddCellAt(let index):
                    self?.singleModeInputView.collectionView.insertItems(at: [index])
                }
                
            }
            .store(in: &cancellable)
        
    }
    
    
    //MARK: View Setup
    private func configureView(){
        view.backgroundColor = .systemSecondary_WhiteColour
        
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
        
        singleModeConstraints.append(contentsOf: [
            textInputView.bottomAnchor.constraint(
                equalTo: view.topAnchor, constant: -.outerSpacer),
            textInputView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .longInnerSpacer),
            textInputView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.longInnerSpacer),
            textInputView.heightAnchor.constraint(equalToConstant: .largeButtonHeight * 2 )
            
        ])
        
        regularModeConstraints.append(contentsOf: [
            textInputView.topAnchor.constraint(
                equalTo: addNewWordsLabel.bottomAnchor, constant: .outerSpacer),
            textInputView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .longInnerSpacer),
            textInputView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.longInnerSpacer),
            textViewHeightInactive
        ])
    }
    private func configureSingleModeInput(){
        view.addSubviews(singleModeInputView)
        
        singleModeConstraints.append(contentsOf: [
            singleModeInputView.topAnchor.constraint(
                equalTo: addNewWordsLabel.bottomAnchor, constant: .innerSpacer),
            singleModeInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            singleModeInputView.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor),
            singleModeInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        regularModeConstraints.append(contentsOf: [
            singleModeInputView.heightAnchor.constraint(
                equalTo: view.heightAnchor),
            singleModeInputView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            singleModeInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            singleModeInputView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        view.bringSubviewToFront(fakeNavView)
    }

    
    private func configureDoneButton(){
        view.addSubviews(fakeNavView/*addNewWordsLabel, doneButton, switchModeButton*/ )
        fakeNavView.addSubviews(addNewWordsLabel, doneButton, switchModeButton)
        
        doneButtonTrailingInactive = doneButton.leadingAnchor.constraint(
            equalTo: view.trailingAnchor, constant: .longInnerSpacer)
        doneButtonTrailingActive = doneButton.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,  constant: -.longInnerSpacer)
        
        switchButtonTrailingInactive = switchModeButton.leadingAnchor.constraint(
            equalTo: view.trailingAnchor, constant: .longInnerSpacer)
        switchButtonTrailingActive = switchModeButton.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,  constant: -.longInnerSpacer)
        
        subviewsInactiveConstraints.append(contentsOf: [
            doneButtonTrailingInactive, switchButtonTrailingActive
        ])
        subviewsActiveConstraints.append(contentsOf: [
            doneButtonTrailingActive, switchButtonTrailingInactive
        ])
        
        
        NSLayoutConstraint.activate([
            fakeNavView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            fakeNavView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            fakeNavView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: .longOuterSpacer),
            fakeNavView.heightAnchor.constraint(equalToConstant: .genericButtonHeight),
            
            
            addNewWordsLabel.centerYAnchor.constraint(
                equalTo: fakeNavView.centerYAnchor),
            addNewWordsLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer ),
            addNewWordsLabel.heightAnchor.constraint(
                equalTo: fakeNavView.heightAnchor),
            
            doneButton.centerYAnchor.constraint(
                equalTo: addNewWordsLabel.centerYAnchor),
            doneButtonTrailingInactive,
            
            switchModeButton.centerYAnchor.constraint(
                equalTo: addNewWordsLabel.centerYAnchor),
            switchModeButton.heightAnchor.constraint(equalToConstant: .systemButtonSize),
            switchButtonTrailingActive
            
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
        
        singleModeConstraints.append(contentsOf: [
            saveButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .longInnerSpacer),
            saveButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.longInnerSpacer),
            saveButton.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            saveButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: .outerSpacer)
            
        ])
        
        regularModeConstraints.append(contentsOf: [
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
}

//MARK: - Actions
extension AddWordsPartitialController {
    //Done button, which appears when user activate keyboard.
    @objc func rightBarButDidTap(sender: Any){
        NSLayoutConstraint.activate([doneButtonTrailingInactive, switchButtonTrailingActive])
        NSLayoutConstraint.deactivate([doneButtonTrailingActive, switchButtonTrailingInactive])
        
        if textInputView.textView.isFirstResponder{
            textInputView.textView.resignFirstResponder()
        } else {
            view.endEditing(true)
        }
    }
    
    //Addding input text to the dictionary.
    @objc func saveButtonDidTap(sender: UIButton){
        guard let text = textInputView.validateText() else { return }
        viewModel?.extendDictionaryWith(text)
    }
    
    ///Changing textView layout and displaying done button
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        let curve = UIView.AnimationOptions(rawValue: curveValue << 16)
        
        if switchModeButton.tag == 1 {
            NSLayoutConstraint.activate([doneButtonTrailingActive, switchButtonTrailingInactive])
            NSLayoutConstraint.deactivate([doneButtonTrailingInactive, switchButtonTrailingActive])
        } else {
            NSLayoutConstraint.deactivate(subviewsInactiveConstraints )
            NSLayoutConstraint.activate(subviewsActiveConstraints)
        }
        UIView.animate(withDuration: duration, delay: 0, options: curve, animations: {
            self.view.layoutIfNeeded()
        })

    }
    
    ///Changing textView layout and hiding done button
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curveValue = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
        
        let curve = UIView.AnimationOptions(rawValue: curveValue << 16)
        
        if switchModeButton.tag == 1 {
            if doneButtonTrailingActive.isActive {
                NSLayoutConstraint.activate([doneButtonTrailingInactive, switchButtonTrailingActive])
                NSLayoutConstraint.deactivate([doneButtonTrailingActive, switchButtonTrailingInactive])
            }
        } else {
            NSLayoutConstraint.deactivate(subviewsActiveConstraints )
            NSLayoutConstraint.activate(subviewsInactiveConstraints)
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: curve, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    


    @objc func sigleModeWasEngaged(sender: UIButton) {
        if sender.tag == 0 {
            viewModel?.splitTheText(text: textInputView.textView.text)
            UIView.animate(withDuration: 0.3) {
                
                NSLayoutConstraint.deactivate(self.regularModeConstraints)
                NSLayoutConstraint.activate(self.singleModeConstraints)
                self.textInputView.alpha = 0
                self.saveButton.alpha = 0
                self.singleModeInputView.alpha = 1
                sender.setImage(UIImage(systemName: "doc.plaintext"), for: .normal)
                self.view.layoutIfNeeded()
                
            }
            self.singleModeInputView.adjustLayoutForSizeClass()
            self.singleModeInputView.collectionView.reloadData()

            
            sender.tag = 1
        } else if sender.tag == 1 {
            self.textInputView.assignText(text: viewModel?.uniteTheText())
            UIView.animate(withDuration: 0.3) {
                
                NSLayoutConstraint.deactivate(self.singleModeConstraints)
                NSLayoutConstraint.activate(self.regularModeConstraints)
                self.textInputView.alpha = 1
                self.saveButton.alpha = 1
                self.singleModeInputView.alpha = 0

                sender.setImage(UIImage(systemName: "doc.richtext"), for: .normal)
                self.view.layoutIfNeeded()
            }
            self.singleModeInputView.collectionView.reloadData()
            self.singleModeInputView.adjustLayoutForSizeClass()

            sender.tag = 0

        }
    }

}

extension AddWordsPartitialController: AddImageDelegate {
    func didSelectAnImage(imageDetails: ImageDetailsCheck, cell: SingleModeImageCell, index: IndexPath) {
        cell.addPhoto(imageDetails: imageDetails)
        viewModel?.imageDidAdd(imageDetails: imageDetails, index: index)
        
    }
}

extension AddWordsPartitialController: SingleModeAddDelegate {
    func didAddCell() {
        guard let model = viewModel else { return }
        model.addEmptyCell()
        singleModeInputView.collectionView.insertItems(at: [IndexPath(item: model.numberOfCells() - 1, section: 0)])
        
    }

    func didSave() {
        let text = viewModel?.uniteTheText()
        textInputView.assignText(text: text)
        guard let text = textInputView.validateText() else { return }
        
        viewModel?.extendDictionaryWithSingleData()
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



