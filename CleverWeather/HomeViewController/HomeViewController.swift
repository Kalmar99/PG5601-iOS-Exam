//
//  HomeViewController.swift
//  CleverWeather
//
//  Created by Jonas on 11/3/20.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate,SimpleForecastDelegate {
    
    @IBOutlet weak var simpleForecast : SimpleForecast!
    let locationManager = CLLocationManager()
    var forecasts : ParsedSimpleWeather?
    var currentIndex : Int?
    var lastDate: Date?

    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsersLocation()
        simpleForecast.delegate = self;
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
    
    func setForecast(forecast: ParsedSimpleWeather) {
            
        
        let imgName = forecast.timeseries[forecast.todayIndex].data.next12hours?.summary.symbol_code
        let img = UIImage(named: imgName!)
        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: forecast.timeseries[forecast.todayIndex].time)
        let dayName = Calendar.current.weekdaySymbols[weekday-1]
        let umbrella = needUmbrella(forecast.timeseries[forecast.todayIndex].data.next12hours!.summary.symbol_code)
        simpleForecast.updateContent(image: img!, day: dayName, umbrella: umbrella)
        
    }
    
    func getWeatherData(lat: Double, lon: Double) {
        let fetcher = FetchData(endpoint: "https://api.met.no/weatherapi/locationforecast/2.0/compact")
        fetcher.getSimpleWeather(lat: lat, lon: lon) { (response) in
            switch response {
                case .success( let weather):
                    DispatchQueue.main.async {
                        
                        /*
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd.MM.yy"
                        let date = formatter.date(from: "08.11.20")
                        print(date) */
                        let date = Date()
                        self.forecasts = weather
                        let next = self.findNext(date: date)!
                        self.lastDate = weather.timeseries[next].time;
    
                        let imgName = weather.timeseries[next].data.next12hours?.summary.symbol_code
                        let img = UIImage(named: imgName!)
                        
                        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: weather.timeseries[next].time)
                        let dayName = Calendar.current.weekdaySymbols[weekday-1]
                        let umbrella = self.needUmbrella(weather.timeseries[next].data.next12hours!.summary.symbol_code)
                        
                        self.simpleForecast.updateContent(image: img!, day: dayName, umbrella: umbrella)
                        
                        
                    }
                case .failure(let error):
                    switch error.code {
                        case .noData:
                            DispatchQueue.main.async {
                                // Show error to user.
                                let img = UIImage(named: "noConnection")
                                self.simpleForecast.updateContent(image: img!, day: "Cant retrieve forcast", umbrella: false)
                            }
                        default:
                            print(error)
                    }
                    //print(error)
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
    
    func getForecastCount() -> Int? {
        return forecasts?.timeseries.count;
    }
    
    func getNextForecast() -> Timeseries?{
        
        guard forecasts != nil else {
            print("No Forecasts")
            return nil;
        }
        
        let tomorow = Calendar.current.date(byAdding: .day, value: 1, to: lastDate!)
        let tomorowIndex = findNext(date: tomorow!)
        
        guard tomorowIndex != nil else {
            print("Found \(tomorowIndex)")
            return nil;
        }
        print()
        lastDate = tomorow
        print(tomorowIndex)
        
        return forecasts?.timeseries[tomorowIndex!]
    }
    
    func getPreviousForecast() -> Timeseries? {
        print("Prev")
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: lastDate!)
        let yersterdayIndex = findNext(date: yesterday!)
        lastDate = yesterday
        guard yersterdayIndex != nil else {
            return nil
        }
        
        return forecasts?.timeseries[yersterdayIndex!]
    }
    
    func findNext(date: Date) -> Int?{
        // Får inn datoen som skal sjekkes
        
        for (index,weather) in forecasts!.timeseries.enumerated() {
            if Calendar.current.compare(date, to: weather.time, toGranularity: .day) == .orderedSame {
                return index
            }
        }
        
        return nil
        
    }
    

    
}
