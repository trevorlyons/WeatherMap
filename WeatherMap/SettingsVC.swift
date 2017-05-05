//
//  SettingsVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-04.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        self.view.superview?.layer.cornerRadius = 0.0
//    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
}
