//
//  SettingsVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-04.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var unitTypeLbl: UILabel!

    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        unitTypeLbl.text = Singleton.sharedInstance.unitSelectedOWM.capitalized
    }



    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? MeasurementUnitsVC {
            slideInTransitioningDelegate.direction = .right
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        }
    }

    @IBAction func measureUnitsPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "unitsSegue", sender: self)
    }


    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
        unitTypeLbl.text = Singleton.sharedInstance.unitSelectedOWM.capitalized
    }
    

}
