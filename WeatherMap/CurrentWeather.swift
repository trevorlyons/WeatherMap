//
//  CurrentWeather.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-08.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import Alamofire

class CurrentWeather {
    
    let currentTemp: Double
    let weatherType: String
    let highTemp: Double
    let lowTemp: Double
    let weatherDesc: String
    let date: String
    let precipPropbability: Double
    let precipType: String
    let apparentTemp: Double
    let humidity: Double
    let windSpeed: Double
    let windDirection: Double
    let pressure: Double
    let cloudCover: Double
    let uvIndex: Double
    let sunrise: String
    let sunset: String
    let uvIndexHigh: Double
    let uvIndexHighTime: String
    
    init(currentDict: JSONDictionary) {
        if let currently = currentDict["currently"] as? JSONDictionary {
            self.currentTemp = currently["temperature"] as? Double ?? 0.0
            let time = currently["time"] as? Double ?? 0.0
            let unixConvertedDate = Date(timeIntervalSince1970: time)
            self.date = unixConvertedDate.currentDate()
            self.weatherType = currently["icon"] as? String ?? "n/a"
            self.weatherDesc = currently["summary"] as? String ?? "n/a"
            self.precipPropbability = currently["precipProbability"] as? Double ?? 0.0
            self.precipType = currently["precipType"] as? String ?? "n/a"
            self.apparentTemp = currently["apparentTemperature"] as? Double ?? 0.0
            self.humidity = currently["humidity"] as? Double ?? 0.0
            self.windSpeed = currently["windSpeed"] as? Double ?? 0.0
            self.windDirection = currently["windBearing"] as? Double ?? 0.0
            self.pressure = currently["pressure"] as? Double ?? 0.0
            self.cloudCover = currently["cloudCover"] as? Double ?? 0.0
            self.uvIndex = currently["uvIndex"] as? Double ?? 0.0
        } else {
            self.currentTemp =  0.0
            self.date = "n/a"
            self.weatherType = "n/a"
            self.weatherDesc = "n/a"
            self.precipPropbability = 0.0
            self.precipType = "n/a"
            self.apparentTemp = 0.0
            self.humidity = 0.0
            self.windSpeed = 0.0
            self.windDirection = 0.0
            self.pressure = 0.0
            self.cloudCover = 0.0
            self.uvIndex = 0.0
        }
        if let daily = currentDict["daily"] as? JSONDictionary,
            let data = daily["data"] as? [JSONDictionary],
            let firstDailyDict = data.first {
            
            self.highTemp = firstDailyDict["temperatureMax"] as? Double ?? 0.0
            self.lowTemp = firstDailyDict["temperatureMin"] as? Double ?? 0.0
            self.uvIndexHigh = firstDailyDict["uvIndex"] as? Double ?? 0.0
            let sunriseTime = firstDailyDict["sunriseTime"] as? Double ?? 0.0
            let unixConvertedDateSunrise = Date(timeIntervalSince1970: sunriseTime)
            self.sunrise = unixConvertedDateSunrise.computeTime()
            let sunsetTime = firstDailyDict["sunsetTime"] as? Double ?? 0.0
            let unixConvertedDateSunset = Date(timeIntervalSince1970: sunsetTime)
            self.sunset = unixConvertedDateSunset.computeTime()
            let uvIndexTime = firstDailyDict["uvIndexTime"] as? Double ?? 0.0
            let unixConvertedDateUvIndex = Date(timeIntervalSince1970: uvIndexTime)
            self.uvIndexHighTime = unixConvertedDateUvIndex.computeTime()
        
        } else {
            self.highTemp = 0.0
            self.lowTemp = 0.0
            self.uvIndexHigh = 0.0
            self.sunrise = "n/a"
            self.sunset = "n/a"
            self.uvIndexHighTime = "n/a"
        }
    }
}

extension Date {
    func currentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.timeZone = TimeZone(secondsFromGMT: Singleton.sharedInstance.timeZoneOffset)
        return dateFormatter.string(from: self)
    }
    
    func computeTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone(secondsFromGMT: Singleton.sharedInstance.timeZoneOffset)
        return dateFormatter.string(from: self)
    }
}


