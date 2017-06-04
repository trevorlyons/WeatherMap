//
//  SearchClippingView.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-06-03.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class SearchClippingView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 0.0
        
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 20.0, height: 0.0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
    

}
