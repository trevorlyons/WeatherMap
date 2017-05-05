//
//  ViewController.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-03.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import MapKit

class WeatherMapVC: UIViewController, MKMapViewDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
    }
    
    
    override func prepare(for segue:UIStoryboardSegue, sender:Any!) {
        if segue.identifier == "settings" {
            let settingsController = segue.destination as! SettingsVC
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            settingsController.preferredContentSize = CGSize(width: screenWidth, height: screenHeight*0.75)
            
            let popoverController = settingsController.popoverPresentationController
            
            if popoverController != nil {
                popoverController!.delegate = self
                popoverController!.backgroundColor = UIColor.white
                popoverController!.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)

            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    @IBAction func settingsBtnPressed(_ sender: Any) {
    }
    

    @IBAction func searchBtnPressed(_ sender: Any) {
    }
    
    
}

