//
//  FavouritesVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-22.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import os.log

class FavouritesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "favouritesCell", for: indexPath) as? FavouritesCell {
            
            let favourites = Singleton.sharedInstance.favouritesArray[indexPath.row]
            cell.configureCell(favourites: favourites)
            return cell
        } else {
            return FavouritesCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Singleton.sharedInstance.favouritesArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellDict = Singleton.sharedInstance.favouritesArray[indexPath.row]
        let send = SegueData(cityName: cellDict.cityName, latitude: cellDict.latitude, longitude: cellDict.longitude)
        self.performSegue(withIdentifier: "favouritesCityWeather", sender: send)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Singleton.sharedInstance.favouritesArray.remove(at: indexPath.row)
            self.tableView.reloadData()
            saveFavouritesData()
        }
    }
    
    
    
    func saveFavouritesData() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(Singleton.sharedInstance.favouritesArray, toFile: Favourites.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Favourites successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save Favourites...", log: OSLog.default, type: .error)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? CityWeatherVC {
            if let x = sender as? SegueData {
                controller.segueData = x
            }
            
            slideInTransitioningDelegate.direction = .bottom
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        }
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
