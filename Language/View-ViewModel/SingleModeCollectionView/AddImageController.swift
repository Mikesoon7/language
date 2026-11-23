//
//  AddImageController.swift
//  Learny
//
//  Created by Star Lord on 17/04/2025.
//
//TODO: Polished

import UIKit
import PhotosUI

protocol AddImageDelegate: AnyObject {
    func didSelectAnImage(imageDetails: ImageDetailsCheck, data: SingleModeCellData)
}


class AddImageController: UIViewController {

    ///Allows present upload image view on VC appearance
    var isFirstLaunch: Bool = true
    
    //MARK: Properties
    weak var delegate: AddImageDelegate?
    var data: SingleModeCellData
    
    var originalImage: UIImage? = nil
    var imageDetails: ImageDetailsCheck = .init()
    
    var isInSplitMode: Bool?
    var isSavingRequired = false
    
    //MARK: - Views
    private var addImageLabel: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.subtitleSize)
        label.text = "addWord.title".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    //MARK: Cards View
    let cardShadowView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.masksToBounds = true
        view.layer.cornerRadius = .outerCornerRadius
        view.layer.cornerCurve = .continuous
        view.addCenterShadows()
        return view
    }()

    let cardView : UIView = {
        let view = UIView()
        view.backgroundColor = .systemSecondary_WhiteColour
        view.layer.cornerRadius = .outerCornerRadius
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        view.layer.shouldRasterize = false
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = .cornerRadius
        view.layer.cornerCurve = .continuous
        
        view.layer.masksToBounds = true
        view.contentMode = imageDetails.contentMode.uiViewContentMode
        return view
    }()
    
    private var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.spacing = 10.0
        view.distribution = .fill
        view.layer.cornerRadius = .cornerRadius
        view.layer.cornerCurve = .continuous
        
//        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.5)
//        
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(
            top: .innerSpacer,
            left: .innerSpacer,
            bottom: .innerSpacer,
            right: .innerSpacer
        )
        
        view.axis = .vertical
        view.alignment = .fill
        return view
    }()


    //MARK: Labels
    var word: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.bodyTextSize)
        label.numberOfLines = 0
        label.textColor = .label
        label.text = ""
        label.textAlignment = .center

        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    var translation: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.subBodyTextSize)
        label.numberOfLines = 0
        label.textColor = .label
        
        label.text = ""
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    //MARK: Buttons
    private lazy var saveButton = UIButton.configureNavButtonWith(title: "system.save".localized)

    private var scaleSelectionButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "rectangle.and.arrow.up.right.and.arrow.down.left.slash"), for: .normal)
        button.tag = 0
        button.layer.masksToBounds = true
        button.contentMode = .scaleToFill
        button.tintColor = .label
        return button
    }()
    
    private var addImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "photo.badge.plus"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    
    private var applyFilterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = .cornerRadius
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "circle.righthalf.filled"), for: .normal)
        button.tintColor = .label
        button.tag = 0
        return button
    }()

    var initialGenericSize: [NSLayoutConstraint] = []
    var cellSizeToWidth:    [NSLayoutConstraint] = []
    var cellSizeToHeight:   [NSLayoutConstraint] = []
    
    //MARK: Inherited
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureCardView()
        configureStackView()
        configureButtons()
        
        configureAddImageTapGesture()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstLaunch {
            presentPhotoSourceSelection()
            isFirstLaunch.toggle()
        }
    }
    
    init(data: SingleModeCellData, delegate: AddImageDelegate) {
        self.data = data
        self.delegate = delegate
        
        if let imageDetails = data.imageDetails, let image = imageDetails.originalImage {
            self.originalImage = image
            self.imageDetails = imageDetails
        }

        super.init(nibName: nil, bundle: nil)
        
        self.word.text = data.word
        self.translation.text = data.definition
        
        if let image = originalImage {
            let processedImage = self.imageDetails.filterValue.original ? image : image.applyBlackAndWhiteFilter()
            self.imageView.image = processedImage
        }
        updateScaleButton(selectedMode: imageDetails.contentMode)
        updateFilterButton(selectedMode: imageDetails.filterValue)
        
        updateStackViewBackground()
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - StyleChange Responding
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            view.subviews.forEach { section in
                section.layer.shadowColor = (traitCollection.userInterfaceStyle == .dark
                                             ? shadowColorForDarkIdiom
                                             : shadowColorForLightIdiom)
            }
            updateStackViewBackground()
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.adjustLayoutIfNeeded(size: size)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.adjustLayoutIfNeeded()
    }

    
    //MARK: SetUp Subviews
    private func configureView(){
        self.view.backgroundColor = .systemBackground
        

        if let sheetPresentationController = self.presentationController as? UISheetPresentationController {
            sheetPresentationController.delegate = self
        }
    }
    
    private func configureStackView(){
        stackView.addArrangedSubviews(word, translation)
        cardView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            
            stackView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            
            stackView.widthAnchor.constraint(
                lessThanOrEqualTo: cardView.widthAnchor, constant: -.innerSpacer * 2 ),
            stackView.heightAnchor.constraint(
                lessThanOrEqualTo: cardView.heightAnchor, constant: -.innerSpacer * 2)
        ])
    }
    
    private func configureCardView(){
        self.view.addSubviews( addImageLabel, saveButton, cardShadowView, cardView)
        cardView.addSubview(imageView)
        cellSizeToWidth.append(contentsOf: [
            cardShadowView.widthAnchor.constraint(
                equalTo: view.widthAnchor, multiplier: 0.8),
            cardShadowView.heightAnchor.constraint(
                equalTo: cardShadowView.widthAnchor, multiplier: 1.5),
        ])
        cellSizeToHeight.append(contentsOf: [
            cardShadowView.heightAnchor.constraint(
                equalTo: view.heightAnchor, multiplier: 0.66),
            cardShadowView.widthAnchor.constraint(
                equalTo: cardShadowView.heightAnchor, multiplier: 0.66),
        ])
            

        NSLayoutConstraint.activate([
            addImageLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .outerSpacer),
            addImageLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor, constant: .outerSpacer ),
            addImageLabel.heightAnchor.constraint(
                equalToConstant: addImageLabel.font.lineHeight),
            
            cardShadowView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor, constant: -40),
            cardShadowView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor),
            
            cardView.topAnchor.constraint(
                equalTo: cardShadowView.topAnchor),
            cardView.leadingAnchor.constraint(
                equalTo: cardShadowView.leadingAnchor),
            cardView.bottomAnchor.constraint(
                equalTo: cardShadowView.bottomAnchor),
            cardView.trailingAnchor.constraint(
                equalTo: cardShadowView.trailingAnchor),
            
            
            imageView.topAnchor.constraint(
                equalTo: cardShadowView.topAnchor, constant: .innerSpacer),
            imageView.leadingAnchor.constraint(
                equalTo: cardShadowView.leadingAnchor, constant: .innerSpacer),
            imageView.bottomAnchor.constraint(
                equalTo: cardShadowView.bottomAnchor, constant: -.innerSpacer),
            imageView.trailingAnchor.constraint(
                equalTo: cardShadowView.trailingAnchor, constant: -.innerSpacer),

        ])
    }
    
    func configureButtons(){
        view.addSubviews(saveButton, addImageButton, scaleSelectionButton, applyFilterButton)

        NSLayoutConstraint.activate([

            saveButton.centerYAnchor.constraint(
                equalTo: addImageLabel.centerYAnchor),
            saveButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,  constant: -.longInnerSpacer),

            scaleSelectionButton.topAnchor.constraint(
                equalTo: cardShadowView.bottomAnchor, constant: .outerSpacer),
            scaleSelectionButton.centerXAnchor.constraint(
                equalTo: cardShadowView.centerXAnchor),
            scaleSelectionButton.widthAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            scaleSelectionButton.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),
        
            addImageButton.topAnchor.constraint(
                equalTo: cardShadowView.bottomAnchor, constant: .outerSpacer),
            addImageButton.trailingAnchor.constraint(
                equalTo: cardShadowView.trailingAnchor, constant: -.outerSpacer),
            addImageButton.widthAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            addImageButton.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            
            applyFilterButton.topAnchor.constraint(
                equalTo: cardShadowView.bottomAnchor, constant: .outerSpacer),
            applyFilterButton.leadingAnchor.constraint(
                equalTo: cardShadowView.leadingAnchor, constant: .outerSpacer),
            applyFilterButton.widthAnchor.constraint(
                equalToConstant: .genericButtonHeight),
            applyFilterButton.heightAnchor.constraint(
                equalToConstant: .genericButtonHeight),


        ])
        
        addImageButton.addTarget(self, action: #selector(addImageDidTap(sender: )), for: .touchUpInside)
        scaleSelectionButton.addTarget(self, action: #selector(scaleButtonDidTap(sender: )), for: .touchUpInside)
        applyFilterButton.addTarget(self, action: #selector(applyFilterButtonDidTap(sender: )), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(sender: )), for: .touchUpInside)
    }

    //MARK: Layout
    func isInPortraitSplit(size: CGSize? = nil) -> Bool{
        return UIWindow.isInSplitScreenMode() && (size?.width ?? view.bounds.width) / (size?.height ?? view.bounds.height) < 0.5
    }

    private func adjustLayoutIfNeeded(size: CGSize? = nil){
        if let size = size {
            let isInSplitMode = isInPortraitSplit(size: size)
            changeLayoutForSplitMode(isActive: isInSplitMode)
            self.isInSplitMode = isInSplitMode
        } else {
            let isInSplitMode = isInPortraitSplit()
            guard self.isInSplitMode != isInSplitMode else { return }
            changeLayoutForSplitMode(isActive: isInSplitMode)
            self.isInSplitMode = isInSplitMode
        }
        self.view.layoutIfNeeded()
    }
    
    func changeLayoutForSplitMode(isActive: Bool){
        if isActive {
            NSLayoutConstraint.deactivate(cellSizeToHeight)
            NSLayoutConstraint.activate(cellSizeToWidth)
        } else {
            NSLayoutConstraint.deactivate(cellSizeToWidth)
            NSLayoutConstraint.activate(cellSizeToHeight)
        }
        
    }

    //MARK: Present Image Picker
    private func configureAddImageTapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(addImageDidTap(sender: )))
        stackView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
        stackView.addGestureRecognizer(tap)
        imageView.addGestureRecognizer(tap)
    }

    private func presentPhotoSourceSelection() {
        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default) { _ in
                self.presentImagePicker(sourceType: .camera)
            })
        }

        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default) { _ in
            self.presentImagePicker(sourceType: .photoLibrary)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.actions.forEach { action in
            action.setValue(UIColor.label, forKey: "titleTextColor")
        }
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.allowsEditing = false
        present(picker, animated: true)
    }
    
    func updateFilterButton(selectedMode: ImageFilterMode){
        if selectedMode == .blackAndWhite {
            applyFilterButton.setImage(UIImage(systemName: "circle.bottomrighthalf.checkered"), for: .normal)
            applyFilterButton.tag = 1
        } else {
            applyFilterButton.setImage(UIImage(systemName: "circle.righthalf.filled"), for: .normal)
            applyFilterButton.tag = 0
        }
    }    
    func updateScaleButton(selectedMode: ImageContentMode){
        if selectedMode == .fit {
            scaleSelectionButton.setImage(UIImage(systemName: "rectangle.and.arrow.up.right.and.arrow.down.left"), for: .normal)
            scaleSelectionButton.tag = 1
        } else {
            scaleSelectionButton.setImage(UIImage(systemName: "rectangle.and.arrow.up.right.and.arrow.down.left.slash"), for: .normal)
            scaleSelectionButton.tag = 0
        }
    }
    func updateStackViewBackground(){
        
        if word.text == "" && translation.text == "" {
            stackView.backgroundColor = .clear
        } else {
            stackView.backgroundColor = .systemBackground.withAlphaComponent(0.6)
        }
        
    }
    

    
}
//MARK: - Actions
extension AddImageController {
    @objc func saveButtonDidTap(sender: Any){
        let imageDetails = ImageDetailsCheck(
            image: originalImage,
            contentMode: imageDetails.contentMode,
            filterValue: imageDetails.filterValue)
        delegate?.didSelectAnImage(imageDetails: imageDetails, data: data)
        
        isSavingRequired = false
        self.dismiss(animated: true)
    }
    
    @objc func addImageDidTap(sender: Any){
        presentPhotoSourceSelection()
    }
    
    @objc func applyFilterButtonDidTap(sender: UIButton){
        self.isSavingRequired = true

        if sender.tag == 0 {
            updateFilterButton(selectedMode: .blackAndWhite)
            
            if let image = self.originalImage  {
                imageDetails.filterValue = .blackAndWhite
                imageView.image = image.applyBlackAndWhiteFilter()

            }
        } else {
            updateFilterButton(selectedMode: .original)
            
            if let image = self.originalImage {
                imageDetails.filterValue = .original
                imageView.image = image
            }
        }
    }
    
    @objc func scaleButtonDidTap(sender: UIButton){
        self.isSavingRequired = true
        if sender.tag == 0 {
            updateScaleButton(selectedMode: .fit)
            
            imageView.contentMode = .scaleAspectFit
            imageDetails.contentMode = .fit
        } else {
            updateScaleButton(selectedMode: .fill)
            imageView.contentMode = .scaleAspectFill
            imageDetails.contentMode = .fill
        }
    }
    
}


//MARK: Image Picker Delegate
extension AddImageController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            self.isSavingRequired = true
            DispatchQueue.main.async {
                let processedImage = self.imageDetails.filterValue.original ? selectedImage : selectedImage.applyBlackAndWhiteFilter()
                self.originalImage = selectedImage
                self.imageView.image = processedImage
                
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

//MARK: UISheetPresentationController delegate.
extension AddImageController: UISheetPresentationControllerDelegate {
    ///Insures, that view won't be accedentaly dismissed without saving the data.
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        guard isSavingRequired else { return true }
        
        let alert = UIAlertController.alertWithAction(
            alertTitle: "addWords.contentSaving.title".localized,
            alertMessage: "addWords.contentSaving.image".localized,
            alertStyle: .actionSheet,
            action1Title: "addWords.contentSaving.save".localized,
            action1Handler: { _ in
                self.saveButtonDidTap(sender: self.saveButton)
            },
            
            action1Style: .default,
            action2Title: "addWords.contentSaving.clear".localized,
            action2Handler: { _ in
                self.dismiss(animated: true)
            },
            action2Style: .destructive,
            sourceView: view
        )
        let editAction = UIAlertAction.init(title: "system.edit".localized, style: .cancel) { _ in }
        editAction.setValue(UIColor.label, forKey: "titleTextColor")
        alert.addAction(editAction)
        self.present(alert, animated: true)
        return false
        
    }
}


