//
//  ForecastFetcher.swift
//  CleverWeather
//
//  Created by Jonas on 11/6/20.
//


struct DailyForecast {
    var instant: Instant
    var hours: [NextHours]
    var units: Units
}

enum DailyForecastResponse {
    case success(DailyForecast)
    case failure(FetchError)
}

struct SimpleForecast2 {
    var timeseries: [Timeseries]
    var todayIndex: Int
}

enum SimpleForecastResponse {
    case success(SimpleForecast2)
    case failure(FetchError)
}

enum FetchResponse {
    case success(Data)
    case failure(FetchError)
}

import Foundation

class ForecastFetcher {
    
    var endpoint : String
    
    init(endpoint: String) {
        self.endpoint = endpoint
    }
    
    var test : String?
    
    private func fetch(_ url: String, complete: @escaping (FetchResponse) -> Void ) {
        let endpoint = URL(string: url)!
        let task = URLSession.shared.dataTask(with: endpoint, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                guard data != nil else {
                    complete(.failure(FetchError(code: .noData, reason: "Could not get any data from api", description: "ForecastFetcher.swift", error: NSError())))
                    return;
                }
                complete(.success(data!))
            }
        })
        task.resume()
    }
    
    private func getData(lat: Double, lon: Double, complete: @escaping (FetchResponse) -> Void) {
        let url = "?lat=\(String(format: "%.2f", lat))&lon=\(String(format: "%.2f",lon))"
        let storage = StorageManager()
        if storage.isData() {
            let dataString = storage.read()
            
            guard dataString != nil else {
                let error = FetchError(code: .storageError, reason: "file exists but contain no data", description: "ForecastFetcher.swift : getData", error: NSError())
                complete(.failure(error))
                return;
            }
            
            storage.save(json: dataString!)
            complete(.success(Data(base64Encoded: dataString!)!))
        } else {
            fetch(url, complete: complete)
        }
    }

    func getSimpleForecast(lat: Double, lon: Double, complete: @escaping (SimpleForecastResponse) -> Void) {
        
    }
    
    func getDailyForecast(lat: Double, lon: Double, complete: @escaping (DailyForecastResponse) -> Void) {
        getData(lat: lat, lon: lon) { data in
            switch data {
                case .success(let data):
                    let dailyForecast = WeatherParser().parseDailyForecast(String(data: data,encoding: .utf8)!)
                    complete(.success(dailyForecast))
                case .failure(let error):
                    complete(.failure(error))
            }
        }
    }
    
}
