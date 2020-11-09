//
//  WeatherDetails.swift
//  CleverWeather
//
//  Source: https://guides.codepath.com/ios/Custom-Views-Quickstart
//

import UIKit
import CoreLocation

protocol WeatherDetailDelegate {
    func getLocation() -> (lat: Double?, lon: Double?)
}

class WeatherDetails: UIView,WeatherDetailsDelegate, ForecastFetcherDelegate {
    
    @IBOutlet weak var latLabel : UILabel!;
    @IBOutlet weak var lonLabel : UILabel!;
    @IBOutlet weak var contentView: UIView!;
    @IBOutlet weak var symbolImageView : UIImageView!;
    
    var delegate: WeatherDetailDelegate?
    
    let locationManager = CLLocationManager()
    var lat: Double?
    var lon: Double?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    func initViews() {
        let nib = UINib(nibName: "WeatherDetails", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = self.bounds;
        addSubview(contentView)
    }
    
    func updateData(lat: Double, lon: Double, data: NextHours) {
        latLabel.text = String(format: "%.2f",lat)
        lonLabel.text = String(format: "%.2f",lon)
        
        let image = UIImage(named: data.summary.symbol_code)
        symbolImageView.image = image;
        
        print(data)
    }
    
    func updateDailyWeather(forecast: DailyForecast) {
        
        let cords = delegate?.getLocation()
        print(cords)
        guard cords?.lat != nil && cords?.lon != nil else {
            return
        }
        
        var data = forecast.hours[0];
        
        if data.summary.symbol_code == "No Data" {
            if forecast.hours[1].summary.symbol_code !=  "No Data" {
                data = forecast.hours[1]
            } else if forecast.hours[2].summary.symbol_code != "No Data" {
                data = forecast.hours[2]
            }
        }
    
        self.updateData(lat: cords!.lat! , lon: cords!.lon! , data: forecast.hours[0])
        
    }
    
    
  
}

