//
//  SearchToolBarView.swift
//  Language
//
//  Created by Star Lord on 16/09/2023.
//

import Foundation
import UIKit

class CustomSearchToolBar: UIToolbar {
    //MARK: Properties
    private var searchResultsByRange = [NSRange]()
    private var searchResultPointerIndex = Int()
    
    private var currentRange: NSRange = .init()

    var textView: UITextView?
    var layoutManager: HighlightLayoutManager?

    //MARK: Views
    let searchBar: UISearchBar = UISearchBar()

    var doneButton = UIBarButtonItem()
    var chevronUp = UIBarButtonItem()
    var chevronDown = UIBarButtonItem()

    //MARK: Inherited
    required init(textView: UITextView, layoutManager: HighlightLayoutManager) {
        self.textView = textView
        self.layoutManager = layoutManager
        super.init(frame: .zero)
        configureToolBar()
        configureSearchBar()
        configureView()
        configureLabels()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: External methods
    func configureLabels(){
        searchBar.placeholder = "edit.searchPlaceholder".localized
    }
    func beginSearchSession(){
        self.searchBar.becomeFirstResponder()
    }
    func endSearchSession() {
        layoutManager?.highlightRanges = []
        layoutManager?.currentRange = NSRange()
        searchBar.text = nil
        textView?.setNeedsDisplay()
    }

    private func configureToolBar(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.barStyle = .default

    }
    //MARK: Configure Subviews
    private func configureSearchBar(){
        searchBar.delegate = self
        searchBar.contentMode = .scaleAspectFit
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7),
            searchBar.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9)
        ])
    }
    private func configureView(){
        chevronUp = UIBarButtonItem(
            image: UIImage(systemName: "chevron.up"),
            style: .done,
            target: self,
            action: #selector(navigateToPreviousResult(sender: )))
        chevronUp.tintColor = .label
        chevronDown = UIBarButtonItem(
            image: UIImage(systemName: "chevron.down"),
            style: .done,
            target: self,
            action: #selector(navigateToNextResult(sender: )))
        chevronDown.tintColor = .label


        let searchButton = UIBarButtonItem(customView: searchBar)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.items = [searchButton, spaceButton, chevronUp, chevronDown]

        self.sizeToFit()
        self.barStyle = .default
    }

    //MARK: System methods.
    ///Finding matches and assinging founded ranges to local array.
    private func findSearchResults(for searchText: String) {
        guard let textView = textView else { return}
        searchResultsByRange.removeAll()

        guard let text = textView.text, !text.isEmpty, !searchText.isEmpty else {
            return
        }

        var searchStartIndex = text.startIndex
        while let range = text.range(of: searchText, options: .caseInsensitive, range: searchStartIndex..<text.endIndex) {
            let nsRange = NSRange(range, in: text)
            searchResultsByRange.append(nsRange)

            searchStartIndex = range.upperBound
        }
    }
    ///Update textView visible scope to ensure, that selected word in center
    private func scrollRangeToVisibleCenter(range: NSRange) {
        guard let textView = textView else { return }
        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer

        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        var boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

        let offset1 = textView.contentOffset
        let midPoint = textView.center.y / 2


        if boundingRect.origin.y <= offset1.y {
            let newY = boundingRect.origin.y - midPoint
            if newY <= 0 {
                boundingRect.origin.y = 0
            } else {
                boundingRect.origin.y -= midPoint
            }
        } else {
            let newY = boundingRect.origin.y - offset1.y

            if textView.center.y / 2 >= newY {
                boundingRect.origin.y += newY
            } else{
                boundingRect.origin.y += midPoint
            }
        }
        textView.scrollRectToVisible(boundingRect, animated: true)
    }
    ///Sending selected range to LayoutManager and scrolling to it.
    private func updateSelectedRange(_ range: NSRange){
        scrollRangeToVisibleCenter(range: range)
        layoutManager?.currentRange = range
        textView?.setNeedsDisplay()
//        layoutManager?.updateSelectedRange(range)
    }
}
//MARK: SearchBar delegate.
extension CustomSearchToolBar: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        findSearchResults(for: searchText)
        print("searchBar textFifChange")
        layoutManager?.highlightRanges = searchResultsByRange

        
        
        if searchResultsByRange.count != 0 {
            if searchResultPointerIndex + 1 > searchResultsByRange.count {
                searchResultPointerIndex = searchResultsByRange.count - 1
            }
            textView?.backgroundColor = .searchModeBackground
            updateSelectedRange(searchResultsByRange[searchResultPointerIndex])
        } else {
            searchResultPointerIndex = 0 
            textView?.backgroundColor = .systemBackground
            textView?.setNeedsDisplay()
        }

    }
}
//MARK: - Actions
extension CustomSearchToolBar{
    @objc func navigateToNextResult(sender: Any) {
        guard searchResultsByRange.count > searchResultPointerIndex + 1 else {
            return
        }
        searchResultPointerIndex += 1
        updateSelectedRange(searchResultsByRange[searchResultPointerIndex])
    }
    @objc func navigateToPreviousResult(sender: Any) {
        guard searchResultPointerIndex != 0  else {
            return
        }
        searchResultPointerIndex -= 1
        updateSelectedRange(searchResultsByRange[searchResultPointerIndex])
    }
}

//class CustomSearchToolBar: UIStackView {
//    //MARK: Properties
//    var searchResultsByRange = [NSRange]()
//    var searchResultPointerIndex = Int()
//
//    var textView: UITextView?
//    var layoutManager: HighlightLayoutManager?
//
//    //MARK: Views
////    let searchBar: UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 240, height: 35))
//    let searchBar: UISearchBar = UISearchBar()
//
////    var doneButton = UIBarButtonItem()
////    var chevronUp = UIBarButtonItem()
////    var chevronDown = UIBarButtonItem()
//
//    var doneButton = UIButton()
//    var chevronUp = UIButton()
//    var chevronDown = UIButton()
//
//
//    //MARK: Inherited
//    required init(textView: UITextView, layoutManager: HighlightLayoutManager) {
//        self.textView = textView
//        self.layoutManager = layoutManager
//        super.init(frame: .zero)
//        configureView()
//        configureSearchBar()
//        configureLabels()
//
//    }
//
//    required init(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
////    required init?(coder: NSCoder) {
////        fatalError("init(coder:) has not been implemented")
////    }
//
//    //MARK: External methods
//    func configureLabels(){
//        searchBar.placeholder = "edit.searchPlaceholder".localized
//    }
//    func beginSearchSession(){
//        self.searchBar.becomeFirstResponder()
//    }
//    func endSearchSession() {
//        layoutManager?.highlightRanges = []
//        layoutManager?.currentRange = NSRange()
//        searchBar.text = nil
//        textView?.setNeedsDisplay()
//    }
//
//    //MARK: Configure Subviews
//    private func configureSearchBar(){
//        searchBar.delegate = self
//        searchBar.contentMode = .scaleAspectFit
//        searchBar.translatesAutoresizingMaskIntoConstraints = false
//
//        self.addSubview(searchBar)
//        NSLayoutConstraint.activate([
//            searchBar.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7),
//            searchBar.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.9)
//        ])
//    }
//    private func configureView(){
//        chevronUp = {
//            let button = UIButton()
//            button.setImage(UIImage(systemName: "chevron.up")?
//                .withConfiguration(UIImage.SymbolConfiguration(weight: .medium)),
//                            for: .normal)
//
//            button.sizeToFit()
//            button.tintColor = .label
//            button.backgroundColor = .clear
//            return button
//        }()
//        chevronDown = {
//            let button = UIButton()
//            button.setImage(UIImage(systemName: "chevron.down")?
//                .withConfiguration(UIImage.SymbolConfiguration(weight: .medium)),
//                            for: .normal)
//
//            button.sizeToFit()
//            button.tintColor = .label
//            button.backgroundColor = .clear
//            return button
//        }()
//
//        self.distribution = .equalSpacing
//        self.alignment = .fill
//        self.axis = .vertical
//        self.addSubviews(searchBar, chevronUp, chevronDown)
//        self.backgroundColor = .secondarySystemBackground
//        }
//
//    //MARK: System methods.
//    ///Finding matches and assinging founded ranges to local array.
//    private func findSearchResults(for searchText: String) {
//        guard let textView = textView else { return}
//        searchResultsByRange.removeAll()
//
//        guard let text = textView.text, !text.isEmpty, !searchText.isEmpty else {
//            return
//        }
//
//        var searchStartIndex = text.startIndex
//        while let range = text.range(of: searchText, options: .caseInsensitive, range: searchStartIndex..<text.endIndex) {
//            let nsRange = NSRange(range, in: text)
//            searchResultsByRange.append(nsRange)
//
//            searchStartIndex = range.upperBound
//        }
//    }
//    ///Update textView visible scope to ensure, that selected word in center
//    private func scrollRangeToVisibleCenter(range: NSRange) {
//        guard let textView = textView else { return }
//        let layoutManager = textView.layoutManager
//        let textContainer = textView.textContainer
//
//        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
//        var boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
//
//        let offset1 = textView.contentOffset
//        let midPoint = textView.center.y / 2
//
//
//        if boundingRect.origin.y <= offset1.y {
//            let newY = boundingRect.origin.y - midPoint
//            if newY <= 0 {
//                boundingRect.origin.y = 0
//            } else {
//                boundingRect.origin.y -= midPoint
//            }
//        } else {
//            let newY = boundingRect.origin.y - offset1.y
//
//            if textView.center.y / 2 >= newY {
//                boundingRect.origin.y += newY
//            } else{
//                boundingRect.origin.y += midPoint
//            }
//        }
//        textView.scrollRectToVisible(boundingRect, animated: true)
//    }
//    ///Sending selected range to LayoutManager and scrolling to it.
//    private func updateSelectedRange(_ range: NSRange){
//        scrollRangeToVisibleCenter(range: range)
//        layoutManager?.updateSelectedRange(range)
//    }
//}
////MARK: SearchBar delegate.
//extension CustomSearchToolBar: UISearchBarDelegate {
//
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        findSearchResults(for: searchText)
//        layoutManager?.highlightRanges = searchResultsByRange
//
//        if searchResultsByRange.count != 0 {
//            if searchResultPointerIndex + 1 > searchResultsByRange.count {
//                searchResultPointerIndex = searchResultsByRange.count - 1
//            }
//            textView?.backgroundColor = .searchModeBackground
//            updateSelectedRange(searchResultsByRange[searchResultPointerIndex])
//        } else {
//            textView?.backgroundColor = .systemBackground
//            textView?.setNeedsDisplay()
//        }
//
//    }
//}
////MARK: - Actions
//extension CustomSearchToolBar{
//    @objc func navigateToNextResult(sender: Any) {
//        guard searchResultsByRange.count > searchResultPointerIndex + 1 else {
//            return
//        }
//        searchResultPointerIndex += 1
//        updateSelectedRange(searchResultsByRange[searchResultPointerIndex])
//    }
//    @objc func navigateToPreviousResult(sender: Any) {
//        guard searchResultPointerIndex != 0  else {
//            return
//        }
//        searchResultPointerIndex -= 1
//        updateSelectedRange(searchResultsByRange[searchResultPointerIndex])
//    }
//}
