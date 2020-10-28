//
//  WeatherResponseModels.swift
//  CleverWeather
//
//  Created by Jonas on 10/27/20.
//

import Foundation

protocol WeatherData {
    
}

struct WeatherResponse : Decodable {
    let type: String
    let geometry: Geometry
    let properties: Properties
}

struct Geometry : Decodable {
    let type: String
    let coordinates: [Double]
}

struct Properties : Decodable {
    let meta: Meta
    let timeseries: [Timeseries]
}

struct Meta : Decodable {
    let updated_at: Date
    let units: Units
}

struct Units : Decodable {
    let air_pressure_at_sea_level: String
    let air_temperature: String
    let cloud_area_fraction: String
    let precipitation_amount: String
    let relative_humidity: String
    let wind_from_direction: String
    let wind_speed: String
}

struct Timeseries : Decodable {
    var time: Date
    let data: TimeseriesData
}

struct TimeseriesData : Decodable {
    let instant: Instant
    let next12hours, next1hours,next6hours : NextHours?
    
    enum CodingKeys: String, CodingKey {
        case next12hours = "next_12_hours"
        case next6hours = "next_6_hours"
        case next1hours = "next_1_hours"
        case instant
    }
}

struct NextHours : Decodable, WeatherData {
    var type: Int?
    let summary: Summary
    let details: Details?
}

struct Summary : Decodable {
    let symbol_code: String
}

struct Details : Decodable {
    let precipitation_amount : Double
}

struct Instant : Decodable {
    let details: InstantDetails
}

struct InstantDetails : Decodable, WeatherData {
    let air_pressure_at_sea_level: Double
    let air_temperature: Double
    let cloud_area_fraction: Double
    let relative_humidity: Double
    let wind_from_direction: Double
    let wind_speed: Double
}

