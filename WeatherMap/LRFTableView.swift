//
//  LRFTableView.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-06-09.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class LRFTableView: UITableView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        addBottomBorderWithColor(color: .white, width: 0.5)
        addTopBorderWithColor(color: .white, width: 0.5)
    }
    
}
