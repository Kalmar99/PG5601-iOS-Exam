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
        
        // Get the api data
        DispatchQueue.init(label: "Get Api Data").async {
            //get a fetcher object to handle the request & parsing
            let fetcher = FetchData(endpoint: "https://api.met.no/weatherapi/locationforecast/2.0/compact")
            fetcher.getWeatherByCords(lat: 59.91, lon: 10.74) { (result) in
            switch(result) {
                case .success(let hoursArray):
                    DispatchQueue.main.async {
                        self.weather = hoursArray
                        self.forecastTable.reloadData()
                    }
                case .failure(let error):
                    print(error)
            }}
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
        
        return cell;
    }
    
}

