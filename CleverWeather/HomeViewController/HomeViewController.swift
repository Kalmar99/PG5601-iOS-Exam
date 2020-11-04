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
        getUsersLocation()
        
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
        fetcher.getSimpleWeather(lat: lat, lon: lon) { (response) in
            switch response {
                case .success( let weather):
                    DispatchQueue.main.async {
                        self.locationManager.stopUpdatingLocation()
                        let imgName = weather.timeseries[0].data.next12hours?.summary.symbol_code
                        let img = UIImage(named: imgName!)
                        
                        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: weather.timeseries[0].time)
                        let dayName = Calendar.current.weekdaySymbols[weekday-1]
                        
                        self.simpleForecast.updateContent(image: img!, day: dayName, umbrella: true)
                        
                        
                    }
                case .failure(let error):
                    print(error)
            }
        }

    }
    

    
}
