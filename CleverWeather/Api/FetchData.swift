//
//  FetchData.swift
//  CleverWeather
//
//  Created by REDACTED on 10/26/20.
//  "Borrowed" the completion handler code from here: https://stackoverflow.com/questions/40184468/convert-data-to-string-in-swift-3/40185083

import Foundation

enum FetchResponse {
    case success(String),failure(Error)
}

enum FetchWeatherByCordsResponse {
    case success((hours: [NextHours],instant: InstantDetails, units: Units)), failure(Error)
}

class FetchData {

    var endpoint: String

    init(endpoint: String) {
        self.endpoint = endpoint
    }

    
    func get(url: String, complete: @escaping (FetchResponse) -> Void ) {
        
        let endpoint = URL(string: url)!
        let session = URLSession.shared;
        let task = session.dataTask(with: endpoint, completionHandler: { (data, response, error) in
            if(error != nil) {
                complete(.failure(error!))
            } else if(data != nil) {
                complete(.success(String(data: data!, encoding: .utf8)!))
            } else {
                complete(.failure(NSError(domain: "example.cleverweather", code: 500, userInfo: [NSLocalizedDescriptionKey : "Cant convert data to string"])))
            }
        })
        task.resume()
        
    }
    
    // Gets the weather data and parsing it
    func getWeatherByCords(lat: Double, lon: Double, complete: @escaping (FetchWeatherByCordsResponse) -> Void ) {
        let session = URLSession.shared
        let coords = (lat: String(format: "%.1f",lat), lon: String(format: "%.1f", lon))
        let urlString = "\(endpoint)?lat=\(coords.lat)&lon=\(coords.lon)"
        
        let url = URL(string: urlString)!
        
        let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
            if(error != nil) {
                complete(.failure(error!))
            } else if(data != nil) {
                
                //Parse the data
                let parser = WeatherParser();
                let json = String(data: data!, encoding: .utf8)!
                let weather = parser.parseWeather(data: json)
                
                //Format it so we get the todays data
                let formattedWeather = parser.format(weatherData: weather)
                // Create a tupple containing all the information we need in ViewController
                let todaysData = (hours: formattedWeather.hours, instant: formattedWeather.instant, units: weather.properties.meta.units)
                complete(.success(todaysData))
            } else {
                complete(.failure(NSError(domain: "example.cleverweather", code: 500, userInfo: [NSLocalizedDescriptionKey : "Cant convert data to string"])))
            }
        })
        task.resume()
        
    }
    
    func getWeatherDescription() {
        
        get(url: "https://api.met.no/weatherapi/weathericon/2.0/legends",complete: {(result) in
            switch result {
                case .success(let data):
                    let decoder = JSONDecoder();
                    do {
                        let json = data.data(using: .utf8)
                        let obj = try JSONSerialization.jsonObject(with: json!, options: .mutableContainers) as! [String: AnyObject]
                        print(obj["lightsleet"]!["desc_en"])
                    } catch (let error) {
                        print(error)
                    }
                case .failure(let error):
                    print(error)
                default:
                    print("Did not recieve response from weathericon api")
            }
        })
        
    }
    
}
