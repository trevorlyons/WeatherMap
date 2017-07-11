//
//  LanguagesCell.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-07-10.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class LanguagesCell: UITableViewCell {

    

    @IBOutlet weak var languageLbl: UILabel!
    @IBOutlet weak var selectorImg: UIImageView!
    
    func configureCell(languages: Languages) {
        
        languageLbl.text = languages.language
        
        var setSelected: String
        if languages.selector == true {
            setSelected = "selected"
        } else {
            setSelected = "unselected"
        }
        selectorImg.image = UIImage(named: setSelected)
    }

}
