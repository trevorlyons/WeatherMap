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
    
    func configureCell(hourlyForecast: HourlyForecast) {
        hourLbl.text = hourlyForecast.time
        //currentWeatherImg.image = UIImage(named: hourlyForecast.weatherDesc)
        currentTempLbl.text = "\(Int(hourlyForecast.temp))"
    }
    
}
