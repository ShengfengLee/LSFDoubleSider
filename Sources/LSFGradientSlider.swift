//
//  LSFGradientSlider.swift
//  LSFDoubleSider_Example
//
//  Created by 李胜锋 on 2020/2/9.
//  Copyright © 2020 李胜锋. All rights reserved.
//

import UIKit

@IBDesignable
open class LSFGradientSlider: UIControl {
    
    ///当前选中的值
    @IBInspectable public var value: Float = 0.0 {
        didSet{
            setLayerFrame()
        }
    }
    
    ///最小值
    @IBInspectable public var minimumValue: Float = 0.0 {
        didSet{
            setLayerFrame()
        }
    }
    
    ///最大值
    @IBInspectable public var maximumValue: Float = 1.0 {
        didSet{
            setLayerFrame()
        }
    }
    
    ///滑条的高度
    @IBInspectable public var trackHeight: CGFloat = 2 {
        didSet{
            setLayerFrame()
        }
    }
    
    ///滑条渐变色数组
    @IBInspectable public var trackColors: [UIColor]? {
        didSet{
            setupView()
        }
    }
    
    ///滑条渐变色数开始颜色，需要与trackEndColor同时设置才有效。 trackColors有值时该值不生效
    @IBInspectable public var trackStartColor: UIColor? {
        didSet{
            setupView()
        }
    }
    
    ///滑条渐变色数结束颜色，需要与trackStartColor同时设置才有效。 trackColors有值时该值不生效
    @IBInspectable public var trackEndColor: UIColor? {
        didSet{
            setupView()
        }
    }
    
    ///滑条的背景色
    @IBInspectable public var trackBackColor: UIColor = UIColor.gray {
        didSet{
            trackLayer.backgroundColor = trackBackColor.cgColor
        }
    }
    
    ///滑块的大小
    @IBInspectable public var thumbSize: CGSize = CGSize(width: 30, height: 30) {
        didSet{
            setLayerFrame()
        }
    }
    
    ///滑块渐变色
    public var thumbColors: [UIColor]? {
        didSet{
            setupView()
        }
    }
    
    ///滑块渐变色数开始颜色，需要与thumbEndColor同时设置才有效。 thumbColors有值时该值不生效
    @IBInspectable public var thumbStartColor: UIColor? {
        didSet{
            setupView()
        }
    }
    
    ///滑块渐变色数结束颜色，需要与thumbStartColor同时设置才有效。 thumbColors有值时该值不生效
    @IBInspectable public var thumbEndColor: UIColor? {
        didSet{
            setupView()
        }
    }
    
    
    var trackLayer: LSFDoubleSiderTrackLayer!
    var thumbLayer: LSFDoubleSiderThumbLayer!
    
    ///记录滑动式上一次的point
    fileprivate var previousTouchPoint: CGPoint = CGPoint.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initView()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        initView()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        initView()
    }
    
    func initView() {
        if self.trackLayer != nil { return }
        
        //track
        trackLayer = LSFDoubleSiderTrackLayer()
        self.layer.addSublayer(trackLayer)
        
        //滑块
        thumbLayer = LSFDoubleSiderThumbLayer()
        self.layer.addSublayer(thumbLayer)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        setLayerFrame()
    }
    
    open func setupView() {
//        trackLayer.backgroundColor = trackBackColor.cgColor
        //渐变色
        if let trackColors = self.trackColors {
            let cgColors = trackColors.map { $0.cgColor }
            trackLayer.middleLayer.colors = cgColors
        }
        else if let start = trackStartColor, let end = trackEndColor {
            let cgColors: [CGColor] = [start.cgColor, end.cgColor]
            trackLayer.middleLayer.colors = cgColors
        }
        
        //滑块
        thumbLayer.backgroundColor = UIColor.green.cgColor
        //滑块渐变色
        if let trackColors = self.trackColors {
            let cgColors = trackColors.map { $0.cgColor }
            thumbLayer.gradientLayer.colors = cgColors
        }
        else if let start = thumbStartColor, let end = thumbEndColor {
            let cgColors: [CGColor] = [start.cgColor, end.cgColor]
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
        var tempValue = value + deltaValue
        if tempValue < minimumValue {
            tempValue = minimumValue
        }
        if tempValue > maximumValue {
            tempValue = maximumValue
        }
        
        //更新UI
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.value = tempValue
        sendActions(for: UIControl.Event.valueChanged)
        CATransaction.commit()
        
        print("value: \(value)")
        return true
    }
    
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        thumbLayer.setNeedsDisplay()
    }
}

