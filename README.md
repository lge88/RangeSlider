# RangeSlider

## Usage:
See `ViewController.swift` for more detail.

```swift
let dates = (0..<10).map { "Aug \($0), 2015" }
var startDateIndex = 3
var endDateIndex = 8

let rangeSlider = RangeSlider(frame: CGRect(x: 0.0, y: 0.0, width: 450.0, height: 80.0))

rangeSlider.numSteps = dates.count
rangeSlider.startStepIndex = startDateIndex
rangeSlider.endStepIndex = endDateIndex

rangeSlider.labelTextFnInt = { (i) -> String in return dates[i] }

func printDateRange() {
  print("From \(dates[startDateIndex]) to \(dates[endDateIndex])")
}

rangeSlider.onChange = {
  let state = rangeSlider.getState()
  startDateIndex = state.startStepIndex
  endDateIndex = state.endStepIndex
  printDateRange()
}
```
