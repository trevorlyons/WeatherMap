//
//  Languages.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-07-10.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import Foundation

class Languages {
    
    let language: String
    var selector: Bool
    
    init(language: String, selector: Bool) {
        self.language = language
        self.selector = selector
    }
}
