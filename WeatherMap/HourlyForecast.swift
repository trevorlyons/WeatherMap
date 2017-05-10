//
//  HourlyForecast.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-09.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import Alamofire

class HourlyForecast {
    
    private var _time: String!
    private var _weatherDesc: String!
    private var _temp: Double!
    
    var time: String {
        if _time == nil {
            _time = ""
        }
        return _time
    }
    
    var weatherDesc: String {
        if _weatherDesc == nil {
            _weatherDesc = ""
        }
        return _weatherDesc
    }
    
    var temp: Double {
        if _temp == nil {
            _temp = 0.0
        }
        return _temp
    }
    
    init(hourlyDict: Dictionary<String, AnyObject>) {
        
        if let time = hourlyDict["time"] as? Double {
            let unixConvertedDate = Date(timeIntervalSince1970: time)
            self._time = unixConvertedDate.hourOfTheDay()
        }
        if let icon = hourlyDict["icon"] as? String {
            self._weatherDesc = icon
        }
        if let temp = hourlyDict["temperature"] as? Double {
            self._temp = temp
        }
    }
}

extension Date {
    
    func hourOfTheDay() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha"
        return dateFormatter.string(from: self)
    }
}

