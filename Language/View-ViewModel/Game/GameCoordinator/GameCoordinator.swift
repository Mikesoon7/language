//
//  GameCoordinator.swift
//  Learny
//
//  Created by Star Lord on 15/10/2025.
//
//TODO: Polish

import UIKit
import Combine

protocol GameInteractionCoordinatorDelegate: AnyObject {
    func restoreCell(completion: (() -> Void)?)
}

enum GameInteractionIntent {
    case showDetails(IndexPath, CollectionViewCell)
    case cancelInteraction
}

final class GameInteractionCoordinator: NSObject {

    // MARK: Dependencies
    weak var collectionView: UICollectionView?
    weak var animator: GameAnimator?
    weak var delegate: GameInteractionCoordinatorDelegate?
    
    let events = PassthroughSubject<GameInteractionIntent, Never>()

    // MARK: Interaction State
    private var selectedIndexPath: IndexPath?
    private var tappedToScrollIndexPath: IndexPath?
    private var longPressActivated = false
    private var longPressEligible = false
    private let isOneSideMode: Bool

    private var gesture = UILongPressGestureRecognizer()
    
    // MARK: Inherited
    init( isOneSideMode: Bool ) {
        self.isOneSideMode = isOneSideMode
        super.init()
    }
    
    
    //MARK: Animations
    ///Restores the initial state of the cards
    func restoreAnimation() -> UIViewPropertyAnimator{
        guard let index = selectedIndexPath,
              let cell = collectionView?.cellForItem(at: index) as? CollectionViewCell
        else {
            return UIViewPropertyAnimator()
        }
        
        let dimming = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut){
            cell.transform = .identity
            cell.cardView.subviews.forEach { view in
                view.alpha = 1
            }
            cell.translationBacksideLabel.alpha = cell.isFlipped ? 1 : 0
            cell.cardShadowView.layer.shadowOpacity = cell.shadowOpacity
        }
        dimming.addCompletion { _ in
            cell.layer.removeAllAnimations()
            self.collectionView?.isUserInteractionEnabled = true
        }
        return dimming
    }

    func stopTrackingGestures() {
        gesture.isEnabled = false
        resetGestureState()
    }
    
    func viewDidSceroll() {
        guard tappedToScrollIndexPath == nil else {
//            let cell = collectionView?.cellForItem(at: tappedToScrollIndexPath!)

            self.gesture.state = .cancelled
            
            
            if let selectedCell = selectedIndexPath, let cardCell = collectionView?.cellForItem(at: selectedCell) as? CollectionViewCell  {
                guard !cardCell.isFlipped else {
                    animator?.flip(cell: cardCell, frontToBack: !cardCell.isFlipped)
                    self.tappedToScrollIndexPath = nil
                    self.selectedIndexPath = nil
                    return
                }
            }
            self.tappedToScrollIndexPath = nil
            self.selectedIndexPath = nil

            return
        }
        
        guard selectedIndexPath == nil else {
            if let cardCell = collectionView?.cellForItem(at: selectedIndexPath!) as? CollectionViewCell  {
                
                self.gesture.state = .cancelled

                
                animator?.shrinkOut(cell: cardCell)
                
                guard !cardCell.isFlipped else {
                    animator?.flip(cell: cardCell, frontToBack: !cardCell.isFlipped)
                    selectedIndexPath = nil
                    return
                }
            }
            selectedIndexPath = nil
            return
        }
    }
}


//MARK: Gestures
extension GameInteractionCoordinator {

    func configureGesture() -> UILongPressGestureRecognizer {
        let gesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longGestureDidPress(sender:))
        )
        gesture.minimumPressDuration = 0.01
        gesture.delegate = self

        self.gesture = gesture
        return gesture
    }
    
    @objc func longGestureDidPress(sender: UILongPressGestureRecognizer) {
        guard sender.isEnabled else { return }
        guard let cell = resolveCell(from: sender) as? CollectionViewCell,
              let indexPath = collectionView?.indexPath(for: cell) else { return }
        
        let centerIndexPath = collectionView?.indexPathForItem(at: centerPoint)
        
        switch sender.state {
        case .began:
            handleGestureBegan(cell: cell, indexPath: indexPath, centerIndexPath: centerIndexPath, sender: sender)
        case .changed:
            break
        case .ended:
            handleGestureEnded(cell: cell, indexPath: indexPath, centerIndexPath: centerIndexPath, sender: sender)
        case .cancelled:
            resetGestureState()
        default:
            restoreCellTransformIfNeeded(cell)
        }
    }
    
    private func resolveCell(from sender: UIGestureRecognizer) -> UICollectionViewCell? {
        guard
            let collectionView = collectionView,
            let indexPath = collectionView.indexPathForItem(
                at: sender.location(in: collectionView)
            ),
            let cell = collectionView.cellForItem(at: indexPath)
        else { return nil }

        if cell is CollectionViewCell {
            return cell
        }
        if let cell = cell as? CollectionViewLastCell,
           let indexPath = collectionView.indexPath(for: cell) {
            tappedToScrollIndexPath = indexPath
            animator?.centerLastCell(at: indexPath, cell: cell)
        }
        return nil
    }
    
    
    private func handleGestureBegan(cell: CollectionViewCell, indexPath: IndexPath, centerIndexPath: IndexPath?, sender: UILongPressGestureRecognizer) {
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.prepare()
        
        longPressActivated = false
        longPressEligible = isOneSideMode

        if indexPath == centerIndexPath {
            selectedIndexPath = indexPath
            animator?.shrinkIn(cell: cell) {
                if sender.state == .began {
                    impactGenerator.impactOccurred()
                    self.longPressEligible = true
                    self.longPressActivated = true
                }
            }
        } else {
            tappedToScrollIndexPath = indexPath
        }
    }
    
    private func handleGestureEnded(cell: CollectionViewCell, indexPath: IndexPath, centerIndexPath: IndexPath?, sender: UILongPressGestureRecognizer) {
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        let point = sender.location(in: cell)
        
        guard indexPath == centerIndexPath else {
            animator?.centerCellManually(at: indexPath)
            self.tappedToScrollIndexPath = nil
            return
        }
        
        if cell.bounds.contains(point) {
            if longPressEligible || longPressActivated {
                impactGenerator.impactOccurred()
                
                events.send(.showDetails(indexPath, cell))
            } else {
                    
                animator?.flip(cell: cell, frontToBack: !cell.isFlipped)
                animator?.shrinkOut(cell: cell)
            }
        } else {
            animator?.shrinkOut(cell: cell)
            selectedIndexPath = nil
        }
    }
    
    //MARK: Gestures assist
    private func resetGestureState() {
        selectedIndexPath = nil
        tappedToScrollIndexPath = nil
    }

    private var centerPoint: CGPoint {
        guard let collectionView else { return .zero }
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let centerY = collectionView.bounds.height / 2
        return CGPoint(x: centerX, y: centerY)
    }
    private func centerCellIndexPath() -> IndexPath? {
        guard let collectionView else { return nil }

        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let centerY = collectionView.bounds.height / 2
        return collectionView.indexPathForItem(at: CGPoint(x: centerX, y: centerY))
    }
    private func restoreCellTransformIfNeeded(_ cell: UICollectionViewCell) {
        guard cell.transform != .identity else { return }
        UIView.animate(withDuration: 0.2) {
            cell.transform = .identity
            self.resetGestureState()
        }
    }
}

//MARK: - Gestures delegate
extension GameInteractionCoordinator: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let collectionView else { return true }

        if otherGestureRecognizer == collectionView.panGestureRecognizer,
           collectionView.isDragging || collectionView.isDecelerating {
            return false
        }
        return true
    }
}

//MARK: GameInteraction Delegate
extension GameInteractionCoordinator: GameInteractionCoordinatorDelegate {
    /// Plays the restore animation, then runs `completion` exactly once.
    func restoreCell(completion: (() -> Void)? = nil) {
        guard let index = selectedIndexPath,
              collectionView?.cellForItem(at: index) is CollectionViewCell else {
            selectedIndexPath = nil
            completion?()
            return
        }
        let animation = restoreAnimation()
        animation.addCompletion { [weak self] _ in
            self?.selectedIndexPath = nil
            completion?()
        }
        animation.startAnimation()
    }
}
