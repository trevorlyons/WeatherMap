//
//  CityWeatherVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-05.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import Alamofire

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
        
        
        currentWeather = CurrentWeather()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        currentWeather.downloadWeatherDetails {
            self.downloadApiData {
                self.updateCurrentWeatherUI()
            }
            
        }
    }

    func downloadApiData(completed: DownloadComplete) {
        
        let currentWeatherUrl = URL(string: "\(darkSkyUrl)\(segueData.latitude),\(segueData.longitude)?units=si")!
        Alamofire.request(currentWeatherUrl).responseJSON { response in
            let result = response.result
            
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
    

    func updateCurrentWeatherUI() {
        cityNameLbl.text = segueData.cityName
        dateLbl.text = currentWeather.date
        currentTempLbl.text = segueData.temperature
        currentWeatherType.text = currentWeather.weatherDesc
        currentWeatherImg.image = UIImage(named: "\(currentWeather.weatherType)L")
        dayHighTempLbl.text = "\(Int(currentWeather.highTemp))"
        dayLowTempLbl.text = "\(Int(currentWeather.lowTemp))"
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


}
