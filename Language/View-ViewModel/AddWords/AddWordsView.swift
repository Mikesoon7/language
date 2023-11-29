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

    //MARK: ViewModel related
    private var viewModel: AddWordsViewModel?
    private var viewModelFactory: ViewModelFactory
    
    private var cancellable = Set<AnyCancellable>()
    
    //MARK: Views
    private lazy var textInputView: TextInputView = TextInputView(delegate: self)
    
    //Navigation bar button to dismiss keyboard.
    private lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "system.done".localized,
            style: .done,
            target: self,
            action: #selector(rightBarButDidTap(sender:))
        )
        return button
    }()
    
    private let saveButton : UIButton = {
        let button = UIButton()
        button.setUpCustomButton()
        return button
    }()

    
    //MARK: Constraints related
    private var textInputViewHeightAnchor: NSLayoutConstraint!
    private var textInputViewBottomAnchor: NSLayoutConstraint!
    
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
                switch output {
                case .shouldPresentError(let error):
                    self?.presentError(error)
                case .shouldPop:
                    self?.navigationController?.popViewController(animated: true)
                case .shouldUpdatePlaceholder:
                    self?.textInputView.updatePlaceholder()
                case .shouldUpdateText:
                    self?.textInputView.updatePlaceholder()
                    self?.configureText()
                case .shouldHighlightError(let word):
                    self?.highlightErrorFor(word)
                }
            }
            .store(in: &cancellable)
    }
    //MARK: View Setup
    private func configureView(){
        
        //Observer on keyboard.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    //MARK: Subviews SetUp
    private func configureTextInputView(){
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
    private func configureSaveButton(){
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
        doneButton.title = "system.done".localized
        textInputView.textView.isTextUpdateRequired = true
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
        print(range)
        self.textInputView.highlightError(NSRAnge)
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

extension AddWordsView: PlaceholderTextViewDelegate{
    func textViewWillAppear() {
        guard navigationItem.rightBarButtonItem == doneButton else {
            navigationItem.setRightBarButton(doneButton, animated: true)
            return
        }
    }
    
    func configurePlaceholderText() -> String? {
        viewModel?.configureTextPlaceholder()
    }
    
}
