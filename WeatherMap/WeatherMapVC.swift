//
//  ViewController.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-03.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import CoreLocation

class WeatherMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var mapHasCenteredOnce = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location
            mapView.showsUserLocation = true
            Location.sharedInstance.latitude = currentLocation.coordinate.latitude
            Location.sharedInstance.longitude = currentLocation.coordinate.longitude
            
//            currentWeather.downloadWeatherDetails {
//                
//                self.downloadForecastData {
//                    
//                    self.updateMainUI()
//                }
//            }
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 100000, 100000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
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

