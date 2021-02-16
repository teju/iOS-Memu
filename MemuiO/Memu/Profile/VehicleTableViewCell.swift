//
//  VehicleTableViewCell.swift
//  Memu
//
//  Created by Tejaswini N on 11/02/21.
//  Copyright © 2021 APPLE. All rights reserved.
//

import UIKit

class VehicleTableViewCell: UITableViewCell {
 @IBOutlet weak var reg_no: UITextField!
  @IBOutlet weak var type: UITextField!
    @IBOutlet weak var yellowboard: UIButton!
    @IBOutlet weak var brand: UITextField!
    @IBOutlet weak var whiteboard: UIButton!
    @IBOutlet weak var model: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
