//
//  TempChartVC.swift
//  WeatherMap
//
//  Created by Trevor Lyons on 2017-08-20.
//  Copyright © 2017 Trevor Lyons. All rights reserved.
//

import UIKit
import Alamofire
import Charts

class TempChartVC: UIViewController {
    
    @IBOutlet weak var tempLineChart: LineChartView!
    @IBOutlet weak var noDataAvailableView: RoundedCornerView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var ellipsesLbl: UILabel!
    
    var tempAvgs = [TemperatureChart]()
    var tempMaxs = [TemperatureChart]()
    var tempMins = [TemperatureChart]()
    var jans = [TemperatureChart]()
    var febs = [TemperatureChart]()
    var mars = [TemperatureChart]()
    var aprs = [TemperatureChart]()
    var mays = [TemperatureChart]()
    var juns = [TemperatureChart]()
    var juls = [TemperatureChart]()
    var augs = [TemperatureChart]()
    var seps = [TemperatureChart]()
    var octs = [TemperatureChart]()
    var novs = [TemperatureChart]()
    var decs = [TemperatureChart]()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempLineChart.isHidden = true
        noDataAvailableView.isHidden = true
        

        ellipsesTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(updateLabelEllipses(timer:)), userInfo: nil, repeats: true)
        
        findClosestNOAAStation {}
    }
    
    
    // Loading Timer
    
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
    
    
    // Download API Data
    
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
                        print("No perfect stations, trying below 0.9")
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
                self.downloadWeatherData {}

            } else {
                self.loadingView.isHidden = true
                self.noDataAvailableView.isHidden = false
            }
        }
        completed()
    }
    
    func downloadWeatherData(completed: DownloadComplete) {
        if Singleton.sharedInstance.unitSelectedOWM == "metric" {
            self.units = "metric"
        } else {
            self.units = "standard"
        }
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        let year =  components.year! - 1
        
        let NOAATempUrl = URL(string: "https://www.ncdc.noaa.gov/cdo-web/api/v2/data?datasetid=GSOM&startdate=\(year)-01-01&enddate=\(year)-12-01&datatypeid=TAVG,TMAX,TMIN&stationid=\(self.station!)&limit=1000&units=\(self.units!)")
        print(NOAATempUrl!)
        let headers: HTTPHeaders = ["token": "UOWhOfDlwQTucPNBsmcRMskuxRjXlGJi"]
        
        Alamofire.request(NOAATempUrl!, headers: headers).responseJSON { response in
            let result = response.result
            if let dict = result.value as? JSONDictionary {
                if dict.count != 0 {
                    if let results = dict["results"] as? [JSONDictionary] {
                        if results.count > 10 {
                            for obj in results {
                                let dataType = obj["datatype"] as? String ?? "n/a"
                                if dataType == "TAVG" {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.tempAvgs.append(tempChartData)
                                } else if dataType == "TMAX" {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.tempMaxs.append(tempChartData)
                                } else if dataType == "TMIN" {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.tempMins.append(tempChartData)
                                }
                            }
                            let janEntry = TemperatureChart(date: "\(year)-01-01T00:00:00", temp: 30)
                            if self.tempAvgs.count < 11 {
                                self.tempAvgs = []
                                self.tempAvgs.append(janEntry)
                            }
                            if self.tempMaxs.count < 11 {
                                self.tempMaxs = []
                                self.tempMaxs.append(janEntry)
                            }
                            if self.tempMins.count < 11 {
                                self.tempMins = []
                                self.tempMins.append(janEntry)
                            }
                            print("AVG: \(self.tempAvgs.count) MAX: \(self.tempMaxs.count) MIN: \(self.tempMins.count)")
                            
                            if self.tempAvgs.count <= 1 && self.tempMins.count <= 1 && self.tempMaxs.count <= 1 {
                                self.downloadWeatherDataDaily {}
                            } else {
                                self.updateChart()
                                self.loadingView.isHidden = true
                                self.tempLineChart.isHidden = false
                            }
                        } else {
                            self.downloadWeatherDataDaily {}
                        }
                    }
                } else {
                    self.downloadWeatherDataDaily {}
                }
            }
        }
    }
    
    func downloadWeatherDataDaily(completed: DownloadComplete) {
        
        print("No monthly weather data available. Trying daily")
        
        if Singleton.sharedInstance.unitSelectedOWM == "metric" {
            self.units = "metric"
        } else {
            self.units = "standard"
        }
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        let year =  components.year! - 1
        
        let NOAATempUrl = URL(string: "https://www.ncdc.noaa.gov/cdo-web/api/v2/data?datasetid=GHCND&startdate=\(year)-01-01&enddate=\(year)-12-31&datatypeid=TAVG&stationid=\(self.station!)&limit=1000&units=\(self.units!)")
        print(NOAATempUrl!)
        let headers: HTTPHeaders = ["token": "UOWhOfDlwQTucPNBsmcRMskuxRjXlGJi"]
        
        Alamofire.request(NOAATempUrl!, headers: headers).responseJSON { response in
            let result = response.result
            if let dict = result.value as? JSONDictionary {
                if dict.count != 0 {
                    if let results = dict["results"] as? [JSONDictionary] {
                        if results.count >= 100 {
                            for obj in results {
                                let date = obj["date"] as? String ?? "n/a"
                                if (date.range(of: "-01-") != nil) {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.jans.append(tempChartData)
                                } else if (date.range(of: "-02-") != nil) {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.febs.append(tempChartData)
                                } else if (date.range(of: "-03-") != nil) {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.mars.append(tempChartData)
                                } else if (date.range(of: "-04-") != nil) {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.aprs.append(tempChartData)
                                } else if (date.range(of: "-05-") != nil) {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.mays.append(tempChartData)
                                } else if (date.range(of: "-06-") != nil) {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.juns.append(tempChartData)
                                } else if (date.range(of: "-07-") != nil) {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.juls.append(tempChartData)
                                } else if (date.range(of: "-08-") != nil) {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.augs.append(tempChartData)
                                } else if (date.range(of: "-09-") != nil) {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.seps.append(tempChartData)
                                } else if (date.range(of: "-10-") != nil) {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.octs.append(tempChartData)
                                } else if (date.range(of: "-11-") != nil) {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.novs.append(tempChartData)
                                } else if (date.range(of: "-12-") != nil) {
                                    let tempChartData = TemperatureChart(tempDict: obj)
                                    self.decs.append(tempChartData)
                                }
                            }
                            print("JAN: \(self.jans.count) FEB: \(self.febs.count) MAR: \(self.mars.count) APR: \(self.aprs.count) MAY: \(self.mays.count) JUN: \(self.juns.count) JULY: \(self.juls.count) AUG: \(self.augs.count) SEP: \(self.seps.count) OCT: \(self.octs.count) NOV: \(self.novs.count) DEC: \(self.decs.count) TOTAL: \(self.jans.count + self.febs.count + self.mars.count + self.aprs.count + self.mays.count + self.juns.count + self.juls.count + self.augs.count + self.seps.count + self.octs.count + self.novs.count + self.decs.count)")
                            
                            let janSum = self.jans.flatMap({ Double($0.temp) }).reduce(0, +)
                            let febSum = self.febs.flatMap({ Double($0.temp) }).reduce(0, +)
                            let marSum = self.mars.flatMap({ Double($0.temp) }).reduce(0, +)
                            let aprSum = self.aprs.flatMap({ Double($0.temp) }).reduce(0, +)
                            let maySum = self.mays.flatMap({ Double($0.temp) }).reduce(0, +)
                            let junSum = self.juns.flatMap({ Double($0.temp) }).reduce(0, +)
                            let julSum = self.juls.flatMap({ Double($0.temp) }).reduce(0, +)
                            let augSum = self.augs.flatMap({ Double($0.temp) }).reduce(0, +)
                            let sepSum = self.seps.flatMap({ Double($0.temp) }).reduce(0, +)
                            let octSum = self.octs.flatMap({ Double($0.temp) }).reduce(0, +)
                            let novSum = self.novs.flatMap({ Double($0.temp) }).reduce(0, +)
                            let decSum = self.decs.flatMap({ Double($0.temp) }).reduce(0, +)

                            let janAvg = janSum / Double(self.jans.count)
                            let febAvg = febSum / Double(self.febs.count)
                            let marAvg = marSum / Double(self.mars.count)
                            let aprAvg = aprSum / Double(self.aprs.count)
                            let mayAvg = maySum / Double(self.mays.count)
                            let junAvg = junSum / Double(self.juns.count)
                            let julAvg = julSum / Double(self.juls.count)
                            let augAvg = augSum / Double(self.augs.count)
                            let sepAvg = sepSum / Double(self.seps.count)
                            let octAvg = octSum / Double(self.octs.count)
                            let novAvg = novSum / Double(self.novs.count)
                            let decAvg = decSum / Double(self.decs.count)
                            
                            self.tempAvgs = []
                            let tempChartData = TemperatureChart(date: "\(year)-01-01T00:00:00", temp: janAvg)
                            self.tempAvgs.append(tempChartData)
                            let tempChartData2 = TemperatureChart(date: "\(year)-02-01T00:00:00", temp: febAvg)
                            self.tempAvgs.append(tempChartData2)
                            let tempChartData3 = TemperatureChart(date: "\(year)-03-01T00:00:00", temp: marAvg)
                            self.tempAvgs.append(tempChartData3)
                            let tempChartData4 = TemperatureChart(date: "\(year)-04-01T00:00:00", temp: aprAvg)
                            self.tempAvgs.append(tempChartData4)
                            let tempChartData5 = TemperatureChart(date: "\(year)-05-01T00:00:00", temp: mayAvg)
                            self.tempAvgs.append(tempChartData5)
                            let tempChartData6 = TemperatureChart(date: "\(year)-06-01T00:00:00", temp: junAvg)
                            self.tempAvgs.append(tempChartData6)
                            let tempChartData7 = TemperatureChart(date: "\(year)-07-01T00:00:00", temp: julAvg)
                            self.tempAvgs.append(tempChartData7)
                            let tempChartData8 = TemperatureChart(date: "\(year)-08-01T00:00:00", temp: augAvg)
                            self.tempAvgs.append(tempChartData8)
                            let tempChartData9 = TemperatureChart(date: "\(year)-09-01T00:00:00", temp: sepAvg)
                            self.tempAvgs.append(tempChartData9)
                            let tempChartData10 = TemperatureChart(date: "\(year)-10-01T00:00:00", temp: octAvg)
                            self.tempAvgs.append(tempChartData10)
                            let tempChartData11 = TemperatureChart(date: "\(year)-11-01T00:00:00", temp: novAvg)
                            self.tempAvgs.append(tempChartData11)
                            let tempChartData12 = TemperatureChart(date: "\(year)-12-01T00:00:00", temp: decAvg)
                            self.tempAvgs.append(tempChartData12)
                            
                            let janEntry = TemperatureChart(date: "\(year)-01-01T00:00:00", temp: Double.nan)
                            if self.tempAvgs.count < 11 {
                                self.tempAvgs = []
                                self.tempAvgs.append(janEntry)
                            }
                            if self.tempMaxs.count < 11 {
                                self.tempMaxs = []
                                self.tempMaxs.append(janEntry)
                            }
                            if self.tempMins.count < 11 {
                                self.tempMins = []
                                self.tempMins.append(janEntry)
                            }
                            print("AVG: \(self.tempAvgs.count) MAX: \(self.tempMaxs.count) MIN: \(self.tempMins.count)")
                            if self.tempAvgs.count <= 1 && self.tempMins.count <= 1 && self.tempMaxs.count <= 1 {
                                self.loadingView.isHidden = true
                                self.noDataAvailableView.isHidden = false
                            } else {
                                self.updateChart()
                                self.loadingView.isHidden = true
                                self.tempLineChart.isHidden = false
                            }
                        } else {
                            self.loadingView.isHidden = true
                            self.noDataAvailableView.isHidden = false
                        }
                    }
                } else {
                    self.loadingView.isHidden = true
                    self.noDataAvailableView.isHidden = false
                }
            }
        }
    }
    
    
    // Configure Chart
    
    func updateChart() {
        let format: LineChartFormatter = LineChartFormatter()
        let xaxis: XAxis = XAxis()
        
        var lineChartEntry = [ChartDataEntry]()
        var lineChartEntry2 = [ChartDataEntry]()
        var lineChartEntry3 = [ChartDataEntry]()
        for i in 0..<tempAvgs.count {
            let value = ChartDataEntry(x: Double(i), y: tempAvgs[i].temp)
            lineChartEntry.append(value)
        }
        for i in 0..<tempMaxs.count {
            let value2 = ChartDataEntry(x: Double(i), y: tempMaxs[i].temp)
            lineChartEntry2.append(value2)
        }
        for i in 0..<tempMins.count {
            let value3 = ChartDataEntry(x: Double(i), y: tempMins[i].temp)
            lineChartEntry3.append(value3)
        }
        xaxis.valueFormatter = format
        
        let line = LineChartDataSet(values: lineChartEntry, label: "")
        let line2 = LineChartDataSet(values: lineChartEntry2, label: "")
        let line3 = LineChartDataSet(values: lineChartEntry3, label: "Avg, Max, Min Temp")

        line.colors = [NSUIColor(red: 255/255, green: 241/255, blue: 53/255, alpha: 1)]
        line.lineWidth = 2.0
        line.drawCircleHoleEnabled = false
        line.drawCirclesEnabled = false
        line.drawValuesEnabled = false
        line2.colors = [NSUIColor(red: 255/255, green: 49/255, blue: 49/255, alpha: 1)]
        line2.lineWidth = 2.0
        line2.drawCircleHoleEnabled = false
        line2.drawCirclesEnabled = false
        line2.drawValuesEnabled = false
        line3.colors = [NSUIColor(red: 78/255, green: 133/255, blue: 255/255, alpha: 1)]
        line3.lineWidth = 2.0
        line3.drawCircleHoleEnabled = false
        line3.drawCirclesEnabled = false
        line3.drawValuesEnabled = false
        if Singleton.sharedInstance.unitSelectedOWM == "metric" {
            line3.label?.append(" (C)")
        } else {
            line3.label?.append(" (F)")
        }
        
        let data = LineChartData()
        data.addDataSet(line)
        data.addDataSet(line2)
        data.addDataSet(line3)
        
        tempLineChart.data = data
        tempLineChart.chartDescription?.enabled = false
        tempLineChart.backgroundColor = UIColor(red: 35/255, green: 46/255, blue: 94/255, alpha: 1)
        tempLineChart.drawGridBackgroundEnabled = false
        tempLineChart.pinchZoomEnabled = false
        tempLineChart.doubleTapToZoomEnabled = false
        tempLineChart.highlightPerTapEnabled = false
        tempLineChart.highlightPerDragEnabled = false
        tempLineChart.legend.textColor = .white
        tempLineChart.legend.font = UIFont(name: "AvenirNext-Regular", size: 11)!
        tempLineChart.legend.verticalAlignment = .top
        tempLineChart.legend.horizontalAlignment = .left
        tempLineChart.legend.formSize = 8
        tempLineChart.legend.form = .circle
        tempLineChart.legend.xEntrySpace = 0
        
        tempLineChart.xAxis.drawAxisLineEnabled = false
        tempLineChart.xAxis.drawGridLinesEnabled = false
        tempLineChart.xAxis.valueFormatter = xaxis.valueFormatter
        tempLineChart.xAxis.labelFont = UIFont(name: "AvenirNext-Medium", size: 11)!
        tempLineChart.xAxis.labelTextColor = .white
        tempLineChart.xAxis.labelPosition = .bottom
        tempLineChart.xAxis.labelCount = 12
        tempLineChart.xAxis.granularityEnabled = true
        tempLineChart.xAxis.granularity = 1
        
        tempLineChart.leftAxis.drawAxisLineEnabled = false
        tempLineChart.leftAxis.drawGridLinesEnabled = false
        tempLineChart.leftAxis.labelPosition = .outsideChart
        tempLineChart.leftAxis.labelTextColor = .white
        tempLineChart.leftAxis.labelFont = UIFont(name: "AvenirNext-Medium", size: 12)!
        tempLineChart.leftAxis.labelCount = 3
        
        tempLineChart.rightAxis.drawGridLinesEnabled = false
        tempLineChart.rightAxis.drawAxisLineEnabled = false
        tempLineChart.rightAxis.drawLabelsEnabled = false
    }
    
    @IBAction func xPressed(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

