//
//  ViewController.swift
//  CleverWeather
//
//  Created by REDACTED on 10/26/20.
//

import UIKit

protocol ForecastData {}

class ForecastViewController: UIViewController,UITabBarControllerDelegate,locationUpdateDelegate,ForecastFetcherDelegate {
   

    @IBOutlet weak var forecastTable : UITableView!;
    @IBOutlet weak var latLonLabel : UILabel!;
    @IBOutlet weak var errorLabel : UILabel!
    
    let api = ForecastFetcher(endpoint: "https://api.met.no/weatherapi/locationforecast/2.0/compact")
    
    let forecastDataSource = ForecastDataSource()
    var weather : [[ForecastData]] = [
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
        api.delegate = self;
        api.getWeatherDescription()
        api.getDailyForecast(lat: 59.91, lon: 10.74)
        latLonLabel.text = "Høyskolen Kristiania"
           
    }
   
    func locationUpdated(lat: Double, lon: Double) {
        print("updated")
        //Clear old data
        weather = [
            [],
            []
        ]
        api.getDailyForecast(lat: lat, lon: lon)
        latLonLabel.text = "\(String(format: "%.2f",lat)), \(String(format: "%.2f",lon))"
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if(viewController is MapsViewController) {
            let view = viewController as! MapsViewController
            print("delegate")
            view.locationUpdateDelegate = self;
        }
        
    }
    
    func updateDailyWeather(forecast: DailyForecast) -> Void {
        self.forecastDataSource.weather = [
            [],
            []
        ]
        self.forecastDataSource.weather[0].append(forecast.instant.details)
        self.forecastDataSource.weather[1].append(contentsOf: forecast.hours)
        self.forecastDataSource.units = forecast.units
        self.forecastTable.reloadData()
    }
    
    func updateError(error: FetchError) -> Void{
        switch error.code {
        case .noData:
            self.errorLabel.text = "No Connection, connect to internet"
        default:
            print(error.error)
        }
    }
    
    func updateDescriptions(descriptions: [String : AnyObject]) {
        print("Did run")
        self.forecastDataSource.descriptions = descriptions
        self.forecastTable.reloadData()
    }
    
}


