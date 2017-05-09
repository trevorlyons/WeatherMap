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
    @IBOutlet weak var weatherTypeLbl: UILabel!
    @IBOutlet weak var precipLbl: UILabel!
    @IBOutlet weak var cloudsLbl: UILabel!
    @IBOutlet weak var dailyHighTempLbl: UILabel!
    @IBOutlet weak var dailyLowTempLbl: UILabel!
    
    func configureCell(longRangeForecast: LongRangeForecast) {
        currentWeatherImg.image = UIImage(named: longRangeForecast.weatherDesc)
        dayLbl.text = longRangeForecast.date
        weatherTypeLbl.text = longRangeForecast.weatherDesc
        precipLbl.text = "\(longRangeForecast.precip)"
        cloudsLbl.text = "\(longRangeForecast.clouds)"
        dailyHighTempLbl.text = "\(longRangeForecast.highTemp)"
        dailyLowTempLbl.text = "\(longRangeForecast.lowTemp)"
    }

}
