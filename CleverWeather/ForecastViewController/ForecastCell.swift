//
//  TeperatureCell.swift
//  CleverWeather
//
//  Created by REDACTED on 10/26/20.
//

import UIKit

class ForecastCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel : UILabel!;
    @IBOutlet weak var statusLabel : UILabel!;
    @IBOutlet weak var measureLabel : UILabel!;
    @IBOutlet weak var measureTextLabel : UILabel!;

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
