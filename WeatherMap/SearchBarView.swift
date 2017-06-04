//
//  SearchBarView.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-06-02.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit


class SearchBarView: UISearchBar {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.backgroundColor = UIColor(red: 73/255, green: 144/255, blue: 226/255, alpha: 1).cgColor
//        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Zapfino", size: 10)!], for: .normal)
//        layer.cornerRadius = 0.0
//        layer.borderColor = UIColor(red: 73/255, green: 144/255, blue: 226/255, alpha: 1).cgColor
//        layer.borderWidth = 2.0
        
        
//        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Zapfino", size: 10)!], for: .normal)

        
        
    }

}


