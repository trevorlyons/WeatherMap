//
//  CityWeatherVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-05.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import Alamofire
import os.log

class CityWeatherVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cityNameLbl: UILabel!
    @IBOutlet weak var currentTempLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var currentWeatherImg: UIImageView!
    @IBOutlet weak var currentWeatherType: UILabel!
    @IBOutlet weak var dayHighTempLbl: UILabel!
    @IBOutlet weak var dayLowTempLbl: UILabel!
    
    var currentWeather: CurrentWeather!
    var longRangeForecast: LongRangeForecast!
    var longRangeForecasts = [LongRangeForecast]()
    var hourlyForecast: HourlyForecast!
    var hourlyForecasts = [HourlyForecast]()
    
    
    private var _segueData: SegueData!
    var segueData: SegueData {
        get {
            return _segueData
        } set {
            _segueData = newValue
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        downloadApiData {
            //self.updateCurrentWeatherUI()
        }
    }

    func downloadApiData(completed: DownloadComplete) {
        
        let currentWeatherUrl = URL(string: "\(darkSkyUrl)\(segueData.latitude),\(segueData.longitude)?units=si")!
        Alamofire.request(currentWeatherUrl).responseJSON { response in
            let result = response.result
            
            if let array = result.value as? JSONDictionary {
                let current = CurrentWeather(currentDict: array)
                self.updateCurrentWeatherUI(currentWeather: current)
            }
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                
                if let hourly = dict["hourly"] as? Dictionary<String, AnyObject> {
                    if let data = hourly["data"] as? [Dictionary<String, AnyObject>] {
                        
                        for obj in data {
                            let forecast = HourlyForecast(hourlyDict: obj)
                            self.hourlyForecasts.append(forecast)
                        }
                        self.collectionView.reloadData()
                    }
                        
                }
                if let daily = dict["daily"] as? Dictionary<String, AnyObject> {
                    if let data = daily["data"] as? [Dictionary<String, AnyObject>] {
                        
                        for obj in data {
                            let forecast = LongRangeForecast(longWeatherDict: obj)
                            self.longRangeForecasts.append(forecast)
                        }
                        self.longRangeForecasts.remove(at: 0)
                        self.tableView.reloadData()
                    }
                }
            }
            
        }
        completed()
        
    }
    
    // tableView - long range forecast
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "longRangeForecastCell", for: indexPath) as? LongRangeForecastCell {
            let forecast = longRangeForecasts[indexPath.row]
            cell.configureCell(longRangeForecast: forecast)
            return cell
            
        } else {
            return LongRangeForecastCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return longRangeForecasts.count
    }
    
    
    // collectionView - hourly forecast
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourlyForecastCell", for: indexPath) as? HourlyForecastCell {
            
            let forecast = hourlyForecasts[indexPath.row]
            cell.configureCell(hourlyForecast: forecast)
            return cell
        } else {
            return HourlyForecastCell()
        }

    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hourlyForecasts.count
        
    }
    

    func updateCurrentWeatherUI(currentWeather: CurrentWeather) {
        cityNameLbl.text = segueData.cityName
        dateLbl.text = currentWeather.date
        currentTempLbl.text = "\(Int(currentWeather.currentTemp))°"
        currentWeatherType.text = currentWeather.weatherDesc
        currentWeatherImg.image = UIImage(named: "\(currentWeather.weatherType)L")
        dayHighTempLbl.text = "\(Int(currentWeather.highTemp))"
        dayLowTempLbl.text = "\(Int(currentWeather.lowTemp))"
    }
    
    func saveFavouritesData() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(Singleton.sharedInstance.favouritesArray, toFile: Favourites.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func favouritesButtonPressed(_ sender: Any) {
        
        let favs = Favourites(cityName: segueData.cityName, latitude: segueData.latitude, longitude: segueData.longitude)
        Singleton.sharedInstance.favouritesArray.append(favs)
        saveFavouritesData()
        
        
    }

}
