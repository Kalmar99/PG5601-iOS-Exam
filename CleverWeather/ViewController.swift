//
//  ViewController.swift
//  CleverWeather
//
//  Created by Jonas on 10/26/20.
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

