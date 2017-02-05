//
//  Extensions.swift
//  tsundoku
//
//  Created by Hiroaki KARASAWA on 2017/02/06.
//  Copyright © 2017年 浅井紀子. All rights reserved.
//

import Foundation
import UIKit

func random(from range: Range<Int>) -> Int {
    let lowerBound = range.lowerBound
    let upperBound = range.upperBound
    
    return lowerBound + Int(arc4random_uniform(UInt32(upperBound - lowerBound)))
}

func random(from range: ClosedRange<Int>) -> Int {
    let lowerBound = range.lowerBound
    let upperBound = range.upperBound
    
    return lowerBound + Int(arc4random_uniform(UInt32(upperBound - lowerBound + 1)))
}

let r1 = random(from: 4 ..< 8)
let r2 = random(from: 6 ... 8)


// As suggested by Dave Abrahams on swift-users@swift.org mailing list
// https://lists.swift.org/pipermail/swift-users/Week-of-Mon-20161010/003701.html
protocol CompleteRange {
    associatedtype Bound : Comparable
    var lowerBound : Bound { get }
    var upperBound : Bound { get }
}

extension CountableRange : CompleteRange {}
extension CountableClosedRange : CompleteRange {}

import Darwin

func random<R: CompleteRange>(from range: R) -> Int where R.Bound == Int, R: Collection {
    return range.lowerBound + Int(arc4random_uniform(numericCast(range.count)))
}


extension UIColor {
    class func rgb(r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    class func MainColor(index : Int) -> UIColor {
        let r = random(from: -40 ..< 40)
        return (index == 0 ? UIColor.rgb(r: 0, g: 188 + r, b: 188 + r, alpha: 1.0) : UIColor.rgb(r: 225 + r, g: 150 + r, b: 0, alpha: 1.0))
    }
    class func MyColor(index : Int) -> UIColor {
        return (index == 0 ? UIColor.rgb(r: 0, g: 255, b: 188, alpha: 1.0) : UIColor.rgb(r: 255, g: 30, b: 0, alpha: 1.0))
    }
}

