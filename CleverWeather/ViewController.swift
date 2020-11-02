//
//  ViewController.swift
//  CleverWeather
//
//  Created by REDACTED on 10/26/20.
//

import UIKit

struct NowData {
    
}

struct weatherData {
    var time: String = ""
    var status: String = ""
    var measure: String?
}

class ViewController: UIViewController, UITableViewDataSource, locationUpdateDelegate, UITabBarControllerDelegate {
    
    @IBOutlet weak var forecastTable : UITableView!;
    @IBOutlet weak var latLonLabel : UILabel!;
   
    var weather : [[WeatherData]] = [
        [],
        []
    ]
    
    var units : Units?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tabBarController?.delegate = self;
        self.navigationItem.title = "Weather Forecast"
        forecastTable.dataSource = self;
        forecastTable.reloadData();
        // Get the api data
        getWeatherData(lat: 59.91, lon: 10.74)
        latLonLabel.text = "Høyskolen Kristiania"
           
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weather[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return weather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath) as! TeperatureCell;
        
        let time = ["Next Hour","Next 6 Hours","Next 12 Hours"]
        
        switch(weather[indexPath.section][indexPath.row]) {
            case is InstantDetails:
                let details = weather[indexPath.section][indexPath.row] as! InstantDetails
                cell.timeLabel.text = "Now"
                cell.statusLabel.text = "\(String(format: "%.1f", details.air_temperature)) \(units!.air_temperature)"
            case is NextHours:
                cell.timeLabel.text = time[indexPath.row];
                cell.measureTextLabel.text = "Weather";
                let hour = weather[indexPath.section][indexPath.row] as! NextHours
                if(hour.details != nil) {
                    cell.measureLabel.text = "\(String(hour.details!.precipitation_amount)) \(units!.precipitation_amount)"
                }
                cell.statusLabel.text = hour.summary.symbol_code
            default:
                print("No Data")
        }

        return cell;
    }
    
    func getWeatherData(lat: Double, lon: Double) {
        DispatchQueue.init(label: "Get Api Data").async {
            //get a fetcher object to handle the request & parsing
            let fetcher = FetchData(endpoint: "https://api.met.no/weatherapi/locationforecast/2.0/compact")
            fetcher.getWeatherByCords(lat: lat, lon: lon) { (result) in
            switch(result) {
                case .success(let weatherData):
                    DispatchQueue.main.async {
                        self.weather[0].append(weatherData.instant)
                        self.weather[1].append(contentsOf: weatherData.hours)
                        self.units = weatherData.units
                        self.forecastTable.reloadData()
                        if(lat == 59.91 && lon == 10.74) {
                            self.latLonLabel.text = "Location: Høyskolen Kristiania"
                        } else {
                            self.latLonLabel.text = "Location: \(String(format: "%.2f",lat)), \(String(format: "%.2f",lon))"
                        }
                    }
                case .failure(let error):
                    print(error)
            }}
        }
    }
    
    func locationUpdated(lat: Double, lon: Double) {
        print(lat,lon)
        //Clear old data
        weather = [
            [],
            []
        ]
        getWeatherData(lat: lat, lon: lon)
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if(viewController is MapsViewController) {
            let view = viewController as! MapsViewController
            view.locationUpdateDelegate = self;
        }
        
    }
    
}

