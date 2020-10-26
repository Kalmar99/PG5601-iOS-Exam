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
   
    var weather : [weatherData] = [
        weatherData(time: "Now", status: "10 celcius", measure: nil ),
        weatherData(time: "Next Hour", status: "Rain",measure: "2 mm"),
        weatherData(time: "Next 6 Hours", status: "Cloudy", measure: "0 mm"),
        weatherData(time: "Next 12 Hours", status: "Cloudy", measure: nil)
    ]
    
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
                    case .success(let data) : print(data) //Parse JSON here
                    case .failure(let error) : print(error)
                }
                
                // Task finished, return to main thread with result
                DispatchQueue.main.async {
                    // Update table here
                }
                
            })
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weather.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath) as! TeperatureCell;
        cell.statusLabel.text = weather[indexPath.row].status
        cell.timeLabel.text = weather[indexPath.row].time
        if(weather[indexPath.row].measure != nil) {
            cell.measureLabel.text = weather[indexPath.row].measure;
        }
        
        return cell;
    }
    
    


}

