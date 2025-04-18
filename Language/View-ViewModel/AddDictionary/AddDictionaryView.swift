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
    private var cancellabel = Set<AnyCancellable>()
    
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
    
    private lazy var switchModeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "doc.richtext"),
                                     style: .done,
                                     target: self,
                                     action: #selector(sigleModeWasEngaged(sender: )))
        button.tag = 0
        return button
    }()
    
    //MARK: Test
    var layout = UICollectionViewFlowLayout()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.contentInset = .init(top: .longOuterSpacer, left: .outerSpacer, bottom: .outerSpacer, right: .outerSpacer)
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.register(MultiCardsCell.self, forCellWithReuseIdentifier: MultiCardsCell.identifier)
        view.register(MultiCardsAddCell.self, forCellWithReuseIdentifier: MultiCardsAddCell.identifier)
        view.register(MultiCardsNameCell.self, forCellWithReuseIdentifier: MultiCardsNameCell.identifier)
        
        return view
    }()

    
    //MARK: - Constraints and related.
    private var textInputViewHeightAnchor: NSLayoutConstraint = .init()
    private var nameFieldViewBottomAnchor: NSLayoutConstraint = .init()
    
    private var regularModeConstraints: [NSLayoutConstraint] = []
    private var singleModeConstraints: [NSLayoutConstraint] = []
    
    required init(factory: ViewModelFactory){
        self.viewModelFactory = factory
        self.viewModel = viewModelFactory.configureAddDictionaryModel()
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
        configureCollection()
        NSLayoutConstraint.activate(regularModeConstraints)
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
        
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            collectionView.subviews.forEach { section in
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
            .store(in: &cancellabel)
    }
    //MARK: Controller SetUp
    private func configureController(){        
        //Keyboard appearence
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureNavBar(){
        self.navigationItem.rightBarButtonItem = switchModeButton
    }
    //MARK: Test
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adjustLayoutForSizeClass()
    }

    private func adjustLayoutForSizeClass() {
        let isCompact = traitCollection.horizontalSizeClass == .compact
        let numberOfColumns: CGFloat = isCompact ? 1 : 2
        
        let itemWidth = ((self.view.bounds.width - (.outerSpacer * 2)) / numberOfColumns) - (isCompact ? 0 : 10)
        
        layout.itemSize = CGSize(width: itemWidth, height: .largeButtonHeight)
        layout.minimumLineSpacing = .outerSpacer
        layout.invalidateLayout()
    }

    private func configureCollection(){
        view.addSubviews(collectionView)
        
        singleModeConstraints.append(contentsOf: [
            collectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        regularModeConstraints.append(contentsOf: [
            collectionView.topAnchor.constraint(
                equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
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
//        NSLayoutConstraint.activate([
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
        
        
//        collectionView.reloadData()
        print(sender.tag)
        if sender.tag == 0 {
            viewModel?.splitTheText(text: textInputView.textView.text)
            UIView.animate(withDuration: 0.3) {
                
                NSLayoutConstraint.deactivate(self.regularModeConstraints)
                NSLayoutConstraint.activate(self.singleModeConstraints)
                self.textInputView.alpha = 0
                self.nameView.alpha = 0
                self.saveButton.alpha = 0
                sender.image = UIImage(systemName: "doc.plaintext")
                self.view.layoutIfNeeded()
                
            }
            self.collectionView.reloadData()
            self.adjustLayoutForSizeClass()

            
            sender.tag = 1
        } else if sender.tag == 1 {
            self.textInputView.assignText(text: viewModel?.uniteTheText())
            UIView.animate(withDuration: 0.3) {
                
                NSLayoutConstraint.deactivate(self.singleModeConstraints)
                NSLayoutConstraint.activate(self.regularModeConstraints)
                self.textInputView.alpha = 1
                self.nameView.alpha = 1
                self.saveButton.alpha = 1
                sender.image = UIImage(systemName: "doc.richtext")
                self.view.layoutIfNeeded()
            }
            self.collectionView.reloadData()

            self.adjustLayoutForSizeClass()

            sender.tag = 0

        }
    }
}

extension AddDictionaryView {
    @objc func saveButtonDidTap(sender: Any){
        guard let name = validateName(), let text = textInputView.validateText() else { return }
        
        viewModel?.createDictionary(name: name, text: text)
                        
        navigationItem.rightBarButtonItem = nil
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
        
        
//        let button = UIBarButtonItem(image: UIImage(systemName: "doc.richtext"), style: .done, target: self, action: #selector(sigleModeWasEngaged(sender: )))
        self.navigationItem.rightBarButtonItem = switchModeButton
//        button.tag = 0

    }
    @objc func nonAccurateNameFieldTap(sender: Any){
        nameInputField.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(sender: Notification){
        
        updateTextViewConstraits(keyboardIsVisable: true)
        
        if let userInfo = sender.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let animation = userInfo[UIResponder.keyboardDidShowNotification]{
            let keyboardHeight = keyboardFrame.height
            collectionView.contentInset = UIEdgeInsets(top: .longOuterSpacer, left: .outerSpacer, bottom: keyboardHeight, right: .outerSpacer)
            collectionView.scrollIndicatorInsets = collectionView.contentInset
        }
        guard navigationItem.rightBarButtonItem == doneButton else {
            navigationItem.setRightBarButton(doneButton, animated: true)
            return
        }

    }
    @objc func keyboardWillHide(sender: Notification){
        updateTextViewConstraits(keyboardIsVisable: false)
        collectionView.contentInset = UIEdgeInsets(top: .longOuterSpacer, left: .outerSpacer, bottom: .outerSpacer, right: .outerSpacer)
        
        collectionView.scrollIndicatorInsets =   collectionView.contentInset

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

extension AddDictionaryView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let number =  viewModel?.numberOfCells(text: textInputView.textView.text) ?? 2
//        print(number)
        return number
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultiCardsAddCell.identifier, for: indexPath) as? MultiCardsAddCell
//            cell?.addCenterShadows()
            cell?.configureCellWith(delegate: self)
            return cell ?? UICollectionViewCell()
        } else if indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultiCardsNameCell.identifier, for: indexPath) as? MultiCardsNameCell
            cell?.configureCellWith(name: nameInputField.text ?? "" , delegate: self)
//            cell?.addCenterShadows()
            return cell ?? UICollectionViewCell()
        }  else {
            print(indexPath.item)
            let data = viewModel?.dataForCellAt(index: indexPath)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultiCardsCell.identifier, for: indexPath) as? MultiCardsCell
            guard cell != nil, data != nil else { return UICollectionViewCell() }
            cell!.configureCellWith(data: data!, delegate: self, index: indexPath)
            cell?.addCenterShadows()
            return cell!

        }
            }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1,
           let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            })
        } else {
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }

    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1, let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = layout.itemSize.width
        
        if indexPath.item == collectionView.numberOfItems(inSection: 0) - 1 || indexPath.item == collectionView.numberOfItems(inSection: 0) - 2 {
            // This is the "Add" button cell
            return CGSize(width: width, height: .genericButtonHeight)
        } else {
            // Regular chunk cells
            return CGSize(width: width, height: .largeButtonHeight * 2)
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("trying")
        guard indexPath.item < collectionView.numberOfItems(inSection: 0) - 1 else {
            return nil
            
        }      
        let deleteAction = UIContextualAction(style: .normal, title: nil) { _, _, completion in
            // Handle delete action
            completion(true)
        
        }
        deleteAction.image = UIImage(systemName: "trash") // or your custom image
        

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension AddDictionaryView: MultiCellTypeDelegate {
    func definitionDidTye(index: IndexPath, text: String) {
        viewModel?.definitionDidTye(index: index, text: text)
    }
    
    func wordDidType(index: IndexPath, text: String) {
        viewModel?.wordDidType(index: index, text: text)
    }
    func didStartTyping(index: IndexPath) {
        collectionView.scrollToItem(at: index, at: .top, animated: true)
    }
    func didTapAddImage(index: IndexPath) {
        let pair = viewModel?.currentWords[index.item]
        let view = AddImageController(word: pair?.word ?? "Error" , translation: pair?.definition ?? " Error ", image: pair?.image, delegate: self, index: index)
        self.navigationController?.pushViewController(view, animated: true)
    }
}

extension AddDictionaryView: AddImageDelegate {
    func didSelectAnImage(image: UIImage?, index: IndexPath) {
        if let cell = collectionView.cellForItem(at: index) as? MultiCardsCell {
            cell.addPhoto(image: image)
            viewModel?.imageDidAdd(image: image, index: index)
        }
    }
}
extension AddDictionaryView: MultyCellNameDelegate{
    func didTypeName(text: String) {
        self.nameInputField.text = text
    }
    
    
}

extension AddDictionaryView: MultyCellAddDelegate {
    func didAddCell() {
        viewModel?.addEmptyCell()
        collectionView.insertItems(at: [IndexPath(item: collectionView.numberOfItems(inSection: 0) - 2, section: 0)])

    }
    
    func didSave() {
        let text = viewModel?.uniteTheText()
        textInputView.assignText(text: text)
        
        saveButtonDidTap(sender: self)
    }
    
    
}
