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
    func restoreCell()
//    func requestDetailsPresentation(for indexPath: IndexPath, from cell: CollectionViewCell)
//    func requestCentering(at indexPath: IndexPath)
    
}

enum GameInteractionIntent {
//    case flip(CollectionViewCell)
    case showDetails(IndexPath, CollectionViewCell)
//    case center(IndexPath)
    case cancelInteraction
}

final class GameInteractionCoordinator: NSObject {

    // MARK: Dependencies
    weak var collectionView: UICollectionView?
    weak var animator: GameAnimator?
//    private let adapter: GameDataAdapter
    weak var delegate: GameInteractionCoordinatorDelegate?
    
    let events = PassthroughSubject<GameInteractionIntent, Never>()

    // MARK: Interaction State
    private var selectedIndexPath: IndexPath?
    private var tappedToScrollIndexPath: IndexPath?
    private var longPressActivated = false
    private var longPressEligible = false
    private let isOneSideMode: Bool

    private var gesture = UILongPressGestureRecognizer()
    
    // MARK: Init
    init(
//        collectionView: UICollectionView,
//        animator: GameAnimator,
//        adapter: GameDataAdapter,
        isOneSideMode: Bool
    ) {
//        self.collectionView = collectionView
//        self.animator = animator
//        self.adapter = adapter
        self.isOneSideMode = isOneSideMode
        super.init()
//        configureGesture()
    }
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

//    func restoreCardCell() {
//        let animation = restoreAnimation()
//        animation.addCompletion { _ in
//            self.selectedIndexPath = nil
//        }
//        animation.startAnimation()
//    }
    
    func viewDidSceroll() {
        guard tappedToScrollIndexPath == nil else {
            let cell = collectionView?.cellForItem(at: tappedToScrollIndexPath!)
//            let longGesture = collectionView?.gestureRecognizers?.first(where: { $0 is UILongPressGestureRecognizer })
            //                longGesture?.state = .cancelled

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
            print("selectedIndexPath is not nill")
            if let cardCell = collectionView?.cellForItem(at: selectedIndexPath!) as? CollectionViewCell  {
                
//                let longGesture = collectionView?.gestureRecognizers?.first(where: { $0 is UILongPressGestureRecognizer })
//                longGesture?.state = .cancelled
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
        

//        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
//        let centerY = collectionView.bounds.height / 2
//        let center = CGPoint(x: centerX, y: centerY)
//
//        if let index = collectionView.indexPathForItem(at: center){
//            guard let item = dataSource.itemIdentifier(for: index), let _ = item.data as? HashableWordsEntity else { return }
//            let _ = self.scrolledCards.insert(dataSource.itemIdentifier(for: index))
//        }
            
        
//        guard selectedTime == nil else {
//            guard let indexPath = collectionView.indexPathForItem(at: center),
//                  let viewModel = viewModel else { return }
//            var snapshot = dataSource.snapshot()
//            let items = snapshot.itemIdentifiers(inSection: .cards)
//        
//            if items.count - 5 <= indexPath.item {
//                    snapshot.appendItems(viewModel.dataForDiffableDataSource(), toSection: .cards)
//                    dataSource.apply(snapshot, animatingDifferences: false)
//            }
//            return
//        }
//    }

    }

}

extension GameInteractionCoordinator {

    func configureGesture() -> UILongPressGestureRecognizer {
//        guard let collectionView else { return }

        let gesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longGestureDidPress(sender:))
        )
        gesture.minimumPressDuration = 0.01
        gesture.delegate = self

        self.gesture = gesture
//        collectionView.visibleCells.forEach {
//            $0.addGestureRecognizer(gesture)
//        }

//        collectionView.addGestureRecognizer(gesture)
        return gesture
    }
    
//    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
//        print("tracks")
//        guard
//            let collectionView = collectionView,
//            let indexPath = collectionView.indexPathForItem(
//                at: gesture.location(in: collectionView)
//            ),
//            let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
//        else { return }
//
////        guard
////            let collectionView,
////            let cell = gesture.view as? CollectionViewCell,
////            let indexPath = collectionView.indexPath(for: cell)
////        else { return }
//
//        let centerIndexPath = centerCellIndexPath()
//
//        switch gesture.state {
//
//        case .began:
//            handleBegan(
//                cell: cell,
//                indexPath: indexPath,
//                centerIndexPath: centerIndexPath
//            )
//
//        case .ended:
//            handleEnded(
//                cell: cell,
//                indexPath: indexPath,
//                centerIndexPath: centerIndexPath,
//                gesture: gesture
//            )
//
//        case .cancelled:
//            resetState()
//
//        default:
//            break
//        }
//    }
//
//    private func handleBegan(
//        cell: CollectionViewCell,
//        indexPath: IndexPath,
//        centerIndexPath: IndexPath?
//    ) {
//
//        longPressActivated = false
//        longPressEligible = isOneSideMode
//
//        guard indexPath == centerIndexPath else {
//            tappedToScrollIndexPath = indexPath
//            return
//        }
//
//        selectedIndexPath = indexPath
//
//        animator?.shrinkIn(cell: cell) { [weak self] in
//            guard let self else { return }
//            self.longPressActivated = true
//        }
//    }
//
//    private func handleEnded(
//        cell: CollectionViewCell,
//        indexPath: IndexPath,
//        centerIndexPath: IndexPath?,
//        gesture: UILongPressGestureRecognizer
//    ) {
//
//        guard indexPath == centerIndexPath else {
////            delegate?.requestCentering(at: indexPath)
//            centerCellManually(at: indexPath)
//            return
//        }
//
//        let location = gesture.location(in: cell)
//        guard cell.bounds.contains(location) else {
//            animator?.shrinkOut(cell: cell)
//            resetState()
//            return
//        }
//
//        if longPressEligible || longPressActivated {
//
////            guard let word = adapter.word(at: indexPath) else { return }
////            delegate?.requestDetailsPresentation(for: indexPath, from: cell)
//            self.selectedIndexPath = indexPath
//            self.events.send(.showDetails(indexPath, cell))
//            
//
//        } else {
//
//            animator?.flip(cell: cell, frontToBack: !cell.isFlipped)
//            animator?.shrinkOut(cell: cell)
//        }
//
//        resetState()
//    }
//
    @objc func longGestureDidPress(sender: UILongPressGestureRecognizer) {
        guard let cell = resolveCell(from: sender) as? CollectionViewCell,
              let indexPath = collectionView?.indexPath(for: cell) else { return }
//        guard
//            let collectionView = collectionView,
//            let indexPath = collectionView.indexPathForItem(
//                at: sender.location(in: collectionView)
//            ),
//            let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
//        else { return }

        
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
    
    private var centerPoint: CGPoint {
        guard let collectionView else { return .zero }
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        let centerY = collectionView.bounds.height / 2
        return CGPoint(x: centerX, y: centerY)
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
            centerCellManually(at: indexPath)
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
    
    private func resetGestureState() {
        selectedIndexPath = nil
        tappedToScrollIndexPath = nil
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

    private func centerCellManually(at indexPath: IndexPath) {

        collectionView?.isUserInteractionEnabled = false
        collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.collectionView?.isUserInteractionEnabled = true
            self.tappedToScrollIndexPath = nil
            
        })
    }


//    private func resetState() {
////        selectedIndexPath = nil
//        tappedToScrollIndexPath = nil
//        longPressActivated = false
//        longPressEligible = false
//    }


}

//extension GameInteractionCoordinator: UIGestureRecognizerDelegate {
//
//    func gestureRecognizer(
//        _ gestureRecognizer: UIGestureRecognizer,
//        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
//    ) -> Bool {
//        guard let collectionView else { return true }
//        if other == collectionView.panGestureRecognizer &&
//           (collectionView.isDragging || collectionView.isDecelerating) {
//            return false
//        }
//        return true
//    }
//}
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


extension GameInteractionCoordinator: GameInteractionCoordinatorDelegate {
    func restoreCell() {
        let animation = restoreAnimation()
        animation.addCompletion { _ in
            self.selectedIndexPath = nil
        }
        animation.startAnimation()
    }
}
