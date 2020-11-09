//
//  HomeViewController.swift
//  CleverWeather
//


import UIKit
import CoreLocation

class HomeViewController: UIViewController, CLLocationManagerDelegate,SimpleForecastDelegate,ForecastFetcherDelegate {
    
    @IBOutlet weak var simpleForecast : SimpleForecast!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var forecasts : SimpleForecast2?
    var currentIndex : Int?
    var lastDate: Date?
    let api = ForecastFetcher(endpoint: "https://api.met.no/weatherapi/locationforecast/2.0/compact")

    override func viewDidLoad() {
        super.viewDidLoad()
        getUsersLocation()
        simpleForecast.delegate = self;
        api.delegate = self;
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
        api.getSimpleForecast(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
        locationManager.stopUpdatingLocation()
    }
    
    func setForecast(forecast: SimpleForecast2) {
            
        let imgName = forecast.timeseries[forecast.todayIndex].data.next12hours?.summary.symbol_code
        let img = UIImage(named: imgName!)
        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: forecast.timeseries[forecast.todayIndex].time)
        let dayName = Calendar.current.weekdaySymbols[weekday-1]
        let umbrella = needUmbrella(forecast.timeseries[forecast.todayIndex].data.next12hours!.summary.symbol_code)
        simpleForecast.updateContent(image: img!, day: dayName, umbrella: umbrella)
        
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
            return nil;
        }
        print()
        lastDate = tomorow
        
        return forecasts?.timeseries[tomorowIndex!]
    }
    
    func getPreviousForecast() -> Timeseries? {
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: lastDate!)
        let yersterdayIndex = findNext(date: yesterday!)
        lastDate = yesterday
        guard yersterdayIndex != nil else {
            return nil
        }
        
        return forecasts?.timeseries[yersterdayIndex!]
    }
    
    func findNext(date: Date) -> Int?{
        for (index,weather) in forecasts!.timeseries.enumerated() {
            if Calendar.current.compare(date, to: weather.time, toGranularity: .day) == .orderedSame {
                return index
            }
        }
        
        return nil
    }
    
    func updateSimpleWeather(forecast: SimpleForecast2) {
        let date = Date()
        self.forecasts = forecast
        let next = self.findNext(date: date)!
        self.lastDate = forecast.timeseries[next].time;
        setForecast(forecast: forecast)
        lastUpdatedLabel.text = "Last updated: \(forecast.timeseries[0].time)"
    }
    
    func updateError(error: FetchError) -> Void{
        switch error.code {
        case .noData:
            simpleForecast.updateContent(image: UIImage(named: "noConnection")!, day: "Cant retrieve forcast", umbrella: false)
        default:
            print(error.error)
        }
    }
    

    
}
