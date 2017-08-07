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


class WeatherMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, HandleMapPan, MKLocalSearchCompleterDelegate, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, HandleRemoveAnnotations {

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
    var onlyNewMapAnnotations = [MapAnnotation]()
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
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didDoubleTapMap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = self
        mapView.addGestureRecognizer(doubleTapGesture)
        
        tap.require(toFail: doubleTapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.didPinchMap(_:)))
        pinchGesture.delegate = self
        mapView.addGestureRecognizer(pinchGesture)
        
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
            print("App previously launched")
        } else {
            print("First launch, setting UserDefault")
            performSegue(withIdentifier: "showTutorial", sender: self)
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }
    
    
    // Network connection status function
    
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
    
    
    // Load settings function
    
    func loadUserDefaults() {
        Singleton.sharedInstance.unitSelectedDarkSky = defaults.string(forKey: "DarkSky")!
        Singleton.sharedInstance.unitSelectedOWM = defaults.string(forKey: "OWM")!
        Singleton.sharedInstance.languageSelected = defaults.string(forKey: "Language")!
    }

    
    // MapView functions - Location authorization and centering
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if self.locationManager.location != nil {
                currentLocation = locationManager.location
                mapView.showsUserLocation = true
                Location.sharedInstance.latitude = currentLocation.coordinate.latitude
                Location.sharedInstance.longitude = currentLocation.coordinate.longitude
            } else {
                print("error")
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
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
    
    
    // MapView functions - Gesture recognizers
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func didPinchMap(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            removeAnnotations()
        }
    }
    
    func didDoubleTapMap(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            removeAnnotations()
        }
    }
    
    func removeAnnotations() {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        self.mapAnnotations = []
        self.onlyNewMapAnnotations = []
    }
    
    func removeAndReplaceAnnotations() {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        self.mapAnnotations = []
        self.onlyNewMapAnnotations = []
        getMapUrl()
        downloadMapWeatherApi() {
            self.onlyNewMapAnnotations = []
        }
    }
    
    
    // MapView functions - Download API data and annotate mapView
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            view.canShowCallout = false
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        getMapUrl()
        downloadMapWeatherApi {
            self.onlyNewMapAnnotations = []
        }
    }
    
    func getMapUrl() {
        var apiScale: String
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
        } else if mapView.getZoomLevel() >= 9.5 && mapView.getZoomLevel() <= 10.5 {
            apiScale = "12"
        } else if mapView.getZoomLevel() >= 10.5 && mapView.getZoomLevel() <= 13.0 {
            apiScale = "13"
        } else if mapView.getZoomLevel() > 13.0 {
            mapView.setCenter(coordinate: mapView.centerCoordinate, zoomLevel: 13, animated: true)
            apiScale = "13"
        } else {
            apiScale = "0"
        }
        
        let latitudeDelta = mapView.region.span.latitudeDelta
        let longitudeDelta = mapView.region.span.longitudeDelta
        let centerCoordLat = mapView.centerCoordinate.latitude
        let centerCoordLong = mapView.centerCoordinate.longitude
        lowerLeftLong = (centerCoordLong - (longitudeDelta) / 2)
        lowerLeftLat = (centerCoordLat - (latitudeDelta) / 2)
        upperRightLong = (centerCoordLong + (longitudeDelta) / 2)
        upperRightLat = (centerCoordLat + (latitudeDelta) / 2)
        
        mapUrl = "\(OWMUrl)\(lowerLeftLong!),\(lowerLeftLat!),\(upperRightLong!),\(upperRightLat!),\(apiScale)\(OWMKey)\(Singleton.sharedInstance.unitSelectedOWM)"
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
            let lbl = UILabel(frame: CGRect(x: 13, y: 45, width: 35, height: 15))
            lbl.font = UIFont(name: "AvenirNext-Medium", size: 14)
            lbl.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 0.8)
            lbl.textAlignment = .center
            lbl.tag = 42
            annotationView?.frame = lbl.frame
            annotationView?.addSubview(lbl)
            let weatherImg = UIImageView(frame: CGRect(x: 14, y: 14, width: 30, height: 30))
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
        } else if customPointAnnotation.attribute == "02d" || customPointAnnotation.attribute == "03d" {
            weatherIcon = "partly-cloudy-day"
        } else if customPointAnnotation.attribute == "02n" || customPointAnnotation.attribute == "03n" {
            weatherIcon = "partly-cloudy-night"
        } else if customPointAnnotation.attribute == "04d" || customPointAnnotation.attribute == "04n" {
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
//            for anno in Singleton.sharedInstance.favouritesArray {
//                print("\(customPointAnnotation.title!) - \(anno.cityName)")
//                print("\(customPointAnnotation.coordinate.latitude) - \(anno.latitude)")
//                if anno.latitude == customPointAnnotation.coordinate.latitude {
//                    customPin = "location-favourite"
//                    lbl.textColor = UIColor(white: 1, alpha: 1)
//                } else {
//                    customPin = "location-shadow"
//                    lbl.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 0.8)
//                }
//            }
            customPin = "location-shadow"
        }
        annotationView?.image = UIImage(named: customPin)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let send = SegueData(cityName: (((view.annotation?.title)!)!), latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
        performSegue(withIdentifier: "selectedCity", sender: send)
        
        mapView.deselectAnnotation(view.annotation, animated: false)
    }

    func downloadMapWeatherApi(completed: DownloadComplete) {
        Alamofire.request(self.mapUrl).responseJSON { response in
            let result = response.result
            if let dict = result.value as? Dictionary<String, AnyObject> {
                if let list = dict["list"] as? [Dictionary<String, AnyObject>] {
                    
                    for obj in list {
                        let annotation = MapAnnotation(locationDict: obj)
                        if self.mapAnnotations.contains(where: { $0.cityName == annotation.cityName }) {
                        } else {
                            self.mapAnnotations.append(annotation)
                            self.onlyNewMapAnnotations.append(annotation)
                        }
                    }
                    self.annotate()
                }
            }
        }
        completed()
    }
    
    func annotate() {
        for location in self.onlyNewMapAnnotations {
            let annotation = CustomAnnotation()
            annotation.title = location.cityName
            annotation.subtitle = "\(Int(location.temperature))°"
            annotation.attribute = location.weatherType
            annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    
    // Search functions
    // Search - TableView
    
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
    
    
    // Search - Bar
    
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
    
    
    // Annotate and move screen functions
    
    func dropPinZoomIn(placemark:MKPlacemark){
        removeAnnotations()
        selectedPin = placemark
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
        removeAnnotations()
        self.newPin = location
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
    
    
    // Override segue transition styles
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SettingsVC {
            slideInTransitioningDelegate.direction = .bottom
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
            controller.removeAnnotationsDelegate = self
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
    
    
    // Load favourites data function
    
    func loadFavouritesData() {
        if let favouritesData = NSKeyedUnarchiver.unarchiveObject(withFile: Favourites.ArchiveURL.path) as? [Favourites] {
            Singleton.sharedInstance.favouritesArray = favouritesData
        }
    }
    
    
    // Screen press actions
    
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
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            locationAuthStatus()
            centerMapOnLocation(location: currentLocation)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            let alertController = UIAlertController (title: "", message: "User Location is currently not activated. Change to 'While Using the App' to pan to user location.", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
            
        case .restricted:
            break
        }
    }

    
    @IBAction func favouritesPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "toFavourites", sender: self)
    }
}

