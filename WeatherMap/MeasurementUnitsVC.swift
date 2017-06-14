//
//  MeasurementUnitsVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-06-13.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit

//extension Notification.Name {
//    static let reload = Notification.Name("reload")
//}


class MeasurementUnitsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var units = [Units]()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UserDefaults.standard.register(defaults: ["setMetric" : true])
//        UserDefaults.standard.register(defaults: ["setImperial" : false])
//        readDefaults()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let row1 = Units(unitName: "Metric", selector: true)
        let row2 = Units(unitName: "Imperial", selector: false)
        units.append(row1)
        units.append(row2)
        
    }

    
    // tableView
    
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
            defaults.set(true, forKey: "setMetric")
            defaults.set(false, forKey: "setImperial")
            //NotificationCenter.default.post(name: .reload, object: nil)
        } else if indexPath.row == 1 {
            self.units[0].selector = false
            self.units[1].selector = true
            Singleton.sharedInstance.unitSelectedDarkSky = "us"
            Singleton.sharedInstance.unitSelectedOWM = "imperial"
            tableView.reloadData()
            defaults.set(false, forKey: "setMetric")
            defaults.set(true, forKey: "setImperial")
            //NotificationCenter.default.post(name: .reload, object: nil)
        }
        
    }
    
    func readDefaults() {
        self.units[0].selector = defaults.bool(forKey: "setMetric")
        self.units[1].selector = defaults.bool(forKey: "setImperial")
        
    }


}
