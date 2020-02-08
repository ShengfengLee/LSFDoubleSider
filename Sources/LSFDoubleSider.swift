//
//  LSFDoubleSider.swift
//  LSFDoubleSider_Example
//
//  Created by 李胜锋 on 2020/2/8.
//  Copyright © 2020 李胜锋. All rights reserved.
//

import UIKit

open class LSFDoubleSider: UIControl {
    
    /// default 0.0. this value will be pinned to min/max
    open var lowerValue: Float
    /// default 1.0. this value will be pinned to min/max
    open var upperValue: Float

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
    var lowerThumbLayer = LSFDoubleSiderThumbLayer()
    var upperThumbLayer = LSFDoubleSiderThumbLayer()
    ///当前用户点击选中的thumb
    fileprivate var selectThumbLayer: LSFDoubleSiderThumbLayer?
    ///记录滑动式上一次的point
    fileprivate var previousTouchPoint: CGPoint = CGPoint.zero
    
    init(lowerValue: Float = 0.0,
         upperValue: Float = 1.0,
         minimumValue: Float = 0.0,
         maximumValue: Float = 1.0,
         trackHeight: CGFloat = 2,
         trackBackColor: UIColor = UIColor.gray,
         trackColors: [UIColor]? = nil,
         thumbColors: [UIColor]? = nil,
         thumbSize: CGSize = CGSize(width: 30, height: 30)) {
             self.lowerValue = lowerValue
             self.upperValue = upperValue
        
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
    
    open func set(lower: Float? = nil, upper: Float? = nil) {
        if let lower = lower {
            self.lowerValue = lower
        }
        if let upper = upper {
            self.upperValue = upper
        }
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
        
        //lower滑块
        lowerThumbLayer.backgroundColor = UIColor.green.cgColor
        self.layer.addSublayer(lowerThumbLayer)
        
        //upper滑块
        upperThumbLayer.backgroundColor = UIColor.red.cgColor
        self.layer.addSublayer(upperThumbLayer)
        
        //滑块渐变色
        if let trackColors = self.trackColors {
            let cgColors = trackColors.map { $0.cgColor }
            lowerThumbLayer.gradientLayer.colors = cgColors
            upperThumbLayer.gradientLayer.colors = cgColors
        }
        
        setLayerFrame()
    }
    
    
    private func setLayerFrame() {
        trackLayer.frame = CGRect(x: thumbSize.width / 2,
                                  y: (self.frame.size.height - trackHeight) / 2,
                                  width: self.frame.size.width - thumbSize.width,
                                  height: trackHeight)
        trackLayer.setNeedsDisplay()
        
        //计算lower滑块的位置
        let lowerCenterX = positionFor(value: lowerValue)
        lowerThumbLayer.frame = CGRect(x: lowerCenterX - thumbSize.width / 2,
                                       y: (self.frame.size.height - thumbSize.height) / 2,
                                       width: thumbSize.width,
                                       height: thumbSize.height)
        lowerThumbLayer.setNeedsDisplay()
        
        //计算upper滑块的位置
        let upperCenterX = positionFor(value: upperValue)
        upperThumbLayer.frame = CGRect(x: upperCenterX - thumbSize.width / 2,
                                       y: (self.frame.size.height - thumbSize.height) / 2,
                                       width: thumbSize.width,
                                       height: thumbSize.height)
        upperThumbLayer.setNeedsDisplay()
        
        
        trackLayer.lowerCenterX = lowerCenterX
        trackLayer.upperCenterX = upperCenterX
        
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
extension LSFDoubleSider {
    open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousTouchPoint = touch.location(in: self)
        
        //如果连个滑块重叠的时候，优先响应上一次选中的滑块
        if let layer = selectThumbLayer, layer.frame.contains(previousTouchPoint) {
            layer.setNeedsDisplay()
            return true
        }
        
        //选中lower
        if lowerThumbLayer.frame.contains(previousTouchPoint) {
            selectThumbLayer = lowerThumbLayer
            lowerThumbLayer.zPosition = 100
            upperThumbLayer.zPosition = 50
            lowerThumbLayer.setNeedsDisplay()
            return true
        }
        //选中upper
        else if upperThumbLayer.frame.contains(previousTouchPoint) {
            selectThumbLayer = upperThumbLayer
            upperThumbLayer.zPosition = 100
            lowerThumbLayer.zPosition = 50
            upperThumbLayer.setNeedsDisplay()
            return true
        }
        
        return false
    }
    
    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
       let point = touch.location(in: self)
        
        let delta = point.x - previousTouchPoint.x
        let deltaValue = (maximumValue - minimumValue) * Float(delta) / Float(trackLayer.frame.size.width)
        previousTouchPoint = point
        
        //更新lower滑块的值
        if selectThumbLayer == lowerThumbLayer {
            lowerValue += deltaValue
            if lowerValue < minimumValue {
                lowerValue = minimumValue
            }
            if lowerValue > upperValue {
                lowerValue = upperValue
            }
            print("lower value: \(lowerValue)")
        }
        //更新upper滑块的值
        else if selectThumbLayer == upperThumbLayer {
            upperValue += deltaValue
            if upperValue > maximumValue {
                upperValue = maximumValue
            }
            if upperValue < lowerValue {
                upperValue = lowerValue
            }
            print("upper value: \(upperValue)")
        }
        
        //更新UI
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        setLayerFrame()
        CATransaction.commit()
        
        return true
    }
    
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbLayer.setNeedsDisplay()
        upperThumbLayer.setNeedsDisplay()
    }
}
    

    /*

 open var isContinuous: Bool // if set, value change events are generated any time the value changes due to dragging. default = YES

 
 open var minimumTrackTintColor: UIColor?

 open var maximumTrackTintColor: UIColor?

 open var thumbTintColor: UIColor?
 
    open func setValue(_ value: Float, animated: Bool) // move slider at fixed velocity (i.e. duration depends on distance). does not send action

    
    // set the images for the slider. there are 3, the thumb which is centered by default and the track. You can specify different left and right track
    // e.g blue on the left as you increase and white to the right of the thumb. The track images should be 3 part resizable (via UIImage's resizableImage methods) along the direction that is longer
    
    open func setThumbImage(_ image: UIImage?, for state: UIControl.State)

    open func setMinimumTrackImage(_ image: UIImage?, for state: UIControl.State)

    open func setMaximumTrackImage(_ image: UIImage?, for state: UIControl.State)

    
    open func thumbImage(for state: UIControl.State) -> UIImage?

    open func minimumTrackImage(for state: UIControl.State) -> UIImage?

    open func maximumTrackImage(for state: UIControl.State) -> UIImage?

    
    open var currentThumbImage: UIImage? { get }

    open var currentMinimumTrackImage: UIImage? { get }

    open var currentMaximumTrackImage: UIImage? { get }

    
    // lets a subclass lay out the track and thumb as needed
    open func minimumValueImageRect(forBounds bounds: CGRect) -> CGRect

    open func maximumValueImageRect(forBounds bounds: CGRect) -> CGRect

    open func trackRect(forBounds bounds: CGRect) -> CGRect

    open func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect
    // */

