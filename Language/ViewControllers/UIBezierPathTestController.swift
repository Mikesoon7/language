//
//  UIBezierPathTestController.swift
//  Language
//
//  Created by Star Lord on 27/05/2023.
//

import UIKit

class UIBezierPathTestController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let shape = configureMaskFor(frame: CGSize(width: 300, height: 300))
        shape.frame = CGRect(x: 50, y: 100, width: 300, height: 300)
        view.layer.addSublayer( shape)
    }
    

    func configureMaskFor(frame: CGSize) -> CAShapeLayer{
        let cornerRadius: CGFloat = 9

        let bezierPath = UIBezierPath()
        let startPoint = CGPoint(x: 0, y: 0)
        bezierPath.move(to: startPoint)

        let point1 = CGPoint(x: frame.width - cornerRadius, y: 0)
        bezierPath.addLine(to: point1)
        bezierPath.addArc(withCenter: CGPoint(x: point1.x, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat(Double.pi / 2 * 3), endAngle: 0, clockwise: true)

        let point2 = CGPoint(x: frame.width, y: frame.height - cornerRadius)
        bezierPath.addLine(to: point2)
        bezierPath.addArc(withCenter: CGPoint(x: point1.x, y: point2.y), radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi / 2, clockwise: true)


        let point3 = CGPoint(x: 0, y: frame.height)
        bezierPath.addLine(to: point3)
        bezierPath.addArc(withCenter: CGPoint(x: point3.x, y: point3.y - cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi / 2 , endAngle: 0, clockwise: false)

        let point4 = CGPoint(x: cornerRadius, y: cornerRadius)
        bezierPath.addLine(to: point4)
        bezierPath.addArc(withCenter: CGPoint(x: 0, y: cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi / 2 * 3 , clockwise: false)

        bezierPath.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        
        return shapeLayer
    }
}
