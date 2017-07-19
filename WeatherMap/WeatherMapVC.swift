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


class WeatherMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, HandleMapPan, MKLocalSearchCompleterDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchClipping: SearchClippingView!
    @IBOutlet weak var warningView: RoundedCornerView!
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var mapHasCenteredOnce = false
    var mapUrl: String!
    var mapAnnotation: MapAnnotation!
    var mapAnnotations = [MapAnnotation]()
    var mapAnnotationsWithDuplicates = [MapAnnotation]()
    var matchingItems = [MKMapItem]()
    var selectedPin: MKPlacemark? = nil
    var newPin: Favourites!
    var favouritesVC: FavouritesVC!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    var zoomLevelBeforeChange: Double!
    var lowerLeftLong: Double!
    var lowerLeftLat: Double!
    var upperRightLong: Double!
    var upperRightLat: Double!
    
    let defaults = UserDefaults.standard


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
        updateUserInterface()
        warningView.isHidden = true
        
        mapView.delegate = self
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        searchCompleter.delegate = self
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        
        loadFavouritesData()
        searchBar.isHidden = true
        tableView.isHidden = true
        searchClipping.isHidden = true
        mapView.isRotateEnabled = false
        
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(pressScreenDropPin(gesture:)))
        longPressGesture.minimumPressDuration = 0.3
        self.mapView.addGestureRecognizer(longPressGesture)
        
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        defaults.register(defaults: ["DarkSky" : "si"])
        defaults.register(defaults: ["OWM" : "metric"])
        defaults.register(defaults: ["Language" : "English"])
        loadUserDefaults()
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationAuthStatus()
        
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            performSegue(withIdentifier: "showTutorial", sender: self)
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }
    
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            warningView.isHidden = false
        case .wifi:
            warningView.isHidden = true
        case .wwan:
            warningView.isHidden = true
        }
        print("Reachability Summary")
        print("Status:", status)
        print("HostName:", Network.reachability?.hostname ?? "nil")
        print("Reachable:", Network.reachability?.isReachable ?? "nil")
        print("Wifi:", Network.reachability?.isReachableViaWiFi ?? "nil")
    }
    func statusManager(_ notification: NSNotification) {
        updateUserInterface()
    }
    
    
    func loadUserDefaults() {
        Singleton.sharedInstance.unitSelectedDarkSky = defaults.string(forKey: "DarkSky")!
        Singleton.sharedInstance.unitSelectedOWM = defaults.string(forKey: "OWM")!
        Singleton.sharedInstance.languageSelected = defaults.string(forKey: "Language")!
    }

    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location
            mapView.showsUserLocation = true
            Location.sharedInstance.latitude = currentLocation.coordinate.latitude
            Location.sharedInstance.longitude = currentLocation.coordinate.longitude
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
    
    
    
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        zoomLevelBeforeChange = ((mapView.getZoomLevel() * 100).rounded() / 100)
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        var apiScale: String
        print("Zoom: \(mapView.getZoomLevel())")
        
        if mapView.getZoomLevel() < 2 {
            mapView.setCenter(coordinate: mapView.centerCoordinate, zoomLevel: 2, animated: true)
            apiScale = "1"
        } else if mapView.getZoomLevel() >= 2.0 && mapView.getZoomLevel() < 3.0 {
            apiScale = "1"
        } else if mapView.getZoomLevel() >= 3.0 && mapView.getZoomLevel() < 4.0 {
            apiScale = "3"
        } else if mapView.getZoomLevel() >= 4.0 && mapView.getZoomLevel() < 5.0 {
            apiScale = "5"
        } else if mapView.getZoomLevel() >= 5.0 && mapView.getZoomLevel() < 6.0 {
            apiScale = "6"
        } else if mapView.getZoomLevel() >= 6.0 && mapView.getZoomLevel() < 7.5 {
            apiScale = "7"
        } else if mapView.getZoomLevel() >= 7.5 && mapView.getZoomLevel() < 8.5 {
            apiScale = "9"
        } else if mapView.getZoomLevel() >= 8.5 && mapView.getZoomLevel() <= 9.5 {
            apiScale = "11"
        } else if mapView.getZoomLevel() >= 9.5 && mapView.getZoomLevel() <= 10.0 {
            apiScale = "13"
        } else if mapView.getZoomLevel() > 10 {
            mapView.setCenter(coordinate: mapView.centerCoordinate, zoomLevel: 10, animated: true)
            apiScale = "13"
        } else {
            apiScale = "0"
        }
        print(apiScale)
        
        if ((mapView.getZoomLevel() * 100).rounded() / 100) == zoomLevelBeforeChange {
            print("don't remove annotations")
        } else {
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
        }

        let latitudeDelta = mapView.region.span.latitudeDelta
        let longitudeDelta = mapView.region.span.longitudeDelta
        let centerCoordLat = mapView.centerCoordinate.latitude
        let centerCoordLong = mapView.centerCoordinate.longitude
        
        lowerLeftLong = (centerCoordLong - (longitudeDelta) / 2)
        lowerLeftLat = (centerCoordLat - (latitudeDelta) / 2)
        upperRightLong = (centerCoordLong + (longitudeDelta) / 2)
        upperRightLat = (centerCoordLat + (latitudeDelta) / 2)
        
        mapUrl = "http://api.openweathermap.org/data/2.5/box/city?bbox=\(lowerLeftLong!),\(lowerLeftLat!),\(upperRightLong!),\(upperRightLat!),\(apiScale)&appid=***REMOVED***&units=\(Singleton.sharedInstance.unitSelectedOWM)"
        
        downloadMapWeatherApi {
            self.mapAnnotations = []
        }
    }

    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "reuseId"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            annotationView?.canShowCallout = false
            annotationView?.centerOffset = CGPoint(x: 0.0, y: -20.0)
            let lbl = UILabel(frame: CGRect(x: 12, y: 34, width: 35, height: 15))
//            let lbl = UILabel(frame: CGRect(x: 16, y: 45, width: 30, height: 15))
            lbl.font = UIFont(name: "AvenirNext-Medium", size: 14)
            lbl.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 0.8)
            lbl.textAlignment = .center
            lbl.tag = 42
            annotationView?.frame = lbl.frame
            annotationView?.addSubview(lbl)
            let weatherImg = UIImageView(frame: CGRect(x: 12, y: 5, width: 30, height: 30))
//            let weatherImg = UIImageView(frame: CGRect(x: 14, y: 14, width: 30, height: 30))
            weatherImg.contentMode = .center
            weatherImg.tag = 43
            annotationView?.frame = weatherImg.frame
            annotationView?.addSubview(weatherImg)
        } else {
            annotationView?.annotation = annotation
        }
        let customPointAnnotation = annotation as! CustomAnnotation
        
        var weatherIcon: String!
        if customPointAnnotation.attribute == "01d" {
            weatherIcon = "clear-day"
        } else if customPointAnnotation.attribute == "01n" {
            weatherIcon = "clear-night"
        } else if customPointAnnotation.attribute == "02d" {
            weatherIcon = "partly-cloudy-day"
        } else if customPointAnnotation.attribute == "02n" {
            weatherIcon = "partly-cloudy-night"
        } else if customPointAnnotation.attribute == "03d" || customPointAnnotation.attribute == "03n" || customPointAnnotation.attribute == "04d" || customPointAnnotation.attribute == "04n" {
            weatherIcon = "cloudy"
        } else if customPointAnnotation.attribute == "09d" || customPointAnnotation.attribute == "09n" || customPointAnnotation.attribute == "10d" || customPointAnnotation.attribute == "10n" || customPointAnnotation.attribute == "11d" || customPointAnnotation.attribute == "11n" {
            weatherIcon = "rain"
        } else if customPointAnnotation.attribute == "13d" || customPointAnnotation.attribute == "13n" {
            weatherIcon = "snow"
        } else if customPointAnnotation.attribute == "50d" || customPointAnnotation.attribute == "50n" {
            weatherIcon = "fog"
        } else {
            weatherIcon = ""
        }
        
        let lbl = annotationView?.viewWithTag(42) as! UILabel
        lbl.text = customPointAnnotation.subtitle
        let weatherImg = annotationView?.viewWithTag(43) as! UIImageView
        weatherImg.image = UIImage(named: weatherIcon)
        var customPin: String!
        if customPointAnnotation.subtitle == "" {
            customPin = "locationDrop"
        } else {
            customPin = "location"
        }
        annotationView?.image = UIImage(named: customPin)
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let send = SegueData(cityName: ((view.annotation?.title)!)!, latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
        performSegue(withIdentifier: "selectedCity", sender: send)
    }
    
    
    func downloadMapWeatherApi(completed: DownloadComplete) {
        Alamofire.request(self.mapUrl).responseJSON { response in
            let result = response.result
            if let dict = result.value as? Dictionary<String, AnyObject> {
                if let list = dict["list"] as? [Dictionary<String, AnyObject>] {
                    
                    for obj in list {
                        let annotation = MapAnnotation(locationDict: obj)
                        self.mapAnnotations.append(annotation)
                    }
                    self.annotate()
                }
            }
        }
        completed()
    }
    
    
    func annotate() {
        for location in self.mapAnnotations {
            let annotation = CustomAnnotation()
            annotation.title = location.cityName
            annotation.subtitle = "\(Int(location.temperature))°"
            annotation.attribute = location.weatherType
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            mapView.addAnnotation(annotation)
        
        }
    }
    
    
    
    // Search TableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as? SearchCell {
            let selectedItem = searchResults[indexPath.row]
            
            if selectedItem.subtitle != "" {
                cell.textLabel?.text = ""
            } else {
                cell.configureCell(selectedItem: selectedItem)
                return cell
            }
        }
        return SearchCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let selectedItem = searchResults[indexPath.row]
        if selectedItem.subtitle != "" {
            return 0
        }
        return 40
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResults.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let completion = searchResults[indexPath.row]
        let request = MKLocalSearchRequest(completion: completion)
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else { return }

            let selectedItem = response.mapItems[0].placemark
            self.dropPinZoomIn(placemark: selectedItem)
        }
        tableView.isHidden = true
        searchBar.isHidden = true
        searchClipping.isHidden = true
        searchBar.text = ""
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) {
            cell.separatorInset.right = cell.bounds.size.width
        }
    }
    
    
    // SearchBar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableView.isHidden = false
        searchClipping.isHidden = false

        if !searchText.isEmpty {
            searchCompleter.queryFragment = searchText
            searchCompleter.filterType = .locationsOnly
        } else {
            tableView.isHidden = true
            searchClipping.isHidden = true
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: self.tableView.frame.size.width, height: self.tableView.contentSize.height)
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        
        print(error.localizedDescription)
    }
    
    

    
    
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = CustomAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        annotation.subtitle = ""
        annotation.attribute = ""
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(1.0, 1.0)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    func dropPinAndPan(location: Favourites) {
        self.newPin = location
        mapView.removeAnnotations(mapView.annotations)
        let annotation = CustomAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        annotation.title = location.cityName
        annotation.subtitle = ""
        annotation.attribute = ""
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(1.0, 1.0)
        let region = MKCoordinateRegionMake(annotation.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
    func pressScreenDropPin(gesture: UIGestureRecognizer) {
        if gesture.state == .ended {
            let touchPoint = gesture.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = CustomAnnotation()
            annotation.coordinate = newCoordinates
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: { (placemark, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                if (placemark?.count)! > 0 {
                    let pm = placemark?[0]
                    if pm?.ocean != nil {
                        print("No ocean weather")
                    } else if pm?.locality == nil {
                        annotation.title = pm?.name
                        annotation.subtitle = ""
                        annotation.attribute = ""
                        self.mapView.addAnnotation(annotation)
                    } else {
                        annotation.title = pm?.locality
                        annotation.subtitle = ""
                        annotation.attribute = ""
                        self.mapView.addAnnotation(annotation)
                    }
                }
                else {
                    annotation.title = "Unknown Place"
                    self.mapView.addAnnotation(annotation)
                    print("Problem with the data received from geocoder")
                }
            })
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? SettingsVC {
            slideInTransitioningDelegate.direction = .bottom
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
            
        } else if let controller = segue.destination as? CityWeatherVC {
            
            if let x = sender as? SegueData {
                controller.segueData = x
            }
            
            slideInTransitioningDelegate.direction = .bottom
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
            
        } else if let controller = segue.destination as? FavouritesVC {
            slideInTransitioningDelegate.direction = .bottom
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
            
            controller.mapPanDelegate = self
        } else if let controller = segue.destination as? TutorialVC {
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            let screenHeight = screenSize.height
            controller.preferredContentSize = CGSize(width: screenWidth*0.9, height: screenHeight*0.7)
            
            let popoverController = controller.popoverPresentationController
            
            if popoverController != nil {
                popoverController!.delegate = self
                popoverController!.sourceView = self.view
                popoverController!.sourceRect = CGRect(x: self.view.bounds.midX, y: (self.view.bounds.midY)+50, width: 0, height: 0)
                popoverController!.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    
    func loadFavouritesData() {
        if let favouritesData = NSKeyedUnarchiver.unarchiveObject(withFile: Favourites.ArchiveURL.path) as? [Favourites] {
            Singleton.sharedInstance.favouritesArray = favouritesData
        }
    }
    
    

    
    
    @IBAction func unwindToWeatherMapVC(segue: UIStoryboardSegue) {
    }
    
    @IBAction func settingsPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "settings", sender: self)
    }
    
    @IBAction func searchPressed(_ sender: UITapGestureRecognizer) {
        if searchBar.isHidden == true {
            searchBar.isHidden = false
        } else {
            searchBar.isHidden = true
            tableView.isHidden = true
            searchClipping.isHidden = true
            searchBar.text = ""
        }
    }
    
    @IBAction func locatePressed(_ sender: UITapGestureRecognizer) {
        centerMapOnLocation(location: currentLocation)
    }

    
    @IBAction func favouritesPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "toFavourites", sender: self)
    }
}

