//
//  ClosestStation.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-08-22.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import Foundation

class ClosestStation {
    
    let stationId: String
    let stationDist: Double
    let stationName: String
    
    init(stationId: String, stationDist: Double, stationName: String) {
        self.stationId = stationId
        self.stationDist = stationDist
        self.stationName = stationName
    }
}
