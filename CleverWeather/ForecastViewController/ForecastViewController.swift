//
//  ViewController.swift
//  CleverWeather
//
//  Created by REDACTED on 10/26/20.
//

import UIKit

struct weatherData {
    var time: String = ""
    var status: String = ""
    var measure: String?
}

class ForecastViewController: UIViewController, locationUpdateDelegate, UITabBarControllerDelegate {
   

    @IBOutlet weak var forecastTable : UITableView!;
    @IBOutlet weak var latLonLabel : UILabel!;
    @IBOutlet weak var errorLabel : UILabel!
    
    let forecastDataSource = ForecastDataSource()
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
        
        forecastTable.dataSource = forecastDataSource;
        
        // Get the api data
        getWeatherData(lat: 59.91, lon: 10.74)
        latLonLabel.text = "Høyskolen Kristiania"
           
    }
   
    func getWeatherData(lat: Double, lon: Double) {
            //get a fetcher object to handle the request & parsing
            let fetcher = FetchData(endpoint: "https://api.met.no/weatherapi/locationforecast/2.0/compact")
            fetcher.getWeatherDescription() {(result) in
                switch result {
                    case .success(let descriptions):
                        DispatchQueue.main.async {
                            self.forecastDataSource.descriptions = descriptions
                            self.forecastTable.reloadData()
                        }
                    case .failure(let error):
                        print(error)
                }
            }
            fetcher.getWeatherByCords(lat: lat, lon: lon) { (result) in
            switch(result) {
                case .success(let weatherData):
                    DispatchQueue.main.async {
                        self.forecastDataSource.weather = [
                            [],
                            []
                        ]
                        self.forecastDataSource.weather[0].append(weatherData.instant)
                        self.forecastDataSource.weather[1].append(contentsOf: weatherData.hours)
                        self.forecastDataSource.units = weatherData.units
                        self.forecastTable.reloadData()
                        if(lat == 59.91 && lon == 10.74) {
                            self.latLonLabel.text = "Location: Høyskolen Kristiania"
                        } else {
                            self.latLonLabel.text = "Location: \(String(format: "%.2f",lat)), \(String(format: "%.2f",lon))"
                        }
                    }
                case .failure(let error):
                    switch error.code {
                        case .storageError:
                            //Famous last words: "This should never happen"
                            print("Storage Error")
                        case .noData:
                            //Most common, means no internet & no data on disk
                            DispatchQueue.main.async {
                                self.errorLabel.text = "Cant retrieve data, no internet"
                            }
                        default:
                            print(error.description)
                            print(error.reason)
                            print(error.error)
            }}
            }}
    
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


