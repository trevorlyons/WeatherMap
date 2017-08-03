//
//  HourlyForecastCell.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-07.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class HourlyForecastCell: UICollectionViewCell {
    
    @IBOutlet weak var hourLbl: UILabel!
    @IBOutlet weak var currentWeatherImg: UIImageView!
    @IBOutlet weak var currentTempLbl: UILabel!
    @IBOutlet weak var precipLbl: UILabel!
    
    func configureCell(hourlyForecast: HourlyForecast) {
        
        hourLbl.text = hourlyForecast.time
        currentWeatherImg.image = UIImage(named: hourlyForecast.weatherDesc)
        currentTempLbl.text = "\(Int(hourlyForecast.temp))°"
        var precipPercent: String
        if hourlyForecast.precip == 0.00 {
            precipLbl.isHidden = true
            precipPercent = ""
        } else if hourlyForecast.precip > 0.00 && hourlyForecast.precip < 0.1 {
            precipLbl.isHidden = false
            precipPercent = "5%"
        } else {
            precipLbl.isHidden = false
            precipPercent = "\(roundToTens(x: (hourlyForecast.precip*100)))%"
        }
        precipLbl.text = precipPercent
    }
    
    func roundToTens(x : Double) -> Int {
        return 10 * Int(round(x / 10.0))
    }
    
}
