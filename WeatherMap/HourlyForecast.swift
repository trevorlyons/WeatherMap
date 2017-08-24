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
    
    let time: Double
    let weatherDesc: String
    let temp: Double
    let precip: Double
    
    init(hourlyDict: JSONDictionary) {
        self.time = hourlyDict["time"] as? Double ?? 0.0
        self.weatherDesc = hourlyDict["icon"] as? String ?? "n/a"
        self.temp = hourlyDict["temperature"] as? Double ?? 0.0
        self.precip = hourlyDict["precipProbability"] as? Double ?? 0.0
    }
    
    init(sunriseDict: JSONDictionary) {
        self.time = sunriseDict["sunriseTime"] as? Double ?? 0.0
        self.weatherDesc = "sunrise"
        self.temp = 0.0
        self.precip = 0.0
    }
    
    init(sunsetDict: JSONDictionary) {
        self.time = sunsetDict["sunsetTime"] as? Double ?? 0.0
        self.weatherDesc = "sunset"
        self.temp = 0.0
        self.precip = 0.0
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

