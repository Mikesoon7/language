//
//  SingleModeCollectionView.swift
//  Learny
//
//  Created by Star Lord on 21/04/2025.
//
//TODO: Polished

import UIKit


class SingleModeInputView: UIView {
    
    private var cellAdapter: CollectionViewAdapter?
    
    private var menuAccessedForCell: IndexPath?
    private var activeCell: IndexPath?

    private var layout = UICollectionViewFlowLayout()
    private var contentInset: UIEdgeInsets
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.contentInset = contentInset
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.register(SingleModeImageCell.self, forCellWithReuseIdentifier: SingleModeImageCell.identifier)
        view.register(SingleModeNameCell.self, forCellWithReuseIdentifier: SingleModeNameCell.identifier)
        
        return view
    }()
    
    // MARK: - Initialization
    init(frame: CGRect, contentInsets: UIEdgeInsets, adapter: CollectionViewAdapter) {
        self.contentInset = contentInsets
        super.init(frame: frame)

        self.cellAdapter = adapter
        self.cellAdapter?.actionDelegate = self
        
        configureCollectionView()
        cellAdapter?.configureDataSource(for: collectionView)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Changes response
    func applyColourAdjustment(traitCollection: UITraitCollection){
        collectionView.subviews.forEach { section in
            section.layer.shadowColor = (traitCollection.userInterfaceStyle == .dark
                                         ? shadowColorForDarkIdiom
                                         : shadowColorForLightIdiom)
        }
    }

    func adjustLayoutForSizeClass() {
        layout.minimumLineSpacing = .outerSpacer
        layout.invalidateLayout()
    }
    private func itemWidth(for collectionView: UICollectionView) -> CGFloat {
        collectionView.bounds.width - (.outerSpacer * 2)
    }

    
    func adjustLayoutForKeyboard(isVisible: Bool, duration: TimeInterval, intersectingHeight: CGFloat){
            UIView.animate(withDuration: duration) { [weak self] in
                guard let self = self else { return }

                if isVisible {
                    collectionView.contentInset = UIEdgeInsets(top: contentInset.top, left: contentInset.left, bottom: intersectingHeight + .outerSpacer, right: contentInset.right)
                    collectionView.scrollIndicatorInsets = collectionView.contentInset
                    if let activeCell = self.activeCell {
                        collectionView.scrollToItem(at: activeCell, at: .top, animated: true)
                    }
                } else {
                    collectionView.contentInset = contentInset
                    collectionView.scrollIndicatorInsets =   collectionView.contentInset
                }
        }
    }
    
    func adjustForLangugageAndFontChange(){
        self.collectionView.reloadData()
    }

    // MARK: - Setup
    private func configureCollectionView() {
        self.addSubview(collectionView)
        // Constraints
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

//MARK: CollectionViewDelegate
extension SingleModeInputView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let item = cellAdapter?.item(at: indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) {
            switch item {
            case .entry(_):
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    cell.transform = CGAffineTransform.identity
                })
            case .name(_):
                break
            case .none:
                break
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let item = cellAdapter?.item(at: indexPath)
        if let cell = collectionView.cellForItem(at: indexPath) {
            switch item {
            case .entry(_):
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                    cell.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
                })
            case .name(_):
                break
            case .none:
                break
            }
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let width = itemWidth(for: collectionView)

        guard let item = cellAdapter?.item(at: indexPath) else {
            return .zero
        }

        switch item {
        case .entry:
            return CGSize(width: width, height: .largeButtonHeight * 2)

        case .name:
            return CGSize(width: width, height: .genericButtonHeight)
        }
    }

        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            insetForSectionAt section: Int
        ) -> UIEdgeInsets {
            guard let sectionType = cellAdapter?
                .dataSource
                .snapshot()
                .sectionIdentifiers[section]
            else {
                return .zero
            }

            switch sectionType {
            case .main:
                return UIEdgeInsets(
                    top: 0,
                    left: .outerSpacer,
                    bottom: .outerSpacer,
                    right: .outerSpacer
                )

            case .name:
                return UIEdgeInsets(
                    top: 0,
                    left: .outerSpacer,
                    bottom: 0,              
                    right: .outerSpacer
                )
            }
        }
}

//MARK: CollectionView Action Delegate
extension SingleModeInputView: SingleModeCellActionDelegate {
    func requestedScrollToItem(at index: IndexPath) {
        collectionView.scrollToItem(at: index, at: .bottom, animated: true)
    }
    
    func didBeginEditing(cell: UICollectionViewCell) {
        guard let index = collectionView.indexPath(for: cell) else { return }
        
        collectionView.scrollToItem(at: index, at: .top, animated: true)
        self.activeCell = index
    }
    
    func panningBegan(for cell: UICollectionViewCell){
        let index = collectionView.indexPath(for: cell)
        //Dismiss another swiped cell.
        guard index == menuAccessedForCell || menuAccessedForCell == nil else {
            if let cell = collectionView.cellForItem(at: menuAccessedForCell!) as? SingleModeImageCell{
                cell.activate(false)
                menuAccessedForCell = index
            }
            return
        }
        menuAccessedForCell = index
    }
    
    func panningEnded(active: Bool) {
        guard active else {
            menuAccessedForCell = nil
            return
        }
    }
    
    func deleteButtonDidTap(for cell: UICollectionViewCell, id: UUID) {
        menuAccessedForCell = nil
        cellAdapter?.requestedDeleteCell(id: id)
    }
}
