//
//  GameAnimator.swift
//  Learny
//
//  Created by Star Lord on 15/10/2025.
//
//TODO: Polish

import UIKit

protocol GameAnimatorDelegate: AnyObject {
    func requiresDetailsSession(for cell: CollectionViewLastCell)

}


// Handles all animations related to game cells.
final class GameAnimator {
    
    
    weak var collectionView: UICollectionView?
    weak var delegate: GameAnimatorDelegate?

    init(collectionView: UICollectionView, delegate: GameAnimatorDelegate) {
        self.collectionView = collectionView
        self.delegate = delegate
    }

    // MARK: - Public Methods
    
    /// //Flipping cell for 180 degree to reveal the infromation on the back side. Returning 'error' animation in ceses, when there is nothing to reveal.
    ///1. Adjusting Transform3D property of cell's contnent view layer.
    ///2. Changing text label visibility.
    func flip(cell: CollectionViewCell, frontToBack: Bool, swapTextOnly: Bool = false) {
        guard cell.isAccessable else {
            shake(cell: cell)
            return
        }

        collectionView?.isUserInteractionEnabled = false

        let duration = 0.3
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 5000.0

        let liftTransform = CATransform3DTranslate(perspective, 0, -50, 0)
        let initialTransform = CATransform3DTranslate(perspective, 0, 0, 0)

        let halfwayClockwise = CATransform3DRotate(perspective, .pi / 2, 0, 1, 0)
        let finalClockwise = CATransform3DRotate(perspective, .pi, 0, 1, 0)
        let oppositeHalfway = CATransform3DRotate(perspective, .pi / 2, 0, 1, 0)
        let oppositeFinal = CATransform3DRotate(perspective, 0, 0, 1, 0)

        let animator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
            if frontToBack {
                UIView.animate(withDuration: duration / 2) {
                    cell.cardView.layer.transform = CATransform3DConcat(halfwayClockwise, liftTransform)
                } completion: { _ in
                    UIView.animate(withDuration: duration / 2) {
                        cell.cardView.layer.transform = CATransform3DConcat(finalClockwise, initialTransform)
                    }
                }
            } else {
                UIView.animate(withDuration: duration / 2) {
                    cell.cardView.layer.transform = CATransform3DConcat(oppositeHalfway, liftTransform)
                } completion: { _ in
                    UIView.animate(withDuration: duration / 2) {
                        cell.cardView.layer.transform = CATransform3DConcat(oppositeFinal, initialTransform)
                    }
                }
            }
        }

        animator.addCompletion { [weak self] _ in
            guard let self = self else { return }
            if swapTextOnly {
                // Display flip: swap text only, don't toggle isFlipped
                let word = cell.word.text ?? ""
                let translation = cell.translationBacksideLabel.text ?? ""
                cell.word.text = translation
                cell.translationBacksideLabel.text = word
            } else {
                // Single cell flip: toggle isFlipped and adjust visibility
                cell.isFlipped.toggle()
                cell.word.isHidden = frontToBack
                cell.imageView.isHidden = frontToBack
                cell.translationBacksideLabel.alpha = frontToBack ? 1 : 0
            }
            self.collectionView?.isUserInteractionEnabled = true
        }

        animator.startAnimation()
    }

    /// Shrink cell (scale down slightly)
    func shrinkIn(cell: UICollectionViewCell, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            cell.transform = cell.transform.scaledBy(x: 0.95, y: 0.95)
        } completion: { _ in
            completion?()
        }
    }
    
    /// Restore cell scale
    func shrinkOut(cell: UICollectionViewCell) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
            cell.transform = .identity
        }
    }
    
    /// Shake cell for error / inaccessible
    func shake(cell: UICollectionViewCell) {
        let animation = CAKeyframeAnimation.shakingAnimation()
        cell.layer.add(animation, forKey: "shake")
    }
    
    /// Animate transition from cell to a view controller
    func transition(from cell: CollectionViewCell, to controller: UIViewController, in parentVC: UIViewController, completion: (() -> Void)? = nil) {
        
    
        //Ensure, that user can't trigger cell flip while aniamtion persist
        collectionView?.isUserInteractionEnabled = false

        //Applying flip(rotate) animation
        let rotation = CABasicAnimation.rotationAnimation()
        cell.layer.add(rotation, forKey: "rotation")
        
        let slide = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            cell.transform = cell.transform.translatedBy(x: 0, y: -50)
            cell.cardShadowView.layer.shadowOpacity = 0
            cell.cardView.subviews.forEach { $0.alpha = 0 }
        }
        
        
        slide.addCompletion { _ in
            let neededScale: CGFloat
            let neededLength = parentVC.view.bounds.height
            
            if UIDevice.isIPadDevice {
                neededScale = parentVC.view.bounds.width / cell.bounds.width / 2
            } else {
                neededScale = parentVC.view.bounds.width / cell.bounds.width
            }
            
            let scaleAndSlide = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
                let scale = CGAffineTransform(scaleX: neededScale, y: neededScale)
                let slideTransform = CGAffineTransform(translationX: 0, y: neededLength)
                cell.transform = scale.concatenating(slideTransform)
            }
            
            scaleAndSlide.addCompletion { _ in
                cell.layer.removeAllAnimations()
                rotation.fromValue = Double.pi
                rotation.toValue = 0
                cell.layer.add(rotation, forKey: "rotation")
            }
            
            scaleAndSlide.startAnimation()
            
            parentVC.present(controller, animated: UIDevice.isIPadDevice, completion: completion)

        }
        
        slide.startAnimation()
    }
    
    //Cell Centering
    func centerCellManually(at indexPath: IndexPath) {
        
        collectionView?.isUserInteractionEnabled = false
        collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.collectionView?.isUserInteractionEnabled = true            
        })
    }

    func centerLastCell(at indexPath: IndexPath, cell: CollectionViewLastCell){
        self.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self] in
            self?.delegate?.requiresDetailsSession(for: cell)
        })
    }
    
}
