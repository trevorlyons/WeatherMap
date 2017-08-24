//
//  TemperatureChart.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-08-21.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import Alamofire

class TemperatureChart {
    
    let temp: Double
    
    init(tempDict: JSONDictionary) {
        self.temp = tempDict["value"] as? Double ?? 0.0
    }
}
