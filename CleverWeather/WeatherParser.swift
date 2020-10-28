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

class WeatherParser {
    
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
    
    
    
    func format(weatherData: WeatherResponse) -> (hours: [NextHours],instant: InstantDetails) {
        
        let time = Date()
        let currentTime = (
            day: Calendar.current.component(.day, from: time),
            hour: Calendar.current.component(.hour , from: time),
            month: Calendar.current.component(.month , from: time))
        
        var filteredWeather = weatherData.properties.timeseries.filter { item in
            return (Calendar.current.component(.month, from: item.time) == currentTime.month
                    && Calendar.current.component(.day, from: item.time) == currentTime.day
                    && Calendar.current.component(.hour, from: item.time) == currentTime.hour)
        }[0]
        
        var currentWeather  = [NextHours]()
        
        let noData = Summary(symbol_code: "No Data")
        
        if (filteredWeather.data.next1hours != nil) {
          
          currentWeather.append(filteredWeather.data.next1hours!)
        } else {
            currentWeather.append(NextHours(summary: noData, details: nil))
        }
        
        if(filteredWeather.data.next6hours != nil) {
            currentWeather.append(filteredWeather.data.next6hours!)
        } else {
            currentWeather.append(NextHours(summary: noData, details: nil))
        }
        
        if(filteredWeather.data.next12hours != nil) {
            
            currentWeather.append(filteredWeather.data.next12hours!)
        } else {
            currentWeather.append(NextHours(summary: noData, details: nil))
        }
        
        return (hours: currentWeather, instant: filteredWeather.data.instant.details)
    }
    
    
    
}
