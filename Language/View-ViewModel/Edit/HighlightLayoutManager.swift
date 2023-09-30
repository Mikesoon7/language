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
//
//    override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
//        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
//        print("draw glyphs worked before guard")
//
//        guard !highlightRanges.isEmpty else { return }
//
//        let firstGlyphRange = highlightRanges.first(where: {$0.lowerBound >= glyphsToShow.lowerBound})
//        print(firstGlyphRange)
//
//        print("draw glyphs worked after guard")
//        highlightRanges.forEach { range in
//            let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
//            guard let container = self.textContainer(forGlyphAt: glyphRange.location, effectiveRange: nil) else { return }
//
//            self.enumerateEnclosingRects(
//                forGlyphRange: glyphRange,
//                withinSelectedGlyphRange: NSMakeRange(NSNotFound, 0),
//                in: container
//            ) { (rect, _) in
//                //Adding adjust points for selected state.
//                let adjustPoints: CGFloat = range == self.currentRange ? 5 : 0
//                //Calculating Rect by adding inset and adjust points.
//                let adjustedRect = CGRect(
//                    x: rect.origin.x + self.textViewInsets.left - (adjustPoints / 2),
//                    y: rect.origin.y + origin.y - adjustPoints / 2,
//                    width: rect.size.width + adjustPoints,
//                    height: rect.size.height + adjustPoints
//                )
//
//                if range != self.currentRange {
//                    self.drawBackground(with: .searchModeSelection, rect: adjustedRect)
//                } else {
//                    self.drawBackground(with: .systemOrange, rect: adjustedRect)
//                }
//            }
//        }
//    }
    
    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
        
        guard !highlightRanges.isEmpty else { return }

        // Calculate the visible glyph range with some padding before and after
        let padding = 10 // Adjust this value to your needs
        let visibleGlyphRange = NSRange(location: max(0, glyphsToShow.location - padding),
                                        length: glyphsToShow.length + 2 * padding)
        
        highlightRanges.forEach { range in
            let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
            
            // Check if this glyphRange intersects with the visible range
            if NSIntersectionRange(glyphRange, visibleGlyphRange).length > 0 {
                
                guard let container = self.textContainer(forGlyphAt: glyphRange.location, effectiveRange: nil) else { return }
                
                self.enumerateEnclosingRects(
                    forGlyphRange: glyphRange,
                    withinSelectedGlyphRange: NSMakeRange(NSNotFound, 0),
                    in: container
                ) { (rect, _) in
                    // Your drawing logic here
                    let adjustPoints: CGFloat = range == self.currentRange ? 5 : 0
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
    }

    
    
    
    ///Creates coloured rectengles for existing ranges. If range exist and selected as well, changes glyph size and colour.
    //Due to textView offset, we need to add left inset to glyph rectangle.
//    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
//        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
////        print(glyphsToShow)
//        print("\(glyphsToShow.location) at origin \(origin)" )
//
////        print("\(glyphsToShow.upperBound) and \(glyphsToShow.lowerBound)")
////        print("worked before guard")
//        guard !highlightRanges.isEmpty else { return }
//
//
////        let currentHilglightArray =
////        print("worked after guard")
//        highlightRanges.forEach { range in
//            let glyphRange = self.glyphRange(forCharacterRange: range, actualCharacterRange: nil)
//            guard let container = self.textContainer(forGlyphAt: glyphRange.location, effectiveRange: nil) else { return }
//
//            self.enumerateEnclosingRects(
//                forGlyphRange: glyphRange,
//                withinSelectedGlyphRange: NSMakeRange(NSNotFound, 0),
//                in: container
//            ) { (rect, _) in
//                //Adding adjust points for selected state.
//                let adjustPoints: CGFloat = range == self.currentRange ? 5 : 0
//                //Calculating Rect by adding inset and adjust points.
//                let adjustedRect = CGRect(
//                    x: rect.origin.x + self.textViewInsets.left - (adjustPoints / 2),
//                    y: rect.origin.y + origin.y - adjustPoints / 2,
//                    width: rect.size.width + adjustPoints,
//                    height: rect.size.height + adjustPoints
//                )
//
//                if range != self.currentRange {
//                    self.drawBackground(with: .searchModeSelection, rect: adjustedRect)
//                } else {
//                    self.drawBackground(with: .systemOrange, rect: adjustedRect)
//                }
//            }
//        }
//    }
//    func updateSelectedRange(_ range: NSRange){
//        self.currentRange = range
//        self.textView?.setNeedsDisplay()
//    }
}

