//
//  ParseWeatherResponse.swift
//  CleverWeather


import Foundation


struct test : Decodable {
    var type: String
}

typealias ParsedWeather = (hours: [NextHours], instant: InstantDetails)
typealias ParsedSimpleWeather = (timeseries: [Timeseries],todayIndex: Int)

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
    
    func parseDailyForecast(_ json: String) -> DailyForecast {
        
        let apiForecast = parseWeather(data: json).properties
        
        let forecast = apiForecast.filter(date: Date())[0]
        
        let noData = NextHours(summary: Summary(symbol_code: "No Data"), details: nil)

        let hours : [NextHours] = [forecast.data.next1hours,forecast.data.next6hours,forecast.data.next12hours].map { hour in
            guard hour != nil else {
                return noData
            }
            return hour!
        }
                
        return DailyForecast(instant: forecast.data.instant, hours: hours, units: apiForecast.meta.units )
    }
    
    func parseSimpleForecast(_ json: String) -> SimpleForecast2? {
        
        let weather = parseWeather(data: json)
        guard let todayIndex = weather.properties.indexOnDate(Date()) else {
            return nil;
        }
       
        return SimpleForecast2(timeseries: weather.properties.timeseries, todayIndex: todayIndex)
    }
    
    
}

extension Properties {
    func filter(date: Date) -> [Timeseries] {
        let now = Calendar.current.dateComponents([.month,.day,.hour], from: date)
        
        return self.timeseries.filter { weather in
            
            if Calendar.current.compare(date, to: weather.time, toGranularity: .month) == .orderedSame {
                if Calendar.current.compare(date, to: weather.time, toGranularity: .day) == .orderedSame {
                    return true
                } else {return false}
            } else { return false }
            
        }
    }
    func indexOnDate(_ date: Date) -> Int? {
        for (index, weather) in self.timeseries.enumerated() {
            if(Calendar.current.isDateInToday(weather.time)) {
                return index
            }
        }
        
        return nil
    }
}
