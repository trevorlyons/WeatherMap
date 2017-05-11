//
//  Constants.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-08.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import Foundation

typealias DownloadComplete = () -> ()


let CURRENT_WEATHER_URL = "https://api.darksky.net/forecast/***REMOVED***/42.8821,-8.541?units=si"

var MAP_WEATHER_URL = "http://api.openweathermap.org/data/2.5/box/city?bbox=\(Location.sharedInstance.lowerLeftLongitude!),\(Location.sharedInstance.lowerLeftLatitude!),\(Location.sharedInstance.upperRightLongitude!),\(Location.sharedInstance.upperRightLatitude!),10&appid=***REMOVED***"
