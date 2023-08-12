//
//  TextInputView.swift
//  Language
//
//  Created by Star Lord on 12/08/2023.
//

import UIKit

protocol PlaceholderTextViewDelegate: AnyObject{
    func textViewWillAppear()
    func configurePlaceholderText() -> String
}

final class TextInputView: UIView {
    
    weak var delegate: PlaceholderTextViewDelegate?
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    private let textViewBackgroundView: UIView = {
        let view = UIView()
        view.setUpCustomView()
        view.layer.masksToBounds = true
        return view
    }()
    var textView: CustomTextView = {
        var textView = CustomTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 9
        textView.backgroundColor = .clear
        
        textView.layer.masksToBounds = true
        
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.black.cgColor
        
        textView.textContainerInset = .init(top: 5, left: 5, bottom: 5, right: 5)
        textView.allowsEditingTextAttributes = true
        
        textView.typingAttributes = NSAttributedString.textAttributes(with: .timesNewRoman, ofSize: 17)
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
    
    convenience init(delegate: PlaceholderTextViewDelegate){
        self.init(frame: .zero, delegate: delegate)
    }
    
    init(frame: CGRect, delegate: PlaceholderTextViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        configureView()
        updatePlaceholder()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("Coder wasn's imported")
    }
    //MARK: - View SetUp
    func configureView() {
        self.setUpCustomView()
        self.addSubviews(placeholderLabel, textView, pasteButton)
        
        textView.delegate = self
        
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
    
    private func pasteTextToTextView(){
        guard let text = UIPasteboard.general.string, text != "" else {
            return
        }
        textView.text = text
        updatePasteButtonVisability()
        updatePlaceholderVisability()
    }
    private func updatePasteButtonVisability(){
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.pasteButton.alpha = self.textView.text.isEmpty ? 1 : 0
        }
    }
    private func updatePlaceholderVisability(){
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    func updatePlaceholder(){
        placeholderLabel.attributedText =
            .attributedString(string: delegate?.configurePlaceholderText() ?? "gfgkyg", with: .timesNewRoman, ofSize: 17, foregroundColour: .lightGray)
        placeholderLabel.sizeToFit()
    }
    
    @objc func pasteButtonDidTap(sender: Any){
        pasteTextToTextView()
    }
}
extension TextInputView: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        //Showing button for keyboard dismissing
        guard let delegate = self.delegate else { return }
        delegate.textViewWillAppear()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisability()
        updatePasteButtonVisability()
    }
}
class CustomTextView: UITextView{
    override open func paste(_ sender: Any?) {
        if let pasteboardText = UIPasteboard.general.string {
            let attributes = self.typingAttributes
            let attributedString = NSAttributedString(string: pasteboardText, attributes: attributes)
            
            textStorage.insert(attributedString, at: selectedRange.location)
            
            selectedRange = NSRange(location: selectedRange.location + pasteboardText.count, length: 0)
            delegate?.textViewDidChange?(self)
        }
    }
}



