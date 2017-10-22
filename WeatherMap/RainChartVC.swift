//
//  RainChartVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-08-20.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import Alamofire
import Charts

class RainChartVC: UIViewController {
    
    
    // MARK: IBOutlets
    
    @IBOutlet weak var noDataWarningView: RoundedCornerView!
    @IBOutlet weak var rainChart: BarChartView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var ellipsesLbl: UILabel!
    
    
    // MARK: Variables and Constants
    
    var rainAccums = [TemperatureChart]()
    var station: String!
    var stations = [ClosestStation]()
    var units: String!
    var ellipsesTimer: Timer?
    private var _segueData: SegueData!
    var segueData: SegueData {
        get {
            return _segueData
        } set {
            _segueData = newValue
        }
    }
    
    
    // MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rainChart.isHidden = true
        noDataWarningView.isHidden = true
        
        ellipsesTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(updateLabelEllipses(timer:)), userInfo: nil, repeats: true)
        
        findClosestNOAAStation {}
    }
    
    
    // MARK: Loading Timer
    
    func updateLabelEllipses(timer: Timer) {
        let messageText: String = self.ellipsesLbl.text!
        let dotCount: Int = (ellipsesLbl.text?.characters.count)! - messageText.replacingOccurrences(of: ".", with: "").characters.count + 1
        self.ellipsesLbl.text = " "
        var addOn: String = "."
        if dotCount < 4 {
            addOn = "".padding(toLength: dotCount, withPad: ".", startingAt: 0)
        }
        self.ellipsesLbl.text = self.ellipsesLbl.text!.appending(addOn)
    }
    
    
    // MARK: Download API data
    
    func findClosestNOAAStation(completed: DownloadComplete) {
        let lowLLat = segueData.latitude - 1
        let lowLLon = segueData.longitude - 1
        let upRLat = segueData.latitude + 1
        let upRLon = segueData.longitude + 1
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        let year =  components.year! - 1
        
        let NOAAStationsUrl = URL(string: "https://www.ncdc.noaa.gov/cdo-web/api/v2/stations?extent=\(lowLLat),\(lowLLon),\(upRLat),\(upRLon)&startdate=\(year)-01-01&enddate=\(year)-12-01&limit=300&datasetid=GSOM&datatypeid=TAVG")
        print(NOAAStationsUrl!)
        let headers: HTTPHeaders = ["token": "UOWhOfDlwQTucPNBsmcRMskuxRjXlGJi"]
        
        Alamofire.request(NOAAStationsUrl!, headers: headers).responseJSON { response in
            let result = response.result
            if let dict = result.value as? JSONDictionary {
                if let results = dict["results"] as? [JSONDictionary] {
                    for obj in results {
                        let dataCoverage = obj["datacoverage"] as? Double ?? 0.0
                        if dataCoverage == 1 {
                            let stationName = obj["name"] as? String ?? "n/a"
                            let stationId = obj["id"] as? String ?? "n/a"
                            let stationLat = obj["latitude"] as? Double ?? 0.0
                            let stationLong = obj["longitude"] as? Double ?? 0.0
                            let deltaLat = stationLat - self.segueData.latitude
                            let deltaLong = stationLong - self.segueData.longitude
                            let deltaDist = sqrt((deltaLat * deltaLat)+(deltaLong * deltaLong))
                            let stationData = ClosestStation(stationId: stationId, stationDist: deltaDist, stationName: stationName)
                            self.stations.append(stationData)
                        }
                    }
                    if self.stations.count == 0 {
                        print("No perfect stations, trying above 0.9")
                        for obj in results {
                            let dataCoverage = obj["datacoverage"] as? Double ?? 0.0
                            if dataCoverage >= 0.9 {
                                let stationName = obj["name"] as? String ?? "n/a"
                                let stationId = obj["id"] as? String ?? "n/a"
                                let stationLat = obj["latitude"] as? Double ?? 0.0
                                let stationLong = obj["longitude"] as? Double ?? 0.0
                                let deltaLat = stationLat - self.segueData.latitude
                                let deltaLong = stationLong - self.segueData.longitude
                                let deltaDist = sqrt((deltaLat * deltaLat)+(deltaLong * deltaLong))
                                let stationData = ClosestStation(stationId: stationId, stationDist: deltaDist, stationName: stationName)
                                self.stations.append(stationData)
                            }
                        }
                    }
                    if self.stations.count == 0 {
                        print("No good stations available. Continuing with closest station")
                        for obj in results {
                            let stationName = obj["name"] as? String ?? "n/a"
                            let stationId = obj["id"] as? String ?? "n/a"
                            let stationLat = obj["latitude"] as? Double ?? 0.0
                            let stationLong = obj["longitude"] as? Double ?? 0.0
                            let deltaLat = stationLat - self.segueData.latitude
                            let deltaLong = stationLong - self.segueData.longitude
                            let deltaDist = sqrt((deltaLat * deltaLat)+(deltaLong * deltaLong))
                            let stationData = ClosestStation(stationId: stationId, stationDist: deltaDist, stationName: stationName)
                            self.stations.append(stationData)
                        }
                    }
                    self.stations.sort() { ($0.stationDist) < ($1.stationDist) }
                    print("\(self.stations[0].stationDist) \(self.stations[0].stationId) \(self.stations[0].stationName)")
                    self.station = self.stations[0].stationId
                }
            }
            if self.station != nil {
                if Singleton.sharedInstance.unitSelectedOWM == "metric" {
                    self.units = "metric"
                } else {
                    self.units = "standard"
                }
                
                let NOAATempUrl = URL(string: "https://www.ncdc.noaa.gov/cdo-web/api/v2/data?datasetid=GSOM&startdate=\(year)-01-01&enddate=\(year)-12-01&datatypeid=PRCP&stationid=\(self.station!)&limit=12&units=\(self.units!)")
                print(NOAATempUrl!)
                
                
                
                Alamofire.request(NOAATempUrl!, headers: headers).responseJSON { response in
                    let result = response.result
                    if let dict = result.value as? JSONDictionary {
                        if dict.count != 0 {
                            if let results = dict["results"] as? [JSONDictionary] {
                                if results.count >= 1 {
                                    for obj in results {
                                        let tempChartData = TemperatureChart(tempDict: obj)
                                        self.rainAccums.append(tempChartData)
                                    }
                                    let janEntry = TemperatureChart(date: "\(year)-01-01T00:00:00", temp: 0.0001)
                                    let febEntry = TemperatureChart(date: "\(year)-02-01T00:00:00", temp: 0.0001)
                                    let marEntry = TemperatureChart(date: "\(year)-03-01T00:00:00", temp: 0.0001)
                                    let aprEntry = TemperatureChart(date: "\(year)-04-01T00:00:00", temp: 0.0001)
                                    let mayEntry = TemperatureChart(date: "\(year)-05-01T00:00:00", temp: 0.0001)
                                    let junEntry = TemperatureChart(date: "\(year)-06-01T00:00:00", temp: 0.0001)
                                    let julEntry = TemperatureChart(date: "\(year)-07-01T00:00:00", temp: 0.0001)
                                    let augEntry = TemperatureChart(date: "\(year)-08-01T00:00:00", temp: 0.0001)
                                    let sepEntry = TemperatureChart(date: "\(year)-09-01T00:00:00", temp: 0.0001)
                                    let octEntry = TemperatureChart(date: "\(year)-10-01T00:00:00", temp: 0.0001)
                                    let novEntry = TemperatureChart(date: "\(year)-11-01T00:00:00", temp: 0.0001)
                                    let decEntry = TemperatureChart(date: "\(year)-12-01T00:00:00", temp: 0.0001)
                                    let containsEntry = self.rainAccums.contains{ $0.date == janEntry.date }
                                    if containsEntry {
                                    } else {
                                        self.rainAccums.append(janEntry)
                                    }
                                    let containsEntry2 = self.rainAccums.contains{ $0.date == febEntry.date }
                                    if containsEntry2 {
                                    } else {
                                        self.rainAccums.append(febEntry)
                                    }
                                    let containsEntry3 = self.rainAccums.contains{ $0.date == marEntry.date }
                                    if containsEntry3 {
                                    } else {
                                        self.rainAccums.append(marEntry)
                                    }
                                    let containsEntry4 = self.rainAccums.contains{ $0.date == aprEntry.date }
                                    if containsEntry4 {
                                    } else {
                                        self.rainAccums.append(aprEntry)
                                    }
                                    let containsEntry5 = self.rainAccums.contains{ $0.date == mayEntry.date }
                                    if containsEntry5 {
                                    } else {
                                        self.rainAccums.append(mayEntry)
                                    }
                                    let containsEntry6 = self.rainAccums.contains{ $0.date == junEntry.date }
                                    if containsEntry6 {
                                    } else {
                                        self.rainAccums.append(junEntry)
                                    }
                                    let containsEntry7 = self.rainAccums.contains{ $0.date == julEntry.date}
                                    if containsEntry7 {
                                    } else {
                                        self.rainAccums.append(julEntry)
                                    }
                                    let containsEntry8 = self.rainAccums.contains{ $0.date == augEntry.date }
                                    if containsEntry8 {
                                    } else {
                                        self.rainAccums.append(augEntry)
                                    }
                                    let containsEntry9 = self.rainAccums.contains{ $0.date == sepEntry.date }
                                    if containsEntry9 {
                                    } else {
                                        self.rainAccums.append(sepEntry)
                                    }
                                    let containsEntry10 = self.rainAccums.contains{ $0.date == octEntry.date }
                                    if containsEntry10 {
                                    } else {
                                        self.rainAccums.append(octEntry)
                                    }
                                    let containsEntry11 = self.rainAccums.contains{ $0.date == novEntry.date }
                                    if containsEntry11 {
                                    } else {
                                        self.rainAccums.append(novEntry)
                                    }
                                    let containsEntry12 = self.rainAccums.contains{ $0.date == decEntry.date }
                                    if containsEntry12 {
                                    } else {
                                        self.rainAccums.append(decEntry)
                                    }
                                    self.rainAccums.sort() { ($0.date) < ($1.date) }

                                    self.updateChart()
                                    self.loadingView.isHidden = true
                                    self.rainChart.isHidden = false
                                } else {
                                    self.loadingView.isHidden = true
                                    self.noDataWarningView.isHidden = false
                                }
                            }
                        } else {
                            self.loadingView.isHidden = true
                            self.noDataWarningView.isHidden = false
                        }
                    }
                }
            } else {
                self.loadingView.isHidden = true
                self.noDataWarningView.isHidden = false
            }
        }
        completed()
    }
    
    
    // MARK: Configure Chart
    
    func updateChart() {
        let format: BarChartFormatter = BarChartFormatter()
        let xaxis: XAxis = XAxis()
        
        var barChartEntry = [BarChartDataEntry]()
        for i in 0..<rainAccums.count {
            let value = BarChartDataEntry(x: Double(i), y: rainAccums[i].temp)
            barChartEntry.append(value)
        }
        xaxis.valueFormatter = format

        let bar = BarChartDataSet(values: barChartEntry, label: "Rainfall")
        
        bar.colors = [NSUIColor(red: 78/255, green: 133/255, blue: 255/255, alpha: 1)]
        bar.drawValuesEnabled = true
        bar.valueColors = [NSUIColor.white]
        bar.valueFont = UIFont(name: "AvenirNext-Regular", size: 9)!
        if Singleton.sharedInstance.unitSelectedOWM == "metric" {
            bar.label?.append(" (mm)")
        } else {
            bar.label?.append(" (in)")
        }
        
        let data = BarChartData()
        data.barWidth = 0.5
        data.addDataSet(bar)
        rainChart.data = data
        
        let formatter = NumberFormatter()
        
        if Singleton.sharedInstance.unitSelectedOWM == "metric" {
            formatter.numberStyle = .none
        } else {
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
            formatter.numberStyle = .decimal
        }

        data.setValueFormatter(ChartValueFormatter(formatter: formatter))
        
        
        rainChart.chartDescription?.text = ""
        rainChart.backgroundColor = UIColor(red: 35/255, green: 46/255, blue: 94/255, alpha: 1)
        rainChart.drawGridBackgroundEnabled = false
        rainChart.pinchZoomEnabled = false
        rainChart.doubleTapToZoomEnabled = false
        rainChart.animate(yAxisDuration: 1)
        rainChart.legend.textColor = .white
        rainChart.legend.font = UIFont(name: "AvenirNext-Medium", size: 12)!
        rainChart.legend.verticalAlignment = .top
        rainChart.legend.horizontalAlignment = .left
        rainChart.legend.formSize = 8
        rainChart.legend.form = .circle
        
        rainChart.xAxis.drawAxisLineEnabled = false
        rainChart.xAxis.drawGridLinesEnabled = false
        rainChart.xAxis.valueFormatter = xaxis.valueFormatter
        rainChart.xAxis.labelFont = UIFont(name: "AvenirNext-Medium", size: 11)!
        rainChart.xAxis.labelTextColor = .white
        rainChart.xAxis.labelPosition = .bottom
        rainChart.xAxis.labelCount = 12
        
        rainChart.leftAxis.drawAxisLineEnabled = false
        rainChart.leftAxis.drawGridLinesEnabled = false
        rainChart.leftAxis.labelPosition = .outsideChart
        rainChart.leftAxis.labelTextColor = .white
        rainChart.leftAxis.labelFont = UIFont(name: "AvenirNext-Medium", size: 12)!
        rainChart.leftAxis.labelCount = 3
        
        rainChart.rightAxis.drawGridLinesEnabled = false
        rainChart.rightAxis.drawAxisLineEnabled = false
        rainChart.rightAxis.drawLabelsEnabled = false
        
    }
    
    
    // MARK: IBActions
    
    @IBAction func xPressed(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
