//
//  MeasurementUnitsCell.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-06-13.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class MeasurementUnitsCell: UITableViewCell {

    @IBOutlet weak var unitsTypeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if Singleton.sharedInstance.unitSelectedOWM == "metric" {
            unitsTypeLbl.text = "Metric"
        } else {
            unitsTypeLbl.text = "Imperial"
        }
        
    }


}
