//
//  GameCollectionViewLayout.swift
//  Learny
//
//  Created by Star Lord on 27/01/2025.
//
//  REFACTORING STATE: CHECKED

import Foundation
import UIKit


class CustomFlowLayout: UICollectionViewFlowLayout {
    let scaleForTransition: CGFloat = 0.8
    var centeredCellIndexPath: IndexPath?

    ///Cheks whether the main screen is in split mode or not
    private func isInSplitScreenMode() -> Bool {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return false
        }
        return window.bounds.width < UIScreen.main.bounds.width
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { true }

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }

        let isSplitScreen = isInSplitScreenMode()

        let widthToHeightRatio = collectionView.bounds.width / collectionView.bounds.height
        let isWidthMainAnchor = isSplitScreen && widthToHeightRatio < 0.5
        
        let viewsBounds = collectionView.superview?.bounds ?? collectionView.bounds
        
        let anchorConstant: CGFloat = {
            if UIDevice.isIPadDevice && viewsBounds.height > viewsBounds.width && !isSplitScreen{
                return viewsBounds.width
            } else {
                return viewsBounds.height
            }
        }()
        
        
        let itemHeight = (isWidthMainAnchor
                          ? (viewsBounds.width * 0.8 * 1.5)
                          : (anchorConstant * 0.66)
        )
        
        let itemWidth = (isWidthMainAnchor
                         ? viewsBounds.width * 0.8
                         : itemHeight * 0.66)
        
        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
    
        scrollDirection = .horizontal

        let horizontalInset = (collectionView.bounds.width - itemWidth) / 2
        let verticalInset = (collectionView.bounds.height - itemHeight) / 2
        sectionInset = UIEdgeInsets(top: verticalInset - 40,
                                    left: horizontalInset,
                                    bottom: verticalInset + 40,
                                    right: horizontalInset)

        minimumLineSpacing = 30
        minimumInteritemSpacing = 10
        collectionView.decelerationRate = .fast
    }
    

    override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        guard let collectionView = collectionView, centeredCellIndexPath == nil else {
            super.prepare(forAnimatedBoundsChange: oldBounds)
            return
        }
        
        let superview = collectionView.superview?.bounds
        let centerX = collectionView.contentOffset.x + (superview ?? collectionView.bounds).width / 2
        let centerY = (superview ?? collectionView.bounds).height / 2
        
                
        if let centerCellIndex = collectionView.indexPathForItem(at: CGPoint(x: centerX, y: centerY)) {
            centeredCellIndexPath = centerCellIndex
        } else {
            if let cell = collectionView.visibleCells.last {
                centeredCellIndexPath = collectionView.indexPath(for: cell)
            }
        }
        super.prepare(forAnimatedBoundsChange: oldBounds)
    }
    
    override func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        centeredCellIndexPath = nil
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard
            let indexPath = centeredCellIndexPath,
            let attributes = layoutAttributesForItem(at: indexPath),
            let collectionView = collectionView
        else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
        return CGPoint(
            x: attributes.center.x - collectionView.bounds.width / 2,
            y: attributes.center.y
        )
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = collectionView, !collectionView.bounds.isEmpty else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }

        let midX = collectionView.bounds.width / 2
        let proposedContentOffsetCenterX = proposedContentOffset.x + midX

        guard let layoutAttributes = layoutAttributesForElements(in: collectionView.bounds) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }

        
        let closestAttribute = layoutAttributes.min(by: {
            abs($0.center.x - proposedContentOffsetCenterX) < abs($1.center.x - proposedContentOffsetCenterX)
        })

        guard let targetAttribute = closestAttribute else {
            
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }

        let targetOffsetX = targetAttribute.center.x - midX
        let indexPath = targetAttribute.indexPath
    
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let centerY = collectionView.bounds.height / 2
        let center = CGPoint(x: centerX, y: centerY)
        
        let centeredCell = collectionView.indexPathForItem(at: center)
        
        if velocity.x > 0 {
            if let nextAttribute = layoutAttributes.first(where: { $0.indexPath.item == (centeredCell ?? indexPath).item  + 1 }) {
                return CGPoint(x: nextAttribute.center.x - midX, y: proposedContentOffset.y)
            }
        } else if velocity.x < 0 {
            if let previousAttribute = layoutAttributes.first(where: { $0.indexPath.item == (centeredCell ?? indexPath).item - 1 }) {
                return CGPoint(x: previousAttribute.center.x - midX, y: proposedContentOffset.y)
            }
        }
        

        return CGPoint(x: targetOffsetX, y: proposedContentOffset.y)
    }



    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            guard let collectionView = collectionView,
                  let attributesArray = super.layoutAttributesForElements(in: rect) else {
                return nil
            }

            let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2

            return attributesArray.compactMap { attribute in
                guard attribute.representedElementCategory == .cell,
                      let newAttribute = attribute.copy() as? UICollectionViewLayoutAttributes else {
                    return attribute
                }

                let distanceToCenter = abs(newAttribute.center.x - centerX)
                let scaleFactor = max(scaleForTransition, 1 - (distanceToCenter / collectionView.bounds.width) * (1 - scaleForTransition))

                newAttribute.transform3D = CATransform3DScale(newAttribute.transform3D, scaleFactor, scaleFactor, 1)
                return newAttribute
            }
        }
    
}
