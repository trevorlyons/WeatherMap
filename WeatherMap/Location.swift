//
//  Location.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-11.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import Foundation
import CoreLocation

class Location {
    
    static var sharedInstance = Location()
    private init() {}
    
    var latitude: Double!
    var longitude: Double!

}
