//
//  LSFDoubleSider.swift
//  LSFDoubleSider_Example
//
//  Created by 李胜锋 on 2020/2/8.
//  Copyright © 2020 李胜锋. All rights reserved.
//

import UIKit


@IBDesignable
open class LSFDoubleSider: UIControl {
    
    //MARK: -- value
    /// default 0.0. this value will be pinned to min/max
    @IBInspectable open var lowerValue: Float = 0.0 {
        didSet{
            setLayerFrame()
        }
    }
    /// default 1.0. this value will be pinned to min/max
    @IBInspectable open var upperValue: Float = 1.0 {
        didSet{
            setLayerFrame()
        }
    }
    
    /// default 0.0. the current value may change if outside new min value
    @IBInspectable open var minimumValue: Float = 0.0 {
        didSet{
            setLayerFrame()
        }
    }
    /// default 1.0. the current value may change if outside new max value
    @IBInspectable open var maximumValue: Float = 1.0 {
        didSet{
            setLayerFrame()
        }
    }
    
    
    //MARK: -- track
    @IBInspectable open var trackHeight: CGFloat = 2 {
        didSet{
            setLayerFrame()
        }
    }
    ///track渐变色(水平方向)
    open var trackColors: [UIColor]?
    @IBInspectable open var trackBackColor: UIColor = UIColor.gray {
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
    
    @IBInspectable open var thumbSize: CGSize = CGSize(width: 30, height: 30) {
           didSet{
               setLayerFrame()
           }
       }
    
    
    //MARK: --lower Thumb
    ///lower滑块背景色
    @IBInspectable public var lowerThumbBackColor: UIColor = UIColor.gray {
        didSet{
            setupView()
        }
    }
    
    ///lower渐变色(垂直方向)
    open var lowerThumbColors: [UIColor]?
    
    ///lower滑块渐变色数开始颜色，需要与thumbEndColor同时设置才有效。 thumbColors有值时该值不生效
    @IBInspectable public var lowerThumbStartColor: UIColor? {
        didSet{
            setupView()
        }
    }
    
    ///lower滑块渐变色数结束颜色，需要与thumbStartColor同时设置才有效。 thumbColors有值时该值不生效
    @IBInspectable public var lowerThumbEndColor: UIColor? {
        didSet{
            setupView()
        }
    }
    
    //MARK: --upper Thumb
   
    ///upper滑块背景色
    @IBInspectable public var upperThumbBackColor: UIColor = UIColor.gray {
        didSet{
            setupView()
        }
    }
    
    ///upper渐变色(垂直方向)
    open var upperThumbColors: [UIColor]?
       
    
    ///lower滑块渐变色数开始颜色，需要与upperThumbEndColor同时设置才有效。 upperThumbColors有值时该值不生效
    @IBInspectable public var upperThumbStartColor: UIColor? {
        didSet{
            setupView()
        }
    }
    
    ///lower滑块渐变色数结束颜色，需要与upperThumbStartColor同时设置才有效。 upperThumbColors有值时该值不生效
    @IBInspectable public var upperThumbEndColor: UIColor? {
        didSet{
            setupView()
        }
    }
    
    var trackLayer: LSFDoubleSiderTrackLayer!
    var lowerThumbLayer: LSFDoubleSiderThumbLayer!
    var upperThumbLayer: LSFDoubleSiderThumbLayer!
    
    ///当前用户点击选中的thumb
    fileprivate var selectThumbLayer: LSFDoubleSiderThumbLayer?
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
    
    override open func layoutSubviews() {
           super.layoutSubviews()
           setLayerFrame()
       }
    
    private func initView() {
        if self.trackLayer != nil { return }
        
        trackLayer = LSFDoubleSiderTrackLayer()
        lowerThumbLayer = LSFDoubleSiderThumbLayer()
        upperThumbLayer = LSFDoubleSiderThumbLayer()
           
        self.layer.addSublayer(trackLayer)
        self.layer.addSublayer(lowerThumbLayer)
        self.layer.addSublayer(upperThumbLayer)
    }
    
    
    private func setupView() {
        //track
        trackLayer.backgroundColor = trackBackColor.cgColor
        //渐变色
        if let trackColors = self.trackColors {
            let cgColors = trackColors.map { $0.cgColor }
            trackLayer.middleLayer.colors = cgColors
        }
        else if let start = trackStartColor, let end = trackEndColor {
            let cgColors: [CGColor] = [start.cgColor, end.cgColor]
            trackLayer.middleLayer.colors = cgColors
        }
        

        lowerThumbLayer.backgroundColor = lowerThumbBackColor.cgColor
        upperThumbLayer.backgroundColor = upperThumbBackColor.cgColor
        
        //滑块渐变色
        if let colors = self.lowerThumbColors {
            let cgColors = colors.map { $0.cgColor }
            lowerThumbLayer.gradientLayer.colors = cgColors
        }
        else if let start = lowerThumbStartColor, let end = lowerThumbEndColor {
            let cgColors: [CGColor] = [start.cgColor, end.cgColor]
            lowerThumbLayer.gradientLayer.colors = cgColors
        }
        
        if let colors = self.upperThumbColors {
            let cgColors = colors.map { $0.cgColor }
            upperThumbLayer.gradientLayer.colors = cgColors
        }
        else if let start = upperThumbStartColor, let end = upperThumbEndColor {
            let cgColors: [CGColor] = [start.cgColor, end.cgColor]
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
            var tempValue = lowerValue + deltaValue
            if lowerValue < minimumValue {
                tempValue = minimumValue
            }
            if tempValue > upperValue {
                tempValue = upperValue
            }
            //更新UI
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            lowerValue = tempValue
            sendActions(for: UIControl.Event.valueChanged)
            CATransaction.commit()
            print("lower value: \(lowerValue)")
        }
        //更新upper滑块的值
        else if selectThumbLayer == upperThumbLayer {
            var tempValue = upperValue + deltaValue
            if tempValue > maximumValue {
                tempValue = maximumValue
            }
            if tempValue < lowerValue {
                tempValue = lowerValue
            }
            
            //更新UI
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            upperValue = tempValue
            sendActions(for: UIControl.Event.valueChanged)
            CATransaction.commit()
            print("upper value: \(upperValue)")
        }
        
        
        
        return true
    }
    
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbLayer.setNeedsDisplay()
        upperThumbLayer.setNeedsDisplay()
    }
}

