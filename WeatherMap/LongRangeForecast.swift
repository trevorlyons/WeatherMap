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
    
    let weatherDesc: String
    let weatherType: String
    let date: String
    let precip: Double
    let clouds: Double
    let highTemp: Double
    let lowTemp: Double
    
    init(longWeatherDict: JSONDictionary) {
        self.weatherType = longWeatherDict["icon"] as? String ?? "n/a"
        self.weatherDesc = longWeatherDict["summary"] as? String ?? "n/a"
        let day = longWeatherDict["time"] as? Double ?? 0.0
        let unixConvertedDate = Date(timeIntervalSince1970: day)
        self.date = unixConvertedDate.dayOfTheWeek()
        self.precip = longWeatherDict["precipProbability"] as? Double ?? 0.0
        self.clouds = longWeatherDict["cloudCover"] as? Double ?? 0.0
        self.highTemp = longWeatherDict["temperatureHigh"] as? Double ?? 0.0
        self.lowTemp = longWeatherDict["temperatureLow"] as? Double ?? 0.0
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

