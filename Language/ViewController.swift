//
//  ViewController.swift
//  Language
//
//  Created by Star Lord on 03/02/2023.
//

import UIKit

class ViewController: UIViewController {

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}








/*
var dictionaty : [[String: String]] = {
    
    var clas = Divider(text: """
                            - [ ] tree - come before in time. The gun battle has preceded the explosions.
                            - [ ] Determine - вычислять, решать.
                            - [ ] tree - взаимодействие.
                            - [ ] coal -
                            - [ ] Singaphour -
                            - [ ] Flower -
                            -
                            """)
    clas.divider()
    var dict = clas.dividedText
    return dict
}()
var number = 0

var currentWord = [String]()
var imageUIImage = UIImage()


var nextButton : UIButton = {
    var button = UIButton(type: .custom)
    button.configuration = .plain()
    button.configuration?.background.backgroundColor = .lightGray
    button.configuration?.baseForegroundColor = .black
    button.layer.cornerRadius = 7
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor(named: "darkGray")?.cgColor
    button.layer.shadowOffset = CGSize(width: 2, height: 2)
    button.layer.shadowRadius = 1
    button.configuration?.title = "Next Card"
    
return button
}()

var generatedImage : UIImageView = {
    let image = UIImageView()
    image.layer.cornerRadius = 9
    image.clipsToBounds = true
    image.layer.masksToBounds = true
    image.contentMode = .scaleAspectFit

    return image
}()
override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    currentWord = [dictionaty[number].first!.key]
    imageUIImage = UIImage(named: (currentWord.first)!) ?? UIImage(systemName: "xmark.seal")!
    setUpFrames()
}
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    
}
func setUpFrames(){
    setUpImageLayout()
    setUpButtonLayout()
}

func setUpImageLayout(){
    view.addSubview(generatedImage)
    generatedImage.image = imageUIImage
    generatedImage.translatesAutoresizingMaskIntoConstraints = false
    var screenSize = view.bounds.size
    var imageSize = imageUIImage.size
    print(imageSize.height)
    var scaleFactor = CGSize(width: imageSize.width / screenSize.width, height: imageSize.height
                            / screenSize.height)
    print(scaleFactor)

    var imageAspecct = imageSize.height / imageSize.width
    var screenAspect = screenSize.height / screenSize.width
    print(screenAspect)
    print(imageAspecct)
    
    
    NSLayoutConstraint.activate([
        generatedImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        
        
                ])
    if imageSize.width > imageSize.height{
        generatedImage.heightAnchor.constraint(equalToConstant: screenSize.height - (view.safeAreaInsets.top + view.safeAreaInsets.bottom) - 150 ).isActive = false
        generatedImage.widthAnchor.constraint(equalTo: generatedImage.heightAnchor, multiplier: imageAspecct).isActive = false
        generatedImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = false
        
        generatedImage.widthAnchor.constraint(equalToConstant: screenSize.width - 40).isActive = true
        generatedImage.heightAnchor.constraint(equalTo: generatedImage.widthAnchor, multiplier: imageAspecct ).isActive = true
        generatedImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = false
        generatedImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true

    } else {
        generatedImage.widthAnchor.constraint(equalToConstant: screenSize.width - 40).isActive = false
        generatedImage.heightAnchor.constraint(equalTo: generatedImage.widthAnchor, multiplier: imageAspecct ).isActive = false
        generatedImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = false
        generatedImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = false

        generatedImage.heightAnchor.constraint(equalToConstant: screenSize.height - (view.safeAreaInsets.top + view.safeAreaInsets.bottom) - 150 ).isActive = true
        generatedImage.widthAnchor.constraint(equalTo: generatedImage.heightAnchor, multiplier: imageAspecct).isActive = true
        generatedImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }

    
}
func setUpButtonLayout(){
    view.addSubview(nextButton)
    nextButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
    
    nextButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        nextButton.widthAnchor.constraint(equalToConstant: 150),
        nextButton.heightAnchor.constraint(equalToConstant: 50),
        nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        nextButton.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
    ])
}
@objc func buttonPressed(sender: UIButton){
    presentNewImage()
}
func presentNewImage(){
    number += 1
    self.present(NextViewController(), animated: true)
}
*/
