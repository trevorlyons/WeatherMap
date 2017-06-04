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


class WeatherMapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, HandleMapPan, MKLocalSearchCompleterDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchClipping: SearchClippingView!
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var mapHasCenteredOnce = false
    var mapUrl: String!
    var mapAnnnotation: MapAnnotation!
    var mapAnnotations = [MapAnnotation]()
    var matchingItems = [MKMapItem]()
    var selectedPin: MKPlacemark? = nil
    var newPin: Favourites!
    var favouritesVC: FavouritesVC!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        searchCompleter.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
        
        loadFavouritesData()
        searchBar.isHidden = true
        tableView.isHidden = true
        searchClipping.isHidden = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationAuthStatus()
        
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        var apiScale = "9"
        
        print("Zoom: \(mapView.getZoomLevel())")
        if mapView.getZoomLevel() < 2 {
            mapView.setCenter(coordinate: mapView.centerCoordinate, zoomLevel: 2, animated: true)
            apiScale = "2"
        }
        else if mapView.getZoomLevel() > 9 {
            apiScale = "13"
        }
        else if mapView.getZoomLevel() >= 10 {
            mapView.setCenter(coordinate: mapView.centerCoordinate, zoomLevel: 9, animated: true)
        }
        print(apiScale)
        
        //let allAnnotations = self.mapView.annotations
        //self.mapView.removeAnnotations(allAnnotations)
        
        let latitudeDelta = mapView.region.span.latitudeDelta
        let longitudeDelta = mapView.region.span.longitudeDelta
        let centerCoordLat = mapView.centerCoordinate.latitude
        let centerCoordLong = mapView.centerCoordinate.longitude
        
        Location.sharedInstance.lowerLeftLatitude = (centerCoordLat - (latitudeDelta/2.0))
        Location.sharedInstance.lowerLeftLongitude = (centerCoordLong - (longitudeDelta/2.0))
        Location.sharedInstance.upperRightLatitude = (centerCoordLat + (latitudeDelta/2.0))
        Location.sharedInstance.upperRightLongitude = (centerCoordLong + (longitudeDelta/2.0))
        
        self.mapUrl = "http://api.openweathermap.org/data/2.5/box/city?bbox=\(Location.sharedInstance.lowerLeftLongitude!),\(Location.sharedInstance.lowerLeftLatitude!),\(Location.sharedInstance.upperRightLongitude!),\(Location.sharedInstance.upperRightLatitude!),\(apiScale)&appid=d9edbc6106170dc5ca87733c4b46128d"

        downloadMapWeatherApi {
            
            annotate()
            self.mapAnnotations = []
        }
    }
    
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if annotation is MKUserLocation {
//            return nil
//        }
//        let reuseID = "location"
//        var av = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
//        
//        if av != nil {
//            av?.annotation = annotation
//        } else {
//            av = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
//            av?.image = UIImage(named: annotation.subtitle!!)
//        }
//        return av
//    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

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
                }
            }
        }
        completed()
    }
    
    
    func annotate() {
        for location in self.mapAnnotations {
            let annotation = MKPointAnnotation()
            annotation.title = location.cityName
            annotation.subtitle = location.weatherType
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
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
//        if let city = placemark.locality,
//            let state = placemark.administrativeArea {
//            annotation.subtitle = "\(city) \(state)"
//        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(1.0, 1.0)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
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
        }
    }
    
    
    func loadFavouritesData() {
        if let favouritesData = NSKeyedUnarchiver.unarchiveObject(withFile: Favourites.ArchiveURL.path) as? [Favourites] {
            Singleton.sharedInstance.favouritesArray = favouritesData
        }
    }
    
    
    func dropPinAndPan(location: Favourites) {
        self.newPin = location
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        annotation.title = location.cityName
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(1.0, 1.0)
        let region = MKCoordinateRegionMake(annotation.coordinate, span)
        mapView.setRegion(region, animated: true)
        
    }
    
    
    @IBAction func unwindToWeatherMapVC(segue: UIStoryboardSegue) {
    }
    

    @IBAction func settingsBtnPressed(_ sender: Any) {
    }
    

    @IBAction func searchBtnPressed(_ sender: Any) {
        if searchBar.isHidden == true {
            searchBar.isHidden = false
        } else {
            searchBar.isHidden = true
            tableView.isHidden = true
            searchClipping.isHidden = true
            searchBar.text = ""
        }
    }
    
    @IBAction func favouritesBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "toFavourites", sender: self)
    }
}

