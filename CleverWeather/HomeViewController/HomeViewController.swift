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
        print("Got location")
        getWeatherData(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        locationManager.stopUpdatingLocation()
    }
    
    func getWeatherData(lat: Double, lon: Double) {
        let fetcher = FetchData(endpoint: "https://api.met.no/weatherapi/locationforecast/2.0/compact")
        fetcher.getSimpleWeather(lat: lat, lon: lon) { (response) in
            switch response {
                case .success( let weather):
                    DispatchQueue.main.async {
                        let imgName = weather.timeseries[weather.todayIndex].data.next12hours?.summary.symbol_code
                        let img = UIImage(named: imgName!)
                        
                        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: weather.timeseries[weather.todayIndex].time)
                        let dayName = Calendar.current.weekdaySymbols[weekday-1]
                        let umbrella = self.needUmbrella(weather.timeseries[weather.todayIndex].data.next12hours!.summary.symbol_code)
                        
                        self.simpleForecast.updateContent(image: img!, day: dayName, umbrella: umbrella)
                        
                        
                    }
                case .failure(let error):
                    print(error)
            }
        }

    }
    
    
    func needUmbrella(_ symbol: String) -> Bool {
        let weather = symbol.split{$0 == "_"}.map(String.init)
        
       switch weather[0] {
            case "lightrainshowers": return true
            case "heavyrain": return true
            case "lightrainandthunder": return true
            case "sleetshowersandthunder": return true
            case "heavysleetshowersandthunder": return true
            case "rainandthunder": return true
            case "rainshowersandthunder": return true
            case "heavyrainandthunder": return true
            case "lightrain": return true
            case "sleetandthunder": return true
            case "lightrainshowersandthunder": return true
            case "heavyrainshowersandthunder": return true
            case "rain": return true
            case "lightsleet": return true
            case "sleetshowers": return true
            case "lightssleetshowersandthunder": return true
            case "lightsleetandthunder": return true
            case "heavyrainshowers": return true
            case "heavysleetandthunder": return true
            case "rainshowers": return true
            case "heavysleetshowers": return true
            case "heavysleet": return true
            case "lightsleetshowers": return true
            default: return false
        }
    }
    

    
}
