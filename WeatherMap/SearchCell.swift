//
//  TableViewCell.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-06-02.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import MapKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var cityNameLbl: UILabel!

    func configureCell(selectedItem: MKLocalSearchCompletion) {
        cityNameLbl.text = selectedItem.title
    }
    
}
