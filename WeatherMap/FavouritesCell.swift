//
//  FavouritesCell.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-22.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class FavouritesCell: UITableViewCell {
    
    @IBOutlet weak var favouritesLbl: UILabel!
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var temperatureLbl: UILabel!
    
    func configureCityName(favourites: Favourites) {
        favouritesLbl.text = "\(favourites.cityName)"
    }
    
    func configureWeatherData(favouritesWeather: FavouritesWeather) {
        weatherImg.image = UIImage(named: favouritesWeather.weatherType)
        temperatureLbl.text = "\(Int(favouritesWeather.currentTemp))°"
    }
}
