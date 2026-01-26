//
//  CollectionViewCoordinator.swift
//  Learny
//
//  Created by Star Lord on 29/12/2025.
//
//MARK: Polished


import Foundation
import UIKit

struct SingleModeCellData: Hashable {
    var identifier = UUID()

    var word: String
    var definition: String
    
    var imageDetails: ImageDetailsCheck?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: SingleModeCellData, rhs: SingleModeCellData) -> Bool {
        lhs.identifier == rhs.identifier &&
        lhs.imageDetails == rhs.imageDetails
    }
    
    //Checking wether the data empty
    var isValid: Bool {
        let hasText =
            !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            !definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        let hasImage = imageDetails?.originalImage != nil

        return hasText || hasImage
    }


}
protocol CollectionViewCallBack: AnyObject {
    func wordDidType        (id: UUID, text: String)
    func definitionDidType   (id: UUID, text: String)
    func nameDidType        (text: String)
    
    func enteredEditingMode()
    func exitedEditingMode()
    
    func requestedImagePicker(id: UUID)
    func requestedDeletion(id: UUID)
}


protocol SingleModeTextDelegate: AnyObject {
    func didTapAddImage     (id: UUID)
    
    func wordDidType        (id: UUID, text: String)
    func definitionDidType  (id: UUID, text: String)

    func textViewDidBeginEditing()
    func textViewDidEndEditing()
}

protocol SingleModeNameDelegate: AnyObject {
    func didTypeName(text: String)
    
    func nameFieldDidBeginEditing()
    func nameFieldDidEndEditing()
}

protocol SingleModeCellActionDelegate: AnyObject {
    func panningBegan(for cell: UICollectionViewCell)

    func panningEnded(active: Bool)

    func deleteButtonDidTap(for cell: UICollectionViewCell, id: UUID)
    
    func didBeginEditing(cell: UICollectionViewCell)
    
    func requestedScrollToItem(at index: IndexPath)
}

enum SingleModeSection: Hashable {
    case main
    case name
}

enum CollectionItem: Hashable {
    case entry(SingleModeCellData)
    case name(String)
}

final class CollectionViewAdapter: NSObject {
    
    weak var eventHandler: CollectionViewCallBack?
    weak var actionDelegate: SingleModeCellActionDelegate?
    

    private(set) var dataSource: UICollectionViewDiffableDataSource<SingleModeSection, CollectionItem>!

    
    private var name: String!

    func update(_ data: [SingleModeCellData], name: String? = nil) {
        if let name = name {
            self.name = name
        }
        
        apply(
            entries: data,
            showName: !(name == nil)
        )
    }
    
    func insertAndScrollTo(
        entry: SingleModeCellData,
        animating: Bool = true
    ) {

        var snapshot = dataSource.snapshot()

        snapshot.appendItems([.entry(entry)], toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: animating) {
            let indexPath = self.dataSource.indexPath(for: .entry(entry))
            if let indexPath {
                self.actionDelegate?.requestedScrollToItem(at: indexPath)
            }
        }
    }

    
    func requestedDeleteCell(id: UUID){
        eventHandler?.requestedDeletion(id: id)
    }
    
    func item(at indexPath: IndexPath) -> CollectionItem? {
        dataSource.itemIdentifier(for: indexPath)
    }

    func configureDataSource(for collectionView: UICollectionView) {
        dataSource = UICollectionViewDiffableDataSource<SingleModeSection, CollectionItem>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            
            guard let self else { return UICollectionViewCell() }
            
            switch item {
                
            case .entry(let data):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SingleModeImageCell.identifier,
                    for: indexPath
                ) as! SingleModeImageCell
                
                cell.configureCellWith(
                    data: data,
                    delegate: self,
                    actionDelegate: self.actionDelegate!
                )
                cell.addCenterShadows()
                return cell
                
            case .name(let name):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SingleModeNameCell.identifier,
                    for: indexPath
                ) as! SingleModeNameCell
                
                cell.configureCellWith(name: name, delegate: self)
                cell.addCenterShadows()
                return cell
            }
        }
    }
    func apply(
        entries: [SingleModeCellData],
        showName: Bool,
        animating: Bool = true
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<SingleModeSection, CollectionItem>()
        snapshot.appendSections([.main])

        snapshot.appendItems(
            entries.map { .entry($0) },
            toSection: .main
        )

        if showName {
            snapshot.appendSections([.name])
            snapshot.appendItems([.name(name)], toSection: .name)
        }

        dataSource.apply(snapshot, animatingDifferences: animating)
    }
}

extension CollectionViewAdapter: SingleModeTextDelegate {
    func didTapAddImage(id: UUID) {
        eventHandler?.requestedImagePicker(id: id)
    }

    func wordDidType(id: UUID, text: String) {
        eventHandler?.wordDidType(id: id, text: text)
    }
    
    func definitionDidType(id: UUID, text: String) {
        eventHandler?.definitionDidType(id: id, text: text)
    }
    
    func textViewDidBeginEditing() {
        eventHandler?.enteredEditingMode()
    }
    func textViewDidEndEditing() {
        eventHandler?.exitedEditingMode()
    }
}

extension CollectionViewAdapter: SingleModeNameDelegate {
    func didTypeName(text: String) {
        eventHandler?.nameDidType(text: text)
    }
    
    func nameFieldDidBeginEditing() {
        eventHandler?.enteredEditingMode()
    }
    
    func nameFieldDidEndEditing() {
        eventHandler?.exitedEditingMode()
    }
}


