//
//  GameGestureHandler.swift
//  Learny
//
//  Created by Star Lord on 15/10/2025.
//
//TODO: Polish

//import UIKit
//
//protocol GameGestureHandlerDelegate: AnyObject {
//    func gestureDidRequestFlip(cell: CollectionViewCell)
//    func gestureDidRequestDetail(cell: CollectionViewCell)
//    func gestureDidRequestCentering(at indexPath: IndexPath)
//}
//
//class GameGestureHandler: NSObject {
//
//    private weak var collectionView: UICollectionView?
//    private let animator: GameAnimator
//    weak var delegate: GameGestureHandlerDelegate?
//
//    private var selectedCell: IndexPath?
//    private var isOneSidesMode: Bool
//
//    private var longPressEligible = false
//    private var longPressCompleted = false
//    private var tappedToScrollCell: IndexPath?
//
//    
//    init(collectionView: UICollectionView, animator: GameAnimator) {
//        self.collectionView = collectionView
//        self.animator = animator
//        super.init()
//        setupGesture()
//    }
//
//    // MARK: - Setup
//    private func setupGesture() {
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longGestureDidPress(sender: <#T##UILongPressGestureRecognizer#>)))
//        longPress.minimumPressDuration = 0.01
//        longPress.delegate = self
//        collectionView?.addGestureRecognizer(longPress)
//    }
//
//    // MARK: - Gesture Handling
////    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
////        guard let collectionView = collectionView else { return }
////        let point = sender.location(in: collectionView)
////
////        switch sender.state {
////        case .began:
////            handleBegan(at: point)
////        case .ended:
////            handleEnded(at: point)
////        case .cancelled:
////            resetState()
////        default:
////            break
////        }
////    }
////
////    private func handleBegan(at point: CGPoint) {
////        guard let collectionView = collectionView,
////              let indexPath = collectionView.indexPathForItem(at: point),
////              let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell else { return }
////
////        let centerPoint = CGPoint(
////            x: collectionView.contentOffset.x + collectionView.bounds.width / 2,
////            y: collectionView.bounds.height / 2
////        )
////        let centerIndexPath = collectionView.indexPathForItem(at: centerPoint)
////
////        if indexPath == centerIndexPath {
////            selectedCell = indexPath
////            longPressEligible = true
////            animator.shrinkIn(cell: cell) {
////                self.longPressCompleted = true
////            }
////        } else {
////            tappedToScrollCell = indexPath
////        }
////    }
////
////    private func handleEnded(at point: CGPoint) {
////        guard let collectionView = collectionView,
////              let selectedIndex = selectedCell,
////              let cell = collectionView.cellForItem(at: selectedIndex) as? CollectionViewCell else {
////            // Tap outside or scrolling needed
////            if let scrollIndex = tappedToScrollCell {
////                delegate?.gestureDidRequestCentering(at: scrollIndex)
////                tappedToScrollCell = nil
////            }
////            return
////        }
////
////        let centerPoint = CGPoint(
////            x: collectionView.contentOffset.x + collectionView.bounds.width / 2,
////            y: collectionView.bounds.height / 2
////        )
////        let centerIndexPath = collectionView.indexPathForItem(at: centerPoint)
////
////        if selectedIndex != centerIndexPath {
////            delegate?.gestureDidRequestCentering(at: selectedIndex)
////            return
////        }
////
////        if cell.bounds.contains(point) {
////            if longPressEligible || longPressCompleted {
////                delegate?.gestureDidRequestDetail(cell: cell)
////            } else {
////                delegate?.gestureDidRequestFlip(cell: cell)
////            }
////        } else {
////            animator.shrinkOut(cell: cell)
////        }
////
////        resetState()
////    }
////
////    private func resetState() {
////        selectedCell = nil
////        tappedToScrollCell = nil
////        longPressEligible = false
////        longPressCompleted = false
////    }
//    @objc func longGestureDidPress(sender: UILongPressGestureRecognizer) {
//        guard let cell = resolveCell(from: sender) as? CollectionViewCell,
//              let indexPath = collectionView?.indexPath(for: cell) else { return }
//        
//        let centerIndexPath = collectionView?.indexPathForItem(at: centerPoint)
//        
//        switch sender.state {
//        case .began:
//            handleGestureBegan(cell: cell, indexPath: indexPath, centerIndexPath: centerIndexPath, sender: sender)
//        case .changed:
//            break
//        case .ended:
//            handleGestureEnded(cell: cell, indexPath: indexPath, centerIndexPath: centerIndexPath, sender: sender)
//        case .cancelled:
//            resetGestureState()
//        default:
//            restoreCellTransformIfNeeded(cell)
//        }
//    }
//    
//    private func resolveCell(from sender: UILongPressGestureRecognizer) -> UICollectionViewCell? {
//        if let cell = sender.view as? CollectionViewCell {
//            return cell
//        }
//        if let cell = sender.view as? CollectionViewLastCell,
//           let indexPath = collectionView?.indexPath(for: cell) {
//            tappedToScrollCell = indexPath
//            centerLastCell(at: indexPath, cell: cell)
//        }
//        return nil
//    }
//    
//    private var centerPoint: CGPoint {
//        guard let collectionView else { return .zero }
//        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
//        let centerY = collectionView.bounds.height / 2
//        return CGPoint(x: centerX, y: centerY)
//    }
//    
//    private func handleGestureBegan(cell: CollectionViewCell, indexPath: IndexPath, centerIndexPath: IndexPath?, sender: UILongPressGestureRecognizer) {
//        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
//        impactGenerator.prepare()
//        longPressCompleted = false
//        longPressEligible = isOneSidesMode
//        
//        if indexPath == centerIndexPath {
//            selectedCell = indexPath
//            animator.shrinkIn(cell: cell) {
//                if sender.state == .began {
//                    impactGenerator.impactOccurred()
//                    self.longGestureCannHappen = true
//                    self.longPressCompleted = true
//                }
//            }
//        } else {
//            tappedToScrollCell = indexPath
//        }
//    }
//    
//    private func handleGestureEnded(cell: CollectionViewCell, indexPath: IndexPath, centerIndexPath: IndexPath?, sender: UILongPressGestureRecognizer) {
//        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
//        let point = sender.location(in: cell)
//        
//        guard indexPath == centerIndexPath else {
//            centerCellManually(at: indexPath)
//            return
//        }
//        
//        if cell.bounds.contains(point) {
//            if longPressEligible || longPressCompleted {
//                impactGenerator.impactOccurred()
//                if let item = dataSource.itemIdentifier(for: indexPath) as? HashableWordsEntity {
//                    let controller = configureDetailedVCFor(cell: item)
//                    animator.transition(from: cell, to: controller, in: self)
//                }
//            } else {
//                animator.flip(cell: cell, frontToBack: !cell.isFlipped)
//                animator.shrinkOut(cell: cell)
//            }
//        } else {
//            animator.shrinkOut(cell: cell)
//            selectedCell = nil
//        }
//    }
//    
//    private func resetGestureState() {
//        selectedCell = nil
//        tappedToScrollCell = nil
//    }
//    
//    private func restoreCellTransformIfNeeded(_ cell: UICollectionViewCell) {
//        guard cell.transform != .identity else { return }
//        UIView.animate(withDuration: 0.2) {
//            cell.transform = .identity
//            self.resetGestureState()
//        }
//    }
//    
//
//}
//
//// MARK: - UIGestureRecognizerDelegate
//extension GameGestureHandler: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}
