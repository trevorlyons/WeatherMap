//
//  BtmBorderView.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-06.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class BtmBorderView: UIView {

    override func layoutSubviews() {
        addBottomBorderWithColor(color: UIColor.darkGray, width: 0.5)
    }
}
