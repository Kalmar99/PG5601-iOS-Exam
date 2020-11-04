//
//  FetchData.swift
//  CleverWeather
//
//  Created by REDACTED on 10/26/20.
//  "Borrowed" the completion handler code from here: https://stackoverflow.com/questions/40184468/convert-data-to-string-in-swift-3/40185083
//  But modified it to fit my project

import Foundation

enum GetResponse {
    case success(String),failure(Error)
}

typealias CurrentWeather = (hours: [NextHours],instant: InstantDetails, units: Units)

enum FetchWeatherResponse {
    case success(CurrentWeather), failure(Error)
}

enum DescriptionResponse {
    case success([String : AnyObject]), failure(Error)
}

class FetchData {
    
    let storage = StorageManager()

    var endpoint: String

    init(endpoint: String) {
        self.endpoint = endpoint
    }

    
    private func get(url: String, complete: @escaping (GetResponse) -> Void ) {
        
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
    
    func getApiByCords(lat: Double, lon: Double, complete: @escaping (FetchWeatherResponse) -> Void){
        let coords = (lat: String(format: "%.2f",lat), lon: String(format: "%.2f", lon))
        get(url: "\(endpoint)?lat=\(coords.lat)&lon=\(coords.lon)",complete: {(result) in
            switch result {
                case .success(let data):
                    let parser = WeatherParser()
                    let weather : CurrentWeather = {
                        let unformatted = parser.parseWeather(data: data)
                        let formatted = parser.format(unformatted)
                        self.storage.save(json: data)
                        return (hours: formatted.hours, instant: formatted.instant, units: unformatted.properties.meta.units)
                    }()
                    complete(.success(weather))
                case .failure(let error):
                    complete(.failure(error))
            }
        })
    }
    
    func getWeatherByCords(lat: Double, lon: Double, complete: @escaping (FetchWeatherResponse) -> Void){
        if storage.isData() {
            let data = storage.read()
            if data != nil {
                complete(.success(data!))
                print("Loaded data from file")
            }
        } else {
            getApiByCords(lat: lat, lon: lon, complete: complete )
            print("Loaded data from api")
        }
    }
    
    func getWeatherDescription(complete: @escaping (DescriptionResponse) -> Void) {
        get(url: "https://api.met.no/weatherapi/weathericon/2.0/legends",complete: {(result) in
            switch result {
                case .success(let data):
                    do {
                        let json = data.data(using: .utf8)
                        let descriptions = try JSONSerialization.jsonObject(with: json!, options: .mutableContainers) as! [String: AnyObject]
                        complete(.success(descriptions))
                    } catch (let error) {
                        print(error)
                    }
                case .failure(let error):
                    print("getWeatherDescription: ",error)
            }
        })
        
    }
    
}
