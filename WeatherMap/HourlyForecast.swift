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
    
//    let time: String
    let time: Double
    let weatherDesc: String
    let temp: Double
    let precip: Double
    
    init(hourlyDict: JSONDictionary) {
//        let hour = hourlyDict["time"] as? Double ?? 0.0
//        let unixConvertedDate = Date(timeIntervalSince1970: hour)
//        self.time = unixConvertedDate.hourOfTheDay()
        self.time = hourlyDict["time"] as? Double ?? 0.0
        self.weatherDesc = hourlyDict["icon"] as? String ?? "n/a"
        self.temp = hourlyDict["temperature"] as? Double ?? 0.0
        self.precip = hourlyDict["precipProbability"] as? Double ?? 0.0
    }
    
    init(sunriseDict: JSONDictionary) {
//        let sunrise = sunriseDict["sunriseTime"] as? Double ?? 0.0
//        let unixConvertedDate = Date(timeIntervalSince1970: sunrise)
//        self.time = unixConvertedDate.computeTimes()
        self.time = sunriseDict["sunriseTime"] as? Double ?? 0.0
        self.weatherDesc = "sunrise"
        self.temp = 0.0
        self.precip = 0.0
    }
    
    init(sunsetDict: JSONDictionary) {
//        let sunset = sunsetDict["sunsetTime"] as? Double ?? 0.0
//        let unixConvertedDate = Date(timeIntervalSince1970: sunset)
//        self.time = unixConvertedDate.computeTimes()
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

