//
//  Constants.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-08.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import Foundation

// DarkSky API

let DarkSkyURL = "https://api.darksky.net/forecast/"
let DarkSkyAPI_KEY = "***REMOVED***/"
let latitude = "42.8821,"
let longitude = "-8.541"

typealias DownloadComplete = () -> ()

//let CURRENT_WEATHER_URL = "\(DarkSkyURL)\(DarkSkyAPI_KEY)\(latitude)\(longitude)"

let CURRENT_WEATHER_URL = "https://api.darksky.net/forecast/***REMOVED***/42.8821,-8.541?units=si"

//let CURRENT_WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather?lat=42.8821&lon=-8.5419&appid=***REMOVED***"
