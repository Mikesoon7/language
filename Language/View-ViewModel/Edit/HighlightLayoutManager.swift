//
//  HighlightLayoutManager.swift
//  Language
//
//  Created by Star Lord on 17/09/2023.
//

import Foundation
import UIKit

class HighlightLayoutManager: NSLayoutManager {
    
    var highlightRanges: [NSRange] = []
    var currentRange: NSRange = .init()
    var textView: UITextView?
    
    private let textViewInsets:  UIEdgeInsets
    
    required init(textInsets: UIEdgeInsets) {
        self.textViewInsets = textInsets
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Adjust corner radius for passed rect and drawing glypth with passed colour.
    private func drawBackground(with colour: UIColor, rect: CGRect){
        guard let graphicContext = UIGraphicsGetCurrentContext() else { return }
        
        colour.setFill()
        
        let roundedRectangle = UIBezierPath(roundedRect: rect, cornerRadius: 8)
        graphicContext.addPath(roundedRectangle.cgPath)
        graphicContext.drawPath(using: .fill)
    }
    
    
    ///Creates coloured rectengles for existing ranges. If range exist and selected as well, changes glyph size and colour.
    //Due to textView offset, we need to add left inset to glyph rectangle.
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)

        guard !highlightRanges.isEmpty else { return }
        
        highlightRanges.forEach { range in
            let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            guard let container = self.textContainer(forGlyphAt: glyphRange.location, effectiveRange: nil) else { return }

            self.enumerateEnclosingRects(
                forGlyphRange: glyphRange,
                withinSelectedGlyphRange: NSMakeRange(NSNotFound, 0),
                in: container
            ) { (rect, _) in
                //Adding adjust points for selected state.
                let adjustPoints: CGFloat = range == self.currentRange ? 5 : 0
                //Calculating Rect by adding inset and adjust points.
                let adjustedRect = CGRect(
                    x: rect.origin.x + self.textViewInsets.left - (adjustPoints / 2),
                    y: rect.origin.y + origin.y - adjustPoints / 2,
                    width: rect.size.width + adjustPoints,
                    height: rect.size.height + adjustPoints
                )
                
                if range != self.currentRange {
                    self.drawBackground(with: .searchModeSelection, rect: adjustedRect)
                } else {
                    self.drawBackground(with: .systemOrange, rect: adjustedRect)
                }
            }
        }
    }
    func updateSelectedRange(_ range: NSRange){
        self.currentRange = range
        self.textView?.setNeedsDisplay()
    }
}

