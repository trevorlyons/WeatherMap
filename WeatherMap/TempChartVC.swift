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
    @IBOutlet weak var monthsXAxis: UIStackView!
    @IBOutlet weak var noDataAvailableView: RoundedCornerView!
    @IBOutlet weak var loadingLbl: UILabel!
    
    var tempAvg: TemperatureChart!
    var tempAvgs = [TemperatureChart]()
    var tempMaxs = [TemperatureChart]()
    var tempMins = [TemperatureChart]()
    var station: String!
    var stations = [ClosestStation]()
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
        monthsXAxis.isHidden = true
        noDataAvailableView.isHidden = true
        
        findClosestNOAAStation {}
    }
    
    
    // Download API Data
    
    func findClosestNOAAStation(completed: DownloadComplete) {
        let lowLLat = segueData.latitude - 1
        let lowLLon = segueData.longitude - 1
        let upRLat = segueData.latitude + 1
        let upRLon = segueData.longitude + 1
        
        let NOAAStationsUrl = URL(string: "https://www.ncdc.noaa.gov/cdo-web/api/v2/stations?extent=\(lowLLat),\(lowLLon),\(upRLat),\(upRLon)&startdate=2016-01-01&enddate=2016-12-01&limit=200&datasetid=GSOM&datatypeid=TAVG")
        print(NOAAStationsUrl!)
        let headers: HTTPHeaders = ["token": "UOWhOfDlwQTucPNBsmcRMskuxRjXlGJi"]
        
        Alamofire.request(NOAAStationsUrl!, headers: headers).responseJSON { response in
            let result = response.result
            if let dict = result.value as? JSONDictionary {
                if let results = dict["results"] as? [JSONDictionary] {
                    for obj in results {
                        let stationName = obj["name"] as? String ?? "n/a"
                        print(stationName)
                        let stationId = obj["id"] as? String ?? "n/a"
                        print(stationId)
                        let stationLat = obj["latitude"] as? Double ?? 0.0
                        let stationLong = obj["longitude"] as? Double ?? 0.0
                        let deltaLat = stationLat - self.segueData.latitude
                        let deltaLong = stationLong - self.segueData.longitude
                        let deltaDist = sqrt((deltaLat * deltaLat)+(deltaLong * deltaLong))
                        print(deltaDist)
                        let stationData = ClosestStation(stationId: stationId, stationDist: deltaDist, stationName: stationName)
                        self.stations.append(stationData)
                    }
                    self.stations.sort() { ($0.stationDist) < ($1.stationDist) }
                    print("\(self.stations[0].stationDist) \(self.stations[0].stationId) \(self.stations[0].stationName)")
                    self.station = self.stations[0].stationId
                }
            }
            if self.station != nil {
                let NOAATempUrl = URL(string: "https://www.ncdc.noaa.gov/cdo-web/api/v2/data?datasetid=GSOM&startdate=2016-01-01&enddate=2016-12-01&datatypeid=TAVG,TMAX,TMIN&stationid=\(self.station!)&limit=36")
                print(NOAATempUrl!)
                
                Alamofire.request(NOAATempUrl!, headers: headers).responseJSON { response in
                    let result = response.result
                    if let dict = result.value as? JSONDictionary {
                        if dict.count != 0 {
                            if let results = dict["results"] as? [JSONDictionary] {
                                if results.count > 7 {
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
                                    self.updateChart()
                                    self.loadingLbl.isHidden = true
                                    self.tempLineChart.isHidden = false
                                    self.monthsXAxis.isHidden = false
                                } else {
                                    self.loadingLbl.isHidden = true
                                    self.noDataAvailableView.isHidden = false
                                }
                            }
                        } else {
                            self.loadingLbl.isHidden = true
                            self.noDataAvailableView.isHidden = false
                        }
                    }
                }
            } else {
                self.loadingLbl.isHidden = true
                self.noDataAvailableView.isHidden = false
            }
        }
        completed()
    }
    
    
    // Configure Chart
    
    func updateChart() {
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
        let line = LineChartDataSet(values: lineChartEntry, label: "Avg Temp")
        let line2 = LineChartDataSet(values: lineChartEntry2, label: "Max Temp")
        let line3 = LineChartDataSet(values: lineChartEntry3, label: "Min Temp")

        line.colors = [NSUIColor.yellow]
        line.lineWidth = 3.0
        line.lineCapType = .round
        line.drawCircleHoleEnabled = false
        line.drawCirclesEnabled = false
        line.drawValuesEnabled = false
        
        line2.colors = [NSUIColor.red]
        line2.lineWidth = 3.0
        line2.lineCapType = .round
        line2.drawCircleHoleEnabled = false
        line2.drawCirclesEnabled = false
        line2.drawValuesEnabled = false
        
        line3.colors = [NSUIColor.blue]
        line3.lineWidth = 3.0
        line3.lineCapType = .round
        line3.drawCircleHoleEnabled = false
        line3.drawCirclesEnabled = false
        line3.drawValuesEnabled = false
        
        let data = LineChartData()
        data.addDataSet(line)
        data.addDataSet(line2)
        data.addDataSet(line3)
        tempLineChart.data = data
        
        tempLineChart.chartDescription?.text = ""
        tempLineChart.backgroundColor = UIColor(red: 35/255, green: 46/255, blue: 94/255, alpha: 1)
        tempLineChart.drawGridBackgroundEnabled = false
        tempLineChart.pinchZoomEnabled = false
        tempLineChart.doubleTapToZoomEnabled = false
        tempLineChart.legend.textColor = .white
        tempLineChart.legend.font = UIFont(name: "AvenirNext-Regular", size: 11)!
        tempLineChart.legend.verticalAlignment = .top
        tempLineChart.legend.horizontalAlignment = .left
        
        tempLineChart.xAxis.drawGridLinesEnabled = false
        tempLineChart.xAxis.drawAxisLineEnabled = false
        tempLineChart.xAxis.labelPosition = .bottom
        tempLineChart.xAxis.labelTextColor = .white
        tempLineChart.xAxis.labelFont = UIFont(name: "AvenirNext-Medium", size: 12)!
        tempLineChart.xAxis.labelCount = 12
        tempLineChart.xAxis.drawLabelsEnabled = false
        
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
}

