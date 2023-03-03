//
//  LaunchScreenAnimation.swift
//  Language
//
//  Created by Star Lord on 02/03/2023.
//
import AVKit
import AVFoundation
import UIKit

class LaunchScreenAnimation: UIViewController {
    
    let label: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "Learny",
                                                  attributes: [NSAttributedString.Key.font :
                                                                UIFont(name: "Georgia-BoldItalic",
                                                                       size: 20) ?? UIFont()])
        
        return label
    }()
    let animationView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 9
        view.layer.masksToBounds = true
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.isNavigationBarHidden = true
//        playVideo(from: "Launch3.mp4")
        additionalViewCustom()
        labelCustomization()

        initialAnimation()
            }
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
        
                }
    
    func labelCustomization(){
        animationView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: animationView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: animationView.centerXAnchor)
        ])
        
    }
    func additionalViewCustom(){
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height / 3),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width / 3),
            animationView.widthAnchor.constraint(equalToConstant: view.bounds.width / 3),
            animationView.heightAnchor.constraint(equalTo: animationView.widthAnchor)
        ])
    }
    func initialAnimation(){

        func strokeLayerFrom(_ startPoint: CGPoint, to endPoint: CGPoint, _ strokeWidth: CGFloat , with color: UIColor, _ readyPath: UIBezierPath?) -> (CAShapeLayer) {
            let layer = CAShapeLayer()
            layer.strokeColor = color.cgColor
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = strokeWidth
            guard readyPath == nil else {
                layer.path = readyPath?.cgPath
                return layer
            }
            let path = UIBezierPath()
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            layer.path = path.cgPath
            return layer
        }
//Black to draw
        let widthPont = view.bounds.width / 3
        let heightPoint = view.bounds.height / 3
        let topLeft = strokeLayerFrom(CGPoint(x: widthPont , y: 0 ), to: CGPoint(x: widthPont, y: heightPoint * 3), 5, with: .label, nil)
        let topRight = strokeLayerFrom(CGPoint(x: widthPont * 2, y: 0), to: CGPoint(x: widthPont * 2, y: heightPoint * 3), 5, with: .label, nil)
        let rightTop = strokeLayerFrom(CGPoint(x: 0, y: heightPoint), to: CGPoint(x: widthPont * 3, y: heightPoint), 5,  with: .label, nil)
        let rightBottom = strokeLayerFrom(CGPoint(x: 0, y: heightPoint + widthPont ), to: CGPoint(x: widthPont * 3 , y: heightPoint + widthPont), 5, with: .label, nil)
        
//White to vanish
        let topLeftV = strokeLayerFrom(CGPoint(x: widthPont , y: 0 ), to: CGPoint(x: widthPont, y: heightPoint * 3), 6,  with: .systemBackground, nil)
        let topRightV = strokeLayerFrom(CGPoint(x: widthPont * 2, y: 0), to: CGPoint(x: widthPont * 2, y: heightPoint * 3), 6,  with: .systemBackground, nil)
        let rightTopV = strokeLayerFrom(CGPoint(x: 0, y: heightPoint), to: CGPoint(x: widthPont * 3, y: heightPoint), 6,  with: .systemBackground, nil)
        let rightBottomV = strokeLayerFrom(CGPoint(x: 0, y: heightPoint + widthPont ), to: CGPoint(x: widthPont * 3 , y: heightPoint + widthPont), 6, with: .systemBackground, nil)

            
        
        CATransaction.begin()
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 3
        animation.duration = 4
        
        let animationToVanish = CABasicAnimation(keyPath: "strokeEnd")
        animationToVanish.fromValue = 0.0
        animationToVanish.toValue = 1.3
        animationToVanish.duration = 4
        
        topLeft.add(animation, forKey: "myStroke")
        topRight.add(animation, forKey: "myStroke")
        rightTop.add(animation, forKey: "myStroke")
        rightBottom.add(animation, forKey: "myStroke")
        
        topLeftV.add(animationToVanish, forKey: "myStroke")
        topRightV.add(animationToVanish, forKey: "myStroke")
        rightTopV.add(animationToVanish, forKey: "myStroke")
        rightBottomV.add(animationToVanish, forKey: "myStroke")


        CATransaction.setCompletionBlock{ [weak self] in
            
        }

                
        CATransaction.commit()
        
        view.layer.addSublayer(topRight)
        view.layer.addSublayer(topRightV)
        view.layer.addSublayer(rightTop)
        view.layer.addSublayer(rightBottom)
        view.layer.addSublayer(rightBottomV)
        view.layer.addSublayer(topLeft)
        view.layer.addSublayer(topLeftV)
        view.layer.addSublayer(rightTopV)

        self.perform(#selector(goBack(sender:)), with: MenuVC(), afterDelay: TimeInterval(floatLiteral: 4.0) )

    }
    @objc func goBack(sender: Any){
        self.navigationController?.popToRootViewController(animated: true)
        }
    

        
    /*
     private func playVideo(from file:String) {
        let file = file.components(separatedBy: ".")

        guard let path = Bundle.main.path(forResource: file[0], ofType:file[1]) else {
            debugPrint( "\(file.joined(separator: ".")) not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
    
        playerController.player = player
        playerController.showsPlaybackControls = false
        playerController.modalPresentationStyle = .overFullScreen
        playerController.entersFullScreenWhenPlaybackBegins = true
        playerController.view.backgroundColor = .white
        modalPresentationStyle = .overFullScreen
        present(playerController, animated: false)
        player.play()
    }
    
    
     */
}
