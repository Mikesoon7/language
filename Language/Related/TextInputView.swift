//
//  TextInputView.swift
//  Language
//
//  Created by Star Lord on 12/08/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit

@objc protocol PlaceholderTextViewDelegate: AnyObject{
    func textViewDidBeginEditing()
    func textViewDidEndEditing()
    func textViewDidChange()
    func currentSeparatorSymbol() -> String?
    func configurePlaceholderText() -> String?
    func presentErrorAlert(alert: UIAlertController)
    
    @objc optional func textViewDidScroll()
}

final class TextInputView: UIView {
    
    private var textContainerInsets: UIEdgeInsets
    private var textContainer   = NSTextContainer()
    private let textStorage     = NSTextStorage()

     lazy var layoutManager = HighlightLayoutManager(textInsets: self.textContainerInsets)
    private weak var delegate: PlaceholderTextViewDelegate?
    
    private var shouldBecomeActive = false
    
    //MARK: Views
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .timesNewRoman.withSize(17)
        label.textColor = .lightGray
        label.numberOfLines = 0
        return label
    }()
    
    lazy var textView: CustomTextView = {
        var textView = CustomTextView(frame: .zero, textContainer: textContainer)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 9
        textView.layer.cornerCurve = .continuous
        textView.backgroundColor = .clear
        
        textView.layer.masksToBounds = true
        textView.textContainerInset = textContainerInsets
        textView.allowsEditingTextAttributes = false
        textView.tintColor = .label
        textView.font = .selectedFont.withSize(17)
        return textView
    }()
    
    
    //MARK: AccessoryView
    var customAccessoryView : UIView = UIView()
    private let customAccessoryViewHeight : CGFloat = 50


    private let newLineButton: UIButton = {
        let button = UIButton()
        button.setUpAccessoryViewButton(image: nil, title: "system.newLine".localized)
        button.tag = 1
        return button
    }()
    
    private let scanButton: UIButton = {
        let button = UIButton()
        button.setUpAccessoryViewButton(image: .init(systemName: "text.viewfinder"))
        button.tag = 2
        return button
    }()
    
    private let translateButton : UIButton = {
        let button = UIButton()
        button.setUpAccessoryViewButton(image: .init(systemName: "character.phonetic"))
        button.layer.cornerRadius = 3
        button.layer.masksToBounds = true
        button.backgroundColor = .systemGray2
        button.translatesAutoresizingMaskIntoConstraints = true
        button.frame.size = CGSize(width: 40, height: 40)
        return button
    }()
    
    private let pasteButton: UIButton = {
        let button = UIButton()
        button.setUpAccessoryViewButton(image: .init(systemName: "doc.on.clipboard"))
        button.tag = 3
        return button
    }()
    
    private lazy var separatorButton: UIButton = {
        let button = UIButton()
        button.setUpAccessoryViewButton(image: nil, title: delegate?.currentSeparatorSymbol())
        button.tag = 4
        return button
    }()
    
    private lazy var translationAccessoryItemGroup: UIBarButtonItemGroup = {
        let buttonGroup = UIBarButtonItemGroup(barButtonItems: [UIBarButtonItem(customView: translateButton)], representativeItem: nil)
        return buttonGroup
    }()
    

    //MARK: Inherited
    convenience init(delegate: PlaceholderTextViewDelegate){
        self.init(frame: .zero, delegate: delegate)
    }
    
    init(frame: CGRect, delegate: PlaceholderTextViewDelegate,
         textContainer: NSTextContainer? = NSTextContainer(),
         textContainerInsets: UIEdgeInsets? = .init(top: 10, left: 5, bottom: 5, right: 5)) {
        self.delegate = delegate
        self.textContainer = textContainer!
        self.textContainerInsets = textContainerInsets!
        super.init(frame: frame)
        configureView()
        configureTableView()
        configureAccessoryView()
        updatePlaceholder()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground(sender: )),
            name: UIScene.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidActivate(sender: )),
            name: UIScene.didActivateNotification,
            object: nil
        )
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("Coder wasn's imported")
//        super.init(coder: coder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIScene.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIScene.didActivateNotification, object: nil)
    }
    
    //MARK: View SetUp
    private func configureView(){
        self.layer.cornerRadius = 9

        self.addCenterShadows()
        self.backgroundColor = .secondarySystemBackground
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //MARK: Subviews SetUp
    private func configureTableView() {
        layoutManager.addTextContainer(textContainer)
        
        textStorage.addLayoutManager(layoutManager)
        
        textView.delegate = self

        self.addSubviews(placeholderLabel, textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor ),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, 
                                                  constant: textView.textContainerInset.top ),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor,
                                                      constant: textView.textContainerInset.left * 2),
        ])
    }
    
    private func configureAccessoryView(){
        newLineButton.addTarget(self, action: #selector(softReturnDidPress), for: .touchUpInside)
        scanButton.addAction(UIAction.captureTextFromCamera(responder: textView, identifier: .paste), for: .touchUpInside)
        translateButton.addTarget(self, action: #selector(translationButtonDidPress), for: .touchUpInside)
        pasteButton.addTarget(self, action: #selector(pasteButtonDidPress), for: .touchUpInside)
        separatorButton.addTarget(self, action: #selector(separatorButtonDidPress), for: .touchUpInside)
        
        if UIDevice.isIPadDevice {
            let item = textView.inputAssistantItem
            
            let line = UIBarButtonItem(customView: newLineButton)
            let scan = UIBarButtonItem(customView: scanButton)
            let separate = UIBarButtonItem(customView: separatorButton)
            
            let group = UIBarButtonItemGroup(
                barButtonItems: [line, scan, separate],
                representativeItem: nil )
            item.trailingBarButtonGroups = [group]
            textView.inputAssistantItem.trailingBarButtonGroups = [group]
        } else {
            let view = CustomInputAccessoryView(button: newLineButton,
                                                scanButton: scanButton,
                                                pasteButton: pasteButton,
                                                translateButton: translateButton,
                                                separateButton: separatorButton,
                                                frame: CGRect(origin: .zero, 
                                                              size: .init(width: 200,
                                                                          height: customAccessoryViewHeight))
            )
            textView.inputAccessoryView = view
            self.customAccessoryView = view
        }
    }
    
    //MARK: Placeholder
    ///Change placeholder visibility, reflected by textView text value
    func updatePlaceholderVisability(){
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    ///Changes placeholder text with provided by the delegate.
    func updatePlaceholder(){
        textView.font = .selectedFont.withSize(17)
        placeholderLabel.text = delegate?.configurePlaceholderText() ?? ""
        placeholderLabel.font = .selectedFont.withSize(17)
        newLineButton.setTitle("system.newLine".localized, for: .normal)
        placeholderLabel.sizeToFit()
    }
    //MARK: Error Highlight
    func highlightError(_ range: NSRange){
        textView.scrollRangeToVisible(range)
        textView.selectedRange = range
        layoutManager.errorRange = range
        textView.setNeedsDisplay()
    }
    
    // MARK: Translation Logic
    private func removeTranslationButton(){
        textView.inputAssistantItem.trailingBarButtonGroups.removeAll(where: {$0 == translationAccessoryItemGroup})

        if let view = customAccessoryView as? CustomInputAccessoryView {
            // Use the built-in Translate feature (by showing UIReferenceLibraryViewController)
            view.removeTranslationButton()
        }
    }

    private func dispalayTranslationButton() {
        textView.inputAssistantItem.trailingBarButtonGroups.append(translationAccessoryItemGroup)
        
        if let view = customAccessoryView as? CustomInputAccessoryView {
            view.dispalayTranslationButton()
        }
    }

    func clearTextView(){
        self.textView.text = ""
        self.textViewDidChange(textView)
        self.textView.resignFirstResponder()
    }
    
    func validateText() -> String?{
        guard let text = self.textView.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            let insertTextAllert = UIAlertController.alertWithAction(alertTitle: "textAlert".localized,
                                                                     alertMessage: "textInfo".localized,
                                                                     alertStyle: .actionSheet,
                                                                     action1Title: "system.agreeInformal".localized,
                                                                     action1Handler: { _ in self.textView.becomeFirstResponder() },
                                                                     action1Style: .cancel,
                                                                     sourceView: self,
                                                                     sourceRect: nil)

            delegate?.presentErrorAlert(alert: insertTextAllert)
            return nil
        }
        return text
    }

    
    //MARK: Action
    @objc func appDidEnterBackground(sender: Notification){
        shouldBecomeActive = textView.isFirstResponder
        textView.resignFirstResponder()
    }
    
    @objc func appDidActivate(sender: Notification){
        if shouldBecomeActive {
            textView.becomeFirstResponder()
        }
    }
    
    //Buttons
    @objc private func softReturnDidPress() {
        if let selectedRange = textView.selectedTextRange {
            textView.replace(selectedRange, withText: "\r") // Insert soft return
        }
    }
    
    @objc private func pasteButtonDidPress(){
            guard let pasteboardText = UIPasteboard.general.string else { return }

            let attributes = textView.typingAttributes
            let selectedRange = textView.selectedRange
            let attributedString = NSAttributedString(string: pasteboardText, attributes: attributes)

            textView.textStorage.beginEditing()

            if selectedRange.length > 0 {
                textView.textStorage.replaceCharacters(in: selectedRange, with: attributedString)
            } else {
                textView.textStorage.insert(attributedString, at: selectedRange.location)
            }

            let newCursorPosition = selectedRange.location + attributedString.length
            textView.selectedRange = NSRange(location: newCursorPosition, length: 0)

        
            textView.textStorage.endEditing()
            textView.delegate?.textViewDidChange?(textView)

    }
    @objc private func separatorButtonDidPress(){
        guard let separator = delegate?.currentSeparatorSymbol() else { return }

        let attributes = self.textView.typingAttributes
        let selectedRange = textView.selectedRange
        let attributedString = NSAttributedString(string: " \(separator) ", attributes: attributes)
        
        if selectedRange.length > 0 {
            textView.textStorage.replaceCharacters(in: selectedRange, with: attributedString)
        } else {
            textView.textStorage.insert(attributedString, at: selectedRange.location)
        }

        textView.selectedRange = NSRange(location: selectedRange.location + separator.count + 2, length: 0)
        textView.delegate?.textViewDidChange?(textView)
    }
    
    @objc private func translationButtonDidPress(){
        let wordRange: UITextRange? = textView.selectedTextRange
        
        let errorAnimation: CAKeyframeAnimation = .shakingAnimation()
        
        guard let wordRange = wordRange, 
                let word = textView.text(in: wordRange),
                let parentVC = self.nearestViewController() else {
            self.textView.layer.add(errorAnimation, forKey: "animation")
            return
        }
        
        let refVC = UIReferenceLibraryViewController(term: word)
        parentVC.present(refVC, animated: true)
    }
    
}

//MARK: - TextView Delegate
extension TextInputView: UITextViewDelegate{
    //Since textInputView is textView's delegate, we use custom delegate to respond on textView notification within another view.
    func textViewDidBeginEditing(_ textView: UITextView) {
        layoutManager.clearContentHiglight()
        textView.setNeedsDisplay()
        
        updatePlaceholderVisability()
        guard let delegate = self.delegate else { return }
        delegate.textViewDidBeginEditing()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        guard let delegate = self.delegate else { return }
        delegate.textViewDidEndEditing()
        updatePlaceholderVisability()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisability()
        delegate?.textViewDidChange()
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        let selectedRange = textView.selectedRange
        
        if let text = textView.text, selectedRange.length > 0 {
            dispalayTranslationButton()
        } else {
            removeTranslationButton()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.textViewDidScroll?()
    }
}

class CustomTextView: UITextView{
    
    convenience init(){
        self.init(frame: .zero, textContainer: nil)
    }
    required override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    //MARK: System
    override open func paste(_ sender: Any?) {
        guard let pasteboardText = UIPasteboard.general.string else { return }

        let attributes = typingAttributes
        let selectedRange = selectedRange
        let attributedString = NSAttributedString(string: pasteboardText, attributes: attributes)

        textStorage.beginEditing()

        if selectedRange.length > 0 {
            textStorage.replaceCharacters(in: selectedRange, with: attributedString)
        } else {
            textStorage.insert(attributedString, at: selectedRange.location)
        }

        let newCursorPosition = selectedRange.location + attributedString.length
        self.selectedRange = NSRange(location: newCursorPosition, length: 0)

    
        textStorage.endEditing()
        delegate?.textViewDidChange?(self)
        }
    
    private func getGlyphRectangle(for range: NSRange, from textView: UITextView) -> CGRect {
        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer
        
        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        let glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

        return glyphRect
    }
    
    override func scrollRangeToVisible(_ range: NSRange) {
        let glyphRect = getGlyphRectangle(for: range, from: self)
        
        let visibleHeight = self.bounds.height - self.contentInset.bottom - self.contentInset.top - (self.inputAccessoryView?.bounds.height ?? 44)
        
        let yOffset = glyphRect.origin.y - min(glyphRect.origin.y, (visibleHeight / 2))
        let newOffset = CGPoint(x: self.contentOffset.x, y: yOffset)
        
        self.setContentOffset(newOffset, animated: true)

        self.isScrollEnabled = false
        self.isScrollEnabled = true
    }
}

//MARK: Custom Input View
class CustomInputAccessoryView: UIInputView {
    
    private var subviewsOrderKey = "accessoryViewElementOrder"
    
    private let stackView : UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 5
        view.alignment = .center
        view.distribution = .equalSpacing
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
     
    private var subviewsOrder = [1, 2, 3, 4]
    
    //MARK: Buttons
    var accessoryButton: UIButton
    var scanButton: UIButton
    var pasteButton: UIButton
    var translationButton: UIButton
    var separateButton: UIButton
    
    init(button: UIButton, scanButton: UIButton, pasteButton: UIButton, translateButton: UIButton, separateButton: UIButton, frame: CGRect){
        self.accessoryButton = button
        self.scanButton = scanButton
        self.pasteButton = pasteButton
        self.translationButton = translateButton
        self.separateButton = separateButton

        super.init(frame: frame, inputViewStyle: .default)
        
        setUpStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpStackView(){
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8),
            stackView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
        
        let subviews = [accessoryButton, scanButton, pasteButton, separateButton]
        
        if let order = UserDefaults.standard.array(forKey: subviewsOrderKey) as? [Int] {
            subviewsOrder = order
        }
        
        let sortedButtons = subviews
            .sorted {
                guard let tag1 = subviewsOrder.firstIndex(of: $0.tag),
                      let tag2 = subviewsOrder.firstIndex(of: $1.tag) else {
                    return false
                }
                return tag1 < tag2
            }
        sortedButtons.forEach({
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureDidOccure(_:)))
            stackView.addArrangedSubview($0)
            $0.addGestureRecognizer(panGesture)
        })
    
        
    }

    func dispalayTranslationButton(){
        stackView.addArrangedSubview(translationButton)
    }
    func removeTranslationButton(){
        stackView.removeArrangedSubview(translationButton)
        translationButton.removeFromSuperview()
    }
        
    @objc private func panGestureDidOccure(_ gesture: UIPanGestureRecognizer) {
        guard let draggedView = gesture.view else { return }
        let translation = gesture.translation(in: stackView)
        
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.prepare()
        switch gesture.state {
        case .began:
            impactGenerator.impactOccurred()
            draggedView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            draggedView.layer.opacity = 0.8
        case .changed:
            let location = gesture.location(in: stackView)
            
            
            // Find the nearest subview to the drag location
            if let targetIndex = stackView.arrangedSubviews.firstIndex(where: {
                $0.frame.contains(location) && $0 != draggedView
            }) {
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.stackView.removeArrangedSubview(draggedView)
                    self.stackView.insertArrangedSubview(draggedView, at: targetIndex)
                })
                impactGenerator.impactOccurred()
                gesture.state = .ended
            } else {
                draggedView.transform = CGAffineTransform(translationX: translation.x, y: 0)
            }
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.2) {
                draggedView.transform = .identity
                draggedView.layer.opacity = 1.0
            }
            let orderArray = stackView.arrangedSubviews.map({$0.tag})
            UserDefaults.standard.setValue(orderArray, forKey: subviewsOrderKey)
        default:
            break
        }
    }
    
    
    
}

extension CustomInputAccessoryView: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIButton)
    }
    
}
