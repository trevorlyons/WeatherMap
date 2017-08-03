//
//  RoundViewNoShadow.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-08-01.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class RoundViewNoShadow: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.width / 2
        
    }

}
