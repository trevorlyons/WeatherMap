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

    @IBOutlet weak var noDataWarningView: RoundedCornerView!
    @IBOutlet weak var loadingLbl: UILabel!
    @IBOutlet weak var rainChart: BarChartView!
    
    var rainAccums = [TemperatureChart]()
    var station: String!
    var stations = [ClosestStation]()
    var units: String!
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

        rainChart.isHidden = true
        noDataWarningView.isHidden = true
        
        findClosestNOAAStation {}
    }
    
    
    // Download API data
    
    func findClosestNOAAStation(completed: DownloadComplete) {
        let lowLLat = segueData.latitude - 1
        let lowLLon = segueData.longitude - 1
        let upRLat = segueData.latitude + 1
        let upRLon = segueData.longitude + 1
        
        let NOAAStationsUrl = URL(string: "https://www.ncdc.noaa.gov/cdo-web/api/v2/stations?extent=\(lowLLat),\(lowLLon),\(upRLat),\(upRLon)&startdate=2016-01-01&enddate=2016-12-01&limit=200&datasetid=GSOM&datatypeid=PRCP")
        print(NOAAStationsUrl!)
        let headers: HTTPHeaders = ["token": "UOWhOfDlwQTucPNBsmcRMskuxRjXlGJi"]
        
        Alamofire.request(NOAAStationsUrl!, headers: headers).responseJSON { response in
            let result = response.result
            if let dict = result.value as? JSONDictionary {
                if let results = dict["results"] as? [JSONDictionary] {
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
                
                let NOAATempUrl = URL(string: "https://www.ncdc.noaa.gov/cdo-web/api/v2/data?datasetid=GSOM&startdate=2016-01-01&enddate=2016-12-01&datatypeid=PRCP&stationid=\(self.station!)&limit=12&units=\(self.units!)")
                print(NOAATempUrl!)
                
                
                
                Alamofire.request(NOAATempUrl!, headers: headers).responseJSON { response in
                    let result = response.result
                    if let dict = result.value as? JSONDictionary {
                        if dict.count != 0 {
                            if let results = dict["results"] as? [JSONDictionary] {
                                if results.count > 1 {
                                    for obj in results {
//                                        let date = obj["date"] as? String ?? "n/a"
//                                        if (date.range(of: "-01-01") != nil) {
//                                            print(date)
//                                            print(obj)
//                                        }
                                        let tempChartData = TemperatureChart(tempDict: obj)
                                        self.rainAccums.append(tempChartData)
                                    }

                                    let janEntry = TemperatureChart(date: "2016-01-01T00:00:00", temp: 0.001)
                                    let febEntry = TemperatureChart(date: "2016-02-01T00:00:00", temp: 0)
                                    let marEntry = TemperatureChart(date: "2016-03-01T00:00:00", temp: 0)
                                    let aprEntry = TemperatureChart(date: "2016-04-01T00:00:00", temp: 0)
                                    let mayEntry = TemperatureChart(date: "2016-05-01T00:00:00", temp: 0)
                                    let junEntry = TemperatureChart(date: "2016-06-01T00:00:00", temp: 0)
                                    let julEntry = TemperatureChart(date: "2016-07-01T00:00:00", temp: 0)
                                    let augEntry = TemperatureChart(date: "2016-08-01T00:00:00", temp: 0)
                                    let sepEntry = TemperatureChart(date: "2016-09-01T00:00:00", temp: 0)
                                    let octEntry = TemperatureChart(date: "2016-10-01T00:00:00", temp: 0)
                                    let novEntry = TemperatureChart(date: "2016-11-01T00:00:00", temp: 0)
                                    let decEntry = TemperatureChart(date: "2016-12-01T00:00:00", temp: 0)
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
                                    self.loadingLbl.isHidden = true
                                    self.rainChart.isHidden = false
                                } else {
                                    self.loadingLbl.isHidden = true
                                    self.noDataWarningView.isHidden = false
                                }
                            }
                        } else {
                            self.loadingLbl.isHidden = true
                            self.noDataWarningView.isHidden = false
                        }
                    }
                }
            } else {
                self.loadingLbl.isHidden = true
                self.noDataWarningView.isHidden = false
            }
        }
        completed()
    }
    
    
    // Configure Chart
    
    func updateChart() {
        let format: BarChartFormatter = BarChartFormatter()
        let xaxis: XAxis = XAxis()
        
        var barChartEntry = [BarChartDataEntry]()
        for i in 0..<rainAccums.count {
            let value = BarChartDataEntry(x: Double(i), y: Double(round(10*rainAccums[i].temp)/10))
            print(rainAccums[i].temp)
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
        formatter.zeroSymbol = "n/a"
        
        if Singleton.sharedInstance.unitSelectedOWM == "metric" {
            formatter.numberStyle = .none
        } else {
            formatter.numberStyle = .decimal
        }
        
        data.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        
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

    @IBAction func xPressed(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
