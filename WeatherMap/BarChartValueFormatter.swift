//
//  BarChartValueFormatter.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-08-27.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import Foundation
import Charts

class ChartValueFormatter: NSObject, IValueFormatter {
    fileprivate var numberFormatter: NumberFormatter?
    
    convenience init(numberFormatter: NumberFormatter) {
        self.init()
        self.numberFormatter = numberFormatter
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
//        guard let numberFormatter = numberFormatter
//            else {
//                return "\(value)"
//        }
//        return numberFormatter.string(for: value)!
        if value < 0.001 {
            return "\(value)"
        } else if value == 0.001 {
            return "n/a"
        } else if value > 0.001 {
            return "\(value)"
        } else {
            return ""
        }
    }
}
