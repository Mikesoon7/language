//
//  SingleModeAddImageCell.swift
//  Learny
//
//  Created by Star Lord on 21/04/2025.
//
//TODO: Polished

import UIKit


class SingleModeImageCell: UICollectionViewCell {
    
    private enum ViewConstants{
        static let cornerRadius: CGFloat = .cornerRadius
        static let overlayPoints: CGFloat = 2
        static let actionViewMultiplier: CGFloat = 0.2
    }
    
    static var identifier = "SingleModeImage"
    
    //MARK: Properties
    weak var delegate: SingleModeTextDelegate?
    weak var actionDelegate: SingleModeCellActionDelegate?
    
    private var direction: Direction = .right
    private var isActionActive: Bool = false
    private var isActionLooped: Bool = false
    
    private var displayedID: UUID!
    
    //MARK: Views
    lazy var mainView : UIView = {
        let view = UIView()
        view.layer.cornerRadius = .cornerRadius
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        
        view.backgroundColor = .selectedColourPalette.primaryBackgroundColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = .cornerRadius
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "photo.badge.plus"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    lazy var frontSideTextView: TextInputView = {
        let view = TextInputView(delegate: self, tag: 0)
        view.textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5 )
        view.textView.textAlignment = .left
        view.textView.clipsToBounds = true
        view.textView.backgroundColor = .clear
        
        view.backgroundColor = .popoverSubviewsBackgroundColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    lazy var backSideTextView: TextInputView = {
        let view = TextInputView(delegate: self, tag: 1)
        view.textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5 )
        view.textView.textAlignment = .left
        view.textView.clipsToBounds = true
        view.textView.backgroundColor = .clear
        
        view.backgroundColor = .popoverSubviewsBackgroundColour
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()
    
    var imageSmallLayout: [NSLayoutConstraint] = []
    var imageLargeLayout: [NSLayoutConstraint] = []
    
    //MARK: Action related properties
    private var actionGestureView = TransperentView()
    
    lazy var deleteView: UIView = configureCustomActions(
        imageName: "trash",
        colour: .systemGray4)
    
    var contentViewWidth: CGFloat = 0
    var contentViewHeight: CGFloat = 0
    
    var mainViewLeadingAnchor: NSLayoutConstraint = .init()
    var mainViewInitital: CGFloat = 0
    var mainViewCurrent: CGFloat = 0
    var mainViewFinal: CGFloat = 0
    
    var deleteViewLeadingAnchor: NSLayoutConstraint = .init()
    var currentDeleteConstant: CGFloat = 0
    var finalDeleteConstant: CGFloat = 0
    var deleteViewFinalConstant: NSLayoutConstraint = .init()
    
    
    private lazy var temporaryRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellDidTap(sender: )))
    
    
    //MARK: - Inherited Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureHolderView()
        configureSubviews()
        configureTextViews()
        
        configurePanGesture()
        configureTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("coder wasn't imported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        deleteView.layer.mask = UIView().configureActionMaskWith(size: CGSize(
            width: contentViewWidth + ViewConstants.overlayPoints,
            height: contentView.frame.height), cornerRadius: .cornerRadius)
        
        mainViewFinal = -(contentViewWidth - ViewConstants.cornerRadius)
        
//        deleteViewFinalConstant = deleteView.leadingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -ViewConstants.cornerRadius)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        guard !isActionActive else {
            activate(false)
            return
        }
        self.displayedID = nil
        self.addPhoto(imageDetails: nil)
    }
    
        
    
    //MARK: Subviews SetUp
    func configureCellWith(data: SingleModeCellData, delegate: SingleModeTextDelegate, actionDelegate: SingleModeCellActionDelegate) {
        
        self.frontSideTextView.assignText(text: data.word)
        self.backSideTextView.assignText(text: data.definition)
        
        self.addPhoto(imageDetails: data.imageDetails)
        
        self.delegate = delegate
        self.actionDelegate = actionDelegate
        self.displayedID = data.identifier
        
        self.configureLabels()
    }
    
    private func configureView(){
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = .cornerRadius
    }
    
    private func configureHolderView(){
        contentView.frame = self.bounds
        
        contentView.backgroundColor = .clear
        
        contentView.addSubviews( mainView, deleteView/*, actionGestureView*/)
        
        contentViewWidth = .genericButtonHeight + .innerSpacer * 2
        
        //Related to the holder
        mainViewFinal = -(contentViewWidth - ViewConstants.cornerRadius )
        mainViewLeadingAnchor = mainView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor, constant: mainViewCurrent)
        
        //Related to Delete
        currentDeleteConstant = -ViewConstants.cornerRadius
        finalDeleteConstant = contentViewWidth - .cornerRadius
        deleteViewLeadingAnchor = deleteView.leadingAnchor.constraint(
            equalTo: mainView.trailingAnchor, constant: .cornerRadius)
        
        deleteViewFinalConstant = deleteView.leadingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -ViewConstants.cornerRadius)

        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(
                equalTo: contentView.topAnchor),
            mainView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor),
            mainView.widthAnchor.constraint(
                equalTo: contentView.widthAnchor),
            mainViewLeadingAnchor,
            
            
            deleteView.topAnchor.constraint(
                equalTo: mainView.topAnchor),
            deleteView.bottomAnchor.constraint(
                equalTo: mainView.bottomAnchor),
            deleteView.widthAnchor.constraint(
                equalToConstant: contentViewWidth),
            deleteViewLeadingAnchor
        ])
    }
    
    private func configureSubviews() {
        self.mainView.addSubviews(button)
        
        imageSmallLayout.append(contentsOf: [
            button.topAnchor.constraint(
                equalTo: mainView.topAnchor, constant: .innerSpacer),
            button.trailingAnchor.constraint(
                equalTo: mainView.trailingAnchor, constant: -.innerSpacer),
            button.widthAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            button.bottomAnchor.constraint(
                equalTo: mainView.bottomAnchor, constant: -.innerSpacer),
        ])
        imageLargeLayout.append(contentsOf: [
            button.topAnchor.constraint(
                equalTo: mainView.topAnchor, constant: .innerSpacer),
            button.trailingAnchor.constraint(
                equalTo: mainView.trailingAnchor, constant: -.innerSpacer),
            button.bottomAnchor.constraint(
                equalTo: mainView.bottomAnchor, constant: -.innerSpacer),
            button.widthAnchor.constraint(
                equalTo: button.heightAnchor, multiplier: 0.66),
            
        ])
        
        NSLayoutConstraint.activate(imageSmallLayout)
        
        button.addTarget(self, action: #selector(addImageButtonDidTap(sender:)), for: .touchUpInside)
    }
    
    private func configureTextViews(){
        self.mainView.addSubviews(frontSideTextView, backSideTextView, actionGestureView)
        
        NSLayoutConstraint.activate([
            frontSideTextView.topAnchor.constraint(
                equalTo: mainView.topAnchor, constant: .innerSpacer),
            frontSideTextView.leadingAnchor.constraint(
                equalTo: mainView.leadingAnchor, constant: .innerSpacer),
            frontSideTextView.trailingAnchor.constraint(
                equalTo: button.leadingAnchor, constant: -.innerSpacer),
            frontSideTextView.heightAnchor.constraint(
                equalTo: mainView.heightAnchor, multiplier: 0.5, constant: -(.innerSpacer * 1.5 )),
            
            backSideTextView.topAnchor.constraint(
                equalTo: frontSideTextView.bottomAnchor, constant: .innerSpacer),
            backSideTextView.leadingAnchor.constraint(
                equalTo: mainView.leadingAnchor, constant: .innerSpacer),
            backSideTextView.trailingAnchor.constraint(
                equalTo: button.leadingAnchor, constant: -.innerSpacer),
            backSideTextView.bottomAnchor.constraint(
                equalTo: mainView.bottomAnchor, constant:  -.innerSpacer ),
            
            
            actionGestureView.topAnchor.constraint(
                equalTo: mainView.topAnchor),
            actionGestureView.leadingAnchor.constraint(
                equalTo: mainView.leadingAnchor),
            actionGestureView.trailingAnchor.constraint(
                equalTo: mainView.trailingAnchor),
            actionGestureView.bottomAnchor.constraint(
                equalTo: mainView.bottomAnchor),
        ])
    }
    
    func configureLabels() {
        frontSideTextView.updatePlaceholder()
        backSideTextView.updatePlaceholder()
    }
    
    //MARK: Gesture SetUp    
    private func configurePanGesture(){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(viewDidPan(sender:)))
        pan.delegate = actionGestureView
        actionGestureView.addGestureRecognizer(pan)
    }
    
    private func configureTapGesture(){
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(deleteViewDidTap(sender: )))
        temporaryRecognizer.delegate = actionGestureView
        actionGestureView.addGestureRecognizer(temporaryRecognizer)
        deleteView.addGestureRecognizer(deleteTap)
    }
    //MARK: Animation
    //Animation for swipe transition
    func activate(_ activate: Bool){
        let animation = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut){
            self.mainViewLeadingAnchor.constant = activate ? self.mainViewFinal : self.mainViewInitital
            self.layoutIfNeeded()
        }
                
        deleteView.isUserInteractionEnabled = activate ? true : false
             
        animation.startAnimation()
        
        isActionActive = activate
        mainViewCurrent = mainViewLeadingAnchor.constant
        currentDeleteConstant = deleteViewLeadingAnchor.constant
    }
    
    //MARK: Changes Response
    func addPhoto(imageDetails: ImageDetailsCheck?){
        if let imageDetails = imageDetails, let image = imageDetails.image {
            let processedImage = imageDetails.filterValue.original ? image : image.applyBlackAndWhiteFilter()
            
            self.button.setImage(processedImage, for: .normal)
            self.button.imageView?.contentMode = imageDetails.contentMode.uiViewContentMode
            
            UIView.animate(withDuration: 0.3) {
                NSLayoutConstraint.deactivate(self.imageSmallLayout)
                NSLayoutConstraint.activate(self.imageLargeLayout)
            }
            self.layoutIfNeeded()
        } else {
            let addImage = UIImage(systemName: "photo.badge.plus")
            guard button.imageView?.image == addImage else {
                self.button.setImage(addImage, for: .normal)
                self.button.imageView?.contentMode = .scaleAspectFill
                
                UIView.animate(withDuration: 0.3) {
                    NSLayoutConstraint.deactivate(self.imageLargeLayout)
                    NSLayoutConstraint.activate(self.imageSmallLayout)
                    self.layoutIfNeeded()
                }
                return
            }
        }
    }
}
    //MARK: - Actions
extension SingleModeImageCell {
    @objc func addImageButtonDidTap(sender: Any){
        if frontSideTextView.isFirstResponder() {
           _ = frontSideTextView.resignFirstResponder()
        } else if backSideTextView.isFirstResponder() {
           _ = backSideTextView.resignFirstResponder()
        }
        delegate?.didTapAddImage(id: displayedID)
    }
    
    @objc func deleteViewDidTap(sender: Any){
        actionDelegate?.deleteButtonDidTap(for: self, id: displayedID)
    }
    
    //Rather less sufficitent but cant come up with another option.
    @objc func cellDidTap(sender: UITapGestureRecognizer){
        guard !isActionActive else {
            activate(false)
            return
        }
        
        let point = sender.location(in: sender.view)
        
        if frontSideTextView.frame.contains(point) {
            _ = frontSideTextView.becomeFirstResponder()
        } else if backSideTextView.frame.contains(point) {
            _ = backSideTextView.becomeFirstResponder()
        } else if button.frame.contains(point){
            addImageButtonDidTap(sender: button)
        }
    }
    
    //Panning
    @objc func viewDidPan(sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: actionGestureView).x
        let velocity = sender.velocity(in: actionGestureView).x
        
        let holderConstant = mainViewCurrent + translation
        let deleteConstant = currentDeleteConstant /*+ -(translation )*/
        
        direction = (0 < translation ? .right : .left)
        
        switch sender.state{
        case .began:
            actionDelegate?.panningBegan(for: self)
        case .changed:
            if holderConstant >= mainViewFinal && holderConstant <= 0{
                mainViewLeadingAnchor.constant = holderConstant
                deleteViewLeadingAnchor.constant = deleteConstant
                
                if direction == .left && holderConstant < -10{
                    isActionLooped = true
                }
            } else if holderConstant < mainViewFinal{
                self.transform = CGAffineTransform(translationX: (holderConstant + abs(mainViewFinal)) / 4, y: 0)
            } else if holderConstant > 0 && holderConstant < 100 && !isActionActive && !isActionLooped {
                self.transform = CGAffineTransform(translationX: translation / 4, y: 0)
            }
            
        case .cancelled:
            if direction == .left {
                activate(true)
            } else {
                activate(false)
            }
        default:
            if holderConstant > 0 && !isActionActive{
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self.transform = .identity
                }
            } else if holderConstant < mainViewFinal {
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self.transform = .identity
                }
            }
            if direction == .left && (holderConstant <= mainViewFinal * 0.1 || abs(velocity) > 800){
                activate(true)
            } else {
                activate(false)
            }
            isActionLooped = false
            
            actionDelegate?.panningEnded(active: isActionActive)
        }
    }
}

//MARK: TextView delegate
extension SingleModeImageCell: PlaceholderTextViewDelegate {
    func textViewDidBeginEditing(sender: UITextView) { 
        self.actionGestureView.isUserInteractionEnabled = false
        self.actionDelegate?.didBeginEditing(cell: self)
        self.delegate?.textViewDidBeginEditing()
    }
    
    func textViewDidEndEditing(sender: UITextView) {
        delegate?.textViewDidEndEditing()
        self.actionGestureView.isUserInteractionEnabled = true
        
    }
    
    func textViewDidChange(sender: UITextView) {
        if sender.tag == 0 {
            delegate?.wordDidType(id: displayedID, text: frontSideTextView.currentText())
        } else {
            delegate?.definitionDidType(id: displayedID, text: backSideTextView.currentText())
        }
    }
    
    //Since its the only place where one class is being ad delegate to two textView's, the correct return defined by the tag.
    func configurePlaceholderText(sender: UITextView) -> String?  {
        if sender.tag == 0 {
            return "frontSide".localized
        } else {
            return "backSide".localized
        }
    }
    
    func currentSeparatorSymbol() -> String?    { nil }
    func presentErrorAlert(alert: UIAlertController) { }
}


class TransperentView: UIView, UIGestureRecognizerDelegate{
    
    init(){
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer, panGestureRecognizer.view == self {
            let velocity = panGestureRecognizer.velocity(in: self)
            return abs(velocity.y) < abs(velocity.x)
        }
        
        return true
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return false
    }
}

