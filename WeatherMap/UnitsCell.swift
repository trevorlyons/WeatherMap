//
//  UnitsCell.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-06-13.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class UnitsCell: UITableViewCell {

    @IBOutlet weak var selectorImg: UIImageView!
    @IBOutlet weak var unitSelectLbl: UILabel!

    func configureCell(units: Units) {
        
        unitSelectLbl.text = units.unitName
        
        var setSelected: String
        if units.selector == true {
            setSelected = "selected"
        } else {
            setSelected = "unselected"
        }
        selectorImg.image = UIImage(named: setSelected)
    }
}
