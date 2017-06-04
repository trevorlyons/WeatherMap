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
        
        
        
        //layer.backgroundColor = UIColor(white: 1.0, alpha: 0.85).cgColor
        layer.backgroundColor = UIColor(red: 187/255, green: 222/255, blue: 251/255, alpha: 0.8).cgColor
//        layer.borderWidth = 3.0
//        layer.borderColor = UIColor(red: 73/255, green: 144/255, blue: 226/255, alpha: 1).cgColor
    }
    


}
