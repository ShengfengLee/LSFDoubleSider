//
//  LSFGradientSlider.swift
//  LSFDoubleSider_Example
//
//  Created by 李胜锋 on 2020/2/9.
//  Copyright © 2020 李胜锋. All rights reserved.
//

import UIKit


open class LSFGradientSlider: UIControl {
    
    /// default 0.0. this value will be pinned to min/max
    open var value: Float

    /// default 0.0. the current value may change if outside new min value
    open var minimumValue: Float
    /// default 1.0. the current value may change if outside new max value
    open var maximumValue: Float

    open var trackHeight: CGFloat = 2
    ///track渐变色(水平方向)
    open var trackColors: [UIColor]?
    open var trackBackColor: UIColor
    
    open var thumbSize: CGSize
    ///track渐变色(垂直方向)
    open var thumbColors: [UIColor]?
    
    
    var trackLayer = LSFDoubleSiderTrackLayer()
    var thumbLayer = LSFDoubleSiderThumbLayer()
    ///记录滑动式上一次的point
    fileprivate var previousTouchPoint: CGPoint = CGPoint.zero
    
    init(value: Float = 0.0,
         minimumValue: Float = 0.0,
         maximumValue: Float = 1.0,
         trackHeight: CGFloat = 2,
         trackBackColor: UIColor = UIColor.gray,
         trackColors: [UIColor]? = nil,
         thumbColors: [UIColor]? = nil,
         thumbSize: CGSize = CGSize(width: 30, height: 30)) {
             self.value = value
        
             self.minimumValue = minimumValue
             self.maximumValue = maximumValue
        
             self.trackHeight = trackHeight
             self.trackColors = trackColors
             self.trackBackColor = trackBackColor
        
             self.thumbSize = thumbSize
             self.thumbColors = thumbColors
        
        super.init(frame: CGRect.zero)
        
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func set(value: Float) {
        self.value = value
        setLayerFrame()
    }
    
    open func setup() {
        //track
        trackLayer.backgroundColor = trackBackColor.cgColor
        //渐变色
        if let trackColors = self.trackColors {
            let cgColors = trackColors.map { $0.cgColor }
            trackLayer.middleLayer.colors = cgColors
        }
        self.layer.addSublayer(trackLayer)
        
        //滑块
        thumbLayer.backgroundColor = UIColor.green.cgColor
        self.layer.addSublayer(thumbLayer)
        //滑块渐变色
        if let trackColors = self.trackColors {
            let cgColors = trackColors.map { $0.cgColor }
            thumbLayer.gradientLayer.colors = cgColors
        }
        
        setLayerFrame()
    }
    
    
    private func setLayerFrame() {
        trackLayer.frame = CGRect(x: thumbSize.width / 2,
                                  y: (self.frame.size.height - trackHeight) / 2,
                                  width: self.frame.size.width - thumbSize.width,
                                  height: trackHeight)
        trackLayer.setNeedsDisplay()
        
        //计算滑块的位置
        let centerX = positionFor(value: value)
        thumbLayer.frame = CGRect(x: centerX - thumbSize.width / 2,
                                  y: (self.frame.size.height - thumbSize.height) / 2,
                                  width: thumbSize.width,
                                  height: thumbSize.height)
        thumbLayer.setNeedsDisplay()
        
        
        
        trackLayer.lowerCenterX = 0
        trackLayer.upperCenterX = centerX
        
    }
    
    ///根据滑块的值来计算滑块对应的center的x值
    private func positionFor(value: Float) -> CGFloat {
        let delta = (value - minimumValue) / (maximumValue - minimumValue)
        //track的宽度
        let trackWidth = self.frame.size.width - thumbSize.width
        let position = trackWidth * CGFloat(delta) + thumbSize.width / 2
        return position
    }
    
}

//MARK: Touch事件
extension LSFGradientSlider {
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousTouchPoint = touch.location(in: self)
        
        //选中滑块
        if thumbLayer.frame.contains(previousTouchPoint) {
            thumbLayer.setNeedsDisplay()
            return true
        }
        return false
    }
    
    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
       let point = touch.location(in: self)
        
        let delta = point.x - previousTouchPoint.x
        let deltaValue = (maximumValue - minimumValue) * Float(delta) / Float(trackLayer.frame.size.width)
        previousTouchPoint = point
        
        //更新滑块的值
        value += deltaValue
        if value < minimumValue {
            value = minimumValue
        }
        if value > maximumValue {
            value = maximumValue
        }
        print("value: \(value)")
        
        //更新UI
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        setLayerFrame()
        CATransaction.commit()
        
        return true
    }
    
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        thumbLayer.setNeedsDisplay()
    }
}

