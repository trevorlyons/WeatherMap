//
//  Singletons.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-06-08.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import Foundation

class Singleton {
    
    static var sharedInstance = Singleton()
    private init() {}
    
    var favouritesArray = [Favourites]()
    var timeZoneOffset: Int!
    var unitSelectedDarkSky: String = "si"
    var unitSelectedOWM: String = "metric"
    var languageSelected: String = "English"
}
