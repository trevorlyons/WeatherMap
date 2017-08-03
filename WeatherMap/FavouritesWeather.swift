//
//  FavouritesWeather.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-08-01.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import Foundation

class FavouritesWeather {
    
    let weatherType: String
    let currentTemp: Double
    
    init(favouritesDict: JSONDictionary) {
        if let currently = favouritesDict["currently"] as? JSONDictionary {
            self.weatherType = currently["icon"] as? String ?? "n/a"
            self.currentTemp = currently["temperature"] as? Double ?? 0.0
        } else {
            self.weatherType = "n/a"
            self.currentTemp = 0.0
        }
    }
}
