//
//  Favourites.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-22.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import Foundation
import MapKit

class Favourites: NSObject, NSCoding {
    
    let cityName: String
    let latitude: Double
    let longitude: Double
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("favouritesArray")
    
    init(cityName: String, latitude: Double, longitude: Double) {
        self.cityName = cityName
        self.latitude = latitude
        self.longitude = longitude
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard
            let cityName = aDecoder.decodeObject(forKey: "cityName") as? String
            else { return nil }
        let latitude = aDecoder.decodeDouble(forKey: "latitude")
        let longitude = aDecoder.decodeDouble(forKey: "longitude")
        self.init(cityName: cityName, latitude: latitude, longitude: longitude)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(cityName, forKey: "cityName")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
    }
}


