//
//  LaunchAnimation.swift
//  Language
//
//  Created by Star Lord on 03/04/2023.
//

import UIKit

class LaunchAnimation{
    
    var animationView : UIView!
    private var cardView: UIView!
    
    private var label1 : UILabel!
    private var label2 : UILabel!
    
    private var userInterfaceStyle: UIUserInterfaceStyle
//    var userInterfaceStyle: UIUserInterfaceStyle = UserSettings.shared.appTheme.userInterfaceStyle
    
    init(bounds: CGRect, interfaceStyle: UIUserInterfaceStyle){
        self.userInterfaceStyle = interfaceStyle
        animationView = {
            let view = UIView(frame: bounds)
            view.backgroundColor = .systemBackground
            return view
        }()
    }

    func animate(){
        animationViewsCustomization()
        stokeAnimationCustomization()
    }
//MARK: - AnimationViews SetUp
    func animationViewsCustomization(){
        cardView = {
            let view = UIView(frame: CGRect(x: 0, y: 0,
                                            width: animationView.frame.width * 0.7,
                                            height: animationView.frame.height * 0.5))
            view.center = animationView.center
            view.backgroundColor = .systemBackground
            view.layer.cornerRadius = 24
            return view
        }()

        label1 = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.attributedText = NSAttributedString().fontWithString(string: "Learny", bold: true, size: 20)
            return label
        }()
        
        label2 = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.attributedText = NSAttributedString().fontWithString(string: "To brew something new", bold: true, size: 16)
            return label
        }()
        
        animationView.addSubview(cardView)
        cardView.addSubviews(label1, label2)
        
        NSLayoutConstraint.activate([
            label1.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            label1.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            
            label2.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            label2.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
        ])
    }
    func changeLabelColor(){
        label1.alpha = 0
        label2.alpha = 0
    }
//MARK: - Run animation Set Up
    func makeKeyView(){
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first{
            window.addSubview(animationView)
            window.bringSubviewToFront(animationView)
        }
    }
//MARK: - CreateStroke
    func stokeAnimationCustomization(){
        let width = cardView.bounds.width
        let height = cardView.bounds.height
        let startY = cardView.bounds.midY
        let curveInset = 24.0
        
        let upperStroke = createLineFrom(CGPoint(x: cardView.bounds.maxX, y: startY), upper: true)
        let downStroke = createLineFrom(CGPoint(x: cardView.bounds.minX, y: startY), upper: false )
        
        CATransaction.begin()
       
        upperStroke.add(strokeAnimation(from: 0, to: 1, inSec: 2), forKey: "Stroke")
        downStroke.add(strokeAnimation(from: 0, to: 1, inSec: 2), forKey: "Stroke")
        
        cardView.layer.addSublayer(upperStroke)
        cardView.layer.addSublayer(downStroke)
        
        CATransaction.commit()
        
        //Animation "Touch" and rotation.
        UIView.animate(withDuration: 0.3, delay: 2) { [weak self] in
            self!.cardView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.2, delay: 0, animations: {
                self!.changeLabelColor()
                scaleAndRotate()
            }
            )}
        //Creating strokes with up/down options
        func createLineFrom(_ start: CGPoint, upper: Bool) -> CAShapeLayer{
            func controlPoint(startPoint: CGPoint, endPoint: CGPoint) -> CGPoint{
                let midPoint = CGPoint(x: (startPoint.x + endPoint.x) / 2,
                                       y: (startPoint.y + endPoint.y) / 2)
                let deltaX = endPoint.x - startPoint.x
                let deltaY = endPoint.y - startPoint.y
                let distance = sqrt(deltaX * deltaX + deltaY * deltaY)
                let controlPoint = CGPoint(x: midPoint.x - deltaY * 14 / distance,
                                           y: midPoint.y + deltaX * 14 / distance)
                return controlPoint
            }
            
            let layer = CAShapeLayer()
            layer.strokeColor =
            {
                switch userInterfaceStyle{
                case .light:
                    return UIColor.black.cgColor
                case .dark:
                    return UIColor.white.cgColor
                default: return UIColor.label.cgColor
                }
            }()
            layer.fillColor = UIColor.clear.cgColor
            layer.lineWidth = 3
            let path = UIBezierPath()
            
            path.move(to: start)
            
            if upper {
                let nextPoint = CGPoint(x: start.x,
                                        y: start.y - ((height / 2) - curveInset))
                path.addLine(to: nextPoint)
                let nextPoint1 = CGPoint(x: nextPoint.x - curveInset,
                                         y: nextPoint.y - curveInset)
                path.addQuadCurve(to: nextPoint1,
                                  controlPoint: controlPoint(startPoint: nextPoint, endPoint: nextPoint1))
                
                let nextPoint2 = CGPoint(x: nextPoint1.x - (width - curveInset * 2),
                                         y: nextPoint1.y)
                path.addLine(to: nextPoint2)
                let nextPoint3 = CGPoint(x: nextPoint2.x - curveInset,
                                         y: nextPoint2.y + curveInset)
                path.addQuadCurve(to: nextPoint3, controlPoint: controlPoint(startPoint: nextPoint2, endPoint: nextPoint3))
                let endPoint = CGPoint(x: nextPoint3.x,
                                       y: startY)
                path.addLine(to: endPoint)
                layer.path = path.cgPath
                
            } else {
                
                let nextPoint = CGPoint(x: start.x,
                                        y: start.y + ((height / 2) - curveInset))
                path.addLine(to: nextPoint)
                let nextPoint1 = CGPoint(x: nextPoint.x + curveInset,
                                         y: nextPoint.y + curveInset)
                path.addQuadCurve(to: nextPoint1,
                                  controlPoint: controlPoint(startPoint: nextPoint, endPoint: nextPoint1))
                
                let nextPoint2 = CGPoint(x: nextPoint1.x + (width - curveInset * 2),
                                         y: nextPoint1.y)
                path.addLine(to: nextPoint2)
                let nextPoint3 = CGPoint(x: nextPoint2.x + curveInset,
                                         y: nextPoint2.y - curveInset)
                path.addQuadCurve(to: nextPoint3, controlPoint: controlPoint(startPoint: nextPoint2, endPoint: nextPoint3))
                let endPoint = CGPoint(x: nextPoint3.x,
                                       y: startY)
                path.addLine(to: endPoint)
                layer.path = path.cgPath
            }
            return layer
        }
        //Animation for strokes
        func strokeAnimation(from: CGFloat, to: CGFloat, inSec: CFTimeInterval) -> CABasicAnimation{
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = from
            animation.toValue = to
            animation.duration = inSec
            return animation
        }
        //Scale and rotate + fading animation view
        func scaleAndRotate(){
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
            rotationAnimation.fromValue = 0
            rotationAnimation.toValue = Double.pi * 1
            rotationAnimation.duration = 1
            rotationAnimation.isRemovedOnCompletion = false
            rotationAnimation.fillMode = .forwards
            
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = 0.8
            scaleAnimation.toValue = 2.8
            scaleAnimation.duration = 1
            scaleAnimation.repeatCount = 1
            scaleAnimation.isRemovedOnCompletion = false
            scaleAnimation.fillMode = .forwards
            
            
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [rotationAnimation, scaleAnimation]
            animationGroup.duration = 1
            animationGroup.repeatCount = 1
            animationGroup.isRemovedOnCompletion = false
            animationGroup.fillMode = .forwards
            
            cardView.layer.add(animationGroup, forKey: "rotationAndScaleAnimation")
            
            UIView.animate(withDuration: 2, delay: 0.9) { [weak self] in
                self!.animationView.alpha = 0
            }
        }
    }
}

class LoadingAnimation: UIView {
    
    private var dots: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let dotRadius: CGFloat = 5
        let dotDiameter: CGFloat = dotRadius * 2
        let dotSpacing: CGFloat = 5

        let totalWidth: CGFloat = (dotDiameter * 3) + (dotSpacing * 2)

        for i in 0..<3 {
            let dot = UIView(frame: CGRect(x: (dotDiameter + dotSpacing) * CGFloat(i), y: 0, width: dotDiameter, height: dotDiameter))
            dot.backgroundColor = .label
            dot.layer.cornerRadius = dotRadius
            addSubview(dot)
            dots.append(dot)
        }

        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: totalWidth, height: dotDiameter)
    }
    
    func startAnimating(){
        for i in 0..<dots.count {
            let dot = dots[i]
            
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.duration = 0.5
            animation.fromValue = 1
            animation.toValue = 0.1
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animation.beginTime = CACurrentMediaTime() + (0.2 * Double(i))

            dot.layer.add(animation, forKey: "loadingAnimation")
        }
    }
    
    func stopAnimating() {
        for dot in dots {
            dot.layer.removeAnimation(forKey: "loadingAnimation")
        }
    }
}
