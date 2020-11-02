//
//  WeatherDetails.swift
//  CleverWeather
//
//  Created by Jonas on 11/2/20.
//

import UIKit

class WeatherDetails: UIView {
    
    
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
    
    func initViews() {
        let nib = UINib(nibName: "WeatherDetails", bundle: nil)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = self.bounds;
        addSubview(contentView)
    }
  
}

