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

enum FetchErrorCodes {
    case noInternet
    case storageError
    case unknownError
    case noData
}

struct FetchError {
    let code: FetchErrorCodes
    let reason: String
    let description: String
    let error : Error
}

enum FetchWeatherResponse {
    case success(CurrentWeather), failure(FetchError)
}

enum fetchSimpleResponse {
    case success(ParsedSimpleWeather), failure(FetchError)
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
                    let weather = self.parseDaily(data)
                    self.storage.save(json: data)
                    complete(.success(weather))
                case .failure(let error):
                    if error.localizedDescription == "The Internet connection appears to be offline." {
                        complete(.failure(FetchError(code: .noInternet, reason: "No internet", description: "getApiByCords: line 63, FetchData.swift",error: error)))
                    } else {
                        complete(.failure(FetchError(code: .unknownError, reason: error.localizedDescription, description: "getApiByCords: line 63, FetchData.swift", error: error)))
                    }
                    
            }
        })
    }
    
    func getApiSimpleByCords(lat: Double, lon: Double, complete: @escaping (fetchSimpleResponse) -> Void){
        let coords = (lat: String(format: "%.2f",lat), lon: String(format: "%.2f", lon))
        get(url: "\(endpoint)?lat=\(coords.lat)&lon=\(coords.lon)",complete: {(result) in
            switch result {
                case .success(let data):
                    let weather = self.parseSimple(data)
                    self.storage.save(json: data)
                    complete(.success(weather))
                case .failure(let error):
                    if error.localizedDescription == "The Internet connection appears to be offline." {
                        complete(.failure(FetchError(code: .noInternet, reason: "Cant get data", description: "getApiSimpleByCords", error: error)))
                    } else {
                        complete(.failure(FetchError(code: .unknownError, reason: "Cant get data", description: "getApiSimpleByCords", error: error)))
                    }
                    
            }
        })
    }
    
    
    
    func getSimpleWeather(lat: Double, lon: Double, complete: @escaping (fetchSimpleResponse) -> Void) {
        
        getApiSimpleByCords(lat: lat, lon: lon) { result in
            switch result {
                case .success(let weather):
                    complete(.success(weather))
                    print("Got data from api")
                case .failure(let error):
                    switch error.code {
                        case .noInternet:
                            if self.storage.isData() {
                                let data = self.storage.read()
                                if data != nil {
                                    let weather = self.parseSimple(data!)
                                    complete(.success(weather))
                                    print("Got data from disk")
                                } else {
                                    complete(.failure(error))
                                }
                            } else {
                                complete(.failure(FetchError(code: .noData, reason: "No data on disk", description: "getApiSimpleByCords", error: error.error)))
                            }
                            
                        default:
                            complete(.failure(error))
                        
                    }
            }
        }
    }
    
    func parseSimple(_ data: String) -> ParsedSimpleWeather {
        let simple : ParsedSimpleWeather = try! {
            let parser = WeatherParser()
            let unformatted = parser.parseWeather(data: data)
            let formatted = parser.formatSimple(unformatted)
            if formatted != nil {
                return formatted!
            } else {
                // Neeed to do something here, just crash for now if it doesent work
                throw NSError(domain: "com.example.cleverWeather", code: 1337, userInfo: ["error":"123"])
            }
           
        }()
        return simple
    }
    
    
    func parseDaily(_ data: String) -> CurrentWeather {
        let daily : CurrentWeather = {
            let parser = WeatherParser()
            let unformatted = parser.parseWeather(data: data)
            let formatted = parser.formatDaily(unformatted)
            return (hours: formatted.hours, instant: formatted.instant, units: unformatted.properties.meta.units)
        }()
        return daily
    }
    
    func getWeatherByCords(lat: Double, lon: Double, complete: @escaping (FetchWeatherResponse) -> Void){
   
        //Try to get data from api
        getApiByCords(lat: lat, lon: lon) { result in
                switch result {
                    case .success(let weahter):
                        //Got data, move on
                        complete(.success(weahter))
                        print("Successfully got data from api")
                    case .failure(let error):
                        //Did not get data, find out why:
                        if(error.code == .noInternet) {
                            if self.storage.isData() {
                                //Found data on disk, move on:
                                let data = self.storage.read()
                                if data != nil {
                                    let weather = self.parseDaily(data!)
                                    complete(.success(weather))
                                    print("Could not connect to the internet but found data on disk")
                                } else {
                                    complete(.failure(FetchError(code: .storageError, reason: "Failed to retrieve data from disk", description: "GetWeatherByCords, FetchData.swift", error: error.error)))
                                }
                            } else {
                                //Did not find data at all, fail:
                                let fail = FetchError(code: .noData, reason: "Could not get data", description: "GetWeatherByCords, FetchData.swift",error: error.error)
                                complete(.failure(fail))
                            }
                        }
                }
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
