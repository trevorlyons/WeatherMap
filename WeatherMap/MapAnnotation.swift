//
//  MapAnnotations.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-11.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import Foundation

class MapAnnotation {
    
    let latitude: Double
    let longitude: Double
    let cityName: String
    let temperature: Double
    let weatherType: String
    
    init(locationDict: JSONDictionary) {
        if let coord = locationDict["coord"] as? JSONDictionary {
            self.latitude = coord["Lat"] as? Double ?? 0.0
            self.longitude = coord["Lon"] as? Double ?? 0.0
        } else {
            self.latitude = 0.0
            self.longitude = 0.0
        }
        self.cityName = locationDict["name"] as? String ?? "n/a"
        if let main = locationDict["main"] as? JSONDictionary {
            self.temperature = main["temp"] as? Double ?? 0.0
        } else {
            self.temperature = 0.0
        }
        if let weather = locationDict["weather"] as? [JSONDictionary] {
            self.weatherType = weather[0]["icon"] as? String ?? "n/a"
        } else {
            self.weatherType = "n/a"
        }
    }
}
