//
//  LaunchAnimation.swift
//  Language
//
//  Created by Star Lord on 03/04/2023.
//

import UIKit

protocol LaunchAnimationDelegate: AnyObject{
    func animationDidFinish(animationView: UIView?)
}
class LaunchAnimation{
    //MARK: Properties
    private var bounds: CGRect
    private var window: UIWindow?
    
    private var borderWidth     = 3.0
    private var cornerRadius    = 20.0
    
    private var cardWidth   = CGFloat()
    private var cardHeight  = CGFloat()
    
    private var cardHeightConstant: NSLayoutConstraint = .init()
    private var cardWidthConstant:  NSLayoutConstraint = .init()
    
    private var viewHeightConstraint:   NSLayoutConstraint = .init()
    private var viewWidthConstraint:    NSLayoutConstraint = .init()
    

    private weak var delegate: LaunchAnimationDelegate?
    
    //MARK: Subviews
    var animationView : UIView = UIView()
    private var cardView = UIView()

    private var titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = .attributedString(string: "Learny", with: .georgianBoldItalic, ofSize: 20)
        return label
    }()
    
    private var subtitleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = .attributedString(string: "To brew something new", with: .georgianBoldItalic, ofSize: 16)
        return label
    }()
    
    private var userInterfaceStyle: UIUserInterfaceStyle
    
    init(window: UIWindow?, bounds: CGRect, interfaceStyle: UIUserInterfaceStyle, delegate: LaunchAnimationDelegate){
        self.userInterfaceStyle = interfaceStyle
        self.delegate = delegate
        self.bounds = bounds
        self.window = window
    }
    
    func animate(){
        self.animationViewsCustomization()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [weak self] in
            self?.stokeAnimationCustomization()
        })
    }
    
    //MARK: - AnimationViews SetUp
    ///Configure laucnhAnimation subviews.
    func animationViewsCustomization() {
        //For iPad version we must assure that card view gonna be proportionaly correct in split view with height excedeing width twice.
        let isSplitScreen = isInSplitScreenMode()
        let widthToHeightRatio = bounds.width / bounds.height
        let isWidthMainAnchor = isSplitScreen && widthToHeightRatio < 0.5
        
        cardHeight = isWidthMainAnchor  ? (bounds.width * 0.8) / 0.6    : (bounds.height * 0.6)
        cardWidth = isWidthMainAnchor   ? (bounds.width * 0.8)          : (bounds.height * 0.6) * 0.6
        
        
        guard let window = window else {
            animationView = {
                let view = UIView(frame: bounds)
                view.backgroundColor = .systemBackground
                return view
            }()
            cardView = {
                let view = UIView(frame: CGRect(x: 0,
                                                y: 0,
                                                width: cardWidth,
                                                height: cardHeight)
                )
                view.center = animationView.center
                view.backgroundColor = .systemBackground
                view.layer.cornerRadius = 20
                return view
            }()
            
            animationView.addSubview(cardView)
            cardView.addSubviews(titleLabel, subtitleLabel)
            
            NSLayoutConstraint.activate([
                titleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
                titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
                
                subtitleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
                subtitleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            ])

            return
        }
        self.animationView = {
            let view = UIView()
            view.backgroundColor = .systemBackground
            view.translatesAutoresizingMaskIntoConstraints = false
            
            
            return view
        }()
        cardView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .systemBackground
            view.layer.cornerRadius = 20
            return view
        }()
        
        window.addSubview(animationView)
        animationView.addSubview(cardView)
        cardView.addSubviews(titleLabel, subtitleLabel)
        
        cardHeightConstant = cardView.heightAnchor.constraint(equalToConstant: cardHeight)
        cardWidthConstant = cardView.widthAnchor.constraint(equalToConstant: cardWidth)

        viewHeightConstraint = cardView.heightAnchor.constraint(equalTo: animationView.heightAnchor, constant: 5)
        viewWidthConstraint = cardView.widthAnchor.constraint(equalTo: animationView.widthAnchor, constant: 5)
        
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: window.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: window.bottomAnchor),

            cardWidthConstant,
            cardHeightConstant,
            cardView.centerXAnchor.constraint(equalTo: animationView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: animationView.centerYAnchor),
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            subtitleLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
        ])

    }
    
    //MARK: - Run animation Set Up
    func makeKeyView(){
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first{
            window.addSubview(animationView)
            window.bringSubviewToFront(animationView)
        }
    }
    ///Cheks whether the main screen is in split mode or not
    private func isInSplitScreenMode() -> Bool {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return false
        }
        return window.bounds.width < UIScreen.main.bounds.width
    }
    
    //MARK: - CreateStroke
    func stokeAnimationCustomization(){
        let width = cardWidth
        let height = cardHeight
        let startY = cardHeight / 2
        let curveInset = 20.0
                
        let upperStroke = createLineFrom(CGPoint(x: cardWidth, y: startY), upper: true)
        let downStroke = createLineFrom(CGPoint(x: 0, y: startY), upper: false )
        
        CATransaction.begin()
        
        upperStroke.add(strokeAnimation(inSec: 1.8), forKey: "Stroke")
        downStroke.add(strokeAnimation(inSec: 1.8), forKey: "Stroke")
        
        cardView.layer.addSublayer(upperStroke)
        cardView.layer.addSublayer(downStroke)
        
        CATransaction.commit()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            scaleAndRotate()
        })
        
        
        ///Creates a BezierPath for view's border in two pieces ( upper or  Returns CAShapeLayer with BezierPath as a path.
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
            layer.strokeColor = {
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
            layer.cornerCurve = .continuous
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
        
        
        ///Returns progressive animation.
        func strokeAnimation(from: CGFloat = 0.0 , to: CGFloat = 1.0 , inSec: CFTimeInterval) -> CABasicAnimation{
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = from
            animation.toValue = to
            animation.duration = inSec
            return animation
        }
        
        func configureViewsBorder(){
            cardView.layer.borderWidth = 3
            cardView.layer.borderColor = { [weak self] in
                switch self?.userInterfaceStyle {
                case .light:
                    return UIColor.black.cgColor
                case .dark:
                    return UIColor.white.cgColor
                default:
                    return UIColor.label.cgColor
                }
            }()
            upperStroke.removeFromSuperlayer()
            downStroke.removeFromSuperlayer()
            cardView.layer.cornerCurve = CALayerCornerCurve.continuous
        }
        
        //Scale and rotate + fading animation view
        func scaleAndRotate(){
            let duration = 0.8
            let goalCornerRadius = UIDevice.current.userInterfaceIdiom == .phone ? 43.0 : cornerRadius
            var perspective = CATransform3DIdentity
            perspective.m34 = -1.0 / 5000.0
            
            let liftTransform       = CATransform3DTranslate(perspective, 0, -50, 0)
            let initialTransfrom    = CATransform3DTranslate(perspective, 0, 0, 0)
       
            let halfwayRotateTranform   = CATransform3DRotate(perspective, .pi / 2, 0, 1, 0)
            let finalRotateTransform    = CATransform3DRotate(perspective, .pi, 0, 1, 0)
        
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear) {
                self.cardView.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            } completion: { _ in
                UIView.animate(withDuration: duration / 2, delay: 0 ) {
                    self.cardView.layer.transform = CATransform3DConcat(halfwayRotateTranform, liftTransform)
                } completion: { _ in
                    configureViewsBorder()
                    self.titleLabel.alpha = 0
                    self.subtitleLabel.alpha = 0
                    UIView.animate(withDuration: duration / 2) {
                        self.cardView.layer.transform = CATransform3DConcat(finalRotateTransform, initialTransfrom)
                    }
                    UIView.animate(withDuration: duration / 2 + 0.8) {
                        self.cardWidthConstant.isActive = false
                        self.cardHeightConstant.isActive = false
                        
                        self.viewWidthConstraint.isActive = true
                        self.viewHeightConstraint.isActive = true
                        self.cardView.layer.cornerRadius = goalCornerRadius
                        
                        self.animationView.layoutIfNeeded()
                    } completion: { _ in
                        UIView.animate(withDuration: 0.4, delay: 0) {
                            self.animationView.alpha = 0
                        } completion: { _ in
                            self.delegate?.animationDidFinish(animationView: self.animationView)
                        }
                    }
                }
            }
        }
    }
}


class LoadingAnimation: UIView {
    
    private var dots: [UIView] = []
    private var dotAnimation: CABasicAnimation = .init()
    
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
        prepareAniamation()
    }
    func prepareAniamation(){
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = 0.5
        animation.fromValue = 1
        animation.toValue = 0.1
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.repeatCount = .infinity
        animation.autoreverses = true
        
        dotAnimation = animation
    }
    
    func startAnimating(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for i in 0..<dots.count {
                let dot = dots[i]
                
                let animation = dotAnimation
                animation.beginTime = CACurrentMediaTime() + (0.1 * Double(i))

                dot.layer.add(animation, forKey: "loadingAnimation")
            }
        }
    }
    
    func stopAnimating() {
        for dot in dots {
            dot.layer.removeAnimation(forKey: "loadingAnimation")
        }
    }
}
