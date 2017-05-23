//
//  MapAnnotations.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-11.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import Foundation

class MapAnnotation {
    
    private var _latitude: Double!
    private var _longitude: Double!
    private var _cityName: String!
    private var _temperature: Double!
    private var _weatherType: String!
    
    var latitude: Double {
        if _latitude == nil {
            _latitude = 0.0
        }
        return _latitude
    }
    
    var longitude: Double {
        if _longitude == nil {
            _longitude = 0.0
        }
        return _longitude
    }
    
    var cityName: String {
        if _cityName == nil {
            _cityName = ""
        }
        return _cityName
    }
    
    var temperature: Double {
        if _temperature == nil {
            _temperature = 0.0
        }
        return _temperature
    }
    
    var weatherType: String {
        if _weatherType == nil {
            _weatherType = ""
        }
        return _weatherType
    }
    
    init(locationDict: Dictionary<String, AnyObject>) {
        if let coord = locationDict["coord"] as? Dictionary<String, AnyObject> {
            if let Lat = coord["Lat"] as? Double {
                self._latitude = Lat
            }
            if let Lon = coord["Lon"] as? Double {
                self._longitude = Lon
            }
        }
        if let name = locationDict["name"] as? String {
            self._cityName = name
        }
        if let main = locationDict["main"] as? Dictionary<String, AnyObject> {
            if let temp = main["temp"] as? Double {
                self._temperature = temp
            }
        }
        if let weather = locationDict["weather"] as? [Dictionary<String, AnyObject>] {
            if let icon = weather[0]["icon"] as? String {
                self._weatherType = icon
            }
        }
    }
    
    
}
