//
//  ForecastTableController.swift
//  CleverWeather
//
//  Created by Jonas on 11/3/20.
//

import UIKit

class ForecastDataSource: NSObject, UITableViewDataSource {
    
    var weather : [[ForecastData]] = [
        [],
        []
    ]
    
    var units : Units?;
    var descriptions: [String: AnyObject]?
    
    func getDescription(symbol: String) -> String {
        // copied the split functionality from here
        // https://stackoverflow.com/questions/25678373/split-a-string-into-an-array-in-swift
        let text = symbol.split{$0 == "_"}.map(String.init)
        
        guard let description = descriptions?[text[0]]?["desc_en"] as? String else {
            // Just in case the symbol for some reason doesent exist in the dictionary
            return symbol
        }
        
        return description
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return weather.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weather[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath) as! ForecastCell;
        
        let time = ["Next Hour","Next 6 Hours","Next 12 Hours"]
        
        let weatherData = weather[indexPath.section][indexPath.row]
        
        if(weatherData is InstantDetails) {
            let details = weather[indexPath.section][indexPath.row] as! InstantDetails
            cell.timeLabel.text = "Now"
            cell.statusLabel.text = "\(String(format: "%.1f", details.air_temperature)) \(units!.air_temperature)"
        } else if (weatherData is NextHours) {
            print(indexPath.row)
            cell.timeLabel.text = time[indexPath.row];
            cell.measureTextLabel.text = "Weather";
            let hour = weather[indexPath.section][indexPath.row] as! NextHours
            if(hour.details != nil) {
                cell.measureLabel.text = "\(String(hour.details!.precipitation_amount)) \(units!.precipitation_amount)"
            }
            let description = getDescription(symbol: hour.summary.symbol_code)
            cell.statusLabel.text = description
            
        }
        
        return cell
    }
    

}
