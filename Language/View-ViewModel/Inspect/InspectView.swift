//
//  InspectView.swift
//  Learny
//
//  Created by Star Lord on 15/11/2025.
//
//MARK: Polished

import UIKit
import Combine

class InspectView: UIViewController {
    
    private var viewModel: InspectViewModel
    private var viewModelFactory: ViewModelFactory
    
    private var cancellables = Set<AnyCancellable>()
    private var keyboardListener: KeyboardListener!
    
    private var isInSearchMode = false
    
    //MARK: View's
    lazy var textInputView: TextInputView = {
        let view = TextInputView(frame: .zero,
                                 delegate: self,
                                 textContainerInsets: textInsets )
        view.textView.allowsEditingTextAttributes = true
        view.textView.textColor = .label
        view.textView.backgroundColor = .systemBackground
        view.textView.font = .selectedFont.withSize(.subtitleSize)
        view.layer.cornerRadius = 0
        view.textView.alwaysBounceVertical = true
        view.textView.isEditable = false
        view.textView.inputAccessoryView = nil
        view.textView.textContainer.lineBreakMode = .byWordWrapping
        view.textView.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: SEARCH view's
    private lazy var customSearchToolBar: CustomSearchToolBar = {
        let view = CustomSearchToolBar(textView: textInputView.textView, layoutManager: textInputView.layoutManager)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    //MARK: Buttons
    private lazy var doneButton = UIBarButtonItem(
        title: "system.done".localized,
        style: .done,
        target: self,
        action: #selector(doneButTap(sender:))
    )

    private lazy var textSearchButton = UIBarButtonItem(
        barButtonSystemItem: .search,
        target: self,
        action: #selector(searchButDidTap(sender: ))
    )
    //MARK: Layout Properties
    private let textInsets = UIEdgeInsets(top: .outerSpacer, left: .outerSpacer, bottom: .outerSpacer + .customSearchAccessoryView , right: .outerSpacer)
    
    //MARK:  Inherited
    required init(dictionary: DictionariesEntity, factory: ViewModelFactory){
        self.viewModelFactory = factory
        viewModel = factory.configureInspectModel(dictionary: dictionary)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init?(coder: NSCoder) wasn't imported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureController()
        configureTextView()
        configureSearchView()

        bind()
        bindViewHelpers()

    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    //MARK: Binding View and ViewModel
    private func bind(){
        viewModel.$data
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                guard let data = data else { return }
                self?.configure(with: data)
            })
            .store(in: &cancellables)
        
        viewModel.output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] output in
                switch output {
                case .shouldPresentData(let parsedDictionary):
                    self?.configure(with: parsedDictionary)
                case .shouldPresentError(let error):
                    self?.presentError(error, sourceView: self?.view)
                case .shouldUpdateLabels:
                    self?.configureLabels()
                    self?.customSearchToolBar.configureLabels()
                case .shouldUpdateFont:
                    self?.updateFont()
                }
            }
            .store(in: &cancellables)
    }
    
    func bindViewHelpers() {
        self.keyboardListener = KeyboardListener(view: self.view)
        
        keyboardListener.events
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleKeyboard(event)
            }
            .store(in: &cancellables)
    }

    //MARK: Subview's SetUp
    private func configureController(){
        updatePrimaryActionsForEdit(isActive: false)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        NotificationCenter.default.addObserver(
            self, selector: #selector(appDidEnterBackground(sender: )), name: UIScene.didEnterBackgroundNotification, object: nil
        )
    }

    ///Assigning recieved data to text view and field.
    private func configure(with data: ParsedDictionary){
        self.navigationItem.title = data.name
        self.textInputView.updateAttributedText(text: data.text)
        self.updateFont()
    }

    
    //MARK: Subviews SetUp
    private func configureTextView(){
        view.addSubview(textInputView)
        
        NSLayoutConstraint.activate([
            textInputView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            textInputView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textInputView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textInputView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
        ])
        
    }
    func configureSearchView(){
        view.addSubviews(customSearchToolBar)
        
        NSLayoutConstraint.activate([
            customSearchToolBar.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor),
            customSearchToolBar.leadingAnchor.constraint(
                equalTo: view.leadingAnchor),
            customSearchToolBar.trailingAnchor.constraint(
                equalTo: view.trailingAnchor),
            customSearchToolBar.heightAnchor.constraint(
                equalToConstant: 44),
        ])
    }

    //MARK: Search related
    private func changeTextViewSearch(activate: Bool) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.customSearchToolBar.alpha = activate ? 1 : 0
        }
        isInSearchMode = activate
        if activate {
            self.updatePrimaryActionsForEdit(isActive: true)
            self.customSearchToolBar.beginSearchSession()
        } else {
            self.updatePrimaryActionsForEdit(isActive: false)
            self.customSearchToolBar.endSearchSession()
            self.customSearchToolBar.enterBackgroundState()
        }
    }
    
    //MARK: Layout
    private func handleKeyboard(_ event: KeyboardListener.Event) {
        UIView.animate(
            withDuration: event.duration,
            delay: 0,
            options: event.curve
        ) {
            switch event.presence {
            case .hidden, .accessoryOnly:
                self.textInputView.textView.contentInset.bottom = 0

            case .full:
                self.textInputView.textView.contentInset.bottom = event.intersection.height
            }
            self.textInputView.textView.scrollIndicatorInsets = self.textInputView.textView.contentInset
        }
    }
    
    func updatePrimaryActionsForEdit(isActive: Bool){
        if isActive {
            guard navigationItem.rightBarButtonItems == [doneButton] else {
                navigationItem.setRightBarButtonItems([doneButton], animated: true)
                return
            }
        } else {
            guard navigationItem.rightBarButtonItems == [textSearchButton] else {
                self.navigationItem.rightBarButtonItems = [textSearchButton]
                return
            }
        }
    }

    
    //MARK: System
    ///Assigning string values to labels.
    private func configureLabels(){
        doneButton.title = "system.done".localized
        
        textInputView.updatePlaceholder()
        customSearchToolBar.configureLabels()
    }
    private func updateFont(){
        textInputView.updateFont(font: .selectedFont.withSize(.subtitleSize))
    }
}

    //MARK: Actions
extension InspectView {
    
    ///Finishes current first responder session.
    @objc private func doneButTap(sender: Any){
        if isInSearchMode {
            changeTextViewSearch(activate: false)
        } else {
            view.endEditing(true)
        }
    }

    @objc func appDidEnterBackground(sender: Notification){
        if textInputView.textView.isFirstResponder {
            textInputView.textView.resignFirstResponder()
        } else if customSearchToolBar.isFirstResponder() {
            customSearchToolBar.enterBackgroundState()
        }
    }
    @objc private func searchButDidTap(sender: UIBarButtonItem){
        changeTextViewSearch(activate: true)
    }


}

//MARK: - TextViewDelegate
extension InspectView: PlaceholderTextViewDelegate {
    ///Reloading input accessory view, finishing search session or cleaning error glyph.
    func textViewDidBeginEditing(sender: UITextView)  { }
    func textViewDidEndEditing(sender: UITextView)    { }
    func textViewDidChange(sender: UITextView)        { }

    func presentErrorAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    func textViewDidScroll() {
        if isInSearchMode {
            textInputView.textView.setNeedsDisplay()
        }
    }
    
    func currentSeparatorSymbol() -> String? {
        viewModel.textSeparator()
    }
    func configurePlaceholderText(sender: UITextView) -> String? {
        viewModel.configureTextPlaceholder()     }
}

extension InspectView: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
