//
//  ViewController.swift
//  CleverWeather
//
//  Created by REDACTED on 10/26/20.
//

import UIKit

struct weatherData {
    var time: String = ""
    var status: String = ""
    var measure: String?
}

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var forecastTable : UITableView!;
   
    var weather = [NextHours]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Weather Forecast"
        forecastTable.dataSource = self;
        forecastTable.reloadData();
        
        
        //Insert db check logic before this
        DispatchQueue.init(label: "Get Api Data").async {
            // instantiate a fetcher object to handle the request
            let fetcher = FetchData()
            let url = "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=59.91&lon=10.74"
            //Get the data
            fetcher.get(url: url,complete: { (result) in
                //Check if it was successfull, if not print error
                
                switch result {
                    case .success(let data) :
                        let parser = ParseWeatherResponse();
                        //Parse data
                        let weatherResponse = parser.parseWeather(data: data)
                        let today = Date()
                        // Get the current day, hour and month
                        let currentDay = Calendar.current.component(.day, from: today)
                        let currentHour = Calendar.current.component(.hour , from: today)
                        let currentMonth = Calendar.current.component(.month , from: today)
                        
                        //Filter array based on time so i can get the closest entry and store it
                        var filteredWeather = weatherResponse.properties.timeseries.filter { item in
                            return (Calendar.current.component(.month, from: item.time) == currentMonth
                                && Calendar.current.component(.day, from: item.time) == currentDay
                                && Calendar.current.component(.hour, from: item.time) == currentHour)
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
                        
                        // Task finished, return to main thread with result
                        DispatchQueue.main.async {
                            // Update table here
                            self.weather = currentWeather
                            self.forecastTable.reloadData()
                        }
                        
                    case .failure(let error) : print(error)
                }
                
                
            })
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return weather.count
      
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath) as! TeperatureCell;
        
        let time = ["Next Hour","Next 6 Hours","Next 12 Hours"]
        
        cell.timeLabel.text = time[indexPath.row];
        cell.measureTextLabel.text = "Weather";
        cell.statusLabel.text = weather[indexPath.row].summary.symbol_code
        
        
        /*
        cell.statusLabel.text = weather[indexPath.row].status
        cell.timeLabel.text = weather[indexPath.row].time
        if(weather[indexPath.row].measure != nil) {
            cell.measureLabel.text = weather[indexPath.row].measure;
        } */
        
        return cell;
    }
    
    


}

