//
//  HeaderView.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-06-10.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class HeaderView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowOpacity = 0.8

    }

}
