//
//  TextInputView.swift
//  Language
//
//  Created by Star Lord on 12/08/2023.
//

import UIKit

protocol PlaceholderTextViewDelegate: AnyObject{
    func textViewDidBeginEditing()
    func textViewDidEndEditing()
    func configurePlaceholderText() -> String?
}

final class TextInputView: UIView {
    let textContainerInsets: UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)
    private lazy var layoutManager = HighlightLayoutManager(textInsets: self.textContainerInsets)
    private let textContainer = NSTextContainer()
    private let textStorage = NSTextStorage()

    weak var delegate: PlaceholderTextViewDelegate?
    
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
        textView.backgroundColor = .clear
        
        textView.layer.masksToBounds = true
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 0.5
        
        textView.textContainerInset = .init(top: 5, left: 5, bottom: 5, right: 5)
        textView.allowsEditingTextAttributes = false
        textView.tintColor = .label
        textView.font = .selectedFont.withSize(17)
        return textView
    }()
    
    private let pasteButton: UIButton = {
        let button = UIButton()
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blur.isUserInteractionEnabled = false
        button.addSubview(blur)
        button.setImage(UIImage(systemName: "doc.on.clipboard"), for: .normal)
        button.tintColor = .label
        button.bringSubviewToFront(button.imageView ?? UIImageView())
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: Inherited
    convenience init(delegate: PlaceholderTextViewDelegate){
        self.init(frame: .zero, delegate: delegate)
    }
    
    init(frame: CGRect, delegate: PlaceholderTextViewDelegate) {
        self.delegate = delegate
        super.init(frame: frame)
        configureView()
        configureTableView()
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
        super.init(coder: coder)
        fatalError("Coder wasn's imported")
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIScene.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIScene.didActivateNotification, object: nil)
    }
    
    //MARK: View SetUp
    private func configureView(){
        self.layer.cornerRadius = 9

        self.backgroundColor = .secondarySystemBackground
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    //MARK: Subviews SetUp
    private func configureTableView() {
        layoutManager.addTextContainer(textContainer)
        
        textStorage.addLayoutManager(layoutManager)
        
        textView.delegate = self

        self.addSubviews(placeholderLabel, textView, pasteButton)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor ),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: textView.contentInset.top + textView.textContainerInset.top),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: textView.textContainerInset.left * 2),
            
            pasteButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -10),
            pasteButton.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -10),
        ])
        pasteButton.addTarget(self, action: #selector(pasteButtonDidTap(sender:)), for: .touchUpInside)
    }
    
    
    
    
    //MARK: System
    private func pasteTextToTextView(){
        guard let text = UIPasteboard.general.string, text != "" else {
            return
        }
        textView.text = text
        updatePasteButtonVisability()
        updatePlaceholderVisability()
    }
    ///Change alpha of paste button, reflected the textView text value.
    private func updatePasteButtonVisability(){
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.pasteButton.alpha = self.textView.text.isEmpty ? 1 : 0
        }
    }
    ///Change placeholder visibility, reflected by textView text value
    private func updatePlaceholderVisability(){
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    ///Changes placeholder text with provided by the delegate.
    func updatePlaceholder(){
        textView.font = .selectedFont.withSize(17)
        placeholderLabel.text = delegate?.configurePlaceholderText() ?? ""
        placeholderLabel.font = .selectedFont.withSize(17)
        placeholderLabel.sizeToFit()
    }
    
    func highlightError(_ range: NSRange){
        textView.scrollRangeToVisible(range)
        textView.selectedRange = range
        layoutManager.errorRange = range
        textView.setNeedsDisplay()
    }
    
    //MARK: Action
    @objc func pasteButtonDidTap(sender: Any){
        pasteTextToTextView()
    }
    @objc func appDidEnterBackground(sender: Notification){
        shouldBecomeActive = textView.isFirstResponder
        textView.resignFirstResponder()
    }
    @objc func appDidActivate(sender: Notification){
        if shouldBecomeActive {
            textView.becomeFirstResponder()
        }
    }

}
extension TextInputView: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        layoutManager.clearContentHiglight()
        textView.setNeedsDisplay()
        //Showing button for keyboard dismissing
        guard let delegate = self.delegate else { return }
        delegate.textViewDidBeginEditing()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let delegate = self.delegate else { return }
        delegate.textViewDidEndEditing()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        updatePlaceholderVisability()
        updatePasteButtonVisability()
    }
}

class CustomTextView: UITextView{
    
    var customToolBar: UIToolbar = UIToolbar()

    var isTextUpdateRequired: Bool = false
    
    private var softReturnButton = UIBarButtonItem()
    
    convenience init(){
        self.init(frame: .zero, textContainer: nil)
    }
    required override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        addKeyboardToolbar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func paste(_ sender: Any?) {
        if let pasteboardText = UIPasteboard.general.string {
            let attributes = self.typingAttributes
            let attributedString = NSAttributedString(string: pasteboardText, attributes: attributes)
            
            textStorage.insert(attributedString, at: selectedRange.location)
            
            selectedRange = NSRange(location: selectedRange.location + pasteboardText.count, length: 0)
            delegate?.textViewDidChange?(self)
        }
    }
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        if isTextUpdateRequired {
            softReturnButton.title = "system.newLine".localized
            isTextUpdateRequired = false
        }
        return true
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
        
        let visibleHeight = self.bounds.height - self.contentInset.bottom - self.contentInset.top - (self.inputAccessoryView?.bounds.height ?? 40)
        
        let yOffset = glyphRect.origin.y - min(glyphRect.origin.y, (visibleHeight / 2))
        let newOffset = CGPoint(x: self.contentOffset.x, y: yOffset)
        
        self.setContentOffset(newOffset, animated: true)

        self.isScrollEnabled = false
        self.isScrollEnabled = true
    }
    
    private func addKeyboardToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolbar.sizeToFit()
        
        softReturnButton = UIBarButtonItem(
            title: "system.newLine".localized,
            style: .done,
            target: self,
            action: #selector(softReturnPressed)
        )
        softReturnButton.tintColor = .label
        
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), softReturnButton]
        
        self.inputAccessoryView = toolbar
        self.customToolBar = toolbar

    }
    
    @objc private func softReturnPressed() {
        if let selectedRange = self.selectedTextRange {
            self.replace(selectedRange, withText: "\r") // Insert soft return
        }
    }
}
