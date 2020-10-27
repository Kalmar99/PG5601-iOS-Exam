//
//  ParseWeatherResponse.swift
//  CleverWeather
//
//  Created by REDACTED on 10/26/20.
//

import Foundation


struct test : Decodable {
    var type: String
}

class ParseWeatherResponse {
    

    
    func parseWeather(data: String) -> WeatherResponse {
        let json = data.data(using: .utf8)
        
        /*
         The date formatting code was copyed from here: https://www.stackoverflow.com/questions/49343500/cant-decode-date-in-swift-4
         but modified to fit my data
         */
        
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let weatherResponse : WeatherResponse = try! decoder.decode(WeatherResponse.self, from: json!)
        //let weatherResponse: WeatherResponse = try! JSONDecoder().decode(WeatherResponse.self,from: json!)
        return weatherResponse
        
    }
    
    
    
}
