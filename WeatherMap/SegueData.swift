//
//  segueData.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-12.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import Foundation

class SegueData {
    
    let cityName: String
    let latitude: Double
    let longitude: Double
    
    init(cityName: String, latitude: Double, longitude: Double) {
        self.cityName = cityName
        self.latitude = latitude
        self.longitude = longitude
    }
}
