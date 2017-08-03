//
//  MeasurementUnitsVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-06-13.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

class MeasurementUnitsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var units = [Units]()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
        
        let row1 = Units(unitName: "Metric", selector: true)
        let row2 = Units(unitName: "Imperial", selector: false)
        units.append(row1)
        units.append(row2)
        
        UserDefaults.standard.register(defaults: ["setMetric" : true])
        UserDefaults.standard.register(defaults: ["setImperial" : false])
        readDefaults()
    }

    
    // TableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "units", for: indexPath) as? UnitsCell {
            let unit = units[indexPath.row]
            cell.configureCell(units: unit)
            return cell
        } else {
            return UnitsCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.units[0].selector = true
            self.units[1].selector = false
            Singleton.sharedInstance.unitSelectedDarkSky = "si"
            Singleton.sharedInstance.unitSelectedOWM = "metric"
            tableView.reloadData()
            defaults.set("si", forKey: "DarkSky")
            defaults.set("metric", forKey: "OWM")
            defaults.set(true, forKey: "setMetric")
            defaults.set(false, forKey: "setImperial")
        } else if indexPath.row == 1 {
            self.units[0].selector = false
            self.units[1].selector = true
            Singleton.sharedInstance.unitSelectedDarkSky = "us"
            Singleton.sharedInstance.unitSelectedOWM = "imperial"
            tableView.reloadData()
            defaults.set("us", forKey: "DarkSky")
            defaults.set("imperial", forKey: "OWM")
            defaults.set(false, forKey: "setMetric")
            defaults.set(true, forKey: "setImperial")
        }
    }
    
    
    // Read existing default settings
    
    func readDefaults() {
        self.units[0].selector = defaults.bool(forKey: "setMetric")
        self.units[1].selector = defaults.bool(forKey: "setImperial")
    }
    
    
    // Screen press actions
    
    @IBAction func backPressed(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "unwindSegueToSettings", sender: self)
    }
}

