//
//  LongRangeForecast.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-09.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import Alamofire

class LongRangeForecast {
    
    private var _weatherDesc: String!
    private var _weatherType: String!
    private var _date: String!
    private var _precip: Double!
    private var _clouds: Double!
    private var _highTemp: Double!
    private var _lowTemp: Double!
    
    var weatherDesc: String {
        if _weatherDesc == nil {
            _weatherDesc = ""
        }
        return _weatherDesc
    }
    
    var weatherType: String {
        if _weatherType == nil {
            _weatherType = ""
        }
        return _weatherType
    }
    
    var date: String {
        if _date == nil {
            _date = ""
        }
        return _date
    }
    
    var precip: Double {
        if _precip == nil {
            _precip = 0.0
        }
        return _precip
    }
    
    var clouds: Double {
        if _clouds == nil {
            _clouds = 0.0
        }
        return _clouds
    }
    
    var highTemp: Double {
        if _highTemp == nil {
            _highTemp = 0.0
        }
        return _highTemp
    }
    
    var lowTemp: Double {
        if _lowTemp == nil {
            _lowTemp = 0.0
        }
        return _lowTemp
    }
    
    init(longWeatherDict: Dictionary<String, AnyObject>) {
        
        if let icon = longWeatherDict["icon"] as? String {
            self._weatherType = icon
        }
        if let summary = longWeatherDict["summary"] as? String {
            self._weatherDesc = summary
        }
        if let date = longWeatherDict["time"] as? Double {
            let unixConvertedDate = Date(timeIntervalSince1970: date)
            self._date = unixConvertedDate.dayOfTheWeek()
        }
        if let precip = longWeatherDict["precipProbability"] as? Double {
            self._precip = precip
        }
        if let clouds = longWeatherDict["cloudCover"] as? Double {
            self._clouds = clouds
        }
        if let highTemp = longWeatherDict["temperatureMax"] as? Double {
            self._highTemp = highTemp
        }
        if let lowTemp = longWeatherDict["temperatureMin"] as? Double {
            self._lowTemp = lowTemp
        }
    }
    
}

extension Date {
    
    func dayOfTheWeek() -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: Singleton.sharedInstance.timeZoneOffset)
        return dateFormatter.string(from: self)
    }
}

