//
//  MultiCardsCell.swift
//  Learny
//
//  Created by Star Lord on 19/03/2025.
//

import UIKit


protocol MultiCellTypeDelegate: AnyObject {
    func wordDidType(index: IndexPath, text: String)
    func definitionDidTye(index: IndexPath, text: String)
    func didStartTyping(index: IndexPath)
    func didTapAddImage(index: IndexPath)
    
}

protocol MultyCellNameDelegate: AnyObject {
    func didTypeName(text: String)
}

protocol MultyCellAddDelegate: AnyObject {
    func didAddCell()
    func didSave()
}

struct MultiCardsData{
    var word: String
    var translation: String
    var image: UIImage?
}
class MultiCardsCell: UICollectionViewCell {
    
    static var identifier = "MultiCard"
    
    var delegate: MultiCellTypeDelegate?
    var index: IndexPath!
    
    private enum ViewConstants{
        static let cornerRadius: CGFloat = .cornerRadius
        static let overlayPoints: CGFloat = 2
        static let actionViewMultiplier: CGFloat = 0.2
    }
    
    lazy var mainView : UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        
        view.layer.cornerRadius = .cornerRadius
        view.clipsToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = .cornerRadius
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "photo.badge.plus"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    lazy var frontSideTextView: TextInputView = {
        let view = TextInputView(delegate: self, tag: 0)
        view.textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5 )
        view.textView.textAlignment = .left
        view.textView.clipsToBounds = true
        view.textView.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
        
    }()
    
    lazy var backSideTextView: TextInputView = {
        let view = TextInputView(delegate: self, tag: 1)
        view.textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5 )
        view.textView.textAlignment = .left
        view.textView.clipsToBounds = true
        view.textView.backgroundColor = .clear
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()

    
    var imageSmallLayout: [NSLayoutConstraint] = []
    var imageLargeLayout: [NSLayoutConstraint] = []

    //MARK: - Inherited Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureSubviews()
        configureView()
        configureTextViews()
//        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = ViewConstants.cornerRadius

    }
    
    
    deinit { NotificationCenter.default.removeObserver(self) }

    required init?(coder: NSCoder) {
        fatalError("coder wasn't imported")
    }
    
    func configureCellWith(data: MultiCardsData, delegate: MultiCellTypeDelegate, index: IndexPath){
        
        frontSideTextView.assignText(text: data.word)
        backSideTextView.assignText(text: data.translation) 
        if let image = data.image {
            button.setImage(image, for: .normal)
        }
        self.delegate = delegate
        self.index = index
    }
    func configureView(){
        button.addTarget(self, action: #selector(addImageButtonDidTap(sender:)), for: .touchUpInside)
    }
    
    func configureSubviews() {
        self.contentView.addSubviews(mainView, button)
        
        
        imageSmallLayout.append(contentsOf: [
            button.topAnchor.constraint(
                equalTo: mainView.topAnchor, constant: .innerSpacer),
            button.trailingAnchor.constraint(
                equalTo: mainView.trailingAnchor, constant: -.innerSpacer),
            button.widthAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            button.bottomAnchor.constraint(
                equalTo: mainView.bottomAnchor, constant: -.innerSpacer),
        ])
        imageLargeLayout.append(contentsOf: [
            button.topAnchor.constraint(
                equalTo: mainView.topAnchor, constant: .innerSpacer),
            button.trailingAnchor.constraint(
                equalTo: mainView.trailingAnchor, constant: -.innerSpacer),
            button.bottomAnchor.constraint(
                equalTo: mainView.bottomAnchor, constant: -.innerSpacer),
            button.widthAnchor.constraint(
                equalTo: button.heightAnchor, multiplier: 0.66),

        ])
        
        NSLayoutConstraint.activate([
            
            mainView.topAnchor.constraint(equalTo: topAnchor),
            mainView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        NSLayoutConstraint.activate(imageSmallLayout)
        
        
        
    }
    func configureTextViews(){
        self.mainView.addSubviews(frontSideTextView, backSideTextView)

        NSLayoutConstraint.activate([
            frontSideTextView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: .innerSpacer),
            frontSideTextView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: .innerSpacer),
            frontSideTextView.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -.innerSpacer),
            frontSideTextView.heightAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 0.5, constant: -(.innerSpacer * 1.5 )),
            
            backSideTextView.topAnchor.constraint(equalTo: frontSideTextView.bottomAnchor, constant: .innerSpacer),
            backSideTextView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: .innerSpacer),
            backSideTextView.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -.innerSpacer),
            backSideTextView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant:  -.innerSpacer ),
            
            ])
    }

    func addPhoto(image: UIImage?){
        if let image = image {
            self.button.setImage(image, for: .normal)
            button.imageView?.contentMode = .scaleAspectFill
            UIView.animate(withDuration: 0.3) {
                NSLayoutConstraint.activate(self.imageLargeLayout)
                NSLayoutConstraint.deactivate(self.imageSmallLayout)
            }
            self.layoutIfNeeded()
        } else {
            self.button.setImage(UIImage(systemName: "photo.badge.plus"), for: .normal)
            button.imageView?.contentMode = .scaleAspectFill
            UIView.animate(withDuration: 0.3) {
                NSLayoutConstraint.activate(self.imageSmallLayout)
                NSLayoutConstraint.deactivate(self.imageLargeLayout)
            }

        }
    }
    @objc func addImageButtonDidTap(sender: Any){
        delegate?.didTapAddImage(index: index)
    }

}
 

extension MultiCardsCell: PlaceholderTextViewDelegate {
    func textViewDidBeginEditing(sender: UITextView) {
        delegate?.didStartTyping(index: index)
    }
    
    func textViewDidEndEditing(sender: UITextView) {
        
        print(sender.tag)
        if sender.tag == 0 {
            delegate?.wordDidType(index: index, text: frontSideTextView.textView.text)
        } else {
            delegate?.definitionDidTye(index: index, text: backSideTextView.textView.text)
        }
    }
    
    func textViewDidChange(sender: UITextView) {  }
    
    func currentSeparatorSymbol() -> String?    { nil }
    
    //Since its the only place where one class is being ad delegate to two textView's, the correct return defined by the tag.
    func configurePlaceholderText(sender: UITextView) -> String?  {
        if sender.tag == 0 {
            print("fr", sender.tag)
            return "Front side"
        } else {
            print("back", sender.tag)
            return "Back side"
        }
        
    }
    
    func presentErrorAlert(alert: UIAlertController) {
        
    }
    
    
}

class MultiCardsAddCell: UICollectionViewCell {
    
    static var identifier = "MultiCardAdd"
    var delegate: MultyCellAddDelegate?
    
    private enum ViewConstants{
        static let cornerRadius: CGFloat = .cornerRadius
        static let overlayPoints: CGFloat = 2
        static let actionViewMultiplier: CGFloat = 0.2
    }
        
    var saveButton : UIButton = {
        var button = UIButton()
        button.setUpCustomButton()
        button.setAttributedTitle(
            .attributedString(string: "system.save".localized,
                              with: .selectedFont,
                              ofSize: .bodyTextSize), for: .normal)
        return button
    }()


    var addNewCellButton: UIButton = {
        let button = UIButton()
        button.setUpCustomButton()
        button.setImage(UIImage(systemName: "plus.viewfinder")?.withTintColor(.label), for: .normal)
        return button
    }()

    //MARK: - Inherited Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureSubviews()

    }
    
    
    deinit { NotificationCenter.default.removeObserver(self) }

    required init?(coder: NSCoder) {
        fatalError("coder wasn't imported")
    }
    

    func configureCellWith(delegate: MultyCellAddDelegate){
        self.delegate = delegate
    }
    func configureSubviews() {
        self.contentView.addSubviews( saveButton, addNewCellButton)
        
        
        
        NSLayoutConstraint.activate([
            addNewCellButton.topAnchor.constraint(equalTo: topAnchor),
            addNewCellButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            addNewCellButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5, constant: -.innerSpacer / 2),
            addNewCellButton.bottomAnchor.constraint(equalTo: bottomAnchor),

            saveButton.topAnchor.constraint(equalTo: topAnchor),
            saveButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            saveButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5, constant: -.innerSpacer / 2),
            saveButton.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        addNewCellButton.addTarget(self, action: #selector(addButtonDidTap(sender: )), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender: )), for: .touchUpInside)
    }
    
    @objc func addButtonDidTap(sender: Any){
        delegate?.didAddCell()
    }
    @objc func saveButtonDidTap(sender: Any){
        delegate?.didSave()
    }


}

class MultiCardsNameCell: UICollectionViewCell {
    
    static var identifier = "MultiCardName"
    var delegate: MultyCellNameDelegate?

    private enum ViewConstants{
        static let cornerRadius: CGFloat = .cornerRadius
        static let overlayPoints: CGFloat = 2
        static let actionViewMultiplier: CGFloat = 0.2
    }
    
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
    
    lazy var nameInputField : UITextField = {
        let field = UITextField()
        field.textColor = .label
        field.textAlignment = .right
        field.font = .selectedFont.withSize(.assosiatedTextSize)
        field.translatesAutoresizingMaskIntoConstraints = false
        field.delegate = self
        return field
    }()

    
    //MARK: - Inherited Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureNameInputView()
    }
    func configureCellWith(name: String, delegate: MultyCellNameDelegate){
        self.nameInputField.text = name
        self.delegate = delegate
    }
    
    
    deinit { NotificationCenter.default.removeObserver(self) }

    required init?(coder: NSCoder) {
        fatalError("coder wasn't imported")
    }
    

    private func configureNameInputView(){
        contentView.addSubview(nameView)
        nameView.addSubviews(nameLabel, nameInputField)
        
        nameLabel.text =  "dictionaryName".localized

        nameInputField.placeholder = "fieldPlaceholder".localized

        NSLayoutConstraint.activate([
            nameView.topAnchor.constraint(
                equalTo: topAnchor),
            nameView.leadingAnchor.constraint(
                equalTo: leadingAnchor),
            nameView.trailingAnchor.constraint(
                equalTo: trailingAnchor),
            nameView.heightAnchor.constraint(
                equalTo: heightAnchor),
            
            
            
            
            nameLabel.leadingAnchor.constraint(
                equalTo: nameView.leadingAnchor, constant: .innerSpacer),
            nameLabel.centerYAnchor.constraint(
                equalTo: nameView.centerYAnchor),
            
            
            nameInputField.trailingAnchor.constraint(
                equalTo: nameView.trailingAnchor, constant: -.innerSpacer),
            nameInputField.centerYAnchor.constraint(
                equalTo: nameView.centerYAnchor)
        ])
        //Action
        nameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nonAccurateNameFieldTap(sender:))))
    }

    @objc func nonAccurateNameFieldTap(sender: Any){
        nameInputField.becomeFirstResponder()
    }

}

extension MultiCardsNameCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            delegate?.didTypeName(text: text)
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        
        return newString.count <= maxLength
    }
}
