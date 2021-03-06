
//  CityWeatherVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-05-05.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import Alamofire
import os.log
import GoogleMobileAds

protocol deleteAnnotation {
    func removeAnnotationsForFavourites()
}

class CityWeatherVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate {
    
    
    // MARK: IBOutlets
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cityNameLbl: UILabel!
    @IBOutlet weak var currentTempLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var currentWeatherImg: UIImageView!
    @IBOutlet weak var currentWeatherType: UILabel!
    @IBOutlet weak var dayHighTempLbl: UILabel!
    @IBOutlet weak var dayLowTempLbl: UILabel!
    @IBOutlet weak var favouritesBtn: UIButton!
    @IBOutlet weak var temperatureLbl: UILabel!
    @IBOutlet weak var apparentTempLbl: UILabel!
    @IBOutlet weak var precipProbabilityLbl: UILabel!
    @IBOutlet weak var humidityLbl: UILabel!
    @IBOutlet weak var windSpeedLbl: UILabel!
    @IBOutlet weak var pressureLbl: UILabel!
    @IBOutlet weak var highTempImg: UIImageView!
    @IBOutlet weak var lowTempImg: UIImageView!
    @IBOutlet weak var uvIndexLbl: UILabel!
    @IBOutlet weak var uvIndexHighLbl: UILabel!
    @IBOutlet weak var sunriseLbl: UILabel!
    @IBOutlet weak var sunsetLbl: UILabel!
    @IBOutlet weak var tempChartView: UIView!
    @IBOutlet weak var rainChartView: UIView!
    
    
    // MARK: Variables and Constants
    
    var currentWeather: CurrentWeather!
    var longRangeForecast: LongRangeForecast!
    var longRangeForecasts = [LongRangeForecast]()
    var hourlyForecast: HourlyForecast!
    var hourlyForecasts = [HourlyForecast]()
    var favourited = false
    var deleteAnnotationsDelegate: deleteAnnotation!
    private var _segueData: SegueData!
    var segueData: SegueData {
        get {
            return _segueData
        } set {
            _segueData = newValue
        }
    }
    
    
    // MARK: ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 1))
        
        setFavouritesIcon()
        
        // test ads
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        
        //live ads
        bannerView.adUnitID = "ca-app-pub-2871254793739488/9633223656"
        
        bannerView.rootViewController = self
        
        let request = GADRequest()
        
        // allowing test simulator to view ads
        request.testDevices = [kGADSimulatorID]
        bannerView.load(request)
    }
    
    
    // MARK: ViewDidAppear
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        downloadApiData {}
    }

    
    // MARK: Download data from API
    
    func downloadApiData(completed: DownloadComplete) {
        let currentWeatherUrl = URL(string: "\(darkSkyUrl)\(segueData.latitude),\(segueData.longitude)?units=\(Singleton.sharedInstance.unitSelectedDarkSky)")!
        print(currentWeatherUrl)
        Alamofire.request(currentWeatherUrl).responseJSON { response in
            let result = response.result
            if let dict = result.value as? Dictionary<String, AnyObject> {
                if let offset = dict["offset"] as? Double {
                    Singleton.sharedInstance.timeZoneOffset = Int(offset) * 3600
                }
                if let daily = dict["daily"] as? Dictionary<String, AnyObject> {
                    if let data = daily["data"] as? [Dictionary<String, AnyObject>] {
                        for obj in data {
                            let forecast = LongRangeForecast(longWeatherDict: obj)
                            self.longRangeForecasts.append(forecast)
                            let sunrise = HourlyForecast(sunriseDict: obj)
                            self.hourlyForecasts.append(sunrise)
                            let sunset = HourlyForecast(sunsetDict: obj)
                            self.hourlyForecasts.append(sunset)
                        }
                        self.longRangeForecasts.remove(at: 0)
                        self.tableView.reloadData()
                    }
                }
                if let hourly = dict["hourly"] as? Dictionary<String, AnyObject> {
                    if let data = hourly["data"] as? [Dictionary<String, AnyObject>] {
                        for obj in data {
                            let forecast = HourlyForecast(hourlyDict: obj)
                            self.hourlyForecasts.append(forecast)
                        }
                        self.collectionView.reloadData()
                        self.hourlyForecasts.sort() { ($0.time) < ($1.time) }
                        
                        if self.hourlyForecasts[0].time == self.hourlyForecasts[1].time {
                            self.hourlyForecasts = self.hourlyForecasts.filter() { $0.weatherDesc != "sunrise" }
                            self.hourlyForecasts = self.hourlyForecasts.filter() { $0.weatherDesc != "sunset" }
                        } else if self.hourlyForecasts[0].weatherDesc == "sunrise" && self.hourlyForecasts[1].weatherDesc == "sunset" {
                            print("sunrise/ sunset")
                            self.hourlyForecasts.removeFirst(2)
                            self.hourlyForecasts.removeLast(10)
                        } else if self.hourlyForecasts[0].weatherDesc == "sunrise" {
                            self.hourlyForecasts.remove(at: 0)
                            self.hourlyForecasts.removeLast(11)
                        } else {
                            self.hourlyForecasts.removeLast(12)
                        }
                    }
                }
            }
            if let array = result.value as? JSONDictionary {
                let current = CurrentWeather(currentDict: array)
                self.updateCurrentWeatherUI(currentWeather: current)
            }
        }
        completed()
    }
    
    
    // MARK: TableView - long range forecast
    
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
    
    
    // MARK: CollectionView - hourly forecast
    
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
    
    
    // MARK: Update UI
    
    func updateCurrentWeatherUI(currentWeather: CurrentWeather) {
        cityNameLbl.text = segueData.cityName.capitalized
        cityNameLbl.isHidden = false
        dateLbl.text = currentWeather.date
        dateLbl.isHidden = false
        currentTempLbl.text = "\(Int(currentWeather.currentTemp))°"
        currentTempLbl.isHidden = false
        currentWeatherType.text = currentWeather.weatherDesc
        currentWeatherType.isHidden = false
        currentWeatherImg.image = UIImage(named: "\(currentWeather.weatherType)L")
        dayHighTempLbl.text = "\(Int(currentWeather.highTemp))°"
        dayHighTempLbl.isHidden = false
        highTempImg.isHidden = false
        dayLowTempLbl.text = "\(Int(currentWeather.lowTemp))°"
        dayLowTempLbl.isHidden = false
        lowTempImg.isHidden = false
        temperatureLbl.text = "\(Int(currentWeather.currentTemp))°"
        apparentTempLbl.text = "\(Int(currentWeather.apparentTemp))°"
        var precipType: String
        if currentWeather.precipType == "n/a" {
            precipType = "rain"
        } else {
            precipType = currentWeather.precipType
        }
        precipProbabilityLbl.text = "At this moment the chance of \(precipType) is \(Int(currentWeather.precipPropbability * 100))%"
        humidityLbl.text = "\(Int(currentWeather.humidity * 100))%"
        var windDirection: String
        if currentWeather.windDirection >= 0 && currentWeather.windDirection <= 90 {
            windDirection = "NE"
        } else if currentWeather.windDirection > 90 && currentWeather.windDirection <= 180 {
            windDirection = "SE"
        } else if currentWeather.windDirection > 180 && currentWeather.windDirection <= 270 {
            windDirection = "SW"
        } else {
            windDirection = "NE"
        }
        var windSpeedUnits: String
        if Singleton.sharedInstance.unitSelectedDarkSky == "us" {
            windSpeedUnits = "mph"
        } else {
            windSpeedUnits = "m/s"
        }
        windSpeedLbl.text = "\(windDirection) \(Int(currentWeather.windSpeed)) \(windSpeedUnits)"
        pressureLbl.text = "\(Int(currentWeather.pressure)) mb"
        uvIndexLbl.text = "\(Int(currentWeather.uvIndex))"
        uvIndexHighLbl.text = "Today's high UV Index is \(Int(currentWeather.uvIndexHigh)) at \(currentWeather.uvIndexHighTime)"
        sunriseLbl.text = "\(currentWeather.sunrise)"
        sunsetLbl.text = "\(currentWeather.sunset)"
    }
    
    
    // MARK: Save current location to Favourites functions
    
    func saveFavouritesData() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(Singleton.sharedInstance.favouritesArray, toFile: Favourites.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Favourites successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save Favourites...", log: OSLog.default, type: .error)
        }
    }
    
    func setFavouritesIcon() {
        let array = Singleton.sharedInstance.favouritesArray
        for obj in array {
            if obj.latitude == segueData.latitude && obj.longitude == segueData.longitude && obj.cityName == segueData.cityName {
                favourited = true
                favouritesBtn.setImage(UIImage(named: "star-filled"), for: .normal)
            }
        }
    }
    
    
    // MARK: Override segue transition styles
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let controller = segue.destination as? TempChartVC {
            controller.preferredContentSize = CGSize(width: 325, height: 200)
            if let x = sender as? SegueData {
                controller.segueData = x
            }
            let popoverController = controller.popoverPresentationController
            if popoverController != nil {
                popoverController?.backgroundColor = UIColor(red: 35/255, green: 46/255, blue: 94/255, alpha: 1)
                popoverController!.delegate = self
                popoverController!.sourceView = tempChartView
                popoverController!.sourceRect = tempChartView.bounds
            }
        } else if let controller = segue.destination as? RainChartVC {
            controller.preferredContentSize = CGSize(width: 325, height: 200)
            if let x = sender as? SegueData {
                controller.segueData = x
            }
            let popoverController = controller.popoverPresentationController
            if popoverController != nil {
                popoverController?.backgroundColor = UIColor(red: 35/255, green: 46/255, blue: 94/255, alpha: 1)
                popoverController!.delegate = self
                popoverController!.sourceView = rainChartView
                popoverController!.sourceRect = rainChartView.bounds
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
    
    // MARK: IBActions
    
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "unwindToWeatherMapVC", sender: self)
    }

    @IBAction func favouritesButtonPressed(_ sender: Any) {
        let favs = Favourites(cityName: segueData.cityName, latitude: segueData.latitude, longitude: segueData.longitude)
        
        if favourited == true {
            
            for obj in Singleton.sharedInstance.favouritesArray {
                if obj.latitude == segueData.latitude && obj.longitude == segueData.longitude && obj.cityName == segueData.cityName {
                    if let index = Singleton.sharedInstance.favouritesArray.index(of: obj) {
                        
                        Singleton.sharedInstance.favouritesArray.remove(at: index)
                        
                    }
                }
            }
            deleteAnnotationsDelegate.removeAnnotationsForFavourites()
            saveFavouritesData()
            favourited = false
            favouritesBtn.setImage(UIImage(named: "Star"), for: .normal)
        } else if favourited == false {
            Singleton.sharedInstance.favouritesArray.append(favs)
            Singleton.sharedInstance.favouritesArray.sort() { ($0.cityName) < ($1.cityName) }
            deleteAnnotationsDelegate.removeAnnotationsForFavourites()
            saveFavouritesData()
            favourited = true
            favouritesBtn.setImage(UIImage(named: "star-filled"), for: .normal)
        }
    }

    @IBAction func darkSkyLogoPressed(_ sender: UITapGestureRecognizer) {
        let url = URL(string: "https://darksky.net/poweredby/")
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url!)
        }
    }
    
    @IBAction func tempChartPressed(_ sender: UITapGestureRecognizer) {
        let send = SegueData(cityName: segueData.cityName, latitude: segueData.latitude, longitude: segueData.longitude)
        performSegue(withIdentifier: "showTempChart", sender: send)
    }
    
    @IBAction func rainChartPressed(_ sender: UITapGestureRecognizer) {
        let send = SegueData(cityName: segueData.cityName, latitude: segueData.latitude, longitude: segueData.longitude)
        performSegue(withIdentifier: "showRainfall", sender: send)
    }
}
