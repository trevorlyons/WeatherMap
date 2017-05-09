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
        
//        currentWeather.downloadWeatherDetails {
//            self.updateCurrentWeatherUI()
//            print(self.currentWeather.currentTemp)
//        }
        dumbFunc()
        
    }
    func dumbFunc() {
        currentWeather.downloadWeatherDetails {
            self.updateCurrentWeatherUI()
        }
    }
    
    
    // tableView - long range forecast
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "longRangeForecastCell", for: indexPath) as? LongRangeForecastCell {
            return cell
            
        } else {
            return LongRangeForecastCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    
    // collectionView - hourly forecast
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hourlyForecastCell", for: indexPath) as? HourlyForecastCell {
            return cell
        } else {
            return HourlyForecastCell()
        }

    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    

    func updateCurrentWeatherUI() {
        dateLbl.text = currentWeather.date
        currentTempLbl.text = "\(currentWeather.currentTemp)°"
        currentWeatherType.text = currentWeather.weatherDesc
        currentWeatherImg.image = UIImage(named: currentWeather.weatherType)
        dayHighTempLbl.text = "\(currentWeather.highTemp)"
        dayLowTempLbl.text = "\(currentWeather.lowTemp)"
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


}
