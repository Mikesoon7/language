//
//  SettingsVC.swift
//  Language
//
//  Created by Star Lord on 11/02/2023.
//
//  REFACTORING STATE: CHECKED

//TODO: Add limit for name
import UIKit
import CoreData
import Combine

class AddDictionaryView: UIViewController {
    //MARK: Properties
    private var viewModel: AddDictionaryViewModel?
    private var viewModelFactory: ViewModelFactory
    private var cancellable = Set<AnyCancellable>()

    private var isInRegularMode = true
    
    
    //MARK: Views
    private lazy var textInputView: TextInputView = TextInputView(delegate: self)
    
    private let nameView : UIView = {
        var view = UIView()
        view.setUpCustomView()
        return view
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.bodyTextSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let nameInputField : UITextField = {
        let field = UITextField()
        field.textColor = .label
        field.textAlignment = .right
        field.font = .selectedFont.withSize(.assosiatedTextSize)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private var saveButton : UIButton = {
        var button = UIButton()
        button.setUpCustomButton()
        return button
    }()
    
    private lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "system.done".localized,
            style: .done,
            target: self,
            action: #selector(rightBarButDidTap(sender:))
        )
        return button
    }()
    
    //MARK: Info views
    var infoPopOver: InfoPopoverViewController?
    
    lazy var informationButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .done,
            target: self,
            action: #selector(showPopover))
        return button
    }()

    //MARK: Single mode view's
    let contentInset = UIEdgeInsets.init(top: .longOuterSpacer, left: .outerSpacer, bottom: .outerSpacer, right: .outerSpacer)
    lazy var singleModeInputView: SingleModeInputView = {
        let view = SingleModeInputView(frame: view.bounds,  delegate: viewModel!, addDelegate: self, nameDelegate: self, contentInsets: contentInset)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private lazy var switchModeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "doc.richtext"),
            style: .done,
            target: self,
            action: #selector(sigleModeWasEngaged(sender: )))
        button.tag = 0
        return button
    }()
    
    //MARK: - Constraints and related.
    private var textInputViewHeightAnchor: NSLayoutConstraint = .init()
    private var nameFieldViewBottomAnchor: NSLayoutConstraint = .init()
    
    private var regularModeConstraints: [NSLayoutConstraint] = []
    private var singleModeConstraints: [NSLayoutConstraint] = []
    
    //MARK: - Inherited
    required init(factory: ViewModelFactory){
        self.viewModelFactory = factory
        self.viewModel = viewModelFactory.configureAddDictionaryModel()
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureController()
        configureTextInputView()
        configureNameInputView()
        configureSaveButton()
        configureText()
        configureCollection()
        
        NSLayoutConstraint.activate(regularModeConstraints)
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
        
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            singleModeInputView.collectionView.subviews.forEach { section in
                section.layer.shadowColor = (traitCollection.userInterfaceStyle == .dark
                                             ? shadowColorForDarkIdiom
                                             : shadowColorForLightIdiom)
            }

            if traitCollection.userInterfaceStyle == .dark{
                nameView.layer.shadowColor = shadowColorForDarkIdiom
                textInputView.layer.shadowColor = shadowColorForDarkIdiom
                saveButton.layer.shadowColor = shadowColorForDarkIdiom
            } else {
                nameView.layer.shadowColor = shadowColorForLightIdiom
                textInputView.layer.shadowColor = shadowColorForLightIdiom
                saveButton.layer.shadowColor = shadowColorForLightIdiom
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //Insure proper sizing and positioning of pop up view
        if infoPopOver != nil{
            coordinator.animate { _ in
                self.dismisPopUp()
            } completion: { _ in
                self.showPopover()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        singleModeInputView.adjustLayoutForSizeClass()
    }

    //MARK: Bind
    private func bind(){
        viewModel?.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {
                case .shouldPop:
                    self?.navigationController?.popViewController(animated: true)
                case .shouldPresentError(let error):
                    self?.presentError(error, sourceView: self?.view)
                case .shouldHighlightError(let word):
                    self?.highlightErrorFor(word)
                case .shouldUpdatePlaceholder:
                    self?.textInputView.updatePlaceholder()
                case .shouldUpdateText:
                    self?.textInputView.updatePlaceholder()
                    self?.configureText()
                case .shouldUpdateFont:
                    self?.textInputView.updatePlaceholder()
                    self?.configureFont()
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
    //MARK: Controller SetUp
    private func configureController(){    
        self.view.backgroundColor = .systemBackground
        self.navigationItem.rightBarButtonItems = [ switchModeButton, informationButton ]

        //Keyboard appearence
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func configureCollection(){
        view.addSubviews(singleModeInputView)
        
        singleModeConstraints.append(contentsOf: [
            singleModeInputView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            singleModeInputView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            singleModeInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            singleModeInputView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        regularModeConstraints.append(contentsOf: [
            singleModeInputView.heightAnchor.constraint(
                equalTo: view.heightAnchor),
            singleModeInputView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            singleModeInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            singleModeInputView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    private func configureTextInputView(){
        view.addSubview(textInputView)
        
            
        textInputViewHeightAnchor = textInputView.heightAnchor.constraint(
            equalToConstant: .textViewGenericSize)

        regularModeConstraints.append(contentsOf: [
        
            textInputView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .longOuterSpacer),
            textInputView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer),
            textInputView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.outerSpacer),
            textInputView.heightAnchor.constraint(
                lessThanOrEqualTo: textInputView.widthAnchor),
        
            textInputViewHeightAnchor
        ])
        singleModeConstraints.append(contentsOf: [
            textInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -.longOuterSpacer),
            textInputView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer),
            textInputView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.outerSpacer),
            textInputView.heightAnchor.constraint(
                lessThanOrEqualTo: textInputView.widthAnchor),
            
            textInputViewHeightAnchor
        ])
    }
    private func configureNameInputView(){
        view.addSubview(nameView)
        nameView.addSubviews(nameLabel, nameInputField)
        nameInputField.delegate = self
        
        nameFieldViewBottomAnchor = nameView.bottomAnchor.constraint(
            equalTo: view.keyboardLayoutGuide.topAnchor, constant: -.innerSpacer )

        regularModeConstraints.append(contentsOf:[
            nameView.topAnchor.constraint(
                equalTo: textInputView.bottomAnchor, constant: .innerSpacer),
            nameView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer),
            nameView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.outerSpacer),
            nameView.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            
            nameLabel.leadingAnchor.constraint(
                equalTo: nameView.leadingAnchor, constant: .innerSpacer),
            nameLabel.centerYAnchor.constraint(
                equalTo: nameView.centerYAnchor),
            
            
            nameInputField.trailingAnchor.constraint(
                equalTo: nameView.trailingAnchor, constant: -.innerSpacer),
            nameInputField.centerYAnchor.constraint(
                equalTo: nameView.centerYAnchor)
        ])
        
        singleModeConstraints.append(contentsOf: [
            nameView.topAnchor.constraint(
                equalTo: textInputView.topAnchor),
            nameView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer),
            nameView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.outerSpacer),
            nameView.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),
        ])
        
        //Action
        nameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nonAccurateNameFieldTap(sender:))))
    }

    private func configureSaveButton(){
        view.addSubview(saveButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        regularModeConstraints.append(contentsOf:[
            saveButton.bottomAnchor.constraint(
                equalTo: UIDevice.isIPadDevice ? view.safeAreaLayoutGuide.bottomAnchor
                                               : view.keyboardLayoutGuide.topAnchor ,
                constant: -.innerSpacer),
            saveButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer),
            saveButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.outerSpacer),
            saveButton.topAnchor.constraint(
                greaterThanOrEqualTo: nameView.bottomAnchor, constant: .innerSpacer),
            saveButton.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),

        ])
        
        singleModeConstraints.append(contentsOf: [
            saveButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: .innerSpacer),
            saveButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer),
            saveButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.outerSpacer),
            saveButton.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),


        ])
        //Action
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender:)), for: .touchUpInside)
    }
    
    
    
    //MARK: System
    /// Congifure all text properties of the view.
    private func configureText(){
        nameLabel.text =  "dictionaryName".localized

        saveButton.setAttributedTitle(
            .attributedString(string: "system.save".localized,
                              with: .selectedFont,
                              ofSize: .bodyTextSize), for: .normal)
        
        self.navigationItem.title = "addDict.title".localized
        nameInputField.placeholder = "fieldPlaceholder".localized
        doneButton.title = "system.done".localized
        textInputView.updatePlaceholder()
    }
    private func configureFont(){
        nameLabel.font = .selectedFont.withSize(.bodyTextSize)
        saveButton.setAttributedTitle(
            .attributedString(string: "system.save".localized,
                              with: .selectedFont,
                              ofSize: .bodyTextSize), for: .normal)
        nameInputField.font = .selectedFont.withSize(.assosiatedTextSize)
    }
    
    ///Returns textFiled value. If value equals nil, return nil and present an error.
    private func validateName() -> String? {
        guard let text = nameInputField.text,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let insertNameAllert = UIAlertController.alertWithAction(alertTitle: "nameAlert".localized, alertMessage: "nameInfo".localized, alertStyle: .actionSheet, action1Title: "system.agreeInformal".localized, action1Handler: nil, action1Style: .cancel, sourceView: self.nameView, sourceRect: nameInputField.frame )
            self.present(insertNameAllert, animated: true)
            return nil
        }
        return text
    }
    ///Update textView layout.
    private func updateTextViewConstraits(keyboardIsVisable: Bool){
    
        textInputViewHeightAnchor.isActive = !keyboardIsVisable
        if UIDevice.isIPadDevice {
            nameFieldViewBottomAnchor.isActive = keyboardIsVisable
        }
    
        view.layoutIfNeeded()
    }
    
    private func highlightErrorFor(_ word: String){
        guard let text = self.textInputView.textView.text, let range = text.range(of: word, options: .caseInsensitive, range: word.startIndex..<text.endIndex) else {
            return
        }
        
        let NSRAnge = NSRange(range, in: text)
        self.textInputView.highlightError(NSRAnge)
    }
}
//MARK: - Actions
extension AddDictionaryView{
    @objc func sigleModeWasEngaged(sender: UIBarButtonItem) {
        if sender.tag == 0 {
            viewModel?.splitTheText(text: textInputView.textView.text)
            UIView.animate(withDuration: 0.3) {
                
                NSLayoutConstraint.deactivate(self.regularModeConstraints)
                NSLayoutConstraint.activate(self.singleModeConstraints)
                self.textInputView.alpha = 0
                self.nameView.alpha = 0
                self.saveButton.alpha = 0
                self.singleModeInputView.alpha = 1
                sender.image = UIImage(systemName: "doc.plaintext")
                self.view.layoutIfNeeded()
                
            }
            self.singleModeInputView.collectionView.reloadData()
            self.singleModeInputView.adjustLayoutForSizeClass()

            isInRegularMode = false
            sender.tag = 1
        } else if sender.tag == 1 {
            self.textInputView.assignText(text: viewModel?.uniteTheText())
            UIView.animate(withDuration: 0.3) {
                
                NSLayoutConstraint.deactivate(self.singleModeConstraints)
                NSLayoutConstraint.activate(self.regularModeConstraints)
                self.textInputView.alpha = 1
                self.nameView.alpha = 1
                self.saveButton.alpha = 1
                self.singleModeInputView.alpha = 0

                sender.image = UIImage(systemName: "doc.richtext")
                self.view.layoutIfNeeded()
            }
            self.singleModeInputView.collectionView.reloadData()
            self.singleModeInputView.adjustLayoutForSizeClass()

            isInRegularMode = true
            sender.tag = 0

        }
    }
    @objc private func showPopover() {
        guard infoPopOver == nil else {
            self.dismisPopUp()
            return
        }
        
        let infoText = switchModeButton.tag == 0 ? "You are in line - by - line mode. It offers much more sufficient way of adding the cards, since text of any size will be devided into cards where one paragrath equals to one card." : "You are in one - by - one mode. It requires to add cards one by one but offers more controll over the end result, allowing to add images"
        
        let infoPopOver = InfoPopoverViewController(frame: view.frame, infoText: infoText, safeAreaInsets: view.safeAreaInsets, delegate: self)
        if let window = view.window {
            window.addSubview(infoPopOver)
            NSLayoutConstraint.activate([
                infoPopOver.topAnchor.constraint(equalTo: window.topAnchor),
                infoPopOver.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                infoPopOver.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                infoPopOver.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])
        }

        
        self.infoPopOver = infoPopOver
        infoPopOver.present()
    }
    
    @objc private func dismisPopUp(){
        self.infoPopOver?.dismiss {
            self.infoPopOver?.removeFromSuperview()
            self.infoPopOver = nil
        }
    }

}

extension AddDictionaryView {
    @objc func saveButtonDidTap(sender: Any){
        guard let name = validateName(), let text = textInputView.validateText() else { return }
        
        viewModel?.createDictionary(name: name, text: text)
                        
//        navigationItem.rightBarButtonItem = nil
        view.becomeFirstResponder()
    }
    //Done buttom tap
    @objc func rightBarButDidTap(sender: Any){
        navigationItem.rightBarButtonItem = nil
        
        if nameInputField.isFirstResponder{
            nameInputField.resignFirstResponder()
        } else if textInputView.textView.isFirstResponder{
            textInputView.textView.resignFirstResponder()
        } else {
            view.endEditing(true)
        }
        
        
        self.navigationItem.rightBarButtonItems = [ switchModeButton, informationButton ]
    }
    @objc func nonAccurateNameFieldTap(sender: Any){
        nameInputField.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(sender: Notification){
        if isInRegularMode {
            updateTextViewConstraits(keyboardIsVisable: true)
            
        }
        guard navigationItem.rightBarButtonItem == doneButton else {
            navigationItem.setRightBarButton(doneButton, animated: true)
            return
        }

    }
    @objc func keyboardWillHide(sender: Notification){
        if isInRegularMode {
            updateTextViewConstraits(keyboardIsVisable: false)
        }

        guard navigationItem.rightBarButtonItems == [ switchModeButton, informationButton ] else {
            self.navigationItem.rightBarButtonItems = [ switchModeButton, informationButton ]
            
            return
        }
    }
}

//MARK: - Extending for PlaceholderTextView
extension AddDictionaryView: PlaceholderTextViewDelegate{
    ///Delegate method. Activating navigation bar bautton item.
    func textViewDidBeginEditing(sender: UITextView)  { }
    func textViewDidEndEditing(sender: UITextView)    { }
    func textViewDidChange(sender: UITextView)        { }

    func presentErrorAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    ///Delegate method. Retrieving and returns placeholder text
    func configurePlaceholderText(sender: UITextView) -> String? {
        viewModel?.configureTextPlaceholder()
    }
    func currentSeparatorSymbol() -> String? {
        viewModel?.textSeparator()
    }
}

//MARK: - TextField delegate
extension AddDictionaryView: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }
}
extension AddDictionaryView: SingleModeNameDelegate {
    func didTypeName(text: String) {
        self.nameInputField.text = text
    }
    func name() -> String {
        return nameInputField.text ?? ""
    }
}

extension AddDictionaryView: SingleModeAddDelegate {
    func didAddCell() {
        guard let model = viewModel else { return }
        model.addEmptyCell()
        singleModeInputView.collectionView.insertItems(at: [IndexPath(item: model.numberOfCells() - 1, section: 0)])
        
    }
    
    func didSave() {
        let text = viewModel?.uniteTheText()
        textInputView.assignText(text: text)
        guard let name = validateName(), let text = textInputView.validateText() else { return }
        
        viewModel?.createDictionaryByCards(name: name)
    }
}

extension AddDictionaryView: InfoViewDelegate {
    func viewDidDismiss() {
        self.infoPopOver?.removeFromSuperview()
        self.infoPopOver = nil
    }
}
