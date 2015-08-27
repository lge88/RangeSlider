//
//  RangeSliderView.swift
//  RangeSlider
//
//  Created by Li Ge on 8/26/15.
//  Copyright © 2015 Li Ge. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class SlideBar: UIView {
  // MARK:- API
  // 0.0 <= startPosition < endPosition <= 1.0
  @IBInspectable var startPosition: CGFloat = 0.0 { didSet { setNeedsDisplay() } }
  @IBInspectable var endPosition: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
  @IBInspectable var inRangeColor: UIColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1.0) { didSet { setNeedsDisplay() } }
  @IBInspectable var notInRangeColor: UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) { didSet { setNeedsDisplay() } }
  @IBInspectable var padding: CGFloat = 20.0 { didSet { setNeedsDisplay() } }
  
  var effectiveWidth: CGFloat { return bounds.width - 2*padding }
  
  override func drawRect(rect: CGRect) {
    let bar = UIBezierPath(rect: bounds)
    notInRangeColor.setFill()
    bar.fill()
    
    // draw selected area
    let x = padding + startPosition * effectiveWidth
    let w = (endPosition - startPosition) * effectiveWidth
    let selectedRect = CGRect(x: x, y: 0, width: w, height: bounds.height)
    let selectedArea = UIBezierPath(rect: selectedRect)
    inRangeColor.setFill()
    selectedArea.fill()
  }
}

@IBDesignable
class RangeSlider: UIControl {
  
  // MARK:- API
  @IBInspectable var numSteps: Int = 5 { didSet { render() } }
  
  @IBInspectable var bgColor: UIColor = UIColor.grayColor().colorWithAlphaComponent(0.6) { didSet { render() } }
  @IBInspectable var cornerRadius: CGFloat = 10.0 { didSet { render() } }
  
  @IBInspectable var sliderPadding: CGFloat = 20.0 { didSet { render() } }
  
  // 0.0 <= startPosition < endPosition <= 1.0
  @IBInspectable var startPosition: CGFloat = 0.0 { didSet { render() } }
  var startStepIndex: Int {
    get { return valToIndex(startPosition) }
    set(i) { startPosition = indexToVal(i) }
  }
    
  @IBInspectable var endPosition: CGFloat = 1.0 { didSet { render() } }
  var endStepIndex: Int {
    get { return valToIndex(endPosition) }
    set(i) { endPosition = indexToVal(i) }
  }
  
  @IBInspectable var slideBarYRatio: CGFloat = 0.65 { didSet { render() } }
  @IBInspectable var slideBarHeight: CGFloat = 10.0 { didSet { render() } }
  @IBInspectable var slideBarInRangeColor: UIColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1.0) { didSet { render() } }
  @IBInspectable var slideBarNotInRangeColor: UIColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0) { didSet { render() } }
  
  @IBInspectable var sliderSize: CGSize = CGSize(width: 20.0, height: 30.0) { didSet { render() } }
  @IBInspectable var sliderColor: UIColor = UIColor.darkGrayColor() { didSet { render() } }
  @IBInspectable var sliderCornerRadius: CGFloat = 5.0 { didSet { render() } }
  @IBInspectable var sliderMinSpaceToStepSizeRatio: CGFloat = 0.6 { didSet { render() } }
  
  @IBInspectable var labelPadding: CGFloat = 10.0 { didSet { render() } }
  @IBInspectable var labelYRatio: CGFloat = 0.15 { didSet { render() } }
  
  // A function that map a value in [0, 1.0] to a string, which will be shown in the label.
  var labelTextFn: (CGFloat) -> String = { val -> String in return "\(val)" } { didSet { render() } }
  
  // A function that map a step index {0, 1, ..., numSteps-1} to a string, which will be shown in the label.
  var labelTextFnInt: (Int) -> String {
    get {
      let fn: (Int) -> String = {
        (i) -> String in
        let val = self.indexToVal(i)
        return self.labelTextFn(val)
      }
      return fn
    }
    
    set(fn) {
      labelTextFn = {
        (val) -> String in
        let i = self.valToIndex(val)
        return fn(i)
      }
    }
  }
  
  // MARK:- Events
  struct State {
    let startPosition: CGFloat
    let endPosition: CGFloat
    let startStepIndex: Int
    let endStepIndex: Int
  }
  
  func getState() -> State {
    return State(startPosition: startPosition, endPosition: endPosition, startStepIndex: startStepIndex, endStepIndex: endStepIndex)
  }
  
  var onChange: () -> Void = {}

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
    render()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
    render()
  }
  
  var slideBar: SlideBar!
  var leftSlider: UIView!
  var rightSlider: UIView!
  var leftLabel: UILabel!
  var rightLabel: UILabel!
  
  private func setup() {
    slideBar = SlideBar()
    slideBar.userInteractionEnabled = false
    addSubview(slideBar)
    
    leftSlider = UIView()
    leftSlider.userInteractionEnabled = false
    addSubview(leftSlider)
    
    rightSlider = UIView()
    rightSlider.userInteractionEnabled = false
    addSubview(rightSlider)
    
    leftLabel = UILabel()
    addSubview(leftLabel)
    
    rightLabel = UILabel()
    addSubview(rightLabel)
  }
  
  func render() {
    configureSelf()
    renderSlideBar()
    renderSliders()
    renderLabels()
  }
  
  private func configureSelf() {
    backgroundColor = bgColor
    layer.cornerRadius = cornerRadius
  }
  
  private func renderSlideBar() {
    let w = bounds.width, h = bounds.height
    slideBar.frame = CGRect(x: 0, y: slideBarYRatio*h, width: w, height: slideBarHeight)
    slideBar.padding = sliderPadding
    slideBar.startPosition = startPosition
    slideBar.endPosition = endPosition
    slideBar.inRangeColor = slideBarInRangeColor
    slideBar.notInRangeColor = slideBarNotInRangeColor
  }
  
  private var sliderYPosition: CGFloat {
    return bounds.height * slideBarYRatio + 0.5*slideBarHeight - 0.5*sliderSize.height
  }
  
  private var effectiveSliderWidth: CGFloat { return slideBar.effectiveWidth }
  
  private func sliderXPosition(normalizedPosition normalizedPosition: CGFloat) -> CGFloat {
    return sliderPadding + normalizedPosition*effectiveSliderWidth - 0.5*sliderSize.width
  }
  
  private func renderSliders() {
    let x1 = sliderXPosition(normalizedPosition: startPosition)
    let x2 = sliderXPosition(normalizedPosition: endPosition)
    renderSlider(leftSlider, x: x1)
    renderSlider(rightSlider, x: x2)
  }
  
  private func renderSlider(slider: UIView, x: CGFloat) {
    slider.backgroundColor = sliderColor
    slider.layer.cornerRadius = sliderCornerRadius
    
    let y = sliderYPosition
    slider.frame.size = sliderSize
    slider.frame.origin = CGPoint(x: x, y: y)
  }
  
  private var leftLabelText: String { return labelTextFn(startPosition) }
  private var rightLabelText: String { return labelTextFn(endPosition) }

  private func renderLabels() {
    let w = bounds.width, y = bounds.height
    
    leftLabel.text = "\(leftLabelText)"
    leftLabel.textAlignment = NSTextAlignment.Left
    leftLabel.sizeToFit()
    leftLabel.frame.origin.x = labelPadding
    leftLabel.frame.origin.y = labelYRatio * y
    
    rightLabel.text = "\(rightLabelText)"
    rightLabel.textAlignment = NSTextAlignment.Right
    rightLabel.sizeToFit()
    rightLabel.frame.origin.x = w-labelPadding-rightLabel.frame.width
    rightLabel.frame.origin.y = labelYRatio * y
  }
  
  static func valueToStepIndex(value: CGFloat, numSteps: Int) -> Int {
    let stepSize = 1.0/CGFloat(numSteps-1)
    return Int(round(value/stepSize))
  }
  
  static func stepIndexToValue(index: Int, numSteps: Int) -> CGFloat {
    let stepSize = 1.0/CGFloat(numSteps-1)
    return CGFloat(index)*stepSize
  }
  
  private var stepSize: CGFloat { return 1.0/CGFloat(numSteps-1) }
  
  private var minSpaceBetweenSliders: CGFloat { return sliderMinSpaceToStepSizeRatio*stepSize }
  
  func valToIndex(val: CGFloat) -> Int { return Int(round(val/stepSize)) }
  
  func indexToVal(index: Int) -> CGFloat { return CGFloat(index)*stepSize }
  
  private enum UIStatus {
    case LeftSliderPicked(sliderPosition: CGFloat, touchBeganLocation: CGPoint)
    case RightSliderPicked(sliderPosition: CGFloat, touchBeganLocation: CGPoint)
    case NonePicked
  }
  
  private var uiStatus = UIStatus.NonePicked
  
  override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
    let location = touch.locationInView(self)
    
    if leftSlider.frame.contains(location) {
      uiStatus = UIStatus.LeftSliderPicked(sliderPosition: startPosition, touchBeganLocation: location)
      return true
    } else if rightSlider.frame.contains(location) {
      uiStatus = UIStatus.RightSliderPicked(sliderPosition: endPosition, touchBeganLocation: location)
      return true
    }
    
    uiStatus = UIStatus.NonePicked
    return false
  }
  
  func clamp<T: Comparable>(val: T, low: T, high: T) -> T {
    return max(low, min(val, high))
  }
  
  override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
    let location = touch.locationInView(self)
    
    switch uiStatus {
    case .NonePicked:
      return false
    case let .LeftSliderPicked(sliderPosition: oldPosition, touchBeganLocation: oldLocation):
      let delta = (location.x - oldLocation.x) / effectiveSliderWidth
      let newPosition = clamp(oldPosition+delta, low: 0.0, high: endPosition-minSpaceBetweenSliders)
      startPosition = newPosition
    case let .RightSliderPicked(sliderPosition: oldPosition, touchBeganLocation: oldLocation):
      let delta = (location.x - oldLocation.x) / effectiveSliderWidth
      let newPosition = clamp(oldPosition+delta, low: startPosition+minSpaceBetweenSliders, high: 1.0)
      endPosition = newPosition
    }

    render()
    onChange()
    return true
  }
  
  override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
    switch uiStatus {
    case .NonePicked: return
    case .LeftSliderPicked:
      let snappedPosition = indexToVal(startStepIndex)
      startPosition = snappedPosition
    case .RightSliderPicked:
      let snappedPosition = indexToVal(endStepIndex)
      endPosition = snappedPosition
    }
    
    uiStatus = UIStatus.NonePicked
    render()
    onChange()
  }
    
  override func prepareForInterfaceBuilder() {
    setup()
    render()
  }
  
}




