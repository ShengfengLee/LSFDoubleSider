//
//  LSFDoubleSiderThumbLayer.swift
//  LSFDoubleSider_Example
//
//  Created by 李胜锋 on 2020/2/8.
//  Copyright © 2020 李胜锋. All rights reserved.
//

import UIKit

class LSFDoubleSiderThumbLayer: CALayer {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    ///渐变图层
    public let gradientLayer = CAGradientLayer()

    open override func draw(in ctx: CGContext) {
        self.cornerRadius = self.frame.size.height / 2
        self.masksToBounds = true
    
        gradientLayer.frame = self.bounds
        
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        self.addSublayer(gradientLayer)
        gradientLayer.setNeedsDisplay()
    }
}
