//
//  StorageManager.swift
//  CleverWeather
//
//  Code for Writing and reading was copied from here:
//  https://medium.com/@CoreyWDavis/reading-writing-and-deleting-files-in-swift-197e886416b0
//  but modified to fit my project


import Foundation
import CoreData

class StorageManager {
    

    let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let filename = "weather"
    let extention = "json"
    
    func isData() -> Bool {
        let fileURL = URL(fileURLWithPath: filename, relativeTo: directoryURL).appendingPathExtension(extention)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    func save(json: String) {
        
        let fileURL = URL(fileURLWithPath: filename, relativeTo: directoryURL).appendingPathExtension(extention)
        guard let data = json.data(using: .utf8) else {
            print("Cant convert string to data")
            return
        }
        
        do {
            try data.write(to: fileURL)
            print("File saved: \(fileURL.absoluteURL)")
        } catch let error {
            print(error)
        }
    }
    
    
    
    func read() -> CurrentWeather? {
        let fileURL = URL(fileURLWithPath: filename, relativeTo: directoryURL).appendingPathExtension(extention)

        do {
            let data = try Data(contentsOf: fileURL)
            let parser = WeatherParser()
            if let string = String(data: data, encoding: .utf8) {
                let unformatted = parser.parseWeather(data: string)
                let formatted = parser.format(unformatted)
                return (hours: formatted.hours, instant: formatted.instant, units: unformatted.properties.meta.units)
            }
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    
}
