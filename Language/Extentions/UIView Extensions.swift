//
//  UIView Extensions.swift
//  Language
//
//  Created by Star Lord on 22/07/2023.
//

import Foundation
import UIKit

extension UIView {
    //MARK: Method to add multiple subviews.
    func addSubviews(_ views: UIView...){
        for i in views{
            self.addSubview(i)
        }
    }

    //MARK: - Creating mask with concave side on left and cambered on right side.
    //For custom actions embeded in MainView cell
    func configureActionMaskWith(size: CGSize, cornerRadius: CGFloat) -> CAShapeLayer{
        let cornerRadius: CGFloat = cornerRadius
        
        let bezierPath = UIBezierPath()
        let startPoint = CGPoint(x: 0, y: 0)
        bezierPath.move(to: startPoint)
        
        let point1 = CGPoint(x: size.width - cornerRadius, y: 0)
        bezierPath.addLine(to: point1)
        bezierPath.addArc(withCenter: CGPoint(x: point1.x, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat(Double.pi / 2 * 3), endAngle: 0, clockwise: true)
        
        let point2 = CGPoint(x: size.width, y: size.height - cornerRadius)
        bezierPath.addLine(to: point2)
        bezierPath.addArc(withCenter: CGPoint(x: point1.x, y: point2.y), radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)
        
        
        let point3 = CGPoint(x: 0, y: size.height)
        bezierPath.addLine(to: point3)
        bezierPath.addArc(withCenter: CGPoint(x: point3.x, y: point3.y - cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi / 2 , endAngle: 0, clockwise: false)
        
        let point4 = CGPoint(x: cornerRadius, y: cornerRadius)
        bezierPath.addLine(to: point4)
        bezierPath.addArc(withCenter: CGPoint(x: 0, y: cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi / 2 * 3 , clockwise: false)
        
        bezierPath.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        return shapeLayer
    }
    //MARK: - Method to round corners on one side.
    func configureOneSideRoundedMask(for view: UIView, left: Bool, cornerRadius: CGFloat) -> CAShapeLayer{
        let path = UIBezierPath(roundedRect: view.bounds,
                                byRoundingCorners: left ? [.topLeft, .bottomLeft] : [.bottomRight, .topRight],
                                        cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        return mask
    }
    //MARK: - Method to add rounded corners and gray colour.
    func setUpCustomView(){
        self.layer.cornerRadius = 9
        self.addRightSideShadow()
        self.backgroundColor = .secondarySystemBackground
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    //MARK: - Creating top stroke offset by navigation Controller.
    func addTopStroke(vc: UIViewController) -> CAShapeLayer{
        let topStroke = CAShapeLayer()
        let path = UIBezierPath()
        let y = {
            if vc.navigationController != nil {
                return vc.view.safeAreaInsets.top
            } else {
                return 0
            }
        }()
        path.move(to: CGPoint(x: 0, y: y ))
        path.addLine(to: CGPoint(x: vc.view.bounds.maxX, y: y))
        topStroke.path = path.cgPath
        topStroke.lineWidth = 0.8
        topStroke.strokeColor = UIColor.label.cgColor
        topStroke.fillColor = UIColor.clear.cgColor
        topStroke.opacity = 0.8
        
        return topStroke
    }
    
    //MARK: Create bottom stroke offset by tabBar controller.
    func addBottomStroke(vc: UIViewController) -> CAShapeLayer{
        let path = UIBezierPath()
        let y = {
            if vc.tabBarController?.tabBar != nil{
                return vc.tabBarController!.tabBar.frame.minY
            } else {
                return 0
            }
        }()
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: vc.view.bounds.maxX, y: y))
        let stroke = CAShapeLayer()
        stroke.path = path.cgPath
        stroke.lineWidth = 0.8
        stroke.strokeColor = UIColor.label.cgColor
        stroke.fillColor = UIColor.clear.cgColor
        stroke.opacity = 0.8
        
        return stroke
    }
    //MARK: - Creates shadow for a view with 0 side ofset
    func addCenterShadows(){
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowColor = ((traitCollection.userInterfaceStyle == .dark)
                                  ? shadowColorForDarkIdiom
                                  : shadowColorForLightIdiom)
        self.layer.shadowOpacity = 0.8
    }

    //MARK: - Creates shadow for a view with slight side offset.
    func addRightSideShadow(){
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 4, height: 5)
        self.layer.shadowColor = ((traitCollection.userInterfaceStyle == .dark)
                                  ? shadowColorForDarkIdiom
                                  : shadowColorForLightIdiom)
        self.layer.shadowOpacity =  0.8
    }

}

extension UIStackView{
    func addArrangedSubviews(_ views: UIView...){
        for view in views{
            self.addArrangedSubview(view)
        }
    }
    
}
