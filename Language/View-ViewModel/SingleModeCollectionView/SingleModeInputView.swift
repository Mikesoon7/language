//
//  SingleModeCollectionView.swift
//  Learny
//
//  Created by Star Lord on 21/04/2025.
//

import UIKit

protocol SingleModeViewDelegate: SingleModeImageDelegate, AddImageDelegate {
    
    func numberOfCells() -> Int
    func dataForCellAt(index: IndexPath) -> SingleModeCellData
    
    func deleteCell(index: IndexPath)
}

class SingleModeInputView: UIView {
    
    private var delegate: SingleModeViewDelegate?
    private var addDelegate: SingleModeAddDelegate?
    private var nameDelegate: SingleModeNameDelegate?
    
    private var menuAccessedForCell: IndexPath?

    private var layout = UICollectionViewFlowLayout()
    private var contentInset: UIEdgeInsets
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.contentInset = contentInset
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = false
        view.register(SingleModeImageCell.self, forCellWithReuseIdentifier: SingleModeImageCell.identifier)
        view.register(SingleModeNameCell.self, forCellWithReuseIdentifier: SingleModeNameCell.identifier)
        view.register(SingleModeAddCell.self, forCellWithReuseIdentifier: SingleModeAddCell.identifier)
        
        return view
    }()
    
    // MARK: - Initialization
    init(frame: CGRect, delegate: SingleModeViewDelegate, addDelegate: SingleModeAddDelegate, nameDelegate: SingleModeNameDelegate?, contentInsets: UIEdgeInsets){
        self.delegate = delegate
        self.addDelegate = addDelegate
        self.nameDelegate = nameDelegate
        self.contentInset = contentInsets
        super.init(frame: frame)
        print(frame)
        configureCollectionView()
        addObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addObservers() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func adjustLayoutForSizeClass() {
        let itemWidth = ((self.bounds.width - (.outerSpacer * 2)))
        
        layout.itemSize = CGSize(width: itemWidth, height: .largeButtonHeight)
        layout.minimumLineSpacing = .outerSpacer
        layout.invalidateLayout()
    }

    // MARK: - Setu
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
    
    
    private func scrollToActiveTextView() {
        if let firstResponder = findFirstResponder(in: collectionView) {
            if let cell = firstResponder.superview(of: UICollectionViewCell.self),
               let indexPath = collectionView.indexPath(for: cell) {
                collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        }
    }
    
    func findFirstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder {
            return view
        }
        for subview in view.subviews {
            if let responder = findFirstResponder(in: subview) {
                return responder
            }
        }
        return nil
    }
    
}

//Actions
extension SingleModeInputView {
    @objc func keyboardWillShow(sender: Notification){
        
        if let userInfo = sender.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
           let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
               let keyboardHeight = keyboardFrame.height
               print("trying to adjust offset")
            print(duration)
               UIView.animate(withDuration: duration) { [weak self] in
                   guard let self = self else { return }
                   collectionView.contentInset = UIEdgeInsets(top: contentInset.top, left: contentInset.left, bottom: keyboardHeight, right: contentInset.right)
                   collectionView.scrollIndicatorInsets = collectionView.contentInset
               } completion: { _ in
                   
                   self.scrollToActiveTextView()
               }
           }
        
    }
    
    @objc func keyboardWillHide(sender: Notification){
        collectionView.contentInset = contentInset
        
        collectionView.scrollIndicatorInsets =   collectionView.contentInset

    }

}
extension SingleModeInputView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let delegate = delegate else { return 0 }
        return delegate.numberOfCells() + (nameDelegate != nil ? 2 : 1)
//        return number
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let delegate = delegate, let addDelegate = addDelegate else {
            return UICollectionViewCell()
        }
        
        if indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleModeAddCell.identifier, for: indexPath) as? SingleModeAddCell
            cell?.configureCellWith(delegate: addDelegate)
            return cell ?? UICollectionViewCell()
        } else {
            if nameDelegate != nil && indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 2 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleModeNameCell.identifier, for: indexPath) as! SingleModeNameCell
                cell.configureCellWith(name: nameDelegate!.name(),
                                       delegate: nameDelegate!)
                return cell

            } else {
                let data = delegate.dataForCellAt(index: indexPath)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleModeImageCell.identifier, for: indexPath) as! SingleModeImageCell
                cell.configureCellWith(data: data, delegate: delegate, actionDelegate: self, index: indexPath)
                cell.addCenterShadows()
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1,
           let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            })
        } else {
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1, let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = layout.itemSize.width
        print(layout.itemSize, "inCollection")
        
        if indexPath.item == collectionView.numberOfItems(inSection: 0) - 1 || (nameDelegate != nil && indexPath.item == collectionView.numberOfItems(inSection: 0) - 2 ) {
            // Add or name button cell
            return CGSize(width: width, height: .genericButtonHeight)
        } else {
            // Regular chunk cells
            return CGSize(width: width, height: .largeButtonHeight * 2)
        }
    }
}

extension SingleModeInputView: SingleModeCellActionDelegate {
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
    func deleteButtonDidTap(for cell: UICollectionViewCell) {
        menuAccessedForCell = nil
        guard let index = collectionView.indexPath(for: cell) else { return }
        delegate?.deleteCell(index: index)
        collectionView.deleteItems(at: [index])
    }
}
