//
//  FetchData.swift
//  CleverWeather
//
//  Created by REDACTED on 10/26/20.
//  "Borrowed" the completion handler code from here: https://stackoverflow.com/questions/40184468/convert-data-to-string-in-swift-3/40185083
//  But modified it to fit my project

import Foundation

enum FetchResponse {
    case success(String),failure(Error)
}

typealias CurrentWeather = (hours: [NextHours],instant: InstantDetails, units: Units)

enum FetchWeatherByCordsResponse {
    case success(CurrentWeather), failure(Error)
}

class FetchData {

    var endpoint: String

    init(endpoint: String) {
        self.endpoint = endpoint
    }

    
    private func get(url: String, complete: @escaping (FetchResponse) -> Void ) {
        
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
    
    func getWeatherByCords(lat: Double, lon: Double, complete: @escaping (FetchWeatherByCordsResponse) -> Void){
        let coords = (lat: String(format: "%.2f",lat), lon: String(format: "%.2f", lon))
        get(url: "\(endpoint)?lat=\(coords.lat)&lon=\(coords.lon)",complete: {(result) in
            switch result {
                case .success(let data):
                    let parser = WeatherParser()
                    let weather : CurrentWeather = {
                        let unformatted = parser.parseWeather(data: data)
                        let formatted = parser.format(weatherData: unformatted)
                        return (hours: formatted.hours, instant: formatted.instant, units: unformatted.properties.meta.units)
                    }()
                    complete(.success(weather))
                case .failure(let error):
                    complete(.failure(error))
            }
        })
    }
    
    func getWeatherDescription() {
        
        get(url: "https://api.met.no/weatherapi/weathericon/2.0/legends",complete: {(result) in
            switch result {
                case .success(let data):
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
