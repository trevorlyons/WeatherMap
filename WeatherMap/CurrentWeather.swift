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
    
    private var _currentTemp: Double!
    private var _date: String!
    private var _weatherType: String!
    private var _highTemp: Double!
    private var _lowTemp: Double!
    private var _weatherDesc: String!
    
    
    var currentTemp: Double {
        if _currentTemp == nil {
            _currentTemp = 0.0
        }
        return _currentTemp
    }
    
    var date: String {
        if _date == nil {
            _date = ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let currentDate = dateFormatter.string(from: Date())
        self._date = "Today \(currentDate)"
        return _date
    }
    
    var weatherType: String {
        if _weatherType == nil {
            _weatherType = ""
        }
        return _weatherType
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
    
    var weatherDesc: String {
        if _weatherDesc == nil {
            _weatherDesc = ""
        }
        return _weatherDesc
    }
    
    
    
    func downloadWeatherDetails(completed: @escaping DownloadComplete) {
        let currentWeatherUrl = URL(string: CURRENT_WEATHER_URL)!
        Alamofire.request(currentWeatherUrl).responseJSON { response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                if let currently = dict["currently"] as? Dictionary<String, AnyObject> {
                    if let temperature = currently["temperature"] as? Double {
                        
                        let roundedTemp = Double(round(temperature))
                        self._currentTemp = roundedTemp
                    }
                    if let icon = currently["icon"] as? String {
                        
                        self._weatherType = icon
                    }
                    if let summary = currently["summary"] as? String {
                        
                        self._weatherDesc = summary
                    }
                }
                if let daily = dict["daily"] as? Dictionary<String, AnyObject> {
                    if let data = daily["data"] as? [Dictionary<String, AnyObject>] {
                        if let temperatureMax = data[0]["temperatureMax"] as? Double {
                            
                            let roundedTemp = Double(round(temperatureMax))
                            self._highTemp = roundedTemp
                        }
                        if let temperatureMin = data[0]["temperatureMin"] as? Double {
                            
                            let roundedTemp = Double(round(temperatureMin))
                            self._lowTemp = roundedTemp
                        }
                    }
                }
                
                
            }
            completed()
        }
        
    }
    
}


