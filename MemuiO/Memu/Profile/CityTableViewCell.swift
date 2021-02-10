//
//  CityTableViewCell.swift
//  Memu
//
//  Created by Tejaswini N on 09/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit

class CityTableViewCell: UITableViewCell {

    @IBOutlet weak var coins: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: roundImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
