//: Playground - noun: a place where people can play

import UIKit

func positionToIndex(normalizedPosition normalizedPosition: CGFloat, count: Int) -> Int {
  if count <= 1 { return 0 }
  
  let dx = 1.0/CGFloat(count-1)
  return Int(round(normalizedPosition/dx))
}

let indices = (0..<100).map { 0.01*CGFloat($0) }.map { positionToIndex(normalizedPosition: $0, count: 5) }

indices.map { Double($0) }
