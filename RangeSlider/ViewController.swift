//
//  ViewController.swift
//  RangeSlider
//
//  Created by Li Ge on 8/26/15.
//  Copyright © 2015 Li Ge. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var rangeSlider: RangeSlider!
  @IBOutlet weak var label: UILabel!
  
  let dates = (1...10).map { "Aug \($0), 2015" }
  var startStepIndex = 3
  var endStepIndex = 8
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    rangeSlider.numSteps = dates.count
    rangeSlider.startStepIndex = startStepIndex
    rangeSlider.endStepIndex = endStepIndex
    
    rangeSlider.labelTextFnInt = {
      [unowned self] (i) -> String in
      return self.dates[i]
    }
    
    rangeSlider.onChange = {
      [unowned self] in
      let state = self.rangeSlider.getState()
      self.startStepIndex = state.startStepIndex
      self.endStepIndex = state.endStepIndex
      self.render()
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    render()
  }
  
  func render() {
    let total = dates.count
    let selected = endStepIndex - startStepIndex + 1
    label.text = "Selected \(selected) / \(total). startIndex: \(startStepIndex), endIndex: \(endStepIndex)"
  }
  

}

