//
//  LongRangeForecastCell.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-07.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class LongRangeForecastCell: UITableViewCell {

    @IBOutlet weak var currentWeatherImg: UIImageView!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var precipLbl: UILabel!
    @IBOutlet weak var cloudsLbl: UILabel!
    @IBOutlet weak var dailyHighTempLbl: UILabel!
    @IBOutlet weak var dailyLowTempLbl: UILabel!
    
    func configureCell(longRangeForecast: LongRangeForecast) {
        
        var weatherImg: String!
        if longRangeForecast.weatherType == "partly-cloudy-night" {
            weatherImg = "clear-day"
        } else {
            weatherImg = longRangeForecast.weatherType
        }
        
        currentWeatherImg.image = UIImage(named: weatherImg)
        dayLbl.text = longRangeForecast.date
        precipLbl.text = "\(Int((longRangeForecast.precip)*100))%"
        cloudsLbl.text = "\(Int((longRangeForecast.clouds)*100))%"
        dailyHighTempLbl.text = "\(Int(longRangeForecast.highTemp))°"
        dailyLowTempLbl.text = "\(Int(longRangeForecast.lowTemp))°"
    }

}
