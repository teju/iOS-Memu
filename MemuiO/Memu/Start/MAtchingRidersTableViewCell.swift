//
//  MAtchingRidersTableViewCell.swift
//  Memu
//
//  Created by Tejaswini N on 21/06/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit

class MAtchingRidersTableViewCell: UITableViewCell {
    @IBOutlet weak var route_percent: UILabel!
    
    @IBOutlet weak var profile_pic: roundImageView!
    @IBOutlet weak var request: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var pay: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
