//
//  WeatherDetails.swift
//  CleverWeather
//
//  Source: https://guides.codepath.com/ios/Custom-Views-Quickstart
//

import UIKit

class WeatherDetails: UIView,WeatherDetailsDelegate {
    
    @IBOutlet weak var latLabel : UILabel!;
    @IBOutlet weak var lonLabel : UILabel!;
    @IBOutlet weak var contentView: UIView!;
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    func updateData(lat: Double, lon: Double, data: NextHours) {
        latLabel.text = String(format: "%.2f",lat)
        lonLabel.text = String(format: "%.2f",lon)
        print(data)
    }
    
    func initViews() {
        let nib = UINib(nibName: "WeatherDetails", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = self.bounds;
        addSubview(contentView)
    }
  
}

