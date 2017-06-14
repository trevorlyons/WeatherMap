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
    private var _precip: Double!
    
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
    
    var precip: Double {
        if _precip == nil {
            _precip = 0.0
        }
        return _precip
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
        if let precip = hourlyDict["precipProbability"] as? Double {
            self._precip = precip
        }
    }
}

extension Date {
    
    func hourOfTheDay() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: Singleton.sharedInstance.timeZoneOffset)
        return dateFormatter.string(from: self)
    }
}

