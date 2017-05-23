//
//  FavouritesVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-22.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

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
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? CityWeatherVC {
            slideInTransitioningDelegate.direction = .bottom
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
        }
    }
    
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
