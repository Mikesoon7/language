//
//  SearchCellDetailedView.swift
//  Learny
//
//  Created by Star Lord on 01/02/2025.
//
//  REFACTORING STATE: CHECKED

import UIKit

enum Position {
    case leading
    case center
    case trailing
}

protocol SearchViewDeleteDelegate: AnyObject {
    func shouldDeleteCell(at index: IndexPath)
    func shouldSaveCell(at index: IndexPath, text: String)
    func popOverDidDismiss()
}

class SearchCellExpandedView: UIViewController {
    //MARK: Properties
    private var selectedIndex: IndexPath
    private var delegate: SearchViewDeleteDelegate
    
    private var windowView: UIView
    private var cellPosition: Position
    
    private var sourceViewFrame: CGRect
    private var wordText: String
    private var descriptionText: String
    
    private var separator: String
    private var placeholder: String
    
    //MARK: Views
    private var cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2.withAlphaComponent(0.8)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var textInputView: TextInputView = {
        let view = TextInputView(delegate: self)
        view.textView.font = .selectedFont.withSize(14)
        view.textView.isEditable = false
        view.textView.isFindInteractionEnabled = false
        view.textView.isSelectable = false
        view.textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 4, right: 5 )
        view.textView.layer.cornerRadius = .cornerRadius
        view.textView.clipsToBounds = true
        view.textView.backgroundColor = .secondarySystemBackground
        view.textView.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setUpCustomButton()
        button.layer.cornerRadius = 6
        
        button.alpha = 0
        button.setTitle("system.delete".localized, for: .normal)
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setUpCustomButton()
        button.layer.cornerRadius = 6
        
        button.alpha = 0
        button.setTitle("system.save".localized, for: .normal)
        return button
    }()
    
    private let copyButton: UIButton = {
        let button = UIButton()
        button.setUpAccessoryViewButton(image: .init(systemName: "doc.on.doc"))
        return button
    }()
    
    private let copiedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.tintColor = .label
        label.text = "copied".localized
        label.alpha = 0
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton()
        button.setUpAccessoryViewButton(image: .init(systemName: "pencil"))
        return button
    }()

    //MARK: Constants and constraints
    private var height: NSLayoutConstraint = .init()
    private var width: NSLayoutConstraint = .init()
    private var centerY: NSLayoutConstraint = .init()
    private var cellEditStateBottomAnchor: NSLayoutConstraint = .init()
    
    private var textTopAnchor: NSLayoutConstraint = .init()
    private var textLeadingAnchor: NSLayoutConstraint = .init()
    private var textTrailingAnchor: NSLayoutConstraint = .init()
    private var textBottomAnchor: NSLayoutConstraint = .init()
    private var textBottomToButton: NSLayoutConstraint = .init()
    

    //MARK: Inherited
    init(windowView: UIView, shadowPosition: Position, sourceViewFrame: CGRect, word: String, description: String, delegate: SearchViewDeleteDelegate, selectedIndex: IndexPath, selectedSeparator: String, placeholder: String ){
        self.delegate = delegate
        self.selectedIndex = selectedIndex
        
        self.windowView = windowView
        self.cellPosition = shadowPosition
        
        self.sourceViewFrame = sourceViewFrame
        self.wordText = word
        self.descriptionText = description
        
        self.separator = selectedSeparator
        self.placeholder = placeholder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        configureView()
        configureCellView()
        configureTextView()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    private func configureView() {
        self.view.backgroundColor = .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimsissPopOverOnTap(sender:)))
        self.view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureCellView(){
        view.addSubviews(cellView)
        
        self.height = cellView.heightAnchor.constraint(equalToConstant: sourceViewFrame.height )
        self.width  = cellView.widthAnchor.constraint(equalToConstant: sourceViewFrame.width )
        self.centerY = cellView.centerYAnchor.constraint(equalTo: view.topAnchor, constant: sourceViewFrame.midY)
        
        self.cellEditStateBottomAnchor = cellView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -(.outerSpacer + 50))
        
        UIKit.NSLayoutConstraint.activate([
            centerY,
            height,
            width
        ])
        
        if cellPosition == .trailing {
            cellView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor, constant: -.innerSpacer).isActive = true
        } else if cellPosition == .leading {
            cellView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: sourceViewFrame.minX).isActive = true
        } else {
            cellView.centerXAnchor.constraint(
                equalTo: view.leadingAnchor, constant: sourceViewFrame.midX).isActive = true
        }
        
        UIBlurEffect.addBlurBackground(to: self.cellView, style: .systemThickMaterial)
    }
    
    private func configureTextView(){
        cellView.addSubviews(copyButton, editButton, copiedLabel, deleteButton, saveButton, textInputView)
        
        //Assigning text Attributes to recreate the collectionView cell appearence.
        let firstAttributes: [NSAttributedString.Key: Any] =    [.font: UIFont.selectedFont.withSize(14), .foregroundColor: UIColor.label]
        let secondAttributes: [NSAttributedString.Key: Any] =   [.font: UIFont.selectedFont.withSize(11), .foregroundColor: UIColor.label]
        
        let firstAttributedString = NSAttributedString(string: wordText , attributes: firstAttributes)
        let secondAttributedString = NSAttributedString(string: "\n" + "\n" + descriptionText, attributes: secondAttributes)
        
        let finalAttributedString = NSMutableAttributedString()
        finalAttributedString.append(firstAttributedString)
        finalAttributedString.append(secondAttributedString)
        
        textInputView.textView.attributedText = finalAttributedString
        
        //Constraints for changing view's dimensions.
        textTopAnchor = textInputView.topAnchor.constraint(
            equalTo: cellView.topAnchor)
        textLeadingAnchor = textInputView.leadingAnchor.constraint(
            equalTo: cellView.leadingAnchor)
        textTrailingAnchor = textInputView.trailingAnchor.constraint(
            equalTo: cellView.trailingAnchor)
        textBottomAnchor = textInputView.bottomAnchor.constraint(
            equalTo: cellView.bottomAnchor)
        textBottomToButton = textInputView.bottomAnchor.constraint(
            equalTo: deleteButton.topAnchor, constant: -.nestedSpacer)
        
        
        UIKit.NSLayoutConstraint.activate([
            
            copyButton.bottomAnchor.constraint(
                equalTo: cellView.bottomAnchor, constant: -.nestedSpacer),
            copyButton.leadingAnchor.constraint(
                equalTo: cellView.leadingAnchor, constant: .outerSpacer),
            copyButton.heightAnchor.constraint(
                equalToConstant: .systemButtonSize),
            copyButton.widthAnchor.constraint(
                equalToConstant: .systemButtonSize),
            
            
            editButton.bottomAnchor.constraint(
                equalTo: cellView.bottomAnchor, constant: -.nestedSpacer),
            editButton.leadingAnchor.constraint(
                equalTo: copyButton.trailingAnchor, constant: .nestedSpacer),
            editButton.heightAnchor.constraint(
                equalToConstant: .systemButtonSize),
            editButton.widthAnchor.constraint(
                equalToConstant: .systemButtonSize),
            
            
            copiedLabel.leadingAnchor.constraint(
                equalTo: editButton.trailingAnchor, constant: .nestedSpacer),
            copiedLabel.centerYAnchor.constraint(
                equalTo: copyButton.centerYAnchor),
            copiedLabel.heightAnchor.constraint(
                equalToConstant: .systemButtonSize),
            
            
            deleteButton.bottomAnchor.constraint(
                equalTo: cellView.bottomAnchor, constant: -.nestedSpacer),
            deleteButton.trailingAnchor.constraint(
                equalTo: cellView.trailingAnchor, constant: -.outerSpacer),
            deleteButton.heightAnchor.constraint(
                equalToConstant: .systemButtonSize),
            deleteButton.widthAnchor.constraint(
                equalToConstant: .systemButtonSize * 5),
            
            
            saveButton.bottomAnchor.constraint(
                equalTo: cellView.bottomAnchor, constant: -.nestedSpacer),
            saveButton.trailingAnchor.constraint(
                equalTo: cellView.trailingAnchor, constant: -.outerSpacer),
            saveButton.heightAnchor.constraint(
                equalToConstant: .systemButtonSize),
            saveButton.widthAnchor.constraint(
                equalToConstant: .systemButtonSize * 5),
            
            
            textTopAnchor,
            textLeadingAnchor,
            textTrailingAnchor,
            textBottomAnchor
        ])
        
        deleteButton.addTarget(self, action: #selector(deleteButtonDidTap(sender: )), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender: )), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyButtonDidTap(sender: )), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonDidTap(sender: )), for: .touchUpInside)
        
    }
    
    
    
    func presentPopOver(){
        UIView.animate(withDuration: 0.1, animations: {
            self.cellView.alpha = 1
        }) { _ in
            self.changePopOverState(activate: true, closure: { } )
        }
    }
    
    func dismissPopOver(closure: @escaping() -> ()){
        changePopOverState(activate: false) {
            UIView.animate(withDuration: 0.3, animations:  {
                self.cellView.alpha = 0
            }) { _ in
                self.dismiss(animated: false)
                closure()
            }
        }
    }
    
    private func changePopOverState(activate: Bool, closure: @escaping() -> ()) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = activate ? .black.withAlphaComponent(0.2) : .clear
            
            if !activate && self.textInputView.textView.isFirstResponder {
                self.chagneEditState(activate: false)
            }
            self.deleteButton.alpha =  activate ? 1 : 0
            
            
            if activate {
                self.textTopAnchor.constant += .nestedSpacer
                self.textLeadingAnchor.constant += .nestedSpacer
                self.textTrailingAnchor.constant -= .nestedSpacer
                
                self.centerY.constant += .outerSpacer
                self.width.constant += self.sourceViewFrame.width + .outerSpacer
                self.height.constant += self.sourceViewFrame.height + .outerSpacer
                
                self.textBottomAnchor.isActive = false
                self.textBottomToButton.isActive = true

            } else {
                self.textTopAnchor.constant -= .nestedSpacer
                self.textLeadingAnchor.constant -= .nestedSpacer
                self.textTrailingAnchor.constant += .nestedSpacer
                
                self.centerY.constant -= .outerSpacer
                self.width.constant = self.sourceViewFrame.width
                self.height.constant = self.sourceViewFrame.height
                
                self.textBottomToButton.isActive = false
                self.textBottomAnchor.isActive = true

            }
            self.view.layoutIfNeeded()
        }) { _ in
            closure()
        }
    }
        
    private func chagneEditState(activate: Bool, duration: Double? = 0){
        self.saveButton.alpha = activate ? 1 : 0
        self.deleteButton.alpha = !activate ? 1 : 0
        self.textInputView.textView.isEditable = activate
        self.textInputView.textView.isFindInteractionEnabled = activate
        self.textInputView.textView.isSelectable = activate
        
        self.centerY.isActive = activate ? false : true
        self.cellEditStateBottomAnchor.isActive = activate ? true : false

        if activate {
            self.textInputView.textView.attributedText = NSAttributedString(
                string: wordText + " " + separator + " " + descriptionText,
                attributes: [.font: UIFont.selectedFont.withSize(14)]
            )
            self.textInputView.textView.becomeFirstResponder()
            self.centerY.isActive = false
            self.cellEditStateBottomAnchor.isActive = true

        } else {
            
            self.cellEditStateBottomAnchor.isActive = false
            self.centerY.isActive = true
            self.textInputView.textView.resignFirstResponder()
        }
        
        UIView.animate(withDuration: duration ?? 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: Actions
    @objc func deleteButtonDidTap(sender: Any) {
        let alert = UIAlertController
            .alertWithAction(
                alertTitle: "gameDetails.deleteAlert.title".localized,
                alertMessage: "gameDetails.deleteAlert.message".localized,
                sourceView: self.view
            )
        
        let confirm = UIAlertAction(title: "system.delete".localized, style: .destructive) { _ in
            self.dismissPopOver(closure: {
                self.delegate.shouldDeleteCell(at: self.selectedIndex)
            })
        }
        
        let cancel = UIAlertAction(title: "system.cancel".localized, style: .cancel)
        cancel.setValue(UIColor.label, forKey: "titleTextColor")
                
        alert.addAction(cancel)
        alert.addAction(confirm)
        self.present(alert, animated: true)
    }

    
    @objc func editButtonDidTap(sender: Any) {
        if textInputView.textView.isFirstResponder {
            textInputView.textView.resignFirstResponder()
        } else {
            textInputView.textView.becomeFirstResponder()
        }
    }

    @objc func saveButtonDidTap(sender: Any) {
        guard let text = textInputView.validateText() else { return }
        self.dismissPopOver(closure: {
            self.delegate.shouldSaveCell(at: self.selectedIndex, text: text)
        })
        
    }
    @objc func dimsissPopOverOnTap(sender: UITapGestureRecognizer){
        self.dismissPopOver(closure: self.delegate.popOverDidDismiss)
    }
    
    @objc func copyButtonDidTap(sender: Any) {
        UIPasteboard.general.string = wordText + " " + descriptionText
        UIView.animate(withDuration: 0.2, animations: {
            self.copiedLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.copiedLabel.alpha = 0
            }
        }
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

        chagneEditState(activate: true, duration: animationDuration)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

        chagneEditState(activate: false, duration: animationDuration)
    }

}

extension SearchCellExpandedView: PlaceholderTextViewDelegate {
    func textViewDidBeginEditing() { }
    
    func textViewDidEndEditing() {  }
    
    func textViewDidChange() { }
    
    func currentSeparatorSymbol() -> String? {
        self.separator
    }
    
    func configurePlaceholderText() -> String? {
        self.placeholder
    }
    
    func presentErrorAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }

}
