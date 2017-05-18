//
//  CurrentWeather.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-08.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import Alamofire

//class CurrentWeather {
//    
//    private var _currentTemp: Double!
//    private var _date: String!
//    private var _weatherType: String!
//    private var _highTemp: Double!
//    private var _lowTemp: Double!
//    private var _weatherDesc: String!
//    
//    
//    var currentTemp: Double {
//        if _currentTemp == nil {
//            _currentTemp = 0.0
//        }
//        return _currentTemp
//    }
//    
//    var date: String {
//        if _date == nil {
//            _date = ""
//        }
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .none
//        let currentDate = dateFormatter.string(from: Date())
//        self._date = "Today \(currentDate)"
//        return _date
//    }
//    
//    var weatherType: String {
//        if _weatherType == nil {
//            _weatherType = ""
//        }
//        return _weatherType
//    }
//    
//    var highTemp: Double {
//        if _highTemp == nil {
//            _highTemp = 0.0
//        }
//        return _highTemp
//    }
//    
//    var lowTemp: Double {
//        if _lowTemp == nil {
//            _lowTemp = 0.0
//        }
//        return _lowTemp
//    }
//    
//    var weatherDesc: String {
//        if _weatherDesc == nil {
//            _weatherDesc = ""
//        }
//        return _weatherDesc
//    }
//    
//    
//
//    init(currentDict: Dictionary<String, AnyObject>) {
//        if let temperature = currentDict["temperature"] as? Double {
//            self._currentTemp = temperature
//        }
//        if let icon = currentDict["icon"] as? String {
//            self._weatherType = icon
//        }
//        if let summary = currentDict["summary"] as? String {
//            self._weatherDesc = summary
//        }
//    }
//    
//}


class CurrentWeather {
    
    let currentTemp: Double
    let weatherType: String
    let highTemp: Double
    let lowTemp: Double
    let weatherDesc: String
    
    var date: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let currentDate = dateFormatter.string(from: Date())
        return "Today \(currentDate)"
    }
    
    
    init(currentDict: JSONDictionary) {
        if let currently = currentDict["currently"] as? JSONDictionary {
            self.currentTemp = currently["temperature"] as? Double ?? 0.0
            self.weatherType = currently["icon"] as? String ?? "n/a"
            self.weatherDesc = currently["summary"] as? String ?? "n/a"
        } else {
            self.currentTemp =  0.0
            self.weatherType = "n/a"
            self.weatherDesc = "n/a"
            
        }
        if let daily = currentDict["daily"] as? JSONDictionary,
            let data = daily["data"] as? [JSONDictionary],
            let firstDailyDict = data.first {
            
            self.highTemp = firstDailyDict["temperatureMax"] as? Double ?? 0.0
            self.lowTemp = firstDailyDict["temperatureMin"] as? Double ?? 0.0
        } else {
            self.highTemp = 0.0
            self.lowTemp = 0.0
        }
    }
}


