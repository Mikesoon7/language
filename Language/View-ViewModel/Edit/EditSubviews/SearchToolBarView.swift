//
//  SearchToolBarView.swift
//  Language
//
//  Created by Star Lord on 16/09/2023.
//

import Foundation
import UIKit

class CustomSearchToolBar: UIView {
    
    //MARK: Properties
    private var searchResultsByRange = [NSRange]()
    private var searchResultPointerIndex = Int()
    
    private let inset = CGFloat(5)

    var textView: UITextView?
    var layoutManager: HighlightLayoutManager?

    //MARK: Views
    private lazy var searchBar = {
        let view = UISearchBar()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundImage = UIImage()
        return view
    }()
    
    private lazy var chevronUpBut = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        button.addTarget(self, action: #selector(navigateToPreviousResult(sender: )), for: .touchUpInside)
        return button
    }()
    private lazy var chevronDonwBut  = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.contentMode = .scaleAspectFit
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.addTarget(self, action: #selector(navigateToNextResult(sender: )), for: .touchUpInside)
        return button
    }()
    
    //MARK: Inherited
    required init(textView: UITextView, layoutManager: HighlightLayoutManager) {
        print("searchview" )
        self.textView = textView
        self.layoutManager = layoutManager
        super.init(frame: .zero)
        configureView()
        configureLabels()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Configure Subviews
    private func configureView(){
        addSubviews(chevronUpBut, chevronDonwBut, searchBar)
        
        NSLayoutConstraint.activate([
            chevronDonwBut.topAnchor.constraint(equalTo: topAnchor),
            chevronDonwBut.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            chevronDonwBut.bottomAnchor.constraint(equalTo: bottomAnchor),
            chevronDonwBut.widthAnchor.constraint(equalTo: chevronDonwBut.heightAnchor),
            
            chevronUpBut.trailingAnchor.constraint(equalTo: chevronDonwBut.leadingAnchor),
            chevronUpBut.topAnchor.constraint(equalTo: topAnchor),
            chevronUpBut.bottomAnchor.constraint(equalTo: bottomAnchor),
            chevronUpBut.widthAnchor.constraint(equalTo: chevronUpBut.heightAnchor),
            
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            searchBar.trailingAnchor.constraint(equalTo: chevronUpBut.leadingAnchor),
        ])
        self.backgroundColor = .secondarySystemBackground
    }

    //MARK: External methods
    func configureLabels(){
        searchBar.placeholder = "edit.searchPlaceholder".localized
    }
    func beginSearchSession(){
        self.searchBar.becomeFirstResponder()
    }
    func endSearchSession() {
        layoutManager?.clearContentHiglight()
        searchResultsByRange = []
        searchResultPointerIndex = 0
        searchBar.text = nil
        textView?.setNeedsDisplay()
    }
    func enterBackgroundState(){
        self.searchBar.resignFirstResponder()
    }
    func isFirstResponder() -> Bool{
        return searchBar.isFirstResponder
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
        
        let glyphRect = getGlyphRectangle(for: range, from: textView)
        
        let visibleHeight = textView.bounds.height - textView.contentInset.bottom - textView.contentInset.top - (textView.inputAccessoryView?.bounds.height ?? 40)
        
        let yOffset = glyphRect.origin.y - min(glyphRect.origin.y, (visibleHeight / 2))
        let newOffset = CGPoint(x: textView.contentOffset.x, y: yOffset)
        
        textView.setContentOffset(newOffset, animated: true)
        
        //I think no one will reach to this point, but this is some kind of a tricky and strange bug, which took me 6 hours to solve. TextView will stop scrolling on a halfWay if you won't add this 2 lines beyond.
        textView.isScrollEnabled = false
        textView.isScrollEnabled = true
        
    }
    
    ///Asks layoutManager of textView for rectangle, which matches to the passed range.
    private func getGlyphRectangle(for range: NSRange, from textView: UITextView) -> CGRect {
        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer
        
        let glyphRange = layoutManager.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        let glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

        return glyphRect
    }

    ///Sending selected range to LayoutManager and scrolling to it.
    private func updateSelectedRange(_ range: NSRange){
        self.layoutManager?.currentRange = range
        self.scrollRangeToVisibleCenter(range: range)
        self.textView?.setNeedsDisplay()
    }


    //MARK: Selected index related.
    ///Updating selected index in order to match existing one or find closest to visible scope.
    private func validateSelectedRange(){
        guard let textView = textView else { return }
        if searchResultsByRange.indices.contains(searchResultPointerIndex), isRangeInVisibleScope(textView: textView, range: searchResultsByRange[searchResultPointerIndex]) {
                return
            
        } else {
            searchResultPointerIndex = closestVisibleRangeIndex(from: searchResultsByRange, in: textView)
        }
        
    }

    private func isRangeInVisibleScope(textView: UITextView, range: NSRange) -> Bool{
        let visibleScope = textViewVisibleScope(textView: textView)
        let glyphRect = getGlyphRectangle(for: range, from: textView)
                
        return visibleScope.contains(glyphRect)
    }
    
    ///Returns textview visible rect.
    private func textViewVisibleScope(textView: UITextView) -> CGRect {
        let visibleRect = CGRect(x: textView.contentOffset.x,
                                 y: textView.contentOffset.y,
                                 width: textView.bounds.width,
                                 height: textView.bounds.height - textView.contentInset.bottom - textView.contentInset.top)

        return visibleRect
    }
    
    ///Returns index of the closest to visible scope range.
    private func closestVisibleRangeIndex(from ranges: [NSRange], in textView: UITextView?) -> Int {
        guard let textView = textView else { return 0 }
        let visibleRect = textViewVisibleScope(textView: textView)
        
        let visibleMidY = visibleRect.midY
        
        var closestRangeIndex = 0
        var smallestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for (index, range) in ranges.sorted(by: {$0.location < $1.location}).enumerated() {
            print(range.location)
            let glyphRect = getGlyphRectangle(for: range, from: textView)
            
            let distance = abs(glyphRect.midY - visibleMidY)
            
            print("distance = \(distance)")
            if distance <= smallestDistance {
                smallestDistance = distance
                closestRangeIndex = index
            } else {
                break
            }
        }
        
        return closestRangeIndex
    }
    
}
//MARK: SearchBar delegate.
extension CustomSearchToolBar: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        findSearchResults(for: searchText)
        layoutManager?.highlightRanges = searchResultsByRange

        guard !searchResultsByRange.isEmpty else {
            searchResultPointerIndex = 0
            textView?.backgroundColor = .systemBackground
            textView?.setNeedsDisplay()
            return
        }
        validateSelectedRange()

        textView?.backgroundColor = .searchModeBackground
        updateSelectedRange(searchResultsByRange[searchResultPointerIndex])

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

