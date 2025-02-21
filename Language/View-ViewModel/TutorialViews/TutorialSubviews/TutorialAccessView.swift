//
//  TutorialAccessView.swift
//  Language
//
//  Created by Star Lord on 27/09/2023.
//
//  REFACTORING STATE: NOT CHECKED

import UIKit

protocol AccessViewDelegate: AnyObject{
    func didChangeCurrentPage(manually: Bool, with pointerOn: Int)
    func shouldFinish()
}
protocol AccessViewFinishDelegate: AnyObject{
    func didEndTutorial()
}
class TutorialAccessView: UIView {

    //MARK: Properties
    private weak var delegate: AccessViewDelegate?

    private let numberOfViews: Int

    //MARK: Views
    lazy var pageControll: UIPageControl = {
        let controll = UIPageControl()
        controll.numberOfPages = numberOfViews
        controll.currentPage = 0
        controll.backgroundColor = .clear
        controll.translatesAutoresizingMaskIntoConstraints = false
        controll.currentPageIndicatorTintColor = .label
        controll.pageIndicatorTintColor = .lightGray
        controll.direction = .leftToRight
        controll.isUserInteractionEnabled = false
        return controll
    }()

    //MARK: Buttons
    private lazy var nextButton: UIButton = {
        let button = UIButton(configuration: .gray())
        button.setAttributedTitle(
            .attributedString(string: "system.letsGo".localized, with: .helveticaNeueBold, ofSize: .assosiatedTextSize), for: .normal)
        button.addTarget(self, action: #selector(nextButtonDidTap(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.setAttributedTitle(
            .attributedString(string: "system.skip".localized, with: .helveticaNeueMedium, ofSize: .assosiatedTextSize, foregroundColour: .placeholderText), for: .normal)
        button.addTarget(self, action: #selector(skipButtonDidTap(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    
    //MARK: Inherited
    required init(pagesNumber: Int, currentPage: Int, delegate: AccessViewDelegate? ){
        self.numberOfViews = pagesNumber
        self.delegate = delegate
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
            skipButton.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: .longInnerSpacer),
            skipButton.heightAnchor.constraint(
                equalTo: heightAnchor),
            skipButton.bottomAnchor.constraint(
                equalTo: bottomAnchor),
            
            nextButton.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -.longInnerSpacer),
            nextButton.heightAnchor.constraint(
                equalTo: heightAnchor),
            nextButton.bottomAnchor.constraint(
                equalTo: bottomAnchor),
            
            pageControll.centerXAnchor.constraint(
                equalTo: centerXAnchor),
            pageControll.heightAnchor.constraint(
                equalTo: heightAnchor),
            pageControll.bottomAnchor.constraint(
                equalTo: bottomAnchor)
        ])
    }
    
    ///Changes next button title
    private func updateButtonsAppearence(){
        let lastPageIndex = numberOfViews - 1
        if pageControll.currentPage == lastPageIndex{
            nextButton.setAttributedTitle(
                .attributedString(string: "system.finish".localized, with: .helveticaNeueBold, ofSize: .assosiatedTextSize), for: .normal)
        } else {
            nextButton.setAttributedTitle(
                .attributedString(string: "system.next".localized, with: .helveticaNeueBold, ofSize: .assosiatedTextSize), for: .normal)
        }
    }
    func pageDidChange(updatedIndex: Int){
        pageControll.currentPage = updatedIndex
        delegate?.didChangeCurrentPage(manually: false, with: pageControll.currentPage)
        updateButtonsAppearence()
    }
    
    //MARK: Actions
    @objc private func nextButtonDidTap(sender: UIButton){
        guard pageControll.currentPage != numberOfViews - 1 else {
            delegate?.shouldFinish()
            return
        }
        pageControll.currentPage += 1
        delegate?.didChangeCurrentPage(manually: true, with: pageControll.currentPage)
        updateButtonsAppearence()
    }
    ///Dismissing tutorial view on tap.
    @objc private func skipButtonDidTap(sender: UIButton){
        delegate?.shouldFinish()
    }

}
