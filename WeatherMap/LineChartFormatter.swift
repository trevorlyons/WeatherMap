//
//  LineChartFormatter.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-08-25.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import Foundation
import Charts

@objc(LineChartFormatter)
public class LineChartFormatter: NSObject, IAxisValueFormatter{
    
    var months: [String]! = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]
    
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        
        return months[Int(value)]
    }
}
