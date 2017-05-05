//
//  ViewController.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-03.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import MapKit

class WeatherMapVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SettingsVC {
            slideInTransitioningDelegate.direction = .bottom
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
            
        } else if let controller = segue.destination as? CityWeatherVC {
            
            slideInTransitioningDelegate.direction = .bottom
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        }
    }
    

    @IBAction func settingsBtnPressed(_ sender: Any) {
    }
    

    @IBAction func searchBtnPressed(_ sender: Any) {
    }
    
    
}

