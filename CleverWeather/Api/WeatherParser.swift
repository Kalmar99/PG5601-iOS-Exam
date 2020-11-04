//
//  ParseWeatherResponse.swift
//  CleverWeather


import Foundation


struct test : Decodable {
    var type: String
}

typealias ParsedWeather = (hours: [NextHours], instant: InstantDetails)

class WeatherParser {
    
    func parseWeather(data: String) -> WeatherResponse {
        let json = data.data(using: .utf8)
        
        /*
         The date formatting code was copied from here: https://www.stackoverflow.com/questions/49343500/cant-decode-date-in-swift-4
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
    
    func format(_ data: WeatherResponse) -> ParsedWeather {
        let time = Calendar.current.dateComponents([.month,.day,.hour], from: Date())
        
        let weather = data.properties.filter(date: Date())
        
        var currentWeather = [NextHours]()
        let noData = NextHours(summary: Summary(symbol_code: "No Data"),details: nil)
        
        let hours : [NextHours?] = [weather.data.next1hours,weather.data.next6hours,weather.data.next12hours]
        for hour in hours {
            if hour != nil {
                currentWeather.append(hour!)
            } else {
                currentWeather.append(noData)
            }
        }
        
        return ParsedWeather(hours: currentWeather, instant: weather.data.instant.details)
        
    }
    
}

extension Properties {
    func filter(date: Date) -> Timeseries {
        let now = Calendar.current.dateComponents([.month,.day,.hour], from: date)
        
        return self.timeseries.filter { weather in
            return Calendar.current.dateComponents([.month,.day,.hour], from: weather.time) == now
        }[0]
    }
}
