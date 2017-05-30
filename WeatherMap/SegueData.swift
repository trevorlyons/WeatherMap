//
//  segueData.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-12.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import Foundation

class SegueData {
    
    private var _cityName: String!
    //private var _temperature: String!
    private var _latitude: Double!
    private var _longitude: Double!
    
    var cityName: String {
        return _cityName
    }
    
//    var temperature: String {
//        return _temperature
//    }
    
    var latitude: Double {
        return _latitude
    }
    
    var longitude: Double {
        return _longitude
    }
    
    
    init(cityName: String, latitude: Double, longitude: Double) {
        _cityName = cityName
//        _temperature = temperature
        _latitude = latitude
        _longitude = longitude
    }
}
