//
//  HomeViewController.swift
//  CleverWeather
//
//  Created by Jonas on 11/3/20.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var simpleForecast : SimpleForecast!
    let locationManager = CLLocationManager()
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        //getUsersLocation()
        
    }
    
    func getUsersLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1000.0;
        locationManager.delegate = self;
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count-1]
        getWeatherData(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }
    
    func getWeatherData(lat: Double, lon: Double) {
        let fetcher = FetchData(endpoint: "https://api.met.no/weatherapi/locationforecast/2.0/compact")
        fetcher.getWeatherByCords(lat: lat, lon: lon) { (response) in
            switch response {
                case .success( let currentWeather):
                    DispatchQueue.main.async {
                        self.locationManager.stopUpdatingLocation()
                    }
                case .failure(let error):
                    print(error)
            }
        }

    }
    

    
}
