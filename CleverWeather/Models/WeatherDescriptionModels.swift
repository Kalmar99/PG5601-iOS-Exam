//
//  WeatherDescriptionModels.swift
//  CleverWeather
//
//
//

import Foundation

struct WeatherDescriptions : Decodable {
    let descriptions : [String : String]
    
}

struct Description : Decodable {
    let desc_en : String;
    let desc_nb : String
    
    
}
