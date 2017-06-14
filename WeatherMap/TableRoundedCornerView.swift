//
//  TableRoundedCornerView.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-06-12.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class TableRoundedCornerView: UITableView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 8
    }

}
