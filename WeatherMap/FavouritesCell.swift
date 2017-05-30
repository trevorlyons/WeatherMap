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

    
    func configureCell(favourites: Favourites) {
        favouritesLbl.text = favourites.cityName
    }
}
