//
//  SettingsVC.swift
//  Language
//
//  Created by Star Lord on 11/02/2023.
//

//TODO: Add limit for name
import UIKit
import CoreData
import Combine

class AddDictionaryVC: UIViewController {
    
    private var viewModel: AddDictionaryViewModel
    private var viewModelFactory: ViewModelFactory
    private var cancellabel = Set<AnyCancellable>()
        
    private lazy var textInputView: TextInputView = TextInputView(delegate: self )

    private let nameView : UIView = {
        var view = UIView()
        view.setUpCustomView()
        return view
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let nameInputField : UITextField = {
        let field = UITextField()
        field.textColor = .label
        field.textAlignment = .right
        field.font = .georgianItalic.withSize(15)
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    private var saveButton : UIButton = {
        var button = UIButton()
        button.setUpCustomButton()
        return button
    }()
    
    private var topStroke = CAShapeLayer()
    private var bottomStroke = CAShapeLayer()

    //MARK: - Constraints and related.
    private var textInputViewHeightAnchor: NSLayoutConstraint!
    private var textInputViewBottomAnchor: NSLayoutConstraint!
    
    private var subviewsVerticalInset: CGFloat = 13
    private var buttonHeight: CGFloat = 60
    
    required init(factory: ViewModelFactory){
        self.viewModelFactory = factory
        self.viewModel = factory.configureAddDictionaryModel()
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported")
    }

    //MARK: - Inherited
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureController()
        configureNavBar()
        configureTextInputView()
        configureNameInputView()
        configureSaveButton()
        configureText()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureStrokes()
    }
    
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            self.bottomStroke.strokeColor = UIColor.label.cgColor
            self.topStroke.strokeColor = UIColor.label.cgColor
            if traitCollection.userInterfaceStyle == .dark{
                nameView.layer.shadowColor = shadowColorForDarkIdiom
                saveButton.layer.shadowColor = shadowColorForDarkIdiom
                textInputView.layer.shadowColor = shadowColorForDarkIdiom
            } else {
                nameView.layer.shadowColor = shadowColorForLightIdiom
                saveButton.layer.shadowColor = shadowColorForLightIdiom
                textInputView.layer.shadowColor = shadowColorForLightIdiom

            }
        }
    }
    //MARK: - Bind
    private func bind(){
        viewModel.output
            .sink { output in
                switch output {
                case .shouldPop:
                    self.navigationController?.popViewController(animated: true)
                case .shouldPresentError(let error):
                    self.presentError(error)
                case .shouldUpdatePlaceholder:
                    self.textInputView.updatePlaceholder()
                case .shouldUpdateText:
                    self.textInputView.updatePlaceholder()
                    self.configureText()
                }
            }
            .store(in: &cancellabel)
    }
    //MARK: - Controleler SetUp
    private func configureController(){
        view.backgroundColor = .systemBackground
        
        //Keyboard appearence
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //MARK: - Stroke SetUp
    private func configureStrokes(){
        topStroke = UIView().addTopStroke(vc: self)
        bottomStroke = UIView().addBottomStroke(vc: self)
        
        view.layer.addSublayer(topStroke)
        view.layer.addSublayer(bottomStroke)
    }
    
    //MARK: - NavBar SetUp
    private func configureNavBar(){
        navigationController?.navigationBar.titleTextAttributes = NSAttributedString().fontWithoutString(bold: true, size: 23)
    }

    //MARK: - TextInputView SetUp
    private func configureTextInputView(){
        view.addSubview(textInputView)

        textInputViewHeightAnchor = textInputView.heightAnchor.constraint(equalTo: textInputView.widthAnchor, multiplier: 0.66)
        textInputViewBottomAnchor = textInputView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -(subviewsVerticalInset * 2 + buttonHeight))
        NSLayoutConstraint.activate([
            textInputView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 35),
            textInputView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textInputView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            textInputViewHeightAnchor
        ])
    }
    //MARK: - NameInputView SetUp
    private func configureNameInputView(){
        view.addSubview(nameView)
        nameView.addSubviews(nameLabel, nameInputField)
        nameInputField.delegate = self
        
        NSLayoutConstraint.activate([
            nameView.topAnchor.constraint(equalTo: self.textInputView.bottomAnchor, constant: subviewsVerticalInset),
            nameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            nameView.heightAnchor.constraint(equalToConstant: 60),
            
            nameLabel.leadingAnchor.constraint(equalTo: nameView.leadingAnchor, constant: 15),
            nameLabel.centerYAnchor.constraint(equalTo: nameView.centerYAnchor),
            
            nameInputField.trailingAnchor.constraint(equalTo: nameView.trailingAnchor, constant: -15),
            nameInputField.centerYAnchor.constraint(equalTo: nameView.centerYAnchor)
        ])
        //Action
        nameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nonAccurateNameFieldTap(sender:))))
        

    }
    //MARK: - SaveButton SetUp
    private func configureSaveButton(){
        view.addSubview(saveButton)
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -subviewsVerticalInset),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: .widthMultiplerFor(type: .forViews)),
            saveButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
        //Action
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender:)), for: .touchUpInside)
        saveButton.addTargetTouchBegin()
        saveButton.addTargetOutsideTouchStop()
        saveButton.addTargetInsideTouchStop()
    }
    
    //MARK: - Other
    //Uses as initial configurator for text values and in order to update them.
    private func configureText(){
        nameLabel.attributedText =
            .attributedString(string: "dictionaryName".localized,
                              with: .georgianBoldItalic, ofSize: 18)
        saveButton.setAttributedTitle(
            .attributedString(string: "system.save".localized,
                              with: .georgianBoldItalic, ofSize: 18), for: .normal)

        self.navigationItem.title = "addDictTitle".localized
        nameInputField.placeholder = "fieldPlaceholder".localized
        if let doneButton = navigationItem.rightBarButtonItem {
            doneButton.title = "system.done".localized
        }
    }
    //When user trying to save information, checks if is the name empty and return String if is not.
    private func validateName() -> String? {
        let insertNameAllert = UIAlertController(
            title: "nameAlert".localized,
            message: "nameInfo".localized,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: "agreeInformal".localized,
            style: .cancel)
        insertNameAllert.addAction(action)
        action.setValue(UIColor.label, forKey: "titleTextColor")
        
        guard nameInputField.hasText else {
            self.present(insertNameAllert, animated: true)
            return nil
        }
        return nameInputField.text
    }
    //When user trying to save information, checks if is the text empty and return String if is not.
    private func validateText() -> String?{
        let insertTextAllert = UIAlertController(
            title: "textAlert".localized,
            message: "textInfo".localized ,
            preferredStyle: .alert)
        let action = UIAlertAction(
            title: "system.agreeInformal".localized,
            style: .cancel)
        insertTextAllert.addAction(action)
        action.setValue(UIColor.label, forKey: "titleTextColor")

        guard let text = textInputView.textView.text, text != "" && textInputView.textView.textColor != .lightGray else {
            self.present(insertTextAllert, animated: true)
            return nil
        }
        return text
    }
    //Switch between standalone contrait and attached to saveButton
    private func updateTextViewConstraits(keyboardIsvisable: Bool){
        textInputViewHeightAnchor.isActive = !keyboardIsvisable
        textInputViewBottomAnchor.isActive = keyboardIsvisable
        view.layoutIfNeeded()
    }
    
//MARK: - Actions
    @objc func saveButtonDidTap(sender: Any){
        guard let name = validateName() else { return }
        guard let text = validateText() else { return }
        
        viewModel.createDictionary(name: name, text: text)
                        
        navigationItem.rightBarButtonItem = nil
        view.becomeFirstResponder()
    }
    //Done buttom tap
    @objc func rightBarButDidTap(sender: Any){
        navigationItem.rightBarButtonItem = nil
        
        if nameInputField.isFirstResponder{
            nameInputField.resignFirstResponder()
        } else {
            textInputView.textView.resignFirstResponder()
        }
    }
    @objc func nonAccurateNameFieldTap(sender: Any){
        nameInputField.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(sender: Notification){
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        bottomStroke.add(animation, forKey: "strokeOpacity")
        
        updateTextViewConstraits(keyboardIsvisable: true)
    }
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

//MARK: - Extending for PlaceholderTextView
extension AddDictionaryVC: PlaceholderTextViewDelegate{
    func textViewWillAppear() {
        if self.navigationController?.navigationItem.rightBarButtonItem == nil{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "system.done".localized, style: .plain, target: self, action: #selector(rightBarButDidTap(sender:)))
        }
    }
    func configurePlaceholderText() -> String {
        viewModel.configureTextPlaceholder()
    }
}

//MARK: - TextField delegate
extension AddDictionaryVC: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Showing button for keyboard dismissing
        if self.navigationController?.navigationItem.rightBarButtonItem == nil{
            self.navigationItem.setRightBarButton(UIBarButtonItem(title: "system.done".localized, style: .plain, target: self, action: #selector(rightBarButDidTap(sender:))), animated: true)
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let maxLength = 15
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }

}
////MARK: - UITextInputTraits
//extension AddDictionaryVC: UITextInputTraits{
//
//}
////MARK: - UITextInputDelegate
//extension AddDictionaryVC: UITextInputDelegate{
//    func selectionWillChange(_ textInput: UITextInput?) {
//        return
//    }
//
//    func selectionDidChange(_ textInput: UITextInput?) {
//        return
//    }
//
//    func textWillChange(_ textInput: UITextInput?) {
//        return
//    }
//
//    func textDidChange(_ textInput: UITextInput?) {
//        return
//    }
//
//
//}
//


//OLD

//func switchPasteButtonTo(visible: Bool){
//    UIView.animate(withDuration: 0.2) {
//        self.pasteButton.alpha = visible ? 1 : 0
//    }
//}

//    private func setupPlaceholderLabel() {
//        placeholderLabel.attributedText =
//            placeholderLabel.numberOfLines = 0
//            addSubview(placeholderLabel)
//            // Add constraints or frame setting to position the label
//            updatePlaceholderVisibility()
//        }

//    func textViewHasPlaceholder() -> Bool {
//        if textView.textColor == .lightGray {
//            return true
//        } else {
//            return false
//        }
//    }
    
//    func configureTapGesture(){
//        let tapGesture = UITapGestureRecognizer()
//        tapGesture.addTarget(self, action: #selector(textViewDidTap(sender:)))
//
//        view.addGestureRecognizer(tapGesture)
//    }
//    func switchTextViewTextStyle(forPlaceholder: Bool){
//        if forPlaceholder {
//            configureTextViewPlaceholder()
//        } else {
//            textView.text = nil
//            textView.textColor = nil
//            textView.font = nil
//            textView.typingAttributes = NSAttributedString.textAttributes(with: .timesNewRoman, ofSize: 17, foregroundColour: .label)
//            isTextViewShowingPlaceholder = false
//        }
//    }
    
//    func configureTextViewPlaceholder(){
//        let text = viewModel.configureTextPlaceholder()
//        textView.attributedText = .attributedString(string: text, with: .timesNewRomanPSMT, ofSize: 15, foregroundColour: .lightGray)
//        isTextViewShowingPlaceholder = true
//    }
//var placeholderAttributes: [NSAttributedString.Key : Any]!{
//        didSet{
//            self.typingAttributes = placeholderAttributes
//        }
//    }
//    var textAttributes: [NSAttributedString.Key : Any]!
//    convenience init(){
//        let placeholderAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
//        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
//        self.init(frame: .zero,
//                  textContainer: nil,
//                  placeholderAttributes: placeholderAttributes,
//                  textAttributes: textAttributes)
////        self.typingAttributes = self.placeholderAttributes
//    }
//    convenience init(placeholderAttributes: [NSAttributedString.Key : Any] , textAttributes: [NSAttributedString.Key : Any]){
//        self.init(frame: .zero,
//                  textContainer: nil,
//                  placeholderAttributes: placeholderAttributes,
//                  textAttributes: textAttributes)
////        self.typingAttributes = self.placeholderAttributes
//    }
//    init(frame: CGRect, textContainer: NSTextContainer?, placeholderAttributes: [NSAttributedString.Key : Any], textAttributes: [NSAttributedString.Key : Any]) {
//        super.init(frame: frame,
//                   textContainer: textContainer)
////        self.placeholderAttributes = placeholderAttributes
////        self.textAttributes = textAttributes
////        self.typingAttributes = self.placeholderAttributes
//    }
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        fatalError("Coder wasn't imported")
//    }
//    override func paste(_ sender: Any?) {
//        if let pasteboardString = UIPasteboard.general.string {
//
//            guard !typingAttributes.contains(where: { (key, value) in
//                let placeholderForegroundColour: UIColor = {
//                   let textColour = placeholderAttributes.first { (key, value) in
//                        key == NSAttributedString.Key.foregroundColor
//                    }
//                    return textColour?.value as? UIColor ?? UIColor()
//                }()
//               return (key == NSAttributedString.Key.foregroundColor && value as? UIColor == placeholderForegroundColour)
//            }) else {
//                self.attributedText = NSAttributedString(string: pasteboardString, attributes: textAttributes)
//                return
//            }
//
//            let attributedString = NSAttributedString(string: pasteboardString, attributes: textAttributes)
//
//            textStorage.insert(attributedString, at: selectedRange.location)
//
//            selectedRange = NSRange(location: selectedRange.location + pasteboardString.count, length: 0)
//        }
//    }
    

//    func textViewDidEndEditing(_ textView: UITextView) {
//        if isTextViewShowingPlaceholder {
//            textView.isUserInteractionEnabled = false
//        }
//           }
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        updatePlaceholderVisability()
//        updatePasteButtonVisability()
//        print("shouldChangeTextIn")
//        if textView.text.count > 0 {
////            if isTextViewShowingPlaceholder {
////                switchTextViewTextStyle(forPlaceholder: false )
//                switchPasteButtonTo(visible: false)
//                print ("text was pasted or inputed")
////            }
//
//        }
//        if textView.text.count <= 1 && text.isEmpty || range.length >= textView.text.count && text.isEmpty{
////            if !isTextViewShowingPlaceholder {
////                switchTextViewTextStyle(forPlaceholder: true)
//                switchPasteButtonTo(visible: true)
////                print("replacementObject(for: )")
////                textView.selectedRange = NSRange(location: 0, length: 0)
////            }
//        }
//
//        return true
//    }
//    func textViewDidChangeSelection(_ textView: UITextView) {
//        if isTextViewShowingPlaceholder {
//            textView.selectedRange = NSRange(location: 0, length: 0)
//        }
//    }

//        if let clipboardText = UIPasteboard.general.string, textView.text.contains(clipboardText) {
//            self.isTextViewShowingPlaceholder = false
//            self.switchPasteButtonTo(visible: false)
//
//        }
//            if isTextViewShowingPlaceholder {
//                switchTextViewTextStyle(forPlaceholder: false)
//                switchPasteButtonTo(visible: false)
//            }
    
//        }

//    func textViewDidChange(_ textView: UITextView) {
//        let textViewHaveText = textView.text.count > 0
//        let textViewHavePasteButton = textView.subviews.contains(where: { button in
//            button == saveButton
//        })
//        if textViewHaveText {
//            if textViewHavePasteButton{
//                UIView.animate(withDuration: 0.2) {
//                    self.saveButton.alpha = 0
//                }
//            }
//        } else {
//            if !textViewHavePasteButton{
//                UIView.animate(withDuration: 0.2) {
//                    self.saveButton.alpha = 1
//                }
//            }
//        }
//    }
