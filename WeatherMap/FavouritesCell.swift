//
//  FavouritesCell.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-22.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class FavouritesCell: UITableViewCell {
    
    @IBOutlet weak var cityNameButtonLbl: UIButton!

    
    func configureCell(favourites: Favourites) {
        cityNameButtonLbl.setTitle(favourites.cityName, for: .normal)
    }
    
    @IBAction func cityNameBtnPressed(_ sender: Any) {
        
    }
}
