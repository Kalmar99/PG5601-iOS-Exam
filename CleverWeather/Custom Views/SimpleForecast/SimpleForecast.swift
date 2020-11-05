//
//  SimpleForecast.swift
//  CleverWeather
//
//  Created by Jonas on 11/3/20.
//

import UIKit

protocol SimpleForecastDelegate {
    func getForecastCount() -> Int?
    func getNextForecast() -> Timeseries?
    func getPreviousForecast() -> Timeseries?
}

class SimpleForecast: UIView {
    
    @IBOutlet weak var contentView : UIView!
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var dayLabel : UILabel!
    @IBOutlet weak var statusLabel : UILabel!
    
    var delegate : SimpleForecastDelegate?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    func updateContent(image: UIImage, day: String, umbrella: Bool) {
        imageView.image = image;
        dayLabel.text = day;
        if(day != "Cant retrieve forcast") {
            if(umbrella) {
                statusLabel.text = "Bring an umbrella"
            } else {
                statusLabel.text = "No need for an umbrella"
            }
        } else {
            statusLabel.text = "Please connect to the internet"
        }
        
    }
    
    func initViews() {
        let nib = UINib(nibName: "SimpleForecast", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = self.bounds;
        addSubview(contentView)
    }
    
    func setForecast(_ weather: Timeseries) {
        
        var symbol = ""
        
        let n12Hours = weather.data.next12hours?.summary.symbol_code
        let n6Hours = weather.data.next6hours?.summary.symbol_code
        let n1Hours = weather.data.next1hours?.summary.symbol_code
        
        if n12Hours != nil {
            symbol = n12Hours!
        } else if n6Hours != nil {
            symbol = n6Hours!
        } else if n1Hours != nil {
            symbol = n1Hours!
        }
        
        let img = UIImage(named: symbol)!
        let weekday = Calendar(identifier: .gregorian).component(.weekday, from: weather.time)
        let dayName = Calendar.current.weekdaySymbols[weekday-1]
        
        updateContent(image: img, day: dayName, umbrella: needUmbrella(symbol))
    }
    
    @IBAction func swipeRight(_ gestureRecognizer : UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            print("Swipe left")
            guard let weather = delegate?.getPreviousForecast() else {
                return;
            }
            
            setForecast(weather)
            
        }
        
    }
    
    @IBAction func swipeLeft(_ gestureRecognizer : UISwipeGestureRecognizer) {
        print("Swipe right")
        let weather = delegate?.getNextForecast()
        
        guard weather != nil else {
            return
        }
        print(weather!.time)
        setForecast(weather!)
        
    }
    
    func needUmbrella(_ symbol: String) -> Bool {
        let weather = symbol.split{$0 == "_"}.map(String.init)
        
       switch weather[0] {
            case "lightrainshowers": return true
            case "heavyrain": return true
            case "lightrainandthunder": return true
            case "sleetshowersandthunder": return true
            case "heavysleetshowersandthunder": return true
            case "rainandthunder": return true
            case "rainshowersandthunder": return true
            case "heavyrainandthunder": return true
            case "lightrain": return true
            case "sleetandthunder": return true
            case "lightrainshowersandthunder": return true
            case "heavyrainshowersandthunder": return true
            case "rain": return true
            case "lightsleet": return true
            case "sleetshowers": return true
            case "lightssleetshowersandthunder": return true
            case "lightsleetandthunder": return true
            case "heavyrainshowers": return true
            case "heavysleetandthunder": return true
            case "rainshowers": return true
            case "heavysleetshowers": return true
            case "heavysleet": return true
            case "lightsleetshowers": return true
            default: return false
        }
    }

}
