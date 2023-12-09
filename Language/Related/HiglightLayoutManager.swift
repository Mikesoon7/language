//
//  CustomTextViewLayoutManager.swift
//  Learny
//
//  Created by Star's MacBook Air on 06.11.2023.
//

import Foundation
import UIKit

class HighlightLayoutManager: NSLayoutManager {
    
    var highlightRanges: [NSRange] = []
    var currentRange: NSRange? = .init()
    var errorRange: NSRange? = .init()
        
    private let textViewInsets:  UIEdgeInsets?
    
    required init(textInsets: UIEdgeInsets?) {
        self.textViewInsets = textInsets
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func clearContentHiglight(){
        self.errorRange = nil
        self.currentRange = nil
        self.highlightRanges = []
    }
    
    ///Adjust corner radius for passed rect and drawing glypth with the passed colour.
    private func drawBackground(with colour: UIColor, rect: CGRect){
        guard let graphicContext = UIGraphicsGetCurrentContext() else { return }
        
        colour.setFill()
        
        let roundedRectangle = UIBezierPath(roundedRect: rect, cornerRadius: 8)
        graphicContext.addPath(roundedRectangle.cgPath)
        graphicContext.drawPath(using: .fill)
    }
    
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
        
        let visibleGlyphRange = NSRange(location: max(0, glyphsToShow.location ),
                                        length: glyphsToShow.length + 2 )
        
        if let errorRange = errorRange {
            self.displayErrorGlyph(errorRange: errorRange, visibleGlyphRange: visibleGlyphRange, origin: origin)
        } else if !highlightRanges.isEmpty {
            highlightRanges.forEach { range in
                drawRange(range, with: (range == self.currentRange ? .systemOrange : .searchModeSelection), inVisibleGlyphs: visibleGlyphRange, at: origin)
            }
        }
    }

    private func drawRange(_ range: NSRange, with color: UIColor, inVisibleGlyphs visibleGlyphRange: NSRange, at origin: CGPoint) {
        let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
        
        // Check if this glyphRange intersects with the visible range
        if NSIntersectionRange(glyphRange, visibleGlyphRange).length > 0 {
            
            guard let container = self.textContainer(forGlyphAt: glyphRange.location, effectiveRange: nil) else { return }
            
            self.enumerateEnclosingRects(
                forGlyphRange: glyphRange,
                withinSelectedGlyphRange: NSMakeRange(NSNotFound, 0),
                in: container
            ) { (rect, _) in
                let adjustPoints: CGFloat = (range == self.currentRange || range == self.errorRange) ? 5 : 0
                let adjustedRect = CGRect(
                    x: rect.origin.x + (self.textViewInsets?.left ?? 0 ) - (adjustPoints / 2),
                    y: rect.origin.y + origin.y - adjustPoints / 2,
                    width: rect.size.width + adjustPoints,
                    height: rect.size.height + adjustPoints
                )
                self.drawBackground(with: color, rect: adjustedRect)
            }
        }
    }
    private func displayErrorGlyph(errorRange: NSRange, visibleGlyphRange: NSRange, origin: CGPoint) {
        if NSIntersectionRange(errorRange, visibleGlyphRange).length > 0 {
            drawRange(errorRange, with: .systemRed, inVisibleGlyphs: visibleGlyphRange, at: origin)
        }
    }
//    private func displaySearchGlyph(
}
    
    
    
