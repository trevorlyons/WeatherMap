//
//  searchTableView.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-06-02.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class SearchTableView: UITableView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 0.0
        
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 20.0, height: 0.0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer

        layer.backgroundColor = UIColor(red: 70/255, green: 80/255, blue: 137/255, alpha: 0.8).cgColor

    }
    


}
