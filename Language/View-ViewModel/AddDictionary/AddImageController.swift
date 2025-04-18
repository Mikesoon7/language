//
//  AddImageController.swift
//  Learny
//
//  Created by Star Lord on 17/04/2025.
//

import UIKit
import PhotosUI

protocol AddImageDelegate: AnyObject {
    func didSelectAnImage(image: UIImage?, index: IndexPath)
}

class AddImageController: UIViewController {

    
    var delegate: AddImageDelegate?
    var index: IndexPath
    
    var isFlipped = false
    var isAccessable = false
    var isEmpty = false
    
    var isOneSideMode = false
    var shadowOpacity: Float = 0.1

    //MARK: Views
    
    let testView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let cardView : UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground_Secondary
        view.layer.cornerRadius = .outerCornerRadius
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerCurve = .continuous
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        view.layer.shouldRasterize = false
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let imageView: UIImageView = {
        
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = .cornerRadius
        view.layer.cornerCurve = .continuous
        
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let cardShadowView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        view.layer.shadowRadius = 40.0
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
//        view.layer.masksToBounds = true
        
        view.layer.backgroundColor = UIColor.white.withAlphaComponent(0.5).cgColor
        
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        view.axis = .vertical
        view.alignment = .fill
        return view
    }()


    //MARK: Labels
    var word: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.subtitleSize)
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
        label.font = .selectedFont.withSize(.bodyTextSize)
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
    let translationBacksideLabel: UILabel = {
        let label = UILabel()
        label.font = .selectedFont.withSize(.bodyTextSize)
        label.numberOfLines = 0
        label.textColor = .label
        label.transform = CGAffineTransform(scaleX: -1, y: 1)
        label.text = ""
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.baselineAdjustment = .alignCenters
        label.alpha = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cardViewCustomiation()
        configureStackView()
        configureNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var config = PHPickerConfiguration()
            config.filter = .images // Only show images
            config.selectionLimit = 1 // Limit to one image (or more if you want)

            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        
    }
    init(word: String, translation: String, image: UIImage? = nil, delegate: AddImageDelegate, index: IndexPath) {
        self.index = index
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        if let image = image {
            self.imageView.image = image
        }
        self.word.text = word
        self.translation.text = translation
        
        if word.isEmpty && translation.isEmpty {
            isEmpty = true
            stackView.isHidden = true
        } else {
            isEmpty = false
            stackView.isHidden = false
        }

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar(){
        let button = UIBarButtonItem(title: "system.save".localized, style: .done, target: self, action: #selector(saveButtonDidTap(sender:)))
        self.navigationItem.rightBarButtonItem = button
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
    private func isInSplitScreenMode() -> Bool {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return false
        }
        return window.bounds.width < UIScreen.main.bounds.width
    }

    
    private func cardViewCustomiation(){
        self.view.addSubviews(/*testView,*/ cardShadowView, cardView)
        cardView.addSubview(imageView)
        cardShadowView.layer.shadowOpacity = 0.1

        let isSplitScreen = isInSplitScreenMode()

        let safeAreaHeight = (view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
                
        let widthToHeightRatio = view.bounds.width / safeAreaHeight
        let isWidthMainAnchor = isSplitScreen && widthToHeightRatio < 0.5
        
        let viewsBounds = CGSize(width: view.bounds.width, height: safeAreaHeight)
        
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
        

        NSLayoutConstraint.activate([

            
            cardShadowView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            
            cardShadowView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cardShadowView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            cardShadowView.heightAnchor.constraint(equalTo: cardShadowView.widthAnchor, multiplier: 1.5),

            cardView.topAnchor.constraint(equalTo: cardShadowView.topAnchor),
            
            cardView.leadingAnchor.constraint(equalTo: cardShadowView.leadingAnchor),
            
            cardView.bottomAnchor.constraint(equalTo: cardShadowView.bottomAnchor),
            
            cardView.trailingAnchor.constraint(equalTo: cardShadowView.trailingAnchor),
            
            
            imageView.topAnchor.constraint(equalTo: cardShadowView.topAnchor, constant: .innerSpacer),
            
            imageView.leadingAnchor.constraint(equalTo: cardShadowView.leadingAnchor, constant: .innerSpacer),
            
            imageView.bottomAnchor.constraint(equalTo: cardShadowView.bottomAnchor, constant: -.innerSpacer),
            
            imageView.trailingAnchor.constraint(equalTo: cardShadowView.trailingAnchor, constant: -.innerSpacer),

            
        ])
    }

    @objc func saveButtonDidTap(sender: Any){
        delegate?.didSelectAnImage(image: imageView.image, index: index)
        self.navigationController?.popViewController(animated: true)    }
    
}

extension AddImageController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { image, error in
            DispatchQueue.main.async {
                if let image = image as? UIImage {
                    self.imageView.image = image
                }
            }
        }
    }

}
