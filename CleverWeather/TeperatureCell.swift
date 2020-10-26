//
//  TeperatureCell.swift
//  CleverWeather
//
//  Created by Jonas on 10/26/20.
//

import UIKit

class TeperatureCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel : UILabel!;
    @IBOutlet weak var statusLabel : UILabel!;
    @IBOutlet weak var measureLabel : UILabel!;

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
