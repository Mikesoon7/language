//
//  TutorialAccessView.swift
//  Language
//
//  Created by Star Lord on 27/09/2023.
//

import UIKit

protocol AccessViewDelegate: AnyObject{
    func didTapNextButton(with pointerOn: Int)
    func didTapSkipButton()
}
protocol AccessViewFinishDelegate: AnyObject{
    func didEndTutorial()
}
class TutorialAccessView: UIView {

    //MARK: Properties
    private weak var delegate: AccessViewDelegate?

    private let subviewsInset = CGFloat(15)
    private var currentPointer: Int
    private let numberOfViews: Int

    //MARK: Views
    private lazy var pageControll: UIPageControl = {
        let controll = UIPageControl()
        controll.numberOfPages = numberOfViews
        controll.currentPage = currentPointer
        controll.backgroundColor = .clear
        controll.translatesAutoresizingMaskIntoConstraints = false
        controll.currentPageIndicatorTintColor = .label
        controll.pageIndicatorTintColor = .lightGray
        controll.direction = .leftToRight
        controll.isUserInteractionEnabled = false
        return controll
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton(configuration: .gray())
        button.setAttributedTitle(
            .attributedString(string: "system.letsGo".localized, with: .helveticaNeueBold, ofSize: 16), for: .normal)
        button.addTarget(self, action: #selector(nextButtonDidTap(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setAttributedTitle(
            .attributedString(string: "system.skip".localized, with: .helveticaNeueMedium, ofSize: 14, foregroundColour: .placeholderText), for: .normal)
        button.addTarget(self, action: #selector(skipButtonDidTap(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    //MARK: Inherited
    required init(pagesNumber: Int, currentPage: Int, delegate: AccessViewDelegate? ){
        self.numberOfViews = pagesNumber
        self.delegate = delegate
        self.currentPointer = currentPage
        super.init(frame: .zero)
        configureView()
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Subviews setUp
    private func configureView(){
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureSubviews(){
        self.addSubviews(skipButton, nextButton, pageControll)
        NSLayoutConstraint.activate([
            skipButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: subviewsInset),
            skipButton.heightAnchor.constraint(equalTo: heightAnchor),
            skipButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -subviewsInset),
            nextButton.heightAnchor.constraint(equalTo: heightAnchor),
            nextButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            pageControll.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControll.heightAnchor.constraint(equalTo: heightAnchor),
            pageControll.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        if currentPointer != 0 {
            updateButtonsAppearence()
        }
    }
    
    ///Changes next button title and removing skip button
    func updateButtonsAppearence(){
        nextButton.setAttributedTitle(
            .attributedString(string: "system.next".localized, with: .helveticaNeueBold, ofSize: 16), for: .normal)
        skipButton.alpha = 0
    }
    
    //MARK: Actions
    @objc func nextButtonDidTap(sender: UIButton){
        pageControll.currentPage += 1
        delegate?.didTapNextButton(with: pageControll.currentPage)
    }
    ///Dismissing tutorial view on tap.
    @objc func skipButtonDidTap(sender: UIButton){
        delegate?.didTapSkipButton()
    }

}
