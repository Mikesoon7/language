//
//  SearchCellDetailedView.swift
//  Learny
//
//  Created by Star Lord on 01/02/2025.
//
//  REFACTORING STATE: CHECKED

import UIKit
import Combine

protocol SearchCellInteractionDelegate: AnyObject {
    func didRequestDelete()
    func didCommitEdit(updatedText: String)
    func didDismissSelection()
}

enum Position {
    case leading
    case center
    case trailing
}

enum CellState {
    case colapsed
    case expanded
}

struct ExpandedCellContext {
    var cellPosition: Position
    var sourceViewFrame: CGRect
    
    var word: String
    var description: String
    var selectedSeparator: String
    
    var placeholder: String
}

class SearchCellExpandedView: UIViewController {
    //MARK: Properties
    private var cellContext: ExpandedCellContext
    private var delegate: SearchCellInteractionDelegate?
    
    private var cancellable = Set<AnyCancellable>()
    private var keyboardListener: KeyboardListener!
    
    private var cellLayoutState: CellState = .colapsed
    private var isInEditMode: Bool = false
    
    private var displayedTextCopy: String?
    
    //MARK: Views
    private var cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2.withAlphaComponent(0.8)
        view.layer.cornerRadius = .outerCornerRadius
        view.clipsToBounds = true
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var textInputView: TextInputView = {
        let view = TextInputView(delegate: self)
        view.updateFont(font: .selectedFont.withSize(.assosiatedTextSize))
        view.textView.isEditable = false
        view.textView.isFindInteractionEnabled = false
        view.textView.isSelectable = false
        view.textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 4, right: 5 )
        view.textView.layer.cornerRadius = .cornerRadius
        view.textView.clipsToBounds = true
        view.textView.backgroundColor = .selectedColourPalette.primaryBackgroundColour
        view.textView.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.setUpCustomButton()
        button.layer.cornerRadius = 6
        
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
        label.font = .systemFont(ofSize: .subCaptionSize, weight: .medium)
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
    private var cellColapsedConstraints:        [NSLayoutConstraint] = []
    private var cellExpandedConstraitns:        [NSLayoutConstraint] = []
    
    private var textViewColapsedConstraints:    [NSLayoutConstraint] = []
    private var textViewExpandedConstraints:    [NSLayoutConstraint] = []
    
    private var cellKeyboardActiveAnchor: NSLayoutConstraint   = .init()

    //MARK: Inherited
    init(cellContext: ExpandedCellContext,
         delegate: SearchCellInteractionDelegate){
        self.delegate = delegate
        self.cellContext = cellContext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        bindViewHelpers()
        
        configureView()
        configureCellView()
        configureCellButtons()
        configureTextView()

        updateCellLayout(for: self.cellLayoutState)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        delegate?.didDismissSelection()
    }

    
    //MARK: Bind
    private func bindViewHelpers() {
        self.keyboardListener = KeyboardListener(view: self.view)
        
        keyboardListener.events
            .sink { event in
                self.handleKeyboard(event)
            }
            .store(in: &cancellable)
    }
    
    
    //MARK: Subviews SetUp
    private func configureView() {
        self.view.backgroundColor = .clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimsissPopOverOnTap(sender:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    
    private func configureCellView(){
        view.addSubviews(cellView)
        
        let sourceFrame = cellContext.sourceViewFrame
        
        let cellMainAnchor = {
            switch cellContext.cellPosition {
            case .center: return
                cellView.centerXAnchor.constraint(
                    equalTo: view.leadingAnchor, constant: sourceFrame.midX)
            case .leading: return
                cellView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor, constant: .innerSpacer)
            case .trailing: return
                cellView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor, constant: -.innerSpacer)
            }
        }()

        cellColapsedConstraints.append(contentsOf: [
            cellView.heightAnchor.constraint(
                equalToConstant: sourceFrame.height),
            cellView.widthAnchor.constraint(
                equalToConstant: sourceFrame.width),
            cellView.centerYAnchor.constraint(
                lessThanOrEqualTo: view.topAnchor,
                constant: sourceFrame.midY),
            cellMainAnchor
        ])
        
        cellExpandedConstraitns.append(contentsOf: [
            cellView.heightAnchor.constraint(
                equalToConstant: (sourceFrame.height * 2) + .longInnerSpacer),
            cellView.widthAnchor.constraint(
                equalToConstant: (sourceFrame.width * 2) + (.nestedSpacer * 2)),
            cellView.centerYAnchor.constraint(
                lessThanOrEqualTo: view.topAnchor,
                constant: sourceFrame.midY + .longInnerSpacer),
            cellMainAnchor
        ])
        
        self.cellKeyboardActiveAnchor = cellView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -(.longInnerSpacer))

        
        UIBlurEffect.addBlurBackground(to: self.cellView, style: .systemThickMaterial)
    }
    
    private func configureTextView(){
        cellView.addSubview(textInputView)
        
        //Assigning text Attributes to recreate the collectionView cell appearence.
        let firstAttributes: [NSAttributedString.Key: Any] =    [.font: UIFont.selectedFont.withSize(.assosiatedTextSize), .foregroundColor: UIColor.label]
        let secondAttributes: [NSAttributedString.Key: Any] =   [.font: UIFont.selectedFont.withSize(.captionTextSize), .foregroundColor: UIColor.label]
        
        let firstAttributedString = NSAttributedString(string: cellContext.word , attributes: firstAttributes)
        let secondAttributedString = NSAttributedString(string: "\n" + "\n" + cellContext.description, attributes: secondAttributes)
        
        let finalAttributedString = NSMutableAttributedString()
        finalAttributedString.append(firstAttributedString)
        finalAttributedString.append(secondAttributedString)
        
        displayedTextCopy = cellContext.word + " " + cellContext.selectedSeparator + " " + cellContext.description
        textInputView.updateAttributedText(text: finalAttributedString)
        
        //Constraints for changing view's dimensions.
        textViewColapsedConstraints.append(contentsOf: [
            textInputView.topAnchor.constraint(
                equalTo: cellView.topAnchor),
            textInputView.leadingAnchor.constraint(
                equalTo: cellView.leadingAnchor),
            textInputView.trailingAnchor.constraint(
                equalTo: cellView.trailingAnchor),
            textInputView.bottomAnchor.constraint(
                equalTo: cellView.bottomAnchor)
        ])
        
        textViewExpandedConstraints.append(contentsOf: [
            textInputView.topAnchor.constraint(
                equalTo: cellView.topAnchor, constant: .nestedSpacer),
            textInputView.leadingAnchor.constraint(
                equalTo: cellView.leadingAnchor, constant: .nestedSpacer),
            textInputView.trailingAnchor.constraint(
                equalTo: cellView.trailingAnchor, constant: -.nestedSpacer),
            textInputView.bottomAnchor.constraint(
                equalTo: deleteButton.topAnchor, constant: -.nestedSpacer)
        ])
    }
    
    func configureCellButtons(){
        cellView.addSubviews(copyButton, editButton, copiedLabel, deleteButton, saveButton)

        
        NSLayoutConstraint.activate([
            copyButton.bottomAnchor.constraint(
                equalTo: cellView.bottomAnchor, constant: -.nestedSpacer),
            copyButton.leadingAnchor.constraint(
                equalTo: cellView.leadingAnchor, constant: .longInnerSpacer),
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
                equalTo: cellView.trailingAnchor, constant: -.longInnerSpacer),
            deleteButton.heightAnchor.constraint(
                equalToConstant: .systemButtonSize),
            deleteButton.widthAnchor.constraint(
                equalToConstant: .systemButtonSize * 5),
            
            
            saveButton.bottomAnchor.constraint(
                equalTo: cellView.bottomAnchor, constant: -.nestedSpacer),
            saveButton.trailingAnchor.constraint(
                equalTo: cellView.trailingAnchor, constant: -.longInnerSpacer),
            saveButton.heightAnchor.constraint(
                equalToConstant: .systemButtonSize),
            saveButton.widthAnchor.constraint(
                equalToConstant: .systemButtonSize * 5),
        ])
        
        deleteButton.addTarget(self, action: #selector(deleteButtonDidTap(sender: )), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender: )), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyButtonDidTap(sender: )), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonDidTap(sender: )), for: .touchUpInside)
    }
    
    
    //MARK: Animations
    func presentPopOver(){
        UIView.animate(withDuration: 0.1, animations: {
            self.cellView.alpha = 1
        }) { _ in
            self.updateCellLayoutState(.expanded, closure: { })
            
        }
    }
    
    func dismissPopOver() {
        updateCellLayoutState(.colapsed) {
            UIView.animate(withDuration: 0.3) {
                self.cellView.alpha = 0
            } completion: { _ in
                self.dismiss(animated: false)
            }
        }
    }

    
    //MARK: Layout
    private func updateCellLayout(for state: CellState, animated: Bool = false){
        
        switch state {
        case .colapsed:
            NSLayoutConstraint.deactivate(
                textViewExpandedConstraints + cellExpandedConstraitns)
            NSLayoutConstraint.activate(
                textViewColapsedConstraints + cellColapsedConstraints)
        case .expanded:
            NSLayoutConstraint.deactivate(
                textViewColapsedConstraints + cellColapsedConstraints)
            NSLayoutConstraint.activate(
                textViewExpandedConstraints + cellExpandedConstraitns)
        }
    }

    private func updateCellLayoutState(_ state: CellState, closure: @escaping() -> ()) {
        UIView.animate(withDuration: 0.3, animations: {
            switch state{
            case .colapsed:
                self.view.backgroundColor = .clear
                self.updateCellEditState(isActive: false)
                self.updateLayoutForStateChange(isActive: false)
            case .expanded:
                self.view.backgroundColor = .black.withAlphaComponent(0.2)
            }
                    
            self.updateCellLayout(for: state)
            
            self.view.layoutIfNeeded()
        }) { _ in
            closure()
        }
    }
    
    private func updateCellEditState(isActive: Bool, duration: Double = 0.3){
        UIView.animate(withDuration: duration) {
            self.saveButton.alpha = isActive ? 1 : 0
            self.deleteButton.alpha = !isActive ? 1 : 0
            
            self.textInputView.textView.isEditable = isActive
            self.textInputView.textView.isFindInteractionEnabled = isActive
            self.textInputView.textView.isSelectable = isActive

            if isActive {
                let attributedText = NSAttributedString(
                    string: self.cellContext.word + " " + self.cellContext.selectedSeparator + " " + self.cellContext.description,
                    attributes: [
                        .font: UIFont.selectedFont.withSize(.assosiatedTextSize),
                        .foregroundColor: UIColor.label
                    ]
                )


                self.textInputView.updateAttributedText(text: attributedText)
                _ = self.textInputView.becomeFirstResponder()
            } else {
                _ = self.textInputView.resignFirstResponder()
            }
            
            
            self.view.layoutIfNeeded()
        }
        
        self.displayedTextCopy = textInputView.currentText()
    }
    
    //MARK: Keyboard handling
    private func handleKeyboard(_ event: KeyboardListener.Event) {
        UIView.animate(
            withDuration: event.duration,
            delay: 0,
            options: event.curve
        ) {
            switch event.presence {
            case .hidden, .accessoryOnly:
                self.updateLayoutForStateChange(isActive: false)
            case .full:
                self.updateLayoutForStateChange(isActive: true)
            }
        }
    }

    private func updateLayoutForStateChange(isActive: Bool, duration: Double = 0.3){
        UIView.animate(withDuration: duration) {
            self.cellKeyboardActiveAnchor.isActive = isActive ? true : false
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
            self.delegate?.didRequestDelete()
            self.dismissPopOver()
        }
        
        let cancel = UIAlertAction(title: "system.cancel".localized, style: .cancel)
        cancel.setValue(UIColor.label, forKey: "titleTextColor")
                
        alert.addAction(cancel)
        alert.addAction(confirm)
        self.present(alert, animated: true)
    }

    
    @objc func editButtonDidTap(sender: Any) {
        isInEditMode.toggle()
        updateCellEditState(isActive: isInEditMode)
    }

    @objc func saveButtonDidTap(sender: Any) {
        guard let delegate = delegate else { return }
        delegate.didCommitEdit(updatedText: self.textInputView.currentText())
        
        self.dismissPopOver()
    }
    
    @objc func dimsissPopOverOnTap(sender: UITapGestureRecognizer){
        self.dismissPopOver()
    }
    
    @objc func copyButtonDidTap(sender: Any) {
        //it might coppy the old value
        UIPasteboard.general.string = cellContext.word + " " + cellContext.word
        UIView.animate(withDuration: 0.2, animations: {
            self.copiedLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.copiedLabel.alpha = 0
            }
        }
    }
    
}

extension SearchCellExpandedView: PlaceholderTextViewDelegate {
    func textViewDidBeginEditing(sender: UITextView) { }
    
    func textViewDidEndEditing(sender: UITextView) {  }
    
    func textViewDidChange(sender: UITextView) { }
    
    func currentSeparatorSymbol() -> String? {
        self.cellContext.selectedSeparator
    }
    
    func configurePlaceholderText(sender: UITextView) -> String? {
        self.cellContext.placeholder
    }
    
    func presentErrorAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }

}
