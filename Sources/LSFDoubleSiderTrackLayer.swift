//
//  LSFDoubleSiderTrackLayer.swift
//  LSFDoubleSider_Example
//
//  Created by 李胜锋 on 2020/2/8.
//  Copyright © 2020 李胜锋. All rights reserved.
//

import UIKit

open class LSFDoubleSiderTrackLayer: CALayer {

    open var lowerCenterX: CGFloat = 0
    open var upperCenterX: CGFloat = 0

    ///渐变图层
    public let middleLayer = CAGradientLayer()


    
    open override func draw(in ctx: CGContext) {
        self.cornerRadius = self.frame.size.height / 2
        self.masksToBounds = true
        
        let lower = self.lowerCenterX - self.frame.origin.x
        let upper = self.upperCenterX - self.frame.origin.x
        
        middleLayer.frame = CGRect(x: lower,
                                   y: 0,
                                   width: upper - lower,
                                   height: self.frame.size.height)
        
        middleLayer.locations = [0, 1]
        middleLayer.startPoint = CGPoint(x: 0, y: 0)
        middleLayer.endPoint = CGPoint(x: 1, y: 0)
        
        self.addSublayer(middleLayer)
        middleLayer.setNeedsDisplay()
    }
}
