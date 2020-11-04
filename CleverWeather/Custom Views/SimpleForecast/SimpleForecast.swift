//
//  SimpleForecast.swift
//  CleverWeather
//
//  Created by Jonas on 11/3/20.
//

import UIKit

protocol SimpleForecastDelegate {
    func getForecastCount()
    func getNextForecast()
    func getPreviousForecast()
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
        if(umbrella) {
            statusLabel.text = "Bring an umbrella"
        } else {
            statusLabel.text = "No need for an umbrella"
        }
    }
    
    func initViews() {
        let nib = UINib(nibName: "SimpleForecast", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = self.bounds;
        addSubview(contentView)
    }

}
